/**************************************************************************************************
/	MODULE: Trigger_Unit
/	PURPOSE: Determine when a trigger occurs given the current configuration
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			TrigCfg - Configuration for trigger
/			CH1TrigCfg - Configuration for Channel 1
/			CH2TrigCfg - Configuration for Channel 2
/			CH3TrigCfg - Configuration for Channel 3
/			CH4TrigCfg - Configuration for Channel 4
/			CH5TrigCfg - Configuration for Channel 5
/			CH1Hff5 - 5 Flip-flop version of Channel 1 High input
/			CH2Hff5 - 5 Flip-flop version of Channel 2 High input
/			CH3Hff5 - 5 Flip-flop version of Channel 3 High input
/			CH4Hff5 - 5 Flip-flop version of Channel 4 High input
/			CH5Hff5 - 5 Flip-flop version of Channel 5 High input
/			CH1Lff5 - 5 Flip-flop version of Channel 1 Low input
/			CH2Lff5 - 5 Flip-flop version of Channel 2 Low input
/			CH3Lff5 - 5 Flip-flop version of Channel 3 Low input
/			CH4Lff5 - 5 Flip-flop version of Channel 4 Low input
/			CH5Lff5 - 5 Flip-flop version of Channel 5 Low input
/			CH1L - Lower input of Channel 1
/			CH2L - Lower input of Channel 2
/			CH3L - Lower input of Channel 3
/			maskH [7:0] - Top 15:8 for mask input to protocol triggering
/			maskL [7:0] - Top 15:8 for mask input to protocol triggering
/			matchH [7:0] - Top 15:8 bits for match input to protocol triggering
/			matchL [7:0] - Top 15:8 bits for match input to protocol triggering
/			armed - Whether to take a trigger or not
/			capture_done - Whether capture is done or not
/			
/	OUTPUTS:
/			triggered - Start taking the final samples
/	
/	INTERNAL:
/			CH1Trig - Whether channel 1 has triggered or not
/			CH2Trig - Whether channel 1 has triggered or not
/			CH3Trig - Whether channel 1 has triggered or not
/			CH4Trig - Whether channel 1 has triggered or not
/			CH5Trig - Whether channel 1 has triggered or not
/			protTrig - Whether protocol unit has triggered or not
/	
**************************************************************************************************/
module Trigger_Unit (clk, rst_n, TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, CH1Hff5, CH2Hff5, CH3Hff5, CH4Hff5, CH5Hff5, CH1Lff5, CH2Lff5, CH3Lff5, CH4Lff5, CH5Lff5, CH1L, CH2L, CH3L, maskH, maskL, matchH, matchL, armed, capture_done, triggered);	
	
	input clk;
	input rst_n;
	
	input [5:0] TrigCfg;
	
	input [4:0] CH1TrigCfg;
	input [4:0] CH2TrigCfg;
	input [4:0] CH3TrigCfg;
	input [4:0] CH4TrigCfg;
	input [4:0] CH5TrigCfg;
	
	input CH1Hff5;
	input CH2Hff5;
	input CH3Hff5;
	input CH4Hff5;
	input CH5Hff5;
	
	input CH1Lff5;
	input CH2Lff5;
	input CH3Lff5;
	input CH4Lff5;
	input CH5Lff5;
	
	input CH1L;
	input CH2L;
	input CH3L;
	
	input [7:0] maskH;
	input [7:0] maskL;
	
	input [7:0] matchH;
	input [7:0] matchL;
	
	input armed;
	input capture_done;
	
	output triggered;
	
	logic CH1Trig;
	logic CH2Trig;
	logic CH3Trig;
	logic CH4Trig;
	logic CH5Trig;
	logic protTrig;
	
	/////MODULE DECLARATION\\\\\
	
	trigger_logic Trig(
				.clk(clk), 
				.rst_n(rst_n), 
				.armed(armed), 
				.capture_done(capture_done), 
				.CH1Trig(CH1Trig), 
				.CH2Trig(CH2Trig), 
				.CH3Trig(CH3Trig), 
				.CH4Trig(CH4Trig), 
				.CH5Trig(CH5Trig), 
				.protTrig(protTrig), 
				.triggered(triggered));
	
	Protocol_Trigger_Unit Prot_Trig (
				.clk		(clk), 
				.rst_n		(rst_n), 
				.TrigCfg	(TrigCfg), 
				.maskH		(maskH), 
				.maskL		(maskL), 
				.matchH		(matchH), 
				.matchL		(matchL), 
				.baud_cntH	(baud_cntH), 
				.baud_cntL	(baud_cntL), 
				.CH1L		(CH1L), 
				.CH2L		(CH2L), 
				.CH3L		(CH3L), 
				.protTrig	(protTrig));

	Channel_Trigger_Unit CH1 (.clk(clk), .rst_n(rst_n), .CHxTrigCfg(CH1TrigCfg), .CHxHff5(CH1Hff5), .CHxLff5(CH1Lff5), .armed(armed), .CHxTrig(CH1Trig));
	Channel_Trigger_Unit CH2 (.clk(clk), .rst_n(rst_n), .CHxTrigCfg(CH2TrigCfg), .CHxHff5(CH2Hff5), .CHxLff5(CH2Lff5), .armed(armed), .CHxTrig(CH2Trig));
	Channel_Trigger_Unit CH3 (.clk(clk), .rst_n(rst_n), .CHxTrigCfg(CH3TrigCfg), .CHxHff5(CH3Hff5), .CHxLff5(CH3Lff5), .armed(armed), .CHxTrig(CH3Trig));
	Channel_Trigger_Unit CH4 (.clk(clk), .rst_n(rst_n), .CHxTrigCfg(CH4TrigCfg), .CHxHff5(CH4Hff5), .CHxLff5(CH4Lff5), .armed(armed), .CHxTrig(CH4Trig));
	Channel_Trigger_Unit CH5 (.clk(clk), .rst_n(rst_n), .CHxTrigCfg(CH5TrigCfg), .CHxHff5(CH5Hff5), .CHxLff5(CH5Lff5), .armed(armed), .CHxTrig(CH5Trig));
	
endmodule