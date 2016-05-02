/***************************************************************************************************
	MODULE: UART_RX_Prot
	PURPOSE: For protocol triggering, will determine if a specific command was sent
	
	INPUTS: 
			clk - Clock
			rst_n - Reset
			RX - Data line
			baud_cnt - Rate at which to accept commands
			mask - Bits to ignore
			match - sequence to match
	
	OUTPUTS:
			UARTtrig - Whether it triggered or not
	
	INTERNAL:
			state - Current state
			nxtstate - state to go into
			RX_met - Metastability for RX, RX_met[2] is oldest
**************************************************************************************************/
module UART_RX_Prot(clk, rst_n, RX, baud_cnt, mask, match, UARTtrig);
	
	typedef enum logic {IDLE, RECIEVE} State;
	
	input 			clk;
	input 			rst_n;
	input 			RX;
	input [15:0] 	baud_cnt;
	input [7:0] 	mask;
	input [7:0] 	match;
	
	output logic	UARTtrig;
	
	State 			state;
	State 			nxtstate;
	
	logic inc_baud;
	logic inc_count;
	
	logic clr_baud;
	logic clr_count;
	
	logic shift;
	
	logic [8:0]		stor;
	logic [2:0] 	RX_met;
	logic [3:0] 	count;
	logic [15:0] 	baud;
	
	/////METASTABILITY\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin		//Metastability for RX
		if(!rst_n)
			RX_met <= 2'h0;
		else begin
			RX_met[2] <= RX_met[1];
			RX_met[1] <= RX_met[0];
			RX_met[0] <= RX;
		end
	end
	
	/////STATE LOGIC\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin		//State Machine
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxtstate;
	end
	
	always_comb begin
		clr_baud = 0;
		clr_count = 0;
		inc_count = 0;
		inc_baud = 0;
		shift = 0;
		UARTtrig = 0;
		nxtstate = IDLE;
		
		case(state)
			IDLE: begin
				if((RX_met[2] == 1) & (RX_met[1] == 0)) begin		//Falling Edge in RX denotes start of transmission
					clr_baud = 1;
					clr_count = 1;
					nxtstate = RECIEVE;
				end
				else
					nxtstate = IDLE;
			end
			
			RECIEVE : begin
				if(baud == baud_cnt & count == 9) begin				//Transmission complete, move to IDLE and compare
					if ((match | mask) == (stor[8:1] | mask))
						UARTtrig = 1;
					clr_baud = 1;
					clr_count = 1;
					nxtstate = IDLE;
				end
				else if (baud == baud_cnt/2 & count == 0) begin 		//First tick after start, start half way through block
					shift = 1;
					clr_baud = 1;
					inc_count = 1;
					nxtstate = RECIEVE;
				end
				else if (baud == baud_cnt) begin					//Standard movement 
					shift = 1;
					clr_baud = 1;
					inc_count = 1;
					nxtstate = RECIEVE;
				end
				else begin											//Nothing to do, increment and move on
					inc_baud = 1;
					nxtstate = RECIEVE;
				end
			end
		endcase
	end
	
	/////STORAGE LOGIC\\\\\
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			stor <= 0;
		else if (shift)
			stor <= {RX_met[1], stor[8:1]};
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

endmodule