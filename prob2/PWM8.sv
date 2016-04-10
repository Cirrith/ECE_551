module PWM8 (clk, rst_n, duty, PWM_sig);

input clk;
input rst_n;
input [7:0] duty;

output logic PWM_sig;

logic [7:0] count;

logic [7:0] i;

counter coun(.clk(clk), .rst_n(rst_n), .count(count)); //Module that counts up at clk edge

always@(posedge clk, rst_n) begin
	if(!rst_n)
		PWM_sig <= 1;
	else if (count == duty)			//Set PWM down when equal to desired duty cycle
		PWM_sig <= 0;
	else if (count == 8'hFF)
		PWM_sig <= 1;
end

endmodule