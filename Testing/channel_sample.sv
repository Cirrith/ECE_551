/**************************************************************************************************
/	MODULE: channel_sample
/	PURPOSE: Do metastability for channel inputs
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			CHxH - High input of Channel
/			CHxL - Low input of Channel
/			smpl_clk - Sample Clock
/			
/	OUTPUTS:
/			CHxHff5 - 5th flip-floped version of CHx H
/			CHxLff5 - 5th flip-floped version of CHx L
/			smpl [7:0] - Sample
/			
/	INTERNAL: 
/			CHxHff1 - 
/			CHxHff2 - 
/			CHxHff3 - 
/			CHxHff4 - 
/			CHxLff1 - 
/			CHxLff2 - 
/			CHxLff3 - 
/			CHxLff4 - 
/			
**************************************************************************************************/
module channel_sample(clk, rst_n, CHxH, CHxL, smpl_clk, CHxHff5, CHxLff5, smpl);

	input clk;
	input rst_n;
	input CHxH;
	input CHxL;
	input [7:0] smpl_clk;
	
	output logic CHxHff5;
	output logic CHxLff5;
	output logic [7:0] smpl;

	logic CHxHff1;
	logic CHxHff2;
	logic CHxHff3;
	logic CHxHff4;
	logic CHxLff1;
	logic CHxLff2;
	logic CHxLff3;
	logic CHxLff4;
 
	// flop CH_H and CH_L five times
	// - twice for metastability, 3 more times for use in forming smpl
	always_ff@(negedge smpl_clk, negedge rst_n)
	begin
		if(!rst_n)
		begin
			CHxHff1 <= 0;
			CHxHff2 <= 0;
			CHxHff3 <= 0;
			CHxHff4 <= 0;
			CHxHff5 <= 0;
			
			CHxLff1 <= 0;
			CHxLff2 <= 0;
			CHxLff3 <= 0;
			CHxLff4 <= 0;
			CHxLff5 <= 0;
		end
		else
		begin
			CHxHff1 <= CHxH;
			CHxHff2 <= CHxHff1;
			CHxHff3 <= CHxHff2;
			CHxHff4 <= CHxHff3;
			CHxHff5 <= CHxHff4;
			
			CHxLff1 <= CHxL;
			CHxLff2 <= CHxLff1;
			CHxLff3 <= CHxLff2;
			CHxLff4 <= CHxLff3;
			CHxLff5 <= CHxLff4;
		end
	end

	// form 8 bit sample - a collection of 4 2-bit samples of CH_H and CH_L
	always_ff@(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
			smpl <= 8'h00;
		else
			smpl <= {CHxHff2, CHxLff2, CHxHff3, CHxLff3, CHxHff4, CHxLff4, CHxHff5, CHxLff5};
	end


endmodule
