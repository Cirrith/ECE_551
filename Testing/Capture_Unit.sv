/**************************************************************************************************
/	MODULE: Capture_Unit
/	PURPOSE: Take in the inputs and write the sample to all ramQueues every cycle, until triggered
/	
/	INPUTS:
/			clk - Clock
/			rst_n - Reset
/			wrt_smpl - To write a sample or not
/			triggered - 
/			TrigCfg [4:0] - 
/			trig_pos [15:0] - 
/	
/	OUTPUTS:
/			waddr - Write address
/			capture_done - Capture is done			
/			
/	INTERNAL:
/			armed - Should it take a trigger or not
/			run - Currently running
/			done - Is the device done
/			smpl_cnt [15:0] - Number of samples that
/			trig_cnt [15:0] - Number of samples that have occured after trigger
/			state - 
/			nxtstate - 
**************************************************************************************************/
module Capture_Unit(clk, rst_n, wrt_smpl, triggered, TrigCfg, trig_pos, waddr, capture_done, write, armed);
	
	parameter 	ENTRIES = 384,	// defaults to 384 for simulation, use 12288 for DE-0
			LOG2 = 9;		// Log base 2 of number of entries
	
	typedef enum logic [1:0] {IDLE, RUN, DONE} State;

	input clk;
	input rst_n;
	input wrt_smpl;
	input triggered;
	input [5:0] TrigCfg;
	input [15:0] trig_pos;
	
	output logic [LOG2-1:0] waddr;
	output logic capture_done;
	output logic write;
	output logic armed;
	
	State state;
	State nxtstate;
	
	logic run;
	logic done;
	logic [15:0] smpl_cnt;
	logic [15:0] trig_cnt;
	
	logic clr_waddr;
	logic inc_waddr;
	
	logic clr_smpl_cnt;
	logic inc_smpl_cnt;
	
	logic clr_trig_cnt;
	logic inc_trig_cnt;
	
	logic clr_armed;
	logic set_armed;
	
	assign run = TrigCfg[4];
	assign done = TrigCfg[5];
	
	always_ff @ (posedge clk, negedge rst_n) begin		//State
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxtstate;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin		//Write Address
		if(!rst_n)
			waddr <= 0;
		else if (clr_waddr)
			waddr <= 0;
		else if (inc_waddr)
			waddr <= waddr + 1;
		else
			waddr <= waddr;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin		//Sample Count
		if(!rst_n)
			smpl_cnt <= 0;
		else if (clr_smpl_cnt)
			smpl_cnt <= 0;
		else if (inc_smpl_cnt)
			smpl_cnt <= smpl_cnt + 1;
		else
			smpl_cnt <= smpl_cnt;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin 		//Trig Count
		if(!rst_n)
			trig_cnt <= 0;
		else if (clr_trig_cnt)
			trig_cnt <= 0;
		else if (inc_trig_cnt)
			trig_cnt <= trig_cnt + 1;
		else 
			trig_cnt <= trig_cnt;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin		//Armed
		if(!rst_n)
			armed <= 0;
		else if (clr_armed)
			armed <= 0;
		else if (set_armed)
			armed <= 1;
		else 
			armed <= armed;
	end
	
	always_comb begin
		capture_done = 0;
		inc_smpl_cnt = 0;
		clr_smpl_cnt = 0;
		inc_trig_cnt = 0;
		clr_trig_cnt = 0;
		inc_waddr = 0;	
		clr_waddr = 0;
		clr_armed = 0;
		set_armed = 0;
		write = 0;
		nxtstate = IDLE;
		
		case(state)
			IDLE : begin
				if (run) begin
					clr_smpl_cnt = 1;
					clr_trig_cnt = 1;
					nxtstate = RUN;
				end
				else
					nxtstate = IDLE;
			end
	
			RUN : begin
				nxtstate = RUN;
				if(wrt_smpl) begin
					if(triggered & (trig_cnt == trig_pos)) begin
						capture_done = 1;
						clr_armed = 1;
						nxtstate = DONE;
					end
					else begin 
						write = 1;
						if(waddr == (ENTRIES - 1))
							clr_waddr = 1;
						else
							inc_waddr = 1;
	
						if (triggered) begin
							inc_trig_cnt = 1;
						end
						else begin
							inc_smpl_cnt = 1;
							if ((smpl_cnt + trig_pos) >= ENTRIES)
								set_armed = 1;
						end
					end
				end
			end
			
			DONE : begin
				if(done)
					nxtstate = DONE;
				else if (run) begin 
					clr_smpl_cnt = 1;
					clr_trig_cnt = 1;
					nxtstate = RUN;
				end
				else
					nxtstate = IDLE;
			end
		endcase
	end
endmodule