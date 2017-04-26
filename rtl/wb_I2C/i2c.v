`timescale 1ns / 1ps

module i2c(
    	input clk,
	input reset,
	input divisor,
	input rw,
	//input start,
	input startread,
	input startwrite,
	input [31:0] i2c_data,

	output i2c_sclk,
	output doneW,
	output busyW,
	output doneR,
	output busyR,
    	output ack,
	output [7:0] i2c_data_out,

   	inout  i2c_sdat 
    );
	 

wire mclk;

wire [7:0]i2c_data_out_wire;

wire i2c_sclk_write;
wire i2c_sclk_read;	

wire done_write;
wire ack_write;
wire busy_write;
wire done_read;
wire ack_read;
wire busy_read;

assign busyR = busy_read;
assign doneR = done_read;
assign busyW = busy_write;
assign doneW = done_write;
//assign done = (done_read||done_write);
assign ack = (ack_read||ack_write);

assign i2c_data_out = i2c_data_out_wire;

//assign i2c_sdat = (rw) ? i2c_sdat_read : i2c_sdat_write;
assign i2c_sclk = (rw) ? i2c_sclk_read : i2c_sclk_write;


i2c_controller_read_new i2c_read (
 	.clk_n(clk),    
	.clk(mclk),
	.reset(reset),
	.i2c_sclk(i2c_sclk_read),
     	.i2c_sdat(i2c_sdat),
     	//.i2c_sclk(i2c_sclk),
     	//.i2c_sdat(i2c_sdat),
	.start(startread),
     	.done(done_read),
	.busy(busy_read),
     	.ack(ack_read),

     	.i2c_data(i2c_data),
	.i2c_data_out(i2c_data_out_wire)
);


i2c_controller_write_new i2c_write (
     	.clk(mclk),
        .reset(reset),

     	.i2c_sclk(i2c_sclk_write),
     	.i2c_sdat(i2c_sdat),
	.start(startwrite),
     	.done(done_write),
	.busy(busy_write),
     	.ack(ack_write),

     	.i2c_data(i2c_data)
);



divisor_frecuencia divisorfrecuencia (
    	.clk(clk),
	.divisor(divisor), 
    	.mclk(mclk)
);





endmodule
