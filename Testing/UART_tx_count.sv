module UART_tx_count (clk, rst_n, clr_count, count_inc, count);

input clk;
input rst_n;
input clr_count;
input count_inc;

output [3:0] count;

logic [3:0] q;
logic [3:0] d;

assign count = q;

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		q <= 0;
	else
		q <= d;
end

always_comb begin
	if(clr_count)
		d = 0;
	else if(count_inc)
		d = q + 1;
	else
		d = q;
end

endmodule 