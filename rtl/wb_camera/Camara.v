/*
Format			Pixel Data Output		COM7[2] COM7[0] COM15[5] COM15[4]
Raw Bayer RGB	8-bit R or 8-bit G or 8-bit B 				0 1 x 0
Prd_Bay_RGB	8-bit R or 8-bit G or 8-bit B 				1 1 x 0
YUV/YCbCr 	4:2:2 8-bit Y, 8-bit U or 8-bit Y, 8-bit V	 	0 0 x 0
GRB 4:2:2	8-bit G, 8-bit R or 8-bit G, 8-bit B 			1 0 x 0
RGB565		5-bit R, 6-bit G, 5-bit B 				1 0 0 1
RGB555		5-bit R, 5-bit G, 5-bit B 				1 0 1 1


*/

module Camara (
		input		clk,
		input		rst,
		
		//Entradas Software
		input		we,
		input		re,
		input [18:0]	addr_ram_i,

		//Entradas Hardware
		input		Vsync,
		input		Href,
		input		Pclk,
		input [7:0]	ram_imagen_i,

		//Salida Hardware
		output reg	Xclk,

		//Salida Software
		output  [7:0] ram_imagen_o,
		output 	fin,

		//output led1,
		//output [7:0] pixel,
		//output [10:0] address,
		//output VS,
		//output href,
		//output pclk,
		//output xclk
		output [18:0] contador

	);



//-------------------------------------------------------

//Salidas software
//wire [7:0]ram_imagen_o;
//wire fin;

//Entradas Software
//reg we=1;
//reg re=0;
//reg [18:0] addr_ram_i=0;

//-----------------------------------------------------------

reg [1:0] cont_clk = 0;
reg 	  cont_aux = 0;
reg [18:0]cont_ram = 0;
reg [18:0]direccion= 0; 
reg 	  START = 0;

wire w_enable;
assign w_enable = we & Href & START & !fin; //Comenzo un nuevo ciclo y Href activo y no a terminado

//-----------------------------------------------------------
//assign pixel=ram_imagen_i;
initial
begin
Xclk<=0;
end
reg var=0;

//assign address=cont_ram[18:8];
//assign VS=Vsync;
//assign xclk=Xclk;
//assign pclk=Pclk;
//assign href=Href;
//assign pixel=ram_imagen_i;
//assign led1=START;
assign contador=cont_ram;

//-----------------------------------------------------------

//--- f_Xclk= 25 Mhz -----------\\

always@(posedge clk)
	begin
	if(rst)
	begin
	cont_clk<=0;
	Xclk<=0;
	end
	else
		if(cont_clk==2'b01) //25Mhz
		begin
		Xclk<=!Xclk;
		cont_clk<=0;
		end
		else
		cont_clk<= cont_clk+2'b01;
	end

//-------------------------------\\

always@(negedge Vsync)
	begin
	if(rst)
		begin
		START<=0;
		end
	else if(we && var)
		begin
		START<=1;
		end
	end

always@(posedge Vsync)
	begin
	if(rst)
		begin
		var<=0;
		end
	else
		begin
		var<=1;
		end
	end


//-------------------------------\\

always@(posedge Pclk)			//tp=2 x Pclk
	begin
	if(rst)
		cont_ram<=0;
	else if(w_enable)
		begin
		if(cont_aux==1)
			begin
			cont_ram<=cont_ram+1'b1;	
			cont_aux<=0;
			end
		else
			cont_aux<=cont_aux+1;
		end
	end

//-------------------------------\\

always@(posedge clk)
	begin
	if(w_enable)
		direccion <= cont_ram;
	else if(re)
		direccion<=addr_ram_i; 
		
	end



RAM_imagen ram(.clk_i(Pclk),.rst(rst), .we_i(w_enable),.re_i(re), .adr_i(direccion), .dat_i(ram_imagen_i), .dat_o(ram_imagen_o), .fin(fin));

endmodule

