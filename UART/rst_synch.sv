module rst_synch (RST_n, clk, rst_n);

input RST_n;
input clk;

output rst_n;

logic [1:0] val;

assign rst_n = val[0];

always_ff @ (negedge RST_n, negedge clk) begin
	if(!RST_n)
		val = 0;
	else if(!clk) begin
		val[1] <= 1;
		val[0] <= val[1];
	end
end
endmodule