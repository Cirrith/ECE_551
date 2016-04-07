module Edg_Dect(clk, rst_n, PB, PB_rise);
input clk;
input rst_n;
input PB;
output PB_rise;

logic [2:0] val; //val[2] is oldest

always_ff@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		val <= 3'h7;
	else begin
		val[2] <= val[1];
		val[1] <= val[0];
		val[0] <= PB;
	end
end

assign PB_rise = (val[2] == 0) & (val[1] == 1);

endmodule