module UART_tx (clk, rst_n, TX, trmt, tx_data, tx_done);

input clk;
input rst_n;
input trmt;
input [7:0] tx_data;

output logic tx_done;
output TX;

logic [7:0] baud;
logic [3:0] count;
logic load;
logic shift;

logic clr_baud;
logic clr_count;
logic clr_done;

logic count_inc;
logic baud_inc;

UART_tx_control control_dv(.clk(clk), .rst_n(rst_n), .trmt(trmt), .baud(baud), .count(count), .load(load), .shift(shift), .clr_baud(clr_baud), .clr_done(clr_done), .clr_count(clr_count), .done(done), .count_inc(count_inc), .baud_inc(baud_inc));
UART_tx_stor stor_dv(.clk(clk), .rst_n(rst_n), .load(load), .shift(shift), .data_in(tx_data), .data_out(TX));
UART_tx_count count_dv(.clk(clk), .rst_n(rst_n), .clr_count(clr_count), .count_inc(count_inc), .count(count));
UART_tx_baud baud_dv(.clk(clk), .rst_n(rst_n), .clr_baud(clr_baud), .baud_inc(baud_inc), .baud(baud));

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		tx_done <= 0;
	end
	else begin
		if(done)
			tx_done <= 1;
		else if(clr_done)
			tx_done <= 0;
	end
end

endmodule