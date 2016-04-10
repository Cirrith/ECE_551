/**************************************************************************************************
	MODULE: cmd_cfg
	PURPOSE: Take in the transmitted command and perform it.
	
	INPUTS:
			clk - Clock
			rst_n - Reset
			cmd [15:0] - Command to execute
			cmd_rdy - Recieved a command
			resp_sent - Respone was sent via UART
			rd_done - Last bye of smaple data has been read
			set_capture_done - Capture is complete
			rdataCH1 [7:0] - Data read from channel 1
			rdataCH2 [7:0] - Data read from channel 2
			rdataCH3 [7:0] - Data read from channel 3
			rdataCH4 [7:0] - Data read from channel 4
			rdataCH5 [7:0] - Data read from channel 5
			
	OUPUTS:
			resp [7:0] - Response to send via UART
			send_resp - Send Response
			clr_cmd_rdy - 
			strt_rd - 
			trig_pos - 
			TrigCfg [5:0] - 
			CH1TrigCfg [4:0] - 
			CH2TrigCfg [4:0] - 
			CH3TrigCfg [4:0] - 
			CH4TrigCfg [4:0] - 
			CH5TrigCfg [4:0] - 
			decimator [3:0] - 
			VIH [7:0] - 
			VIL [7:0] - 
			matchH [7:0] - 
			matchL [7:0] - 
			maskH [7:0] - 
			maskL [7:0] - 
			baud_cntH [7:0] - 
			baud_cntL [7:0] - 
			trig_posH [7:0] - 
			trig_posL [7:0] - 			
	
	INTERNAL:
			command - What kind of command should executed
			register - Which register should the command be done on
			ccc - Which channel should be read
			wrt_reg - Whether to write the register or not
			TrigCfg_nxt - 
			CH1TrigCfg_nxt - 
			CH2TrigCfg_nxt - 
			CH3TrigCfg_nxt - 
			CH4TrigCfg_nxt - 
			CH5TrigCfg_nxt - 
			decimator_nxt - 
			VIH_nxt - 
			VIL_nxt - 
			matchH_nxt - 
			matchL_nxt - 
			maskH_nxt - 
			maskL_nxt - 
			baud_cntH_nxt - 
			baud_cntL_nxt - 
			trig_posH_nxt - 
			trig_posL_nxt - 
**************************************************************************************************/

