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

logic [4:0] count;	
reg [7:0] CH1mem[65535:0];		// 2^16 entries of 8-bits analog for CH1
logic [7:0] smpl1_expected;
			
initial
begin
	$display("START");	
	
	ptr = 16'h0000;
	$readmemh("CH1mem.txt",CH1mem);
	
	clk_50 = 0;
	Rst_n = 0;
	VIL = 8'h55;
	VIH = 8'hAA;
	decimator = 4'h4;

	Rst_n = 1;
	
	for(count = 0; count < 16; count = count + 1)
	begin
		repeat(5)@(posedge smpl_clk);
		@(posedge clk);
		
		// compare expected and actual smpl
		if(smpl1 != smpl1_expected)
		begin
			$display("actual: %h, expected: %h", smpl1, smpl1_expected);	
			$stop;
		end
	end

	$display("It worked!!");	
	$stop;
end

always
begin


	for(count = 0; count < 16; count = count + 1)
	begin
		@(posedge smpl_clk);
		smpl1_expected[count] = {}
	end
end

// actually set to 50MHz
always
#5 clk_50 = ~clk_50;

endmodule


