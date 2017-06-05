module RAM_pantalla (
	input		clk_i,
	input		rst,

	input		we_i,
	input		re_i,
	//
	input      [18:0] adr_i,
	input      [3:0] dat_i,
	output reg [3:0] dat_o,
	output reg fin);

parameter word_depth = 307200; //640 x480
parameter word_width = 8;

reg [3:0] ram [0:word_depth-1];
initial
begin
fin=0;
dat_o=0;
end

always @(posedge clk_i)
begin
	if(rst)
		fin<=0;
	if (we_i)
		begin
		ram[ adr_i ] <= dat_i;
		if(adr_i==(word_depth-1))  
			fin<=1;
		end 
end

always @(posedge clk_i)
	begin
	if(re_i)
		dat_o <= ram[ adr_i ];
	end

endmodule
