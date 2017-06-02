//---------------------------------------------------------------------------
// Wishbone pantalla
//
// Register Description:
//
//
//		
//---------------------------------------------------------------------------

module wb_pantalla (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,		//El esclavo debe activar la señal ack_o como respuesta a la activacion de stb_i
	input              wb_cyc_i,		//Ciclo de bus valido se encuentra en progreso
	output             wb_ack_o,		//Terminacion normal de un ciclo del bus
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,		//Se esta poniendo un dato valido en el bus dat_i durante ciclo de escritura, ó se debe colocar dato en el bus dat_o durante un ciclo de lectura
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	// camera
	output		P_Vsync,
	output		P_Hsync,
	output 	[3:0]   P_red,
	output 	[3:0]	P_green,
	output 	[3:0]	P_blue);

reg [3:0] red_i;
reg [3:0] green_i;
reg [3:0] blue_i;
reg w_enable;


VGA vga0(.clk(clk),.rst(reset),.red_i(red_i),.green_i(green_i),.blue_i(green_i),.w_enable(w_enable),.Hsync(P_Hsync),.Vsync(P_Vsync),.vgaRed(P_red),.vgaGreen(P_green),.vgaBlue(P_blue));

//-----------------------------------------------------
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
		wb_dat_o[7:0]<=20;
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		ack    <= 0;
		if (wb_rd & ~ack) begin			//EScritura
			ack <= 1;

			case (wb_adr_i[3:0])
			default:;
			endcase
		end else if (wb_wr & ~ack ) begin	//Lectura
			ack <= 1;
			case (wb_adr_i[3:0])
                        4'h00:	red_i[3:0] <= wb_dat_i[3:0];
			4'h04:	green_i[3:0] <= wb_dat_i[3:0];
			4'h08:	blue_i[3:0] <= wb_dat_i[3:0];
			4'h0C:  w_enable <= wb_dat_i[0];
			default:;
			endcase
		end
	end
end


endmodule
