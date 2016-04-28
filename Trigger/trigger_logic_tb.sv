	module trigger_logic_tb();

	reg CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig;
	reg armed, set_capture_done;
	reg rst_n, clk;
	reg triggered;
	reg correct;

	trigger_logic iDUT(clk, rst_n, armed, capture_done, CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, triggered);

	initial begin
		clk = 0;
		rst_n = 0;
		
		CH1Trig = 1;
		CH2Trig = 1;
		CH3Trig = 1;
		CH4Trig = 1;
		CH5Trig = 1;
		protTrig = 0;
		armed = 0;
		set_capture_done = 0;
		
		repeat(2) @(negedge clk);
		
		rst_n = 1;
		
		@(posedge clk);
		if (triggered != 0)
			correct = 0;
			
		@(negedge clk);
		protTrig = 1;
		armed = 1;
		set_capture_done = 1;
		
		@(posedge clk)
		if (triggered != 0)
			correct = 0;
			
		if (correct)
			$display("It worked!");
		else
			$display("Something went wrong...");
			
		$stop;
	end

	always
		#5 clk = ~clk;

	endmodule
