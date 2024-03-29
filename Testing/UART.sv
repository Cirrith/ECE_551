/**************************************************************************************************
	MODULE: UART
	PURPOSE:
	
	INPUTS:
	
	OUPUTS:
	
	INTERNAL:
**************************************************************************************************/
module UART(clk, rst_n, TX, RX, tx_data, trmt, clr_rdy, tx_done, rx_data, rdy);

input clk;
input rst_n;
input RX;
input [7:0]tx_data;
input clr_rdy;
input trmt;

output TX;
output tx_done;
output [7:0]rx_data;
output rdy;

UART_rx rx(.clk(clk), .rst_n(rst_n), .clr_rdy(clr_rdy), .RX(RX), .cmd(rx_data), .rdy(rdy));
UART_tx tx(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));

endmodule