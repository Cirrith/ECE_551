module UART_rx_control (clk, rst_n, RX, count, baud, clr_baud, clr_count, clr_rdy, baud_inc, count_inc, shift, rdy);

typedef enum reg {IDLE, RECIEVE} state;

input clk;
input rst_n;

input RX;

input [7:0] baud;
input [3:0] count;

output logic clr_baud;
output logic clr_count;
output logic clr_rdy;
       
output logic rdy;
output logic baud_inc;
output logic count_inc;
       
output logic shift;

state q;
state d;

always_ff @ (posedge clk, negedge rst_n) begin	
	if(!rst_n)
		q <= IDLE;
	else
		q <= d;
end

always_comb begin
	clr_baud = 0;
	clr_count = 0;
	clr_rdy = 0;
	
	shift = 0;
	rdy = 0;
	
	baud_inc = 0;
	count_inc = 0;
	
	d = IDLE;
	
	case (q)
		IDLE: begin
			if(RX == 0 & rst_n) begin
				clr_baud = 1;
				clr_count = 1;
				clr_rdy = 1;
				d = RECIEVE;
			end
			else
				d = IDLE;
		end
		RECIEVE: begin
			if(count == 9) begin
				rdy = 1;
				d = IDLE;
			end
			else if(baud == 162 & count == 0) begin
				count_inc = 1;
				clr_baud = 1;
				shift = 1;
				d = RECIEVE;
			end
			else if(baud == 108 & count != 0) begin
				count_inc = 1;
				clr_baud = 1;
				shift = 1;
				d = RECIEVE;
			end
			else begin
				baud_inc = 1;
				d = RECIEVE;
			end
		end
	endcase
end
endmodule