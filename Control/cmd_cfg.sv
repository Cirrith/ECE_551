/**************************************************************************************************
/	MODULE: cmd_cfg
/	PURPOSE: Take in the transmitted command and perform it.
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			cmd [15:0] - Command to execute
/			cmd_rdy - Recieved a command
/			resp_sent - Respone was sent via UART
/			set_capture_done - Capture is complete
/			waddr [LOG2-1:0] - Writing address from RAM (Assuming that all ram are writing to the same address)
/			rdataCH1 [7:0] - Data read from channel 1
/			rdataCH2 [7:0] - Data read from channel 2
/			rdataCH3 [7:0] - Data read from channel 3
/			rdataCH4 [7:0] - Data read from channel 4
/			rdataCH5 [7:0] - Data read from channel 5
/			
/	OUPUTS:
/			resp [7:0] - Response to send via UART
/			send_resp - Send Response, to UART
/			clr_cmd_rdy - Sets the Command done at the UART
/			trig_pos - How many samples after trigger to capture
/			TrigCfg [5:0] - Configuration of triggering and capture
/			CH1TrigCfg [4:0] - Specific triggering of channel 1
/			CH2TrigCfg [4:0] - Specific triggering of channel 2
/			CH3TrigCfg [4:0] - Specific triggering of channel 3
/			CH4TrigCfg [4:0] - Specific triggering of channel 4
/			CH5TrigCfg [4:0] - Specific triggering of channel 5
/			decimator [3:0] - Setting the sample rate
/			VIH [7:0] - Level set for PWM, HIGH
/			VIL [7:0] - Level set for PWM, LOW
/			matchH [7:0] - Data to match for protocol triggering
/			matchL [7:0] - Data to match for protocol triggering
/			maskH [7:0] - Mask for protocol triggering
/			maskL [7:0] - Mask for protocol triggering
/			baud_cntH [7:0] - Data for UART triggering
/			baud_cntL [7:0] - Data for UART triggering		
/	
/	INTERNAL:
/			command - What kind of command should executed
/			register - Which register should the command be done on
/			data - Last part of command, used in write command
/			ccc - Which channel should be read
/			wrt_reg - Whether to write the register or not
/			raddr - Address that we will be reading from
/			trig_posH [7:0] - Internal Register that is used as top of trig_pos
/			trig_posL [7:0] - Internal Register that is used as bot of trig_pos
/			TrigCfg_nxt - Data to be written to TrigCfg register on next posedge clk
/			CH1TrigCfg_nxt - Data to be written to CH1TrigCfg register on next posedge clk
/			CH2TrigCfg_nxt - Data to be written to CH2TrigCfg register on next posedge clk
/			CH3TrigCfg_nxt - Data to be written to CH3TrigCfg register on next posedge clk
/			CH4TrigCfg_nxt - Data to be written to CH4TrigCfg register on next posedge clk
/			CH5TrigCfg_nxt - Data to be written to CH5TrigCfg register on next posedge clk
/			decimator_nxt - Data to be written to decimator register on next posedge clk
/			VIH_nxt - Data to be written to VIH regsiter on next posedge clk
/			VIL_nxt - Data to be written to VIL register on next posedge clk
/			matchH_nxt - Data to be written to matchH register on next posedge clk
/			matchL_nxt - Data to be written to matchL register on next posedge clk
/			maskH_nxt - Data to be written to maskH register on next posedge clk
/			maskL_nxt - Data to be written to maskL register on next posedge clk
/			baud_cntH_nxt - Data to be written to baud_cntH register on next posedge clk
/			baud_cntL_nxt - Data to be written to baud_cntL register on next posedge clk
/			trig_posH_nxt - Data to be written to trig_posH register on next posedge clk
/			trig_posL_nxt - Data to be written to trig_posL register on next posedge clk
**************************************************************************************************/
module cmd_cfg (clk, rst_n, cmd, cmd_rdy, resp_sent, set_capture_done, waddr, rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5, raddr, resp, send_resp, clr_cmd_rdy, trig_pos, decimator, maskL, maskH, matchL, matchH, baud_cntL, baud_cntH, TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, VIH, VIL);
	
	parameter LOG2 = 9; //Default Size for Data
	parameter ENTRIES = 384;
	
	//Not sure if need enum
	
	localparam ACK = 8'hA5;
	localparam NAK = 8'hEE:
	
	typedef enum logic [1:0] {ReadReg, WriteReg, Dump} Command;
	typedef enum logic [2:0] {CH1, CH2, CH3, Ch4, Ch5} Channel;
	typedef enum logic [5:0] {TrigCfg_Reg, CH1TrigCfg_Reg, CH2TrigCfg_Reg, CH3TrigCfg_Reg, CH4TrigCfg_Reg, CH5TrigCfg_Reg, decimator_Reg, VIH_Reg, VIL_Reg, matchH_Reg, matchL_Reg, maskH_Reg, maskL_Reg, baud_cntH_Reg, baud_cntL_Reg, trig_posH_Reg, trig_posL_Reg} Register;
	typedef enum logic [2:0] {IDLE, WRITE, READ, DUMP, RESP, ERROR} State;
	
	input clk;
	input rst_n;

	input [15:0] cmd;
	input cmd_rdy;
	input resp_sent;
	input set_capture_done;
	
	input [LOG2-1:0] waddr;
	
	input [7:0] rdataCH1;
	input [7:0] rdataCH2;
	input [7:0] rdataCH3;
	input [7:0] rdataCH4;
	input [7:0] rdataCH5;

	output logic [LOG2-1:0] raddr;
	output logic [7:0] resp;
	output logic send_resp;
	output logic clr_cmd_rdy;
	output [LOG2-1:0] trig_pos; //HARD CODING IT FOR 16 NEED TO FIGURE OUT HOW TO USE [LOG2-1:0] as a 

	output logic [3:0] decimator;
	output logic [7:0] maskL;
	output logic [7:0] maskH;
	output logic [7:0] matchL;
	output logic [7:0] matchH;
	output logic [7:0] baud_cntL;
	output logic [7:0] baud_cntH;
	output logic [7:0] TrigCfg;
	output logic [7:0] CH1TrigCfg;
	output logic [7:0] CH2TrigCfg;
	output logic [7:0] CH3TrigCfg;
	output logic [7:0] CH4TrigCfg;
	output logic [7:0] CH5TrigCfg;
	output logic [7:0] VIH;
	output logic [7:0] VIL;
	
	Command command;
	Register register;
	Channel ccc;
	
	State state;
	State nxtstate;
	
	logic [7:0] data;
	
	logic wrt_reg;
	logic [LOG2-1:0] raddr_curr;
	
	logic [7:0] trig_posH;
	logic [7:0] trig_posL;
	
	assign trig_pos = {trig_posH, trig_posL};
	
	assign command = '{cmd[15:14]};
	assign register = '{cmd[12:8]};
	assign data = cmd[7:0];
	assign ccc = '{cmd[10:8]};
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxtstate;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin 
		if(!rst_n)
			TrigCfg <= 6'h03;
		else if(wrt_reg & (register == TrigCfg_Reg))
			TrigCfg <= data[5:0];
		else if(set_capture_done)
			TrigCfg <= TrigCfg | 6'h20;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			CH1TrigCfg <= 5'h01;
		else if (wrt_reg & (register == CH1TrigCfg_Reg))
			CH1TrigCfg <= data[4:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			CH2TrigCfg <= 5'h01;
		else if (wrt_reg & (register == CH2TrigCfg_Reg))
			CH2TrigCfg <= data[4:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			CH3TrigCfg <= 5'h01;
		else if (wrt_reg & (register == CH3TrigCfg_Reg))
			CH3TrigCfg <= data[4:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			CH4TrigCfg <= 5'h01;
		else if (wrt_reg & (register == CH4TrigCfg_Reg))
			CH4TrigCfg <= data[4:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			CH5TrigCfg <= 5'h01;
		else if (wrt_reg & (register == CH5TrigCfg_Reg))
			CH5TrigCfg <= data[4:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			decimator <= 4'h0;
		else if (wrt_reg & (register == decimator_Reg))
			decimator <= data[3:0];
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			VIH <= 8'hAA;
		else if (wrt_reg & (register == VIH_Reg))
			VIH <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			VIL <= 8'h55;
		else if (wrt_reg & (register == VIL_Reg))
			VIL <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			matchH <= 8'h00;
		else if (wrt_reg & (register == matchH_Reg))
			matchH <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			matchL <= 8'h00;
		else if (wrt_reg & (register == matchL_Reg))
			matchL <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			maskH <= 8'h00;
		else if (wrt_reg & (register == maskH_Reg))
			maskH <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			maskL <= 8'h00;
		else if (wrt_reg & (register == maskL_Reg))
			maskL <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud_cntH <= 8'h06;
		else if (wrt_reg & (register == baud_cntH_Reg))
			baud_cntH <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			baud_cntL <= 8'hC8;
		else if (wrt_reg & (register == baud_cntL_Reg))
			baud_cntL <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			trig_posH <= 8'h00;
		else if (wrt_reg & (register == trig_posH_Reg))
			trig_posH <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			trig_posL <= 8'h01;
		else if (wrt_reg & (register == trig_posL_Reg))
			trig_posL <= data;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			raddr_curr <= 0;
		else if(resp_sent | ((state == IDLE) & (command == Dump)));
			raddr_curr <= raddr;
	end
	
	always_comb begin	
		wrt_reg = 1'h0;
		send_resp = 1'h0;
		clr_cmd_rdy = 1'h0;
		resp = 8'h00;
		raddr = raddr_curr;
		nxtstate = IDLE;
	
		case(state)
			IDLE: begin
				if(cmd_rdy) begin
					case(command)
						ReadReg : begin						//Command is to send back what is contained in the specified register. Set response equal to register, with padding, and send it
							nxtstate = READ;
						end
						
						WriteReg : begin
							nxtstate = WRITE;
						end
						
						Dump : begin
							raddr = waddr;
							case(ccc) 
								CH1 : resp = rdataCH1;
								CH2 : resp = rdataCH2;
								CH3 : resp = rdataCH3;
								Ch4 : resp = rdataCH4;
								Ch5 : resp = rdataCH5;
							endcase
							send_resp = 1'h1;
							nxtstate = RESP;
						end
						
						default : begin
							nxtstate = ERROR;
							$display("Sent a Bad Command");
						end
					endcase
				end
			end
			
			READ : begin
				case(register)
					TrigCfg_Reg : 		resp = {2'h0, TrigCfg};
					CH1TrigCfg_Reg : 	resp = {3'h0, CH1TrigCfg};
					CH2TrigCfg_Reg : 	resp = {3'h0, CH2TrigCfg};
					CH3TrigCfg_Reg : 	resp = {3'h0, CH3TrigCfg};
					CH4TrigCfg_Reg : 	resp = {3'h0, CH4TrigCfg};
					CH5TrigCfg_Reg : 	resp = {3'h0, CH5TrigCfg};
					decimator_Reg : 	resp = {4'h0, decimator};
					VIH_Reg : 			resp = VIH;
					VIL_Reg : 			resp = VIL;
					matchH_Reg : 		resp = matchH;
					matchL_Reg : 		resp = matchL;
					maskH_Reg : 		resp = maskH;
					maskL_Reg : 		resp = maskL;
					baud_cntH_Reg : 	resp = baud_cntH;
					baud_cntL_Reg : 	resp = baud_cntL;
					trig_posH_Reg : 	resp = trig_posH;
					trig_posL_Reg : 	resp = trig_posL;
					
					default : begin //Sent bad register
						nxtstate = ERROR;
						$display("Sent a Bad Register");
					end
				endcase
				
				send_resp = 1'h1;
				clr_cmd_rdy = 1'h1;
				nxtstate = IDLE;
			end
			
			WRITE : begin
				wrt_reg = 1'h1;
				send_resp = 1'h1;
				resp = ACK;
				clr_cmd_rdy = 1'h1;
				nxtstate = IDLE;
				
				/*
				if (register != Register) begin //Sent bad Register *REDUCE* This may be quite big
					resp = NAK;
					$display("Sent a Bad Register");
				end
				*/
			end
			
			DUMP : begin
				if(raddr_curr == waddr) begin
					clr_cmd_rdy = 1'h1;
					nxtstate = IDLE;
				end
				else begin 
					case (ccc)
						CH1 : resp = rdataCH1;
						CH2 : resp = rdataCH2;
						CH3 : resp = rdataCH3;
						Ch4 : resp = rdataCH4;
						Ch5 : resp = rdataCH5;
						default : begin //Sent bad channel
							nxtstate = ERROR;
							$display("Sent a Bad Channel");
						end
					endcase
					send_resp = 1'h1;
					nxtstate = RESP;
				end
			end
			
			RESP : begin				//State to wait for response to be sent
				if(raddr_curr == ENTRIES-1)
					raddr = 0;
				else
					raddr = raddr_curr + 1; 
				if(resp_sent) begin
					nxtstate = DUMP;
				end
				else
					nxtstate = RESP;
			end

			ERROR : begin
				resp = 8'hEE;
				clr_cmd_rdy = 1'h1;
				send_resp = 1'h1;
				nxtstate = IDLE;
			end
			
			/*default : begin				//This should be impossible to get into, b/c two bits for state and four defined states
				nxtstate = ERROR;
				$display("Entered a Bad State, %d", state);
			end
			*///This is messing up the TestBench
		endcase
	end
endmodule
