/**************************************************************************************************
/	MODULE: Protocol_Trigger_Unit
/	PURPOSE: When the Logic Analyzer is set for Protocol triggering this unit will detect when to trigger
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			TrigCfg [7:0] - Configuration for Protocol Unit
/			maskH [7:0] - 
/			maskL [7:0] - 
/			matchH [7:0] -
/			matchL [7:0] - 
/			baud_cntH [7:0] -
/			baud_cntL [7:0] - 
/			CH1L - 
/			CH2L - 
/			CH3L - 
/	
/	OUTPUTS:
/			protTrig - Ahhh, the classic one output. What does it really mean to only have one output?
/	
/	INTERNAL:
/			SPItrig - Whether SPI has triggered or not
/			UARTtrig - Whether UART has triggered or not
**************************************************************************************************/
module Protocol_Trigger_Unit();
	//TODO: ADD BAUD TO UART_RX
	input clk;
	input rst_n;
	input [7:0] TrigCfg;
	input [7:0] maskH;
	input [7:0] maskL;
	input [7:0] matchH;
	input [7:0] matchL;
	input [7:0] baud_cntH;
	input [7:0] baud_cntL;
	input CH1L;
	input CH2L;
	input CH3L;
	
	output protTrig;
	
	logic SPItrig;
	logic UARTtrig;
	logic [15:0] mask;
	logic [15:0] match;
	logic [15:0] baud_cnt;
	
	assign protTrig = (SPItrig | TrigCfg[1]) & (UARTtrig | TrigCfg[0]);
	
	assign mask = {maskH, maskL};
	assign match = {matchH, matchL};
	assign baud_cnt = {baud_cntH, baud_cntL};
	
	SPI_RX spi (
			clk(clk),
			rst_n(rst_n),
			edg(TrigCfg[3]),
			SS_n(CH1L),
			SCLK(CH2L),
			MOSI(CH3L),
			mask(mask),
			match(match),
			len8_16(TrigCfg[2]),
			SPItrig(SPItrig));
	
	UART_RX uart (
			clk(clk),
			rst_n(rst_n),
			RX(CH1L),
			baud_cnt(baud_cnt),
			mask(maskL),
			match(matchL),
			UARTtrig(UARTtrig));

endmodule