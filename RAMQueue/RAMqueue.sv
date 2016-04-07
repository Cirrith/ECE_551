module RAMqueue (clk, we, waddr, wdata, raddr, rdata);

parameter LOG2 = 9;
parameter ENTRIES = 384;
parameter DATA_WIDTH = 8;

input [LOG2-1:0] waddr;
input [LOG2-1:0] raddr;
input [DATA_WIDTH-1:0] wdata;

input clk;
input we;

output reg [DATA_WIDTH-1:0] rdata;

reg [DATA_WIDTH-1:0] mem [0:ENTRIES-1];

always@(posedge clk) begin
	if(we)
		mem[waddr] <= wdata;
	
	rdata <= mem[raddr];
end

endmodule 
