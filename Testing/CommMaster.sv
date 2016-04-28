module CommMaster(clk, rst_n, cmd, snd_cmd, clr_rec_rdy, RX, cmd_cmplt, TX, rec_data, rec_rdy);

	typedef enum reg [1:0] {IDLE, HIGH, LOW, SENT} State;

	input clk;
	input rst_n;
	input [15:0] cmd;
	input snd_cmd;
	input clr_rec_rdy;
	input RX;

	output logic cmd_cmplt;
	output TX;
	output [7:0] rec_data;
	output rec_rdy;

	logic [7:0] lower;
	logic sel;
	logic trmt;
	logic [7:0] tx_data;

	UART_tx tx(
		.clk(clk),
		.rst_n(rst_n),
		.TX(TX),
		.trmt(trmt),
		.tx_data(tx_data),
		.tx_done(tx_done));
	
	UART_rx rx(
		.clk(clk),
		.rst_n(rst_n),
		.clr_rdy(clr_rec_rdy),
		.RX(RX),
		.cmd(rec_data),
		.rdy(rec_rdy));
	
	State state, nxt_state;

	assign tx_data = sel ? cmd[15:8] : lower;

	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)				//State Logic
			state <= IDLE;
		else
			state <= nxt_state;
	end
			
	always_ff @ (posedge clk) begin
		if(snd_cmd)				//Enable on lower flops
			lower <= cmd [7:0];
		else
			lower <= lower;
	end

	assign cmd_cmplt = state == SENT;

	always_comb begin
		trmt = 1'b0;
		sel = 1'b0;
		nxt_state = IDLE;
		
		case(state)
			IDLE: begin
				if(snd_cmd) begin
					trmt = 1'b1;
					sel = 1'b1;
					nxt_state = HIGH;
				end
			end
			
			HIGH: begin
				if(tx_done) begin
					sel = 1'b0;
					trmt = 1'b1;
					nxt_state = LOW;
				end
				else
					nxt_state = HIGH;
			end
			
			LOW: begin
				if(tx_done) begin
					nxt_state = SENT;
				end
				else
					nxt_state = LOW;
			end
			
			SENT: begin
				if(snd_cmd) begin
					sel = 1'b1;
					trmt = 1'b1;
					nxt_state = HIGH;
				end
				else begin
					nxt_state = SENT;
				end
			end
		endcase
		
	end
endmodule 
	