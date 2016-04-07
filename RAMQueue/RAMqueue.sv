/**************************************************************************************************
/	MODULE: RAMqueue
/	PURPOSE: Contains a circular queue that stores the data from the channel reads
/	
/	PARAMETERS:
/			ENTRIES - Number of entries in the
/			DATA_WIDTH - Width of data being stored
/			LOG2 - Log base 2 of the # of addreses, i.e. the # address bits
/	
/	INPUTS:
/			clk - Clock
/			we - Write Enable, whether it should store the data on its wdata [LOG2-1:0] port
/			waddr [LOG2-1:0] - Write Address, what address should be written to
/			wdata [DATA_WIDTH-1:0]
/			raddr [LOG2-1:0] - Read Address, what address should be read from
/			
/	OUTPUTS:
/			rdata [DATA_WIDTH-1:0] - Data that is read from address specified by raddr [LOG2-1:0]
**************************************************************************************************/
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
