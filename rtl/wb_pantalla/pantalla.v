module VGA(
	input		clk,		
	input		rst,		//asynchronous reset
	input	[3:0]	red_i,
	input	[3:0]	green_i,
	input	[3:0]	blue_i,
	input		w_enable,
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
parameter hbp =		48; 	
parameter hfp = 	16; 	
parameter vbp = 	33;	
parameter vfp = 	10; 	

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

reg [2:0]cont_clk=0;
reg Xclk=0;

reg direccion;

wire active;

reg [3:0] red_dly=0;
reg [3:0] green_dly=0;
reg [3:0] blue_dly=0;

assign active= (hc<width && vc<height) ? 1:0;

assign clk_RAM= (w_enable) ? clk: Xclk;

assign Imagen= red_i||green_i||blue_i;


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
assign Vsync = (vc >= vfp+height-1 && vc < hfp+height+hpulse-1) ? 1:0;


always @(posedge Xclk)
begin
	// Check if we're within vertical active video range
	if (vc > height)
	begin

		if (hc <width)
		begin
			vgaRed = red_dly;
			vgaGreen = green_dly;
			vgaBlue = blue_dly;
		end
	// we're outside active horizontal range so display black
		else
		begin
			vgaRed = 0;
			vgaGreen = 0;
			vgaBlue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		vgaRed = 0;
		vgaGreen = 0;
		vgaBlue = 0;
	end
end

//--------------------------------------------------------------------------


//Generacion del Reloj

always@(posedge clk)
	begin
	if(rst)begin
		cont_clk=0;
		end
	else
		if(cont_clk==2'b01) //25Mhz
			begin
			Xclk=!Xclk;
			cont_clk=0;
			end
		else
			begin
			cont_clk= cont_clk+2'b01;
			end
	end



//------------------------------------------------------------------------------

always@(posedge clk_RAM)
	begin
	if(rst)
		begin
		direccion=0;
		end
	else 
		begin
		direccion=direccion+1;
		if(fin==1)
			direccion=0;
		end
	end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

always@(posedge clk_RAM)
	begin
	if(direccion%3==0)
		begin
		red_dly=ram_imagen;
		green_dly=0;
		blue_dly=0;
		end
	else if(direccion%3==1)
		begin
		red_dly=0;
		green_dly=ram_imagen;
		blue_dly=0;
		end
	else
		begin
		red_dly=0;
		green_dly=0;
		blue_dly=ram_imagen;
		end
	end
		

RAM_pantalla ram1(.clk_i(clk_RAM), .we_i(w_enable), .adr_i(direccion), .dat_i(Imagen), .dat_o(ram_imagen), .fin(fin));


endmodule
