module UART_tx_stor (clk, rst_n, load, shift, data_in, data_out);

input clk;
input rst_n;
input load;
input shift;

input [7:0] data_in;

output data_out;

logic [9:0] q;
logic [9:0] d;

assign data_out = q[0];

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		q <= 7'hFF;
	else
		q <= d;
end

always_comb begin
	if(load)
		d = {1'b1, data_in, 1'b0};
	else if (shift)
		d = {1'b1, q[9:1]};
	else 
		d = q;
end

endmodule

	