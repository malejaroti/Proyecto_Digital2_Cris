//---------------------------------------------------------------------------
// Wishbone camera
//
// Register Description:
//
//	0x00000 Tomar_imagen
//	0x00004 Picture_Avail
//	0x00008-0x4B008 Imagen
//
//		
//---------------------------------------------------------------------------

module wb_camera (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	// camera
	input		camera_Vsync,
	input		camera_Href,
	input		camera_Pclk,
	input	  [7:0]	Imagen,

	output wire	camera_Xclk

);

//---------------------------------------------------------------------------
// Actual UART engine
//---------------------------------------------------------------------------
wire       Picture_Avail;
reg        Tomar_imagen;

wire we;
reg re;
reg [18:0] addr;
wire [7:0] ram_imagen;
wire fin;

assign we = Tomar_Imagen;
assign Picture_Avail=fin;

Camara C0(.clk(clk),.rst(reset),.we(we),.re(re),.addr(addr),.Vsync(camera_Vsync),.Href(camera_Href),.Pclk(camera_Pclk),.Imagen(Imagen),.Xclk(camera_Xclk),.ram_imagen(ram_imagen),.fin(fin));


//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack;

assign wb_ack_o       = wb_stb_i & wb_cyc_i & ack;


always @(posedge clk)
begin
	if (reset) begin
		ack    <= 0;
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		ack    <= 0;

		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i)
                        32'h00: 
			32'h01: wb_dat_o[7:0] <= Picture_Avail;
			32'h02: begin
				re=1;
				wb_dat_o[7:0] <= ram_imagen;
				end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;
			case (wb_adr_i)
                        32'h00: Tomar_Imagen <= 1;
			32'h02: addr=wb_dat_i;
		end
	end
end


endmodule
