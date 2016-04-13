module UART_rx (clk, rst_n, clr_rdy, RX, cmd, rdy);

input clk;
input rst_n;
input clr_rdy;
input RX;

output logic rdy;
output [7:0] cmd;

logic [7:0] baud;
logic [3:0] count;
logic shift;
logic rdy_o;

logic clr_rdy_i;
logic rdy_i;

logic clr_baud;
logic clr_count;

logic count_inc;
logic baud_inc;

UART_rx_control control_dv(.clk(clk), .rst_n(rst_n), .RX(RX), .count(count), .baud(baud), .clr_baud(clr_baud), .clr_count(clr_count), .clr_rdy(clr_rdy_i), .baud_inc(baud_inc), .count_inc(count_inc), .shift(shift), .rdy(rdy_o));
UART_rx_count count_dv(.clk(clk), .rst_n(rst_n), .clr_count(clr_count), .count_inc(count_inc), .count(count));
UART_rx_baud baud_dv(.clk(clk), .rst_n(rst_n), .clr_baud(clr_baud), .baud_inc(baud_inc), .baud(baud));
UART_rx_stor stor_dv(.clk(clk), .rst_n(rst_n), .shift(shift), .data_in(RX), .data_out(cmd));

always_ff @ (posedge clk, negedge rst_n) begin	
	if(!rst_n) begin
		rdy <= 0;
	end
	else begin
		rdy <= rdy_i;
	end
end

always @ (clr_rdy, rdy_o, rdy, clr_rdy_i) begin
	if(clr_rdy | clr_rdy_i)
		rdy_i = 0;
	else if(rdy_o)
		rdy_i = 1;
	else
		rdy_i = rdy;
end

endmodule