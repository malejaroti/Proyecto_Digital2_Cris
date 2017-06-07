//---------------------------------------------------------------------------
// Wishbone pantalla
//
// Register Description:
//
//	0x00000 -------- / pixel
//	0x00004 -------- / w_enable
//	0x00008 -------- / r_enable
//	0x0000C -------- / reset
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

reg [11:0] pixel_i;
reg w_enable;
reg r_enable;
reg reset1;


VGA vga0( .clk		(clk),
	  .rst		(reset1),
	  .pixel_i	(pixel_i),
	  .w_enable	(w_enable & wb_ack_o),
	  .r_enable	(r_enable),
	  .Hsync	(P_Hsync),
	  .Vsync	(P_Vsync),
	  .vgaRed	(P_red),
	  .vgaGreen	(P_green),
	  .vgaBlue	(P_blue));

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
		wb_dat_o[7:0]<=0;
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
			case (wb_adr_i[7:0])
                        4'h00:	pixel_i<= wb_dat_i[11:0];
			4'h04:  w_enable <= wb_dat_i[0];
			4'h08:  r_enable <= wb_dat_i[0];
			4'h0C:  reset1 <= wb_dat_i[0];
			default:;
			endcase
		end
	end
end


endmodule
