module UART_wrapper(clk, rst_n, clr_cmd_rdy, RX, send_resp, resp, resp_sent, cmd_rdy, cmd, TX);

	typedef enum reg [1:0] {IDLE, STORE, READY} State;

	input clk;
	input rst_n;
	input clr_cmd_rdy;
	input RX;
	input send_resp;
	input [7:0] resp;

	output resp_sent;
	output logic cmd_rdy;
	output [15:0] cmd;
	output TX;

	logic [7:0] upper;
	logic sel;
	logic clr_rdy;
	logic [7:0] rx_data;
	logic rdy;

	State state, nxt_state;

	UART uart(.clk(clk), .rst_n(rst_n), .TX(TX), .RX(RX), .tx_data(resp), .trmt(send_resp), .clr_rdy(clr_rdy), .tx_done(resp_sent), .rx_data(rx_data), .rdy(rdy));

	assign cmd = {upper, rx_data};

	always_ff @ (posedge clk, negedge rst_n) begin //State, Store, & Ready Logic
		if(!rst_n)				//State logic
			state <= IDLE;
		else
			state <= nxt_state;
	end

	always_ff @ (posedge clk) begin
		if(sel)					//Store logic
			upper <= rx_data;
		else
			upper <= upper;
	end

	always_comb begin
		sel = 1'b0;
		cmd_rdy = 1'b0;
		clr_rdy = 1'b0;
		nxt_state = IDLE;
		
		case(state)
			IDLE: begin
				if(rdy) begin
					sel = 1'b1;
					clr_rdy = 1'b1;
					nxt_state =  STORE;
				end			
			end
			
			STORE: begin
				if(rdy) begin
					clr_rdy = 1'b1;
					nxt_state = READY;
				end
				else
					nxt_state = STORE;
			end
			
			READY: begin
				if(rdy) begin
					sel = 1'b1;
					clr_rdy = 1'b1;
					nxt_state = STORE;
				end
				else if(clr_cmd_rdy) begin
					nxt_state = IDLE;
				end
				else begin
					cmd_rdy = 1'b1;
					nxt_state = READY;
				end
			end
		endcase
	end

endmodule