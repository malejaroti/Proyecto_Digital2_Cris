//---------------------------------------------------------------------------
// Wishbone camera
//
// Register Description:
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
	output		camera_Xclk,
	input		camera_Pclk,
	input		camera_Vsync,
	input		camera_Href,
	input	  [7:0]	Imagen
);

//---------------------------------------------------------------------------
// Actual UART engine
//---------------------------------------------------------------------------
wire       ok_foto;
reg        new_foto;

Camara C0(.clk(clk),.rst(reset),.Vsync(camera_Vsync),.Href(camera_Href),.Pclk(camera_Pclk),.Xclk(camera_Xclk),.Imagen(Imagen));


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
			32'b01: begin
				wb_dat_o[7:0] <= ok_foto;
			end
			default: begin
				wb_dat_o[7:0] <= ram[wb_adr_i-2];
			end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;
			if ((wb_adr_i == 32'b00) & new_foto ==0) begin
				new_foto <= 1;
			end
		end
	end
end


endmodule
