`timescale 100ps / 10ps
module channel_sample_tb();

// signals to manipulate
logic clk_50, Rst_n;
logic [3:0] decimator;
logic CH1L, CH1H, CH2L, CH2H, CH3L, CH3H, CH4L, CH4H, CH5L, CH5H; 
logic [7:0] VIL, VIH;

// output/input signals of modules
logic smpl_clk, clk, clk_400;
logic locked, rst_n, wrt_smpl;
logic CH1_Hff5, CH1_Lff5, CH2_Hff5, CH2_Lff5, CH3_Hff5, CH3_Lff5, CH4_Hff5, CH4_Lff5, CH5_Hff5, CH5_Lff5;
logic [7:0] smpl1, smpl2, smpl3, smpl4, smpl5;
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
		.CH1H(CH1H), 
		.CH2L(CH2L), 
		.CH2H(CH2H),
		.CH3L(CH3L), 
		.CH3H(CH3H), 
		.CH4L(CH4L), 
		.CH4H(CH4H), 
		.CH5L(CH5L), 
		.CH5H(CH5H));	
		
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
					
channel_sample iDUT2(.smpl_clk(smpl_clk), 
					.clk(clk), 
					.rst_n(rst_n), 
					.CH_H(CH2H),
					.CH_L(CH2L), 
					.CH_Hff5(CH2_Hff5), 
					.CH_Lff5(CH2_Lff5), 
					.smpl(smpl2));
					
channel_sample iDUT3(.smpl_clk(smpl_clk), 
					.clk(clk), 
					.rst_n(rst_n), 
					.CH_H(CH3H),
					.CH_L(CH3L), 
					.CH_Hff5(CH3_Hff5), 
					.CH_Lff5(CH3_Lff5), 
					.smpl(smpl3));
					
channel_sample iDUT4(.smpl_clk(smpl_clk), 
					.clk(clk), 
					.rst_n(rst_n), 
					.CH_H(CH4H),
					.CH_L(CH4L), 
					.CH_Hff5(CH4_Hff5), 
					.CH_Lff5(CH4_Lff5), 
					.smpl(smpl4));
				
channel_sample iDUT5(.smpl_clk(smpl_clk),
					.clk(clk), 
					.rst_n(rst_n), 
					.CH_H(CH5H),
					.CH_L(CH5L), 
					.CH_Hff5(CH5_Hff5), 
					.CH_Lff5(CH5_Lff5), 
					.smpl(smpl5));				

logic [4:0] count;	
			
initial
begin
	$display("START");	
	clk_50 = 0;
	Rst_n = 0;
	VIL = 8'h77;
	VIH = 8'h77;
	decimator = 4'h4;
	
	repeat(5)@(negedge clk_50);

	Rst_n = 1;
	
	for(count = 0; count < 16; count = count + 1)
	begin
		repeat(5)@(posedge smpl_clk);
		$display("%h", smpl1);	
	end

	$display("STOP");	
	$stop;
end

// actually set to 50MHz
always
#5 clk_50 = ~clk_50;

endmodule
