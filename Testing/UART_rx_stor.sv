module UART_rx_stor (clk, rst_n, shift, data_in, data_out);

input clk;
input rst_n;
input shift;

input data_in;

output [7:0]data_out;

logic [8:0] q;
logic [8:0] d;

assign data_out = q[7:0];

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		q <= 7'h00;
	else
		q <= d;
end

always_comb begin
	if (shift)
		d = {data_in, q[8:1]};
	else 
		d = q;
end

endmodule

	