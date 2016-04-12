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
/			rd_done - Last bye of smaple data has been read
/			set_capture_done - Capture is complete
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
/			strt_rd - Command to external to start reading from RAMqueue at waddr
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
/			trig_posH [7:0] - 
/			trig_posL [7:0] - 			
/	
/	INTERNAL:
/			command - What kind of command should executed
/			register - Which register should the command be done on
/			ccc - Which channel should be read
/			wrt_reg - Whether to write the register or not
/			raddr - Address that we will be reading from
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
module cmd_cfg (clk, rst_n, cmd, cmd_rdy, resp_sent, rd_done, set_capture_done, rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5, resp, send_resp, clr_cmd_rdy, strt_rd, trig_pos, decimator, maskL, maskH, matchL, matchH, baud_cntL, baud_cntH, TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, trig_posH, trig_posL, VIH, VIL);
	
	parameter LOG2 = 9; //Default Size for Data
	parameter ENTRIES = 384;
	
	typedef logic [1:0] {ReadReg, WriteReg, Dump} Command;
	typedef logic [2:0] {CH1, CH2, CH3, Ch4, Ch5} Channel;
	typedef logic [5:0] {TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, decimator, VIH, VIL, matchH, matchL, maskH, maskL, baud_cntH, baud_cntL, trig_posH, trig_posL} Register;
	typedef logic [1:0] {IDLE, DUMP, RESP} State;
	
	input clk;
	input rst_n;

	input [15:0] cmd;
	input cmd_rdy;
	input resp_sent;
	input set_capture_done;

	input [7:0] rdataCH1;
	input [7:0] rdataCH2;
	input [7:0] rdataCH3;
	input [7:0] rdataCH4;
	input [7:0] rdataCH5;

	output [7:0] resp;
	output send_resp;
	output clr_cmd_rdy;
	output [LOG2-1:0] trig_pos;

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
	output logic [7:0] trig_posH;
	output logic [7:0] trig_posL;
	output logic [7:0] VIH;
	output logic [7:0] VIL;
	
	Command command;
	Register register;
	Channel ccc;
	
	State state;
	State nxtstate;
	
	logic wrt_reg;
	logic [LOG2-1:0] raddr; 
	
	logic [5:0] TrigCfg_nxt;
	logic [4:0] CH1TrigCfg_nxt;
	logic [4:0] CH2TrigCfg_nxt;
	logic [4:0] CH3TrigCfg_nxt;
	logic [4:0] CH4TrigCfg_nxt;
	logic [4:0] CH5TrigCfg_nxt;
	logic [3:0] decimator_nxt;
	logic [7:0] VIH_nxt;
	logic [7:0] VIL_nxt;
	logic [7:0] matchH_nxt;
	logic [7:0] matchL_nxt;
	logic [7:0] maskH_nxt;
	logic [7:0] maskL_nxt;
	logic [7:0] baud_cntH_nxt;
	logic [7:0] baud_cntL_nxt;
	logic [7:0] trig_posH_nxt;
	logic [7:0] trig_posL_nxt;
	
	
	assign command = cmd[15:14];
	assign register = cmd[12:8];
	assign data = cmd[7:0];
	assign ccc = cmd[10:8];
	
	always @ (posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxtstate;
	end
	
	always @ (posedge clk, negedge rst_n) begin 
		if(!rst_n) begin
			TrigCfg <= 6'h03;
		end
		else if(wrt_reg) begin
			TrigCfg <= TrigCfg_nxt;
		end
		else if(set_capture_done) begin
			TrigCfg <= TrigCfg | 6'h20;
		end
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n) begin
			CH1TrigCfg <= 5'h01;
			CH2TrigCfg <= 5'h01;
			CH3TrigCfg <= 5'h01;
			CH4TrigCfg <= 5'h01;
			CH5TrigCfg <= 5'h01;
			decimator <= 4'h0;
			VIH <= 8'hAA;
			VIL <= 8'h55;
			matchH <= 8'h00;
			matchL <= 8'h00;
			maskH <= 8'h00;
			maskL <= 8'h00;
			baud_cntH <= 8'h06;
			baud_cntL <= 8'hC8;
			trig_posH <= 8'h00;
			trig_posL <= 8'h01;
		end
		else if(wrt_reg) begin
			CH1TrigCfg <= CH1TrigCfg_nxt;
			CH2TrigCfg <= CH2TrigCfg_nxt;
			CH3TrigCfg <= CH3TrigCfg_nxt;
			CH4TrigCfg <= CH4TrigCfg_nxt;
			CH5TrigCfg <= CH5TrigCfg_nxt;
			decimator <= decimator_nxt;
			VIH <= VIH_nxt;
			VIL <= VIL_nxt;
			matchH <= matchH_nxt;
			matchL <= matchL_nxt;
			maskH <= maskH_nxt;
			maskL <= maskL_nxt;
			baud_cntH <= baud_cntH_nxt;
			baud_cntL <= baud_cntL_nxt;
			trig_posH <= trig_posH_nxt;
			trig_posL <= trig_posL_nxt;
		end
	end
	
	always @ (*) begin	
		wrt_reg = 1'h0;
		send_resp = 1'h0;
		clr_cmd_rdy = 1'h0;
		resp = 8'h00;
		strt_rd = 1'h0;
		nxtstate = IDLE:
	
		case(state)
			IDLE: begin
				if(cmd_rdy) begin
					case(command)
					
						ReadReg : begin						//Command is to send back what is contained in the specified register. Set response equal to register, with padding, and send it
							send_resp = 1'h1;
							clr_cmd_rdy = 1'h1;
							nxtstate = IDLE;
							case(register) begin
								TrigCfg : resp = {2'h0, TrigCfg};
								
								CH1TrigCfg : resp = {3'h0, CH1TrigCfg};
								
								CH2TrigCfg : resp = {3'h0, CH2TrigCfg};
								
								CH3TrigCfg : resp = {3'h0, CH3TrigCfg};
								
								CH4TrigCfg : resp = {3'h0, CH4TrigCfg};
								
								CH5TrigCfg : resp = {3'h0, CH5TrigCfg};
								
								decimator : resp = {4'h0, decimator};
								
								VIH : resp = VIH;
								
								VIL : resp = VIL;
								
								matchH : resp = matchH;
								
								matchL : resp = matchL;
								
								maskH : resp = maskH;
								
								maskL : resp = maskL;
								
								baud_cntH : resp = baud_cntH;
								
								baud_cntL : resp = baud_cntL;
								
								trig_posH : resp = trig_posH;
								
								trig_posL : resp = trig_posL;
								
								default : begin //Sent bad register
									send_resp = 1'h1;
									clr_cmd_rdy = 1'h1;
									resp = 8'hEE;
									nxtstate = IDLE;
									$display("Sent a Bad Register");
								end
							endcase
						end
						
						WriteReg : begin //Command is a send command, set the ***_nxt line of the correct register to configure, if correct will send ack response and will update register on next clock cycle 
							wrt_reg = 1'h1;
							send_resp = 1'h1;
							resp = 8'hA5;
							clr_cmd_rdy = 1'h1;
							nxtstate = IDLE;
							
							case(register) begin
								TrigCfg : TrigCfg_nxt = data[5:0];
								
								CH1TrigCfg : CH1TrigCfg_nxt = data[4:0];
								
								CH2TrigCfg : CH2TrigCfg_nxt = data[4:0];
								
								CH3TrigCfg : CH3TrigCfg_nxt = data[4:0];
								
								CH4TrigCfg : CH4TrigCfg_nxt = data[4:0];
								
								CH5TrigCfg : CH5TrigCfg_nxt = data[4:0];
								
								decimator : decimator_nxt = data[3:0];
								
								VIH : VIH_nxt = data;
								
								VIL : VIL_nxt = data;
								
								matchH : matchH_nxt = data;
								
								matchL : matchL_nxt = data;
								
								maskH : maskH_nxt = data;
								
								maskL : maskL_nxt = data;
								
								baud_cntH : baud_cntH_nxt = data;
								
								baud_cntL : baud_cntL_nxt = data;
								
								trig_posH : trig_posH_nxt = data;
								
								trig_posL : trig_posL_nxt = data;
								
								default : begin //Sent bad register
									send_resp = 1'h1;
									clr_cmd_rdy = 1'h1;
									resp = 8'hEE;
									nxtstate = IDLE;
									$display("Sent a Bad Register");
								end
							endcase
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
						
						default : begin //Sent bad command
							send_resp = 1'h1;
							clr_cmd_rdy = 1'h1;
							resp = 8'hEE;
							nxtstate = IDLE;
							$display("Sent a Bad Command");
						end
					endcase
				end
			end
			
			DUMP : begin				//Direct selected channel into Response and send it if reading is not done
				case (ccc) begin
					CH1 : resp = rdataCH1;
					CH2 : resp = rdataCH2;
					CH3 : resp = rdataCH3;
					Ch4 : resp = rdataCH4;
					Ch5 : resp = rdataCH5;
					default : begin //Sent bad channel
						send_resp = 1'h1;
						clr_cmd_rdy = 1'h1;
						resp = 8'hEE;
						nxtstate = IDLE;
						%display("Sent a Bad Channel");
					end
				endcase
				
				if(rd_done) begin		//If reading is done then clr the command and move back to the waiting state
					clr_cmd_rdy = 1'h1;
					nxtstate = IDLE;
				end
				else begin				//Else send the response and move into waiting state
					send_resp = 1'h1;
					nxtstate = DUMP2;
				end
			end
			
			RESP : begin
				if(resp_sent)begin
					if(raddr == ENTRIES)
						raddr = 0;
			
			default : begin				//This should be impossible to get into, b/c two bits for state and four defined states
				send_resp = 1'h1;
				clr_cmd_rdy = 1'h1;
				resp = 8'hEE;
				nxtstate = IDLE;
				$display("Entered a Bad State");
			end
			
		endcase
	end
endmodule





















