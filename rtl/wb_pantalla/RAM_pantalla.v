module RAM_pantalla (
	input		clk_i, 
	input		we_i,
	input		re_i,
	//
	input      [18:0] adr_i,
	input      [7:0] dat_i,
	output reg [3:0] dat_o,
	output fin);

parameter word_depth = 307200; //640 x480
parameter word_width = 8;

reg [3:0] ram [0:word_depth-1];

reg fin2=0;

assign fin=fin2;
always @(posedge clk_i)
begin
	if (we_i)
		begin
		ram[adr_i] <= dat_i[7:4];
		if(adr_i==307199)  
			fin2=1;
		end 
end

always @(posedge re_i)
	dat_o <= ram[ adr_i ];

endmodule
