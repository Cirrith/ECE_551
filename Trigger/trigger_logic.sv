/**************************************************************************************************
/	MODULE: trigger_logic
/	PURPOSE: Given all the channel and protocol triggers, generate a global trigger signal that signals
/		to start final set of sampling
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			armed - Unit is ready to take a trigger
/			capture_done - Unit has reached the number of samples to take
/			CH1Trig - Whether channel 1 has triggered or not
/			CH2Trig - Whether channel 2 has triggered or not
/			CH3Trig - Whether channel 3 has triggered or not
/			CH4Trig - Whether channel 4 has triggered or not
/			CH5Trig - Whether channel 5 has triggered or not
/			protTrig - Whether the protocol unit has triggered or not
/	
/	OUTPUTS:
/			triggered - To be triggered or not to be triggered that is the question
/	
/	INTERNAL:
/			trig_set - All the trigger units say yes
/	
**************************************************************************************************/
module trigger_logic(clk, rst_n, armed, capture_done, CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, triggered);  	
	
	input clk;
	input rst_n;
	input armed;
	input capture_done;
	input CH1Trig;
	input CH2Trig;
	input CH3Trig;
	input CH4Trig;
	input CH5Trig;
	input protTrig;

	output reg triggered;

	assign trig_set = (CH1Trig & CH2Trig & CH3Trig & CH4Trig & CH5Trig & protTrig);

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			triggered <= 1'b0;
		else if (capture_done)
			triggered <= 1'b0;
		else
			triggered <= triggered | (trig_set & armed);
	end

endmodule
