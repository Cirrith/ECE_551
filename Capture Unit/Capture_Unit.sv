/**************************************************************************************************
/	MODULE: Capture_Unit
/	PURPOSE: Take in the inputs and write the sample to all ramQueues every cycle, until triggered
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			wrt_smpl - To write a sample or not
/	
/	OUTPUTS:
/			waddr - Write address
/			
/	INTERNAL:
/
**************************************************************************************************/
module Capture_Unit(clk, rst_n, wrt_smpl, waddr);
	
	parameter ENTRIES = 384;
	
	input clk;
	input rst_n;
	input wrt_smpl;
	
	output logic [15:0] waddr;
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			waddr <= 0;
		else if (wrt_smpl & (waddr == (ENTRIES - 1))) begin
			waddr <= 0;
		else if (wrt_smpl)
			waddr <= waddr + 1;
		else
			waddr <= waddr;
	end
	
endmodule