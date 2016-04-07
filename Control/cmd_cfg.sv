/**************************************************************************************************
	MODULE: cmd_cfg
	PURPOSE:
	
	INPUTS:
	
	OUPUTS:
	
	INTERNAL:
**************************************************************************************************/

module cmd_cfg ();

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
	output logic [7:0] VIH;
	output logic [7:0] VIL;

	typedef logic [1:0] {ReadReg, WriteReg, Dump, Reserved} Command;

	Command command;

	assign command = cmd[15:14];

	always 
		case(command)
			ReadReg : begin
			
			end
			
			WriteReg : begin
			
			end
			
			Dump : begin
			
			end
			
			Reserved : begin
			
			end
		endcase
	end

endmodule

Register file
Take in Command

RAM queue read from cmd_cfg and wrote from command block

Each channel gets two bits of information, need to double flop channels for metastability