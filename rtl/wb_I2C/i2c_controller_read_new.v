`timescale 1ns / 1ps
////////////////////////////////////////
module i2c_controller_read_new(
    input  clk_n,
    input  clk,
    input  reset,
    input  start,
    input [21:0] i2c_data,

    output i2c_sclk,
    output done,
    output ack,
    output busy,
    output [7:0] i2c_data_out,
	
    inout  i2c_sdat
);

reg [21:0] data;
reg [7:0] data_out;
//wire value;

assign i2c_data_out = data_out;

reg [6:0] stage;
reg [6:0] sclk_divider;
reg clock_en = 1'b0;
reg done = 1'b0;
reg busy = 1'b0;

// don't toggle the clock unless we're sending data
// clock will also be kept high when sending START and STOP symbols
assign i2c_sclk = (!clock_en) || sclk_divider[6];
wire midlow = (sclk_divider == 7'h1f);
//assign value = (i2c_sdat) ? 1'bz : 1'b0;

reg sdat = 1'b1;

assign i2c_sdat = (sdat) ? 1'bz : 1'b0; 

reg [6:0] acks;  //Depende de los Acks May6

parameter LAST_STAGE = 7'd40;

assign ack = (acks == 7'd0);
//assign done = (stage == LAST_STAGE);

reg [1:0] stageclk = 0;
reg startslow = 0;

always @(posedge clk_n) begin
	case (stageclk)
		0: begin
		if (start == 1) begin
			startslow = 1;
			stageclk = 1;
			end
		end
		1: begin
		if (clk == 0) begin
			stageclk = 2;
			end
		end
		2: begin
		if (clk == 1) begin
			stageclk = 3;
			end
		end
		3: begin
			startslow = 0;
			stageclk = 0;
		end
	endcase
end

always @(posedge clk) begin
   if(reset) begin
	  sclk_divider <= 7'd0;
	  stage <= LAST_STAGE;
	  clock_en <= 1'b0;
	  busy <= 1'b0;
	  sdat <= 1'b1;
	  acks <= 7'd1;
	  data <= 31'b0;
	  data_out <= 31'b0;
	 end

   if (startslow) begin
        sclk_divider <= 7'd0;
        stage <= 7'd0;
        clock_en <= 1'b0;
	done <= 1'b0;
	busy <= 1'b0;
        sdat <= 1'b1;
        acks <= 7'd1;
        data <= i2c_data;
    	end else begin
    if (sclk_divider == 7'd127) begin
        sclk_divider <= 7'd0;
     	if (stage != LAST_STAGE)
            stage <= stage + 1'b1;

            case (stage)
                // after start
                7'd0:  begin
			clock_en <= 1'b1;
			done <= 1'b0;
			busy <= 1'b1;
			end
                // receive acks				
                7'd9:  acks[0] <= i2c_sdat;
                7'd18: acks[1] <= i2c_sdat;
		7'd19: clock_en <= 1'b0;
		7'd20: clock_en <= 1'b1;
                7'd29: acks[2] <= i2c_sdat;
		//receive data 
	       	7'd30: data_out [7]<= i2c_sdat;
		7'd31: data_out [6]<= i2c_sdat;
		7'd32: data_out [5]<= i2c_sdat;
		7'd33: data_out [4]<= i2c_sdat;
		7'd34: data_out [3]<= i2c_sdat;
		7'd35: data_out [2]<= i2c_sdat;
		7'd36: data_out [1]<= i2c_sdat;
		7'd37: data_out [0]<= i2c_sdat;
		//receive acks
                7'd38: acks[3] <= i2c_sdat;
		// before stop
                7'd39: begin
			clock_en <= 1'b0;
			done <= 1'b1;
			busy <= 1'b0;
			end
            endcase
        end else
            sclk_divider <= sclk_divider + 1'b1;

        if (midlow) begin
            case (stage)
                // start
                7'd0:  sdat <= 1'b0;
                // byte 1
                7'd1:  sdat <= data[21];
                7'd2:  sdat <= data[20];
                7'd3:  sdat <= data[19];
                7'd4:  sdat <= data[18];
                7'd5:  sdat <= data[17];
                7'd6:  sdat <= data[16];
                7'd7:  sdat <= data[15];
		// write
                7'd8:  sdat <= 1'b0;
                // ack 1
                7'd9:  sdat <= 1'b1;
                // byte 2
                7'd10: sdat <= data[14];
                7'd11: sdat <= data[13];
                7'd12: sdat <= data[12];
                7'd13: sdat <= data[11];
                7'd14: sdat <= data[10];
                7'd15: sdat <= data[9];
                7'd16: sdat <= data[8];
                7'd17: sdat <= data[7];
                // ack 2
		7'd18: sdat <= 1'b1;
		// start
                7'd19: sdat <= 1'b1;
                7'd20: sdat <= 1'b0;
                // byte 3
                7'd21: sdat <= data[6];
                7'd22: sdat <= data[5];
                7'd23: sdat <= data[4];
                7'd24: sdat <= data[3];
                7'd25: sdat <= data[2];
                7'd26: sdat <= data[1];
                7'd27: sdat <= data[0];
		// read
                7'd28: sdat <= 1'b1;
                // ack 3
                7'd29: sdat <= 1'b1;
		// byte 4
                7'd30: sdat <= 1'b1;
                7'd31: sdat <= 1'b1;
                7'd32: sdat <= 1'b1;
                7'd33: sdat <= 1'b1;
                7'd34: sdat <= 1'b1;
                7'd35: sdat <= 1'b1;
                7'd36: sdat <= 1'b1;
                7'd37: sdat <= 1'b1;//1'bz;
                // byte 4
              /*  7'd30: begin sdat  <= 1'b0;
		       data_out [7]<= value;
		       end
                7'd31: begin sdat  <= 1'b1;
		       data_out [6]<= value;
		       end
                7'd32: begin sdat  <= 1'b0;
		       data_out [5]<= value;
		       end
                7'd33: begin sdat  <= 1'b1;
		       data_out [4]<= value;
		       end
                7'd34: begin sdat  <= 1'b1;
		       data_out [3]<= value;
		       end
                7'd35: begin sdat  <= 1'b1;
		       data_out [2]<= value;
		       end
                7'd36: begin sdat  <= 1'b0;
		       data_out [1]<= value;
		       end
                7'd37: begin sdat  <= 1'b1;
		       data_out [0]<= value;
		       end
		// nack 4*/
                7'd38: sdat <= 1'b1;
                // stop
                7'd39: sdat <= 1'b0;
                7'd40: sdat <= 1'b1;
            endcase
        end
    end
end

endmodule
