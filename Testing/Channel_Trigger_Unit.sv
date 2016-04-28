/**************************************************************************************************
	MODULE: Channel_Trigger_Unit
	PURPOSE: Determine if a specific channel has triggered
	
	INPUTS:
			clk - 
			rst_n - 
			CHxTrigCfg [7:0] - 
			CHxHff5 - 
			CHxLff5 - 
			armed - 
	
	OUTPUTS:
			CHxTrig - 
	
	INTERNAL:
			Pos_Edge [1:0] - Pos_Edge[1] is oldest
			Neg_Edge [1:0] - Neg_Edge[1] is oldest
			High_Level - 
			Low_Level - 
			Low_Level_Trig - 
			High_Level_Trig - 
			Neg_Edge_Trig - 
			Pos_Edge_Trig - 
**************************************************************************************************/
module Channel_Trigger_Unit(clk, rst_n, CHxTrigCfg, CHxHff5, CHxLff5, armed, CHxTrig);
	
	input clk;
	input rst_n;
	input [4:0] CHxTrigCfg;
	input CHxHff5;
	input CHxLff5;
	input armed;
	
	output CHxTrig;
	
	logic [1:0] Pos_Edge;
	logic [1:0] Neg_Edge;
	
	logic High_Level;
	logic Low_Level;
	
	logic Low_Level_Trig;
	logic High_Level_Trig;
	logic Neg_Edge_Trig;
	logic Pos_Edge_Trig;
	
	assign CHxTrig = Low_Level_Trig | High_Level_Trig | Neg_Edge_Trig | Pos_Edge_Trig | CHxTrigCfg[0];
	
	assign Low_Level_Trig = !Low_Level & CHxTrigCfg[1];
	assign High_Level_Trig = High_Level & CHxTrigCfg[2];
	assign Neg_Edge_Trig = Neg_Edge[1] & CHxTrigCfg[3];
	assign Pos_Edge_Trig = Pos_Edge[1] & CHxTrigCfg[4];
	
	always_ff @ (posedge clk, negedge rst_n) begin		//High and Low Level flip-flops
		if(!rst_n) begin
			High_Level <= 0;
			Low_Level <= 0;
		end
		else begin
			High_Level <= CHxHff5;
			Low_Level <= CHxLff5;
		end
	end
	
	always_ff @ (posedge CHxHff5, negedge rst_n, negedge armed) begin		//Edge triggered 1st flip-flop High
		if(!rst_n)
			Pos_Edge[0] <= 0;
		else if (!armed)
			Pos_Edge[0] <= 0;
		else
			Pos_Edge[0] <= 1;
	end
	
	always_ff @ (negedge CHxLff5, negedge rst_n, negedge armed) begin		//Edge triggered 1st flip-flop Low
		if(!rst_n)
			Neg_Edge[0] <= 0;
		else if (!armed)
			Neg_Edge <= 0;
		else
			Neg_Edge[0] <= 1;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin		//Edge triggered 2nd flip-flops
		if(!rst_n) begin
			Pos_Edge[1] <= 0;
			Neg_Edge[1] <= 0;
		end
		else begin
			Pos_Edge[1] <= Pos_Edge[0];
			Neg_Edge[1] <= Neg_Edge[0];
		end
	end
	
endmodule