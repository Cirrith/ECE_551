module trigger_logic(CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, armed, set_capture_done, clk, 
rst_n, triggered);  

	input CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig;
	input armed, set_capture_done;
	input rst_n, clk;

	output reg triggered;

	assign trig_set = (CH1Trig & CH2Trig & CH3Trig & CH4Trig & CH5Trig & protTrig);

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			triggered <= 1'b0;
		else if (set_capture_done)
			triggered <= 1'b0;
		else
			triggered <= triggered | (trig_set & armed);
	end

endmodule
