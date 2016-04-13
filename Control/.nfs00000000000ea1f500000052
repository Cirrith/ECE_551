module UART_tx_baud (clk, rst_n, clr_baud, baud_inc, baud);

input clk;
input rst_n;
input clr_baud;
input baud_inc;

output [7:0] baud;

logic [7:0] q;
logic [7:0] d;

assign baud = q;

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		q <= 0;
	else
		q <= d;
end

always_comb begin
	if(clr_baud)
		d = 0;
	else if(baud_inc)
		d = q + 1;
	else
		d = q;
end

endmodule 