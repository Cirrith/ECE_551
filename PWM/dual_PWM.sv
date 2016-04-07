/**************************************************************************************************
	MODULE: dual_PWM
	PURPOSE: Given two duty cycles (VIH & VIL) create two PWM signals with the approiate duty cycles
	
	INPUTS:
			clk - Clock
			rst_n - Reset, active low
			VIH [7:0] - Duty cycle of output VIH_PWM. 
	
	OUPUTS:
	
	INTERNAL:
**************************************************************************************************/
module dual_PWM (clk, rst_n, VIH, VIL, VIH_PWM, VIL_PWM);

input clk;
input rst_n;

input [7:0] VIH;
input [7:0] VIL;

output VIH_PWM;
output VIL_PWM;

PWM8 High(.clk(clk), .rst_n(rst_n), .duty(VIH), .PWM_sig(VIH_PWM));
PWM8 Low(.clk(clk), .rst_n(rst_n), .duty(VIL), .PWM_sig(VIL_PWM));

endmodule