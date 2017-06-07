//---------------------------------------------------------------------------
// Wishbone camera
//
// Register Description:
//
//	0x00000 Cont. Ram     / Tomar_imagen
//	0x00004 Picture_Avail / -------
//	0x00008 Imagen        / Address Imagen
//
//		
//---------------------------------------------------------------------------

module wb_camera (
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
	input		camera_Vsync,
	input		camera_Href,
	input		camera_Pclk,
	input	  [11:0]	Imagen,

	output		camera_Xclk

);

//---------------------------------------------------------------------------
// Actual UART engine
//---------------------------------------------------------------------------

reg re;
reg [16:0] addr;

wire we;
reg  Tomar_imagen;
assign we = Tomar_imagen;

wire [11:0] pIm;
wire [11:0] ram_imagen;
assign pIm=ram_imagen;

wire Picture_Avail;
wire fin;
assign Picture_Avail=fin;

wire [16:0] cont_ram;

Camara C0(.clk		(clk),
	  .rst		(reset),
	  .we		(we),
	  .re		(re),
	  .addr_ram_i	(addr),
	  .Vsync	(camera_Vsync),
	  .Href		(camera_Href),
	  .Pclk		(camera_Pclk),
	  .ram_imagen_i	(Imagen),
	  .Xclk		(camera_Xclk),
	  .ram_imagen_o	(ram_imagen),
	  .fin		(fin),
	  .contador	(cont_ram));


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
		wb_dat_o[31:0]<=0;
	end else begin
		wb_dat_o[31:0] <= 0;
		ack    <= 0;
		if (wb_rd & ~ack) begin			//Escritura al procesador
			ack <= 1;

			case (wb_adr_i[3:0])
                        4'h00:  wb_dat_o[16:0]<=cont_ram[16:0]; 
			4'h04:  wb_dat_o[0] <= Picture_Avail;
			4'h08:  begin
				re=1;
				wb_dat_o[11:0] <= pIm;  //Enviar dato
				end
			default ;
			endcase
		end else if (wb_wr & ~ack ) begin	//Lectura del procesador
			ack <= 1;
			case (wb_adr_i[3:0])
                        4'h00:  Tomar_imagen <= wb_dat_i;
			4'h04:  ;
			4'h08:  addr=wb_dat_i[16:0];
			default ;
			endcase
		end
	end
end


endmodule
