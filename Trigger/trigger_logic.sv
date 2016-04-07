module trigger_logic (CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, armed, set_capture_done, rst_n, clk, triggered);

input CH1Trig;
input CH2Trig;
input CH3Trig;
input CH4Trig;
input CH5Trig;
input protTrig;

input armed;
input set_capture_done;

input rst_n;
input clk;

output reg triggered;

logic trig_set;
logic d;

always_comb begin
	trig_set = CH1Trig & CH2Trig & CH3Trig & CH4Trig & CH5Trig & protTrig; //Large AND Gate
	d = !(set_capture_done | !(triggered | (trig_set & armed))); // Reset of Logic
end

always_ff @ (posedge clk, negedge rst_n) begin //FF Next State Logic
	if(!rst_n)
		triggered <= 0;
	else
		triggered <= d;
end

endmodule