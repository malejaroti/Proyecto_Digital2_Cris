
// synopsys translate_off
//`include "..\..\testbench\verilog\timescale.v"
`include "timescale.v"
// synopsys translate_on


module i2c_master_wb_top(

	input		wb_clk_i,     // master clock input
	input		wb_rst_i,     // synchronous active high reset
	input	        arst_i,       // asynchronous reset
	input	[2:0] 	wb_adr_i,     // lower address bits
	input   [7:0] 	wb_dat_i,     // databus input
	output reg [7:0] wb_dat_o,     // databus output
	input        	wb_we_i,      // write enable input
	input        	wb_stb_i,     // stobe/core select signal
	input        	wb_cyc_i,     // valid bus cycle input
	output reg     	wb_ack_o,     // bus cycle acknowledge output
	output reg     	wb_inta_o,    // interrupt request signal output
	inout		scl,
	inout		sda
);
	////scl_pad_i, scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o );

	// parameters
	parameter ARST_LVL = 1'b0; // asynchronous reset level


    // registers declaration             
	wire  [15:0] prer; // clock prescale register 
	wire  [ 7:0] ctr;  // control register        	
	wire  [ 7:0] txr;  // transmit register       	
	wire  [ 7:0] rxr;  // receive register         	
	wire  [ 7:0] cr;   // command register        	
	wire   [ 7:0] sr;   // status register          	
	
	// done signal: command completed, clear command register
	wire done;

	// core enable signal
	wire core_en;
	wire ien;

	// status register signals
	wire irxack;
/*	reg  rxack;       // received aknowledge from slave
	reg  tip;         // transfer in progress 
	reg  irq_flag;    // interrupt pending flag */
	wire i2c_busy;    // bus busy (start signal detected)
	wire i2c_al;      // i2c bus arbitration lost
/*	reg  al;          // status register arbitration lost bit */

	// status signals between byte controller and bit controller
	wire [3:0] core_cmd; // output from byte controller to input of bit controller
	wire core_txd;       // output from byte controller to input of bit controller
	wire core_ack, core_rxd; // output from bit controller to input of byte controller

	// assign scl and sda to individual wires
        wire scl_pad_i = scl;
	wire scl_pad_o;       
	wire scl_padoen_o; 

        wire sda_pad_i = sda;     
	wire sda_pad_o;       
	wire sda_padoen_o; 

	//
	// module body
	//

	// generate internal reset
	wire rst_i = arst_i ^ ARST_LVL;

	// generate wishbone signals
	wire wb_wacc = wb_cyc_i & wb_stb_i & wb_we_i;
	
        // decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];


        // Wishbone outputs - wb_ack_o, wb_dat_o, and wb_inta_o//
	// generate acknowledge output signal
	always @(posedge wb_clk_i)
	  wb_ack_o <= #1 wb_cyc_i & wb_stb_i & ~wb_ack_o; // because timing is always honored

	// assign DAT_O
	always @(posedge wb_clk_i)
	begin
	  case (wb_adr_i) // synopsis parallel_case
	    3'b000: wb_dat_o <= #1 prer[ 7:0];
	    3'b001: wb_dat_o <= #1 prer[15:8];
	    3'b010: wb_dat_o <= #1 ctr;
	    3'b011: wb_dat_o <= #1 rxr; // write is transmit register (txr)
	    3'b100: wb_dat_o <= #1 sr;  // write is command register (cr)
	    3'b101: wb_dat_o <= #1 txr;
	    3'b110: wb_dat_o <= #1 cr;
	    3'b111: wb_dat_o <= #1 0;   // reserved
	  endcase
	end
	
        // generate interrupt request signals
	always @(posedge wb_clk_i or negedge rst_i)
	  if (!rst_i)
	    wb_inta_o <= #1 1'b0;
	  else if (wb_rst_i)
	    wb_inta_o <= #1 1'b0;
	  else
	    //wb_inta_o <= #1 irq_flag && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)
        wb_inta_o <= #1 sr[0] && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)

	

	// hookup byte controller block
	i2c_master_byte_ctrl byte_controller (
		.clk      ( wb_clk_i     ),
		.rst      ( wb_rst_i     ),
		.nReset   ( rst_i        ),
		//.ena      ( core_en      ),
		.clk_cnt  ( prer         ),
		.start    ( sta          ),
		.stop     ( sto          ),
		.read     ( rd           ),
		.write    ( wr           ),
		.ack_in   ( ack          ),
		.din      ( txr          ),
		.cmd_ack  ( done         ),
		.ack_out  ( irxack       ),
		.dout     ( rxr          ),
		//.i2c_busy ( i2c_busy     ),
		.i2c_al   ( i2c_al       ),
		//.scl_i    ( scl_pad_i    ),
		//.scl_o    ( scl_pad_o    ),
		//.scl_oen  ( scl_padoen_o ),
		//.sda_i    ( sda_pad_i    ),
		//.sda_o    ( sda_pad_o    ),
		//.sda_oen  ( sda_padoen_o ),
		.core_cmd ( core_cmd     ),
		.core_ack ( core_ack      ),
		.core_txd ( core_txd     ),
		.core_rxd ( core_rxd     )
	);
	
	i2c_master_bit_ctrl bit_controller (
		.clk     ( wb_clk_i ),
		.rst     ( wb_rst_i ),
		.nReset  ( rst_i    ),
		.ena     ( core_en  ),
		.clk_cnt ( prer     ),
		.cmd     ( core_cmd ),
		.cmd_ack ( core_ack ),
		.busy    ( i2c_busy ),
		.al      ( i2c_al   ),  // output to other modules
		.din     ( core_txd ),
		.dout    ( core_rxd ),
		.scl_i   ( scl_pad_i),
		.scl_o   ( scl_pad_o),
		.scl_oen ( scl_padoen_o ),
		.sda_i   ( sda_pad_i),
		.sda_o   ( sda_pad_o),
		.sda_oen ( sda_padoen_o  )
	);
	      
	i2c_master_registers registers(
		  .wb_clk_i(wb_clk_i), 
		  .rst_i(rst_i), 
		  .wb_rst_i(wb_rst_i),
		  .wb_dat_i(wb_dat_i),
                  .wb_wacc(wb_wacc), 
                  .wb_adr_i(wb_adr_i),
                  .i2c_al(i2c_al), 
                  .i2c_busy(i2c_busy),
                  .done(done),
                  //.sta(sta),
                  .irxack(irxack),
                  //.rd(rd), 
                  //.wr(wr),
                  //.iack(iack),
		  .prer(prer),                  
		  .ctr(ctr), 
                  .txr(txr), 
                  .cr(cr),  
                  .sr(sr)
                  );
                  
          // generate scl and sda pins
	  assign scl = (scl_padoen_o ? 1'bz : scl_pad_o);
	  assign sda = (sda_padoen_o ? 1'bz : sda_pad_o);
	  
	  

endmodule
