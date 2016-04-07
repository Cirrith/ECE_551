module Counter(clk, rst_n, EN, count);

	input clk;
	input rst_n;
	input EN;

	output [15:0] count;

	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			count <= 16'h0000;
		else if (EN)
			count <= count + 1;
		else
			count <= count;
	end

endmodule