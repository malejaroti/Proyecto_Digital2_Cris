module Camara(clk,rst,we,re/*,addr*/,Vsync,Href,Pclk,Xclk,Imagen/*,ram_imagen*/);

input clk;
input rst;
input we;
input re;
//input [18:0]addr;
input Vsync;
input Href;
input Pclk;
input [7:0]Imagen;

output reg Xclk=0;
//output wire [7:0]ram_imagen;

reg [1:0] cont_clk=	0;
reg [18:0]cont_ram=	0;
reg [18:0]direccion=	0; 
reg START=	0;

reg [18:0]addr=0;    //Temporal
wire [7:0]ram_imagen; //Temporal

wire w_enable;
assign w_enable = we & Href;


/*
Format			Pixel Data Output		COM7[2] COM7[0] COM15[5] COM15[4]
Raw Bayer RGB	8-bit R or 8-bit G or 8-bit B 				0 1 x 0
Prd_Bay_RGB	8-bit R or 8-bit G or 8-bit B 				1 1 x 0
YUV/YCbCr 	4:2:2 8-bit Y, 8-bit U or 8-bit Y, 8-bit V	 	0 0 x 0
GRB 4:2:2	8-bit G, 8-bit R or 8-bit G, 8-bit B 			1 0 x 0
RGB565		5-bit R, 6-bit G, 5-bit B 				1 0 0 1
RGB555		5-bit R, 5-bit G, 5-bit B 				1 0 1 1


*/


//--- f_Xclk= 25 Mhz -----------\\

always@(posedge clk)
	begin
	if(rst==1)
	cont_clk=0;
	else
		if(cont_clk==2'b11) //25Mhz
		begin
		Xclk=!Xclk;
		cont_clk=0;
		end
		else
		cont_clk= cont_clk+2'b01;
	end

//-------------------------------\\


always@(posedge Pclk)
	begin
	if(rst==1)
	cont_ram=0;
	else
		if(START==1 && Href==1)
		cont_ram=cont_ram+1'b1;	

	end


//-------------------------------\\


always@(Vsync)
	begin
	if(rst)
		START=0;
	else if(Vsync==0 && we==1)
		START=1;
	else if(Vsync==1 && !we==1)
		START=0;	
	end
/*
always@(posedge Vsync)
	begin
	if(rst)
		START=0;
	else if(!we)
		START=0;	
	end
*/

//-------------------------------\\

always@(posedge clk)
	begin
	if(w_enable)
		direccion =cont_ram;
	else if(re)
		direccion=addr;	
		
	end




RAM_imagen ram(.clk_i(Pclk), .we_i(w_enable), .re_i(re), .adr_i(direccion), .dat_i(Imagen), .dat_o(ram_imagen));

endmodule


