module counter (clk, rst_n, count);

input clk;
input rst_n;

output logic [7:0] count;

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		count <= 0;
	else
		count <= count + 1;	
end

endmodule