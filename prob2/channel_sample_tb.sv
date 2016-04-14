`timescale 100ps / 10ps
module channel_sample_tb();

// signals to manipulate
logic clk_50, Rst_n;
logic [3:0] decimator;
logic CH1L, CH1H; 
logic [7:0] VIL, VIH;

// output/input signals of modules
logic smpl_clk, clk, clk_400;
logic locked, rst_n, wrt_smpl;
logic CH1_Hff5, CH1_Lff5;
logic [7:0] smpl1;
logic VIH_PWM, VIL_PWM;

// instantiate modules
pll8x mod1(.ref_clk(clk_50), 
			.RST_n(Rst_n), 
			.out_clk(clk_400), 
			.locked(locked));
			
clk_rst_smpl mod2(.clk400MHz(clk_400), 
				.RST_n(Rst_n), 
				.locked(locked), 
				.decimator(decimator),
				.clk(clk), 
				.smpl_clk(smpl_clk), 
				.rst_n(rst_n), 
				.wrt_smpl(wrt_smpl));
				
AFE mod3(.smpl_clk(smpl_clk), 
		.VIH_PWM(VIH_PWM), 
		.VIL_PWM(VIL_PWM), 
		.CH1L(CH1L), 
		.CH1H(CH1H));	
		
dual_PWM mod4(.clk(clk), 
			.rst_n(rst_n), 
			.VIH(VIH), 
			.VIL(VIL), 
			.VIH_PWM(VIH_PWM), 
			.VIL_PWM(VIL_PWM));	
			
channel_sample iDUT1(.smpl_clk(smpl_clk), 
					.clk(clk), 
					.rst_n(rst_n), 
					.CH_H(CH1H),
					.CH_L(CH1L), 
					.CH_Hff5(CH1_Hff5), 
					.CH_Lff5(CH1_Lff5), 
					.smpl(smpl1));			

logic [16:0] count;	
logic [11:0] smpl1_expected;
			
initial
begin
	$display("START");	
	
	clk_50 = 0;
	Rst_n = 0;
	VIL = 8'h55;
	VIH = 8'hAA;
	decimator = 4'h4;
	smpl1_expected = 0;

	@(negedge clk_50);
	
	Rst_n = 1;

	@(posedge rst_n);
	
	// check all values that can be read from CH1mem.txt
	for(count = 0; count < 65536; count = count + 1)
	begin
		// after each posedge of clk, smpl1 should be updated
		@(posedge clk);
		@(posedge clk_400);
		
		// compare expected and actual 
		if(smpl1 != smpl1_expected[7:0])
		begin
			$display("NO --- actual: %h, expected: %h", smpl1, smpl1_expected[7:0]);	
			$stop;
		end
		else
			$display("YES --- actual: %h, expected: %h", smpl1, smpl1_expected[7:0]);
	end
	
	// if this is reached, the modules worked correctly
	$display("It worked!!");
	$stop;
end

// on each negedge of smpl_clk, new values of CH1H and CH1L should be
// loaded into the channel_sample module
always@(negedge smpl_clk)
begin
	// contains the 6 most recent values of CH1H and CH1L.
	// Only bits 7:0 will be checked against smpl1
	if(rst_n)
		smpl1_expected <= {CH1H, CH1L, smpl1_expected[9:2]};
end

// actually set to 50MHz
always
#10 clk_50 = ~clk_50;

endmodule


