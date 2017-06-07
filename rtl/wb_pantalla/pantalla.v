module VGA(
	input		clk,		
	input		rst,		//asynchronous reset
	input	[11:0]	pixel_i,
	input		w_enable,	//selecciona velocidad i/o clk_RAM
	input		r_enable,
	output		Hsync,		//horizontal sync out
	output		Vsync,		//vertical sync out
	output reg [3:0] vgaRed,	//red vga output
	output reg [3:0] vgaGreen,	//green vga output
	output reg [3:0] vgaBlue	//blue vga output
	);

// video structure constants
parameter hpixels =	800;
parameter vlines =	525;
parameter width =	640;
parameter height =	480;
parameter hpulse =	96; 	
parameter vpulse =	2; 	
parameter hbp =		44; 	
parameter hfp = 	20; 	
parameter vbp = 	10;	
parameter vfp = 	33; 	

// registros para guardar los contadores verticales y horizontales
reg [9:0] hc=0;
reg [9:0] vc=0;

reg [2:0] cont_clk;
reg Xclk=0;

wire[18:0]direccion;
reg [18:0]direccionw;
reg [18:0]direccionr;

wire active;
wire [11:0]ram_imagen;

reg clk_RAM;
reg clk_w;
reg clk_r;

assign direccion = (r_enable) ? direccionr:direccionw; 

assign active= (hc<width && vc<height) ? 1:0;

initial
begin
vgaRed<=0;
vgaGreen<=0;
vgaBlue<=0;
cont_clk<=0;
clk_RAM<=0;
clk_w<=0;
clk_r<=0;
direccionw<=0;
direccionr<=0;
end

//Generacion del Reloj

always@(posedge clk)
	begin
	if(rst)begin
		cont_clk<=0;
		end
	else
		if(cont_clk==2'b01) //25Mhz
			begin
			Xclk<=!Xclk;
			cont_clk<=0;
			end
		else
			begin
			cont_clk<= cont_clk+2'b01;
			end
	end



//------------------------------------------------------------------------------

always @(posedge Xclk or posedge rst)
begin
	// reset condition
	if (rst == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
		begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
			begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
			end
		
		end
	end

//Active Low
assign Hsync = (hc >= hfp+width-1 && hc < hfp+width+hpulse-1) ? 1:0;
assign Vsync = (vc >= vfp+height-1 && vc < vfp+height+vpulse-1) ? 1:0;


always @(posedge Xclk)
begin
	if(rst)
		begin
		vgaRed<=0;
		vgaGreen<=0;
		vgaBlue<=0;
		end
	// Check if we're within vertical active video range
	else if (vc > height)
	begin

		if (hc <width)
		begin
			vgaRed <= ram_imagen[3:0];
			vgaGreen <= ram_imagen[7:4];
			vgaBlue <= ram_imagen[11:8];
		end
	// we're outside active horizontal range so display black
		else
		begin
			vgaRed <= 0;
			vgaGreen <= 0;
			vgaBlue <= 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		vgaRed <= 0;
		vgaGreen <= 0;
		vgaBlue <= 0;
	end
end

//--------------------------------------------------------------------------

always@(negedge clk)
	begin
	if(rst)
		begin
		direccionw<=0;
		end
	else if(w_enable && !fin)
		begin
		direccionw<=direccionw+1;
		clk_w=1;
		if(fin==1)
			direccionw<=0;
		end
	clk_w=0;
	end

always@(posedge Xclk)
	begin
	if(rst)
		begin
		direccionr<=0;
		end
	else if(r_enable)
		begin
		direccionr<=direccionr+1;
		clk_r=1;
		if(direccionr==307199)
			direccionr<=0;
		end
	clk_r=0;
	end

always@(negedge clk)
begin
	if(w_enable)
		clk_RAM<=1;
	else if (r_enable)
		clk_RAM<=Xclk;
	else
		clk_RAM<=0;
end



RAM_pantalla ram1(.clk_i(clk_RAM),.rst(rst), .we_i(w_enable),.re_i(r_enable), .adr_i(direccion), .dat_i(pixel_i), .dat_o(ram_imagen), .fin(fin));


endmodule
