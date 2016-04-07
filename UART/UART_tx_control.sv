module UART_tx_control (clk, rst_n, trmt, baud, count, load, shift, clr_baud, clr_done, clr_count, done, count_inc, baud_inc);

typedef enum reg [1:0] {IDLE, TRANS, SHIFT} state;

input clk;
input rst_n;

input trmt;
input [7:0] baud;
input [3:0] count;

output logic clr_done;
output logic clr_baud;
output logic clr_count;
       
output logic done;
output logic baud_inc;
output logic count_inc;
       
output logic load;
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
	clr_done = 0;
	clr_baud = 0;
	clr_count = 0;
	
	done = 0;
	baud_inc = 0;
	count_inc = 0;
	
	load = 0;
	shift = 0;
	
	d = IDLE;
	
	case (q)
		IDLE: begin
			if(trmt) begin
				load = 1;
				clr_baud = 1;
				clr_count = 1;
				clr_done = 1;
				d = TRANS;
			end
			else
				d = IDLE;
		end
		TRANS: begin
			if(baud == 108) begin
				count_inc = 1;
				d = SHIFT;
			end
			else begin
				baud_inc = 1;
				d = TRANS;
			end
		end
		SHIFT: begin
			if(count == 10) begin
				done = 1;
				d = IDLE;
			end
			else begin
				shift = 1;
				clr_baud = 1;
				d = TRANS;
			end
		end
		default:
			d = IDLE;
	endcase
end
endmodule
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			