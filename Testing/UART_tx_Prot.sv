module UART_tx_Prot (clk, rst_n, trmt, tx_data, baud_cnt, tx_done, TX);

	input clk;
	input rst_n;
	input trmt;
	input [7:0] tx_data;
	input [15:0] baud_cnt;

	output logic tx_done;
	output TX;
	
	typedef enum reg [1:0] {IDLE, TRANS, SHIFT} State;
	
	logic inc_baud;
	logic inc_count;
	logic set_done;
	
	logic clr_baud;
	logic clr_count;
	logic clr_done;
	
	logic load;
	logic shift;
	
	logic [9:0] stor;
	logic [3:0] count;
	logic [15:0] baud;
	
	State state;
	State nxtstate;

	assign TX = stor[0];
	
	/////STATE LOGIC\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin	
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxtstate;
	end
	
	/////STORAGE LOGIC\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			stor <= 10'hFFF;
		else if (load)
			stor <= {1'h1, tx_data, 1'h0};
		else if (shift)
			stor <= {1'h1, stor[9:1]};
		else
			stor <= stor;
	end
	
	/////COUNTING LOGIC\\\\\
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			count <= 0;
		else if (clr_count)
			count <= 0;
		else if (inc_count)
			count <= count + 1;
		else
			count <= count;
	end

	
	/////BAUD LOGIC\\\\\
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud <= 0;
		else if (clr_baud)
			baud <= 0;
		else if (inc_baud)
			baud <= baud + 1;
		else
			baud <= baud;
	end
	
	
	/////DONE LOGIC\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			tx_done <= 0;
		end else begin
			if(set_done)
				tx_done <= 1;
			else if(clr_done)
				tx_done <= 0;
		end
	end
	
	always_comb begin
		clr_done = 0;
		clr_baud = 0;
		clr_count = 0;
		
		set_done = 0;
		inc_baud = 0;
		inc_count = 0;
		
		load = 0;
		shift = 0;
		
		nxtstate = IDLE;
		
		case (state)
			IDLE: begin
				if(trmt) begin
					load = 1;
					clr_baud = 1;
					clr_count = 1;
					clr_done = 1;
					nxtstate = TRANS;
				end
				else
					nxtstate = IDLE;
			end
			TRANS: begin
				if(baud == baud_cnt) begin
					inc_count = 1;
					nxtstate = SHIFT;
				end
				else begin
					inc_baud = 1;
					nxtstate = TRANS;
				end
			end
			SHIFT: begin
				if(count == 10) begin
					set_done = 1;
					nxtstate = IDLE;
				end
				else begin
					shift = 1;
					clr_baud = 1;
					nxtstate = TRANS;
				end
			end
			default:
				nxtstate = IDLE;
		endcase
	end
endmodule