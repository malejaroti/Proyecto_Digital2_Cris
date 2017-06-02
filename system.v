//---------------------------------------------------------------------------
// LatticeMico32 System On A Chip
//
// Top Level Design for the Nexys4 ferney
//---------------------------------------------------------------------------

module system
#(
//	parameter   bootram_file     = "../firmware/cain_loader/image.ram",
//	parameter   bootram_file     = "../firmware/arch_examples/image.ram",
//	parameter   bootram_file     = "../firmware/boot0-serial/image.ram",
	parameter   bootram_file     = "../firmware/camera-rec/image.ram",
	parameter   clk_freq         = 100000000,
	parameter   uart_baud_rate   = 115200
) (
	input             clk,
	// Debug 
	output            led,
	input             rst,

	// UART
	input             uart_rxd, 
	output            uart_txd,
	// SPI
	input             spi_miso, 
	output            spi_mosi,
	output            spi_clk,
	// 12c
	inout             i2c_sda, 
	inout             i2c_scl,
	// camera
	input		  cam0_Vsync,
	input		  cam0_Href,
	input             cam0_Pclk,
	input	[7:0]     cam0_Imagen,

	output 		  cam0_Xclk,
	//pantalla
	output		pan0_Vsync,
	output		pan0_Hsync,
	output 	[3:0]   pan0_red,
	output 	[3:0]	pan0_green,
	output 	[3:0]	pan0_blue

);


wire sys_clk = clk;
wire sys_clk_n = ~clk;


	
//------------------------------------------------------------------
// Whishbone Wires
//------------------------------------------------------------------
wire         gnd   =  1'b0;
wire   [3:0] gnd4  =  4'h0;
wire  [31:0] gnd32 = 32'h00000000;

 
wire [31:0]  lm32i_adr,
             lm32d_adr,
             uart0_adr,
             spi0_adr,
             cam0_adr,
             i2c0_adr,
             timer0_adr,
             pan0_adr,
             ddr0_adr,
             bram0_adr,
             sram0_adr;


wire [31:0]  lm32i_dat_r,
             lm32i_dat_w,
             lm32d_dat_r,
             lm32d_dat_w,
             uart0_dat_r,
             uart0_dat_w,
             spi0_dat_r,
             spi0_dat_w,
	     cam0_dat_r,
	     cam0_dat_w,
             i2c0_dat_r,
             i2c0_dat_w,
             timer0_dat_r,
             timer0_dat_w,
             pan0_dat_r,
             pan0_dat_w,
             bram0_dat_r,
             bram0_dat_w,
             sram0_dat_w,
             sram0_dat_r,
             ddr0_dat_w,
             ddr0_dat_r;

wire [3:0]   lm32i_sel,
             lm32d_sel,
             uart0_sel,
             spi0_sel,
	     cam0_sel,
             i2c0_sel,
             timer0_sel,
             pan0_sel,
             bram0_sel,
             sram0_sel,
             ddr0_sel;

wire         lm32i_we,
             lm32d_we,
             uart0_we,
             spi0_we,
   	     cam0_we,
             i2c0_we,
             timer0_we,
             pan0_we,
             bram0_we,
             sram0_we,
             ddr0_we;


wire         lm32i_cyc,
             lm32d_cyc,
             uart0_cyc,
             spi0_cyc,
	     cam0_cyc,
             i2c0_cyc,
             timer0_cyc,
             pan0_cyc,
             bram0_cyc,
             sram0_cyc,
             ddr0_cyc;


wire         lm32i_stb,
             lm32d_stb,
             uart0_stb,
             spi0_stb,
	     cam0_stb,
             i2c0_stb,
             timer0_stb,
             pan0_stb,
             bram0_stb,
             sram0_stb,
             ddr0_stb;

wire         lm32i_ack,
             lm32d_ack,
             uart0_ack,
             spi0_ack,
	     cam0_ack,
             i2c0_ack,
             timer0_ack,
             pan0_ack,
             bram0_ack,
             sram0_ack,
             ddr0_ack;


wire         lm32i_rty,
             lm32d_rty;

wire         lm32i_err,
             lm32d_err;

wire         lm32i_lock,
             lm32d_lock;

wire [2:0]   lm32i_cti,
             lm32d_cti;

wire [1:0]   lm32i_bte,
             lm32d_bte;

//---------------------------------------------------------------------------
// Interrupts
//---------------------------------------------------------------------------
wire [31:0]  intr_n;
wire         uart0_intr = 0;
wire   [1:0] timer0_intr;
wire         gpio0_intr;

assign intr_n = { 28'hFFFFFFF, ~timer0_intr[1], ~gpio0_intr, ~timer0_intr[0], ~uart0_intr };

//---------------------------------------------------------------------------
// Wishbone Interconnect
//---------------------------------------------------------------------------
conbus #(
	.s_addr_w(3),
	.s0_addr(3'b000),	// bram     0x00000000 
	.s1_addr(3'b010),	// uart0    0x20000000 
	.s2_addr(3'b011),	// timer    0x30000000 
	.s3_addr(3'b100),       // pantalla     0x40000000 
	.s4_addr(3'b101),	// camara      0x50000000 
	.s5_addr(3'b110)	// i2c      0x60000000 
) conbus0(
	.sys_clk( clk ),
	.sys_rst( ~rst ),
	// Master0
	.m0_dat_i(  lm32i_dat_w  ),
	.m0_dat_o(  lm32i_dat_r  ),
	.m0_adr_i(  lm32i_adr    ),
	.m0_we_i (  lm32i_we     ),
	.m0_sel_i(  lm32i_sel    ),
	.m0_cyc_i(  lm32i_cyc    ),
	.m0_stb_i(  lm32i_stb    ),
	.m0_ack_o(  lm32i_ack    ),
	// Master1
	.m1_dat_i(  lm32d_dat_w  ),
	.m1_dat_o(  lm32d_dat_r  ),
	.m1_adr_i(  lm32d_adr    ),
	.m1_we_i (  lm32d_we     ),
	.m1_sel_i(  lm32d_sel    ),
	.m1_cyc_i(  lm32d_cyc    ),
	.m1_stb_i(  lm32d_stb    ),
	.m1_ack_o(  lm32d_ack    ),


	// Slave0  bram
	.s0_dat_i(  bram0_dat_r ),
	.s0_dat_o(  bram0_dat_w ),
	.s0_adr_o(  bram0_adr   ),
	.s0_sel_o(  bram0_sel   ),
	.s0_we_o(   bram0_we    ),
	.s0_cyc_o(  bram0_cyc   ),
	.s0_stb_o(  bram0_stb   ),
	.s0_ack_i(  bram0_ack   ),
	// Slave1
	.s1_dat_i(  uart0_dat_r ),
	.s1_dat_o(  uart0_dat_w ),
	.s1_adr_o(  uart0_adr   ),
	.s1_sel_o(  uart0_sel   ),
	.s1_we_o(   uart0_we    ),
	.s1_cyc_o(  uart0_cyc   ),
	.s1_stb_o(  uart0_stb   ),
	.s1_ack_i(  uart0_ack   ),
	// Slave2
	.s2_dat_i(  timer0_dat_r ),
	.s2_dat_o(  timer0_dat_w ),
	.s2_adr_o(  timer0_adr   ),
	.s2_sel_o(  timer0_sel   ),
	.s2_we_o(   timer0_we    ),
	.s2_cyc_o(  timer0_cyc   ),
	.s2_stb_o(  timer0_stb   ),
	.s2_ack_i(  timer0_ack   ),
	// Slave3
	.s3_dat_i(  pan0_dat_r ),
	.s3_dat_o(  pan0_dat_w ),
	.s3_adr_o(  pan0_adr   ),
	.s3_sel_o(  pan0_sel   ),
	.s3_we_o(   pan0_we    ),
	.s3_cyc_o(  pan0_cyc   ),
	.s3_stb_o(  pan0_stb   ),
	.s3_ack_i(  pan0_ack   ),
	// Slave4
	.s4_dat_i(  cam0_dat_r ),
	.s4_dat_o(  cam0_dat_w ),
	.s4_adr_o(  cam0_adr   ),
	.s4_sel_o(  cam0_sel   ),
	.s4_we_o(   cam0_we    ),
	.s4_cyc_o(  cam0_cyc   ),
	.s4_stb_o(  cam0_stb   ),
	.s4_ack_i(  cam0_ack   ),
	// Slave5
	.s5_dat_i(  i2c0_dat_r ),
	.s5_dat_o(  i2c0_dat_w ),
	.s5_adr_o(  i2c0_adr   ),
	.s5_sel_o(  i2c0_sel   ),
	.s5_we_o(   i2c0_we    ),
	.s5_cyc_o(  i2c0_cyc   ),
	.s5_stb_o(  i2c0_stb   ),
	.s5_ack_i(  i2c0_ack   )
	
);


//---------------------------------------------------------------------------
// LM32 CPU 
//---------------------------------------------------------------------------
lm32_cpu lm0 (
	.clk_i(  clk  ),
	.rst_i(  ~rst  ),
	.interrupt_n(  intr_n  ),
	//
	.I_ADR_O(  lm32i_adr    ),
	.I_DAT_I(  lm32i_dat_r  ),
	.I_DAT_O(  lm32i_dat_w  ),
	.I_SEL_O(  lm32i_sel    ),
	.I_CYC_O(  lm32i_cyc    ),
	.I_STB_O(  lm32i_stb    ),
	.I_ACK_I(  lm32i_ack    ),
	.I_WE_O (  lm32i_we     ),
	.I_CTI_O(  lm32i_cti    ),
	.I_LOCK_O( lm32i_lock   ),
	.I_BTE_O(  lm32i_bte    ),
	.I_ERR_I(  lm32i_err    ),
	.I_RTY_I(  lm32i_rty    ),
	//
	.D_ADR_O(  lm32d_adr    ),
	.D_DAT_I(  lm32d_dat_r  ),
	.D_DAT_O(  lm32d_dat_w  ),
	.D_SEL_O(  lm32d_sel    ),
	.D_CYC_O(  lm32d_cyc    ),
	.D_STB_O(  lm32d_stb    ),
	.D_ACK_I(  lm32d_ack    ),
	.D_WE_O (  lm32d_we     ),
	.D_CTI_O(  lm32d_cti    ),
	.D_LOCK_O( lm32d_lock   ),
	.D_BTE_O(  lm32d_bte    ),
	.D_ERR_I(  lm32d_err    ),
	.D_RTY_I(  lm32d_rty    )
);
	
//---------------------------------------------------------------------------
// Block RAM
//---------------------------------------------------------------------------
wb_bram #(
	.adr_width( 12 ),
	.mem_file_name( bootram_file )
) bram0 (
	.clk_i(  clk  ),
	.rst_i(  ~rst  ),
	//
	.wb_adr_i(  bram0_adr    ),
	.wb_dat_o(  bram0_dat_r  ),
	.wb_dat_i(  bram0_dat_w  ),
	.wb_sel_i(  bram0_sel    ),
	.wb_stb_i(  bram0_stb    ),
	.wb_cyc_i(  bram0_cyc    ),
	.wb_ack_o(  bram0_ack    ),
	.wb_we_i(   bram0_we     )
);



//---------------------------------------------------------------------------
// uart0
//---------------------------------------------------------------------------
wire uart0_rxd;
wire uart0_txd;

wb_uart #(
	.clk_freq( clk_freq        ),
	.baud(     uart_baud_rate  )
) uart0 (
	.clk( clk ),
	.reset( ~rst ),
	//
	.wb_adr_i( uart0_adr ),
	.wb_dat_i( uart0_dat_w ),
	.wb_dat_o( uart0_dat_r ),
	.wb_stb_i( uart0_stb ),
	.wb_cyc_i( uart0_cyc ),
	.wb_we_i(  uart0_we ),
	.wb_sel_i( uart0_sel ),
	.wb_ack_o( uart0_ack ), 
//	.intr(       uart0_intr ),
	.uart_rxd( uart0_rxd ),
	.uart_txd( uart0_txd )
);

//---------------------------------------------------------------------------
// spi0
//---------------------------------------------------------------------------
wire spi0_mosi;
wire spi0_miso;
wire spi0_clk;

wb_spi  spi0 (
	.clk( clk ),
	.reset( ~rst ),
	//
	.wb_adr_i( spi0_adr ),
	.wb_dat_i( spi0_dat_w ),
	.wb_dat_o( spi0_dat_r ),
	.wb_stb_i( spi0_stb ),
	.wb_cyc_i( spi0_cyc ),
	.wb_we_i(  spi0_we ),
	.wb_sel_i( spi0_sel ),
	.wb_ack_o( spi0_ack ), 
	.spi_sck(spi0_clk),
	.spi_mosi( spi0_mosi ),
	.spi_miso( spi0_miso )
);

//*************************************************************************
// camera cam0
//************************************************************************

// TODO : interruption and asynchronous reset

wb_camera  cam0 (
        .clk		( clk ),
        .reset		( ~rst ),
        //
	.wb_stb_i	( cam0_stb ),
        .wb_cyc_i	( cam0_cyc ),
	.wb_ack_o	( cam0_ack ),
	.wb_we_i	( cam0_we ),
        .wb_adr_i	( cam0_adr ),
	.wb_sel_i	( cam0_sel ),
        .wb_dat_i	( cam0_dat_w ),
        .wb_dat_o	( cam0_dat_r ),
	//
	.camera_Vsync	( cam0_Vsync ),
        .camera_Href	( cam0_Href ),
	.camera_Pclk	( cam0_Pclk ),
	.Imagen		( cam0_Imagen ),
	.camera_Xclk	( cam0_Xclk )
);




//---------------------------------------------------------------------------
// i2c0
//---------------------------------------------------------------------------
 wire i2c0_sda;
 wire i2c0_scl;

// TODO : interruption and asynchronous reset
 i2c_master_wb_top  i2c0 (
 	.wb_clk_i( clk ),
	.wb_rst_i( ~rst ),
	//
	.wb_adr_i( i2c0_adr ),
	.wb_dat_i( i2c0_dat_w ),
	.wb_dat_o( i2c0_dat_r ),
	.wb_stb_i( i2c0_stb ),
	.wb_cyc_i( i2c0_cyc ),
	.wb_we_i(  i2c0_we ),
	.wb_ack_o( i2c0_ack ), 
	.scl(i2c0_scl),
	.sda( i2c0_sda )
);

//---------------------------------------------------------------------------
// timer0
//---------------------------------------------------------------------------
wb_timer #(
	.clk_freq(   clk_freq  )
) timer0 (
	.clk(      clk          ),
	.reset(    ~rst          ),
	//
	.wb_adr_i( timer0_adr   ),
	.wb_dat_i( timer0_dat_w ),
	.wb_dat_o( timer0_dat_r ),
	.wb_stb_i( timer0_stb   ),
	.wb_cyc_i( timer0_cyc   ),
	.wb_we_i(  timer0_we    ),
	.wb_sel_i( timer0_sel   ),
	.wb_ack_o( timer0_ack   ), 
	.intr(     timer0_intr  )
);

//---------------------------------------------------------------------------
// Pantalla
//---------------------------------------------------------------------------

wb_pantalla  pan0 (
        .clk		( clk ),
        .reset		( ~rst ),
        //
	.wb_stb_i	( pan0_stb ),
        .wb_cyc_i	( pan0_cyc ),
	.wb_ack_o	( pan0_ack ),
	.wb_we_i	( pan0_we ),
        .wb_adr_i	( pan0_adr ),
	.wb_sel_i	( pan0_sel ),
        .wb_dat_i	( pan0_dat_w ),
        .wb_dat_o	( pan0_dat_r ),
	//
	.P_Vsync	( pan0_Vsync ),
        .P_Hsync	( pan0_Hsync ),
	.P_red		( pan0_red ),
	.P_blue		( pan0_blue ),
	.P_green	( pan0_green )
);



//---------------------------------------------------------------------------
// General Purpose IO
//---------------------------------------------------------------------------
/*
wire [7:0] gpio0_io;
wire        gpio0_irq;

wb_gpio gpio0 (
	.clk(      clk          ),
	.rst(    ~rst          ),
	//
	.wb_adr_i( gpio0_adr    ),
	.wb_dat_i( gpio0_dat_w  ),
	.wb_dat_o( gpio0_dat_r  ),
	.wb_stb_i( gpio0_stb    ),
	.wb_cyc_i( gpio0_cyc    ),
	.wb_we_i(  gpio0_we     ),
	.wb_ack_o( gpio0_ack    ), 
	// GPIO
	.gpio_io(gpio0_io)
);
*/


//----------------------------------------------------------------------------
// Mux UART wires according to sw[0]
//----------------------------------------------------------------------------
assign uart_txd  = uart0_txd;
assign uart0_rxd = uart_rxd;
assign led       = ~uart_txd;

assign spi_mosi  = spi0_mosi;
assign spi0_miso = spi_miso;
assign spi_clk = spi0_clk;

assign i2c_sda = i2c0_sda;
assign i2c_scl = i2c0_scl;
endmodule 