module cmd_cfg ();

	typedef logic [1:0] {ReadReg, WriteReg, Dump, Reserved} Command;
	typedef logic [2:0] {CH1, CH2, CH3, Ch4, Ch5} Channel;
	typedef logic [5:0] {TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, decimator, VIH, VIL, matchH, matchL, maskH, maskL, baud_cntH, baud_cntL, trig_posH, trig_posL} Register;
	typedef logic ????? {IDLE, SEND, DUMP} State
	
	input clk;
	input rst_n;

	input [15:0] cmd;
	input cmd_rdy;
	input resp_sent;
	input rd_done;
	input set_capture_done;

	input [7:0] rdataCH1;
	input [7:0] rdataCH2;
	input [7:0] rdataCH3;
	input [7:0] rdataCH4;
	input [7:0] rdataCH5;

	output [7:0] resp;
	output send_resp;
	output clr_cmd_rdy;
	output strt_rd;
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
	
	logic TrigCfg [5:0];
	logic CH1TrigCfg [4:0];
	logic CH2TrigCfg [4:0];
	logic CH3TrigCfg [4:0];
	logic CH4TrigCfg [4:0];
	logic CH5TrigCfg [4:0];
	logic decimator [3:0];
	logic VIH [7:0];
	logic VIL [7:0];
	logic matchH [7:0];
	logic matchL [7:0];
	logic maskH [7:0];
	logic maskL [7:0];
	logic baud_cntH [7:0];
	logic baud_cntL [7:0];
	logic trig_posH [7:0];
	logic trig_posL [7:0];
	
	logic wrt_reg;
	logic TrigCfg_nxt;
	logic CH1TrigCfg_nxt;
	logic CH2TrigCfg_nxt;
	logic CH3TrigCfg_nxt;
	logic CH4TrigCfg_nxt;
	logic CH5TrigCfg_nxt;
	logic decimator_nxt;
	logic VIH_nxt;
	logic VIL_nxt;
	logic matchH_nxt;
	logic matchL_nxt;
	logic maskH_nxt;
	logic maskL_nxt;
	logic baud_cntH_nxt;
	logic baud_cntL_nxt;
	logic trig_posH_nxt;
	logic trig_posL_nxt;
	
	assign command = cmd[15:14];
	assign register = cmd[13:8];
	assign data = cmd[7:0];
	assign ccc = cmd[2:0];
	
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
	
	case(state)
	
		IDLE: begin
		
	
		case(command)
			ReadReg : begin
				send_resp = 1'h1;
				
				case(register) begin
					TrigCfg : begin
						resp = TrigCfg;
					end
					
					CH1TrigCfg : begin
						resp = CH1TrigCfg;
					end
					
					CH2TrigCfg : begin
						resp = CH2TrigCfg;
					end
					
					CH3TrigCfg : begin
						resp = CH3TrigCfg;
					end
					
					CH4TrigCfg : begin
						resp = CH4TrigCfg;
					end
					
					CH5TrigCfg : begin
						resp = CH5TrigCfg;
					end
					
					decimator : begin
						resp = decimator;
					end
					
					VIH : begin
						resp = VIH;
					end
					
					VIL : begin
						resp = VIL;
					end
					
					matchH : begin
						resp = matchH;
					end
					
					matchL : begin
						resp = matchL;
					end
					
					maskH : begin
						resp = maskH;
					end
					
					maskL : begin
						resp = maskL;
					end
					
					baud_cntH : begin
						resp = baud_cntH;
					end
					
					baud_cntL : begin
						resp = baud_cntL;
					end
					
					trig_posH : begin
						resp = trig_posH;
					end
					
					trig_posL : begin
						resp = trig_posL;
					end
				endcase
			end
			
			WriteReg : begin
				wrt_reg = 1'h1;
				
				case(register) begin
					TrigCfg : begin
						TrigCfg_nxt = data;
					end
					
					CH1TrigCfg : begin
						CH1TrigCfg_nxt = data;
					end
					
					CH2TrigCfg : begin
						CH2TrigCfg_nxt = data;
					end
					
					CH3TrigCfg : begin
						CH3TrigCfg_nxt = data;
					end
					
					CH4TrigCfg : begin
						CH4TrigCfg_nxt = data;
					end
					
					CH5TrigCfg : begin
						CH5TrigCfg_nxt = data;
					end
					
					decimator : begin
						decimator_nxt = data;
					end
					
					VIH : begin
						VIH_nxt = data;
					end
					
					VIL : begin
						VIL_nxt = data;
					end
					
					matchH : begin
						matchH_nxt = data;
					end
					
					matchL : begin
						matchL_nxt = data;
					end
					
					maskH : begin
						maskH_nxt = data;
					end
					
					maskL : begin
						maskL_nxt = data;
					end
					
					baud_cntH : begin
						baud_cntH_nxt = data;
					end
					
					baud_cntL : begin
						baud_cntL_nxt = data;
					end
					
					trig_posH : begin
						trig_posH_nxt = data;
					end
					
					trig_posL : begin
						trig_posL_nxt = data;
					end
				endcase
			end
			
			Dump : begin
				case(channel) begin					
					CH1 : begin
						resp = 
					end
					
					CH2 : begin
						resp = 
					end
					
					CH3 : begin
						resp = 
					end
					
					CH4 : begin
						resp = 
					end
					
					CH5 : begin
						resp = 
					end
				endcase
			end
			
			Reserved : begin
			
			end
		endcase
	end
	
endmodule