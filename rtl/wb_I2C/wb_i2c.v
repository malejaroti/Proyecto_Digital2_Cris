//---------------------------------------------------------------------------
// Wishbone I2C 
//
//
//---------------------------------------------------------------------------

module wb_i2c (
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
	// i2c wires
	output scl,
	inout  sda,
	//output doneW,
	//output doneR,
	//output busyW,
	//output busyR,
	output [7:0]i2c_data_out
	//output [7:0]led_i2c
	//output ack_p
);

//---------------------------------------------------------------------------
// Actual i2c engine
//---------------------------------------------------------------------------


//reg start;
reg startread;
reg startwrite;
reg rw;
reg [31:0] i2c_data;

wire scl_wire;
wire sda_wire;
wire doneW_wire;
wire doneR_wire;
wire busyW_wire;
wire busyR_wire;
wire [7:0] i2c_data_out;

assign doneW = doneW_wire;
assign busyR = busyR_wire; 
assign doneR = doneR_wire;
assign busyW = busyW_wire;

i2c i2c0 (
	.clk(clk),
	.reset(reset),
	.divisor(250),
	.i2c_sclk(scl_wire),
	.i2c_sdat(sda_wire),
	.rw(rw),
	.startread(startread),
	.startwrite(startwrite),
	.doneW(doneW_wire),
	.doneR(doneR_wire),
	.busyW(busyW_wire),
	.busyR(busyR_wire),
	.ack(ack_p),
	.i2c_data(i2c_data),
	.i2c_data_out(i2c_data_out)
    );


assign scl = scl_wire;
assign sda = sda_wire;
//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;
always @(posedge clk)
begin
	if (reset) begin
		//wb_dat_o[31:8] <= 24'b0;
		startread <= 0;
                startwrite <= 0;
                ack    <= 0;
	end else begin
                ack    <= 0;
		if (wb_rd & ~ack) begin
			ack <= 1;
			case (wb_adr_i[4:2])
			3'b000: wb_dat_o[7:0] <= i2c_data_out;
			3'b001: wb_dat_o      <= {busyW_wire,doneW_wire};
			3'b010: wb_dat_o      <= {busyW_wire,doneW_wire,busyR_wire,doneR_wire};	
			default: wb_dat_o[7:0] <= 8'b0;
			endcase
		end else 
		if (wb_wr & ~ack ) begin
			ack <= 1;
			 case (wb_adr_i[4:2])
			   3'b011: rw <= wb_dat_i;
			   3'b100: i2c_data <= wb_dat_i;
			   3'b101: startread <= wb_dat_i;
			   3'b110: startwrite <= wb_dat_i;
			 endcase
		end
	end
end


endmodule
