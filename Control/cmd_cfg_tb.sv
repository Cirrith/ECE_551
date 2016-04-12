/**************************************************************************************************
/
/
/
/
/
/
/
**************************************************************************************************/
module cmd_cfg_tb();
	
	typedef logic [1:0] {ReadReg, WriteReg, Dump} Command;
	typedef logic [2:0] {CH1, CH2, CH3, Ch4, Ch5} Channel;
	typedef logic [5:0] {TrigCfg, CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, decimator, VIH, VIL, matchH, matchL, maskH, maskL, baud_cntH, baud_cntL, trig_posH, trig_posL} Register;
	
	logic clk;
	logic rst_n;

	logic [15:0] cmd;
	logic cmd_rdy;
	logic resp_sent;
	logic rd_done;
	logic set_capture_done;

	logic [7:0] rdataCH1;
	logic [7:0] rdataCH2;
	logic [7:0] rdataCH3;
	logic [7:0] rdataCH4;
	logic [7:0] rdataCH5;

	logic [7:0] resp;
	logic send_resp;
	logic clr_cmd_rdy;
	logic strt_rd;
	logic [LOG2-1:0] trig_pos;

	logic [3:0] decimator;
	logic [7:0] maskL;
	logic [7:0] maskH;
	logic [7:0] matchL;
	logic [7:0] matchH;
	logic [7:0] baud_cntL;
	logic [7:0] baud_cntH;
	logic [7:0] TrigCfg;
	logic [7:0] CH1TrigCfg;
	logic [7:0] CH2TrigCfg;
	logic [7:0] CH3TrigCfg;
	logic [7:0] CH4TrigCfg;
	logic [7:0] CH5TrigCfg;
	logic [7:0] trig_posH;
	logic [7:0] trig_posL;
	logic [7:0] VIH;
	logic [7:0] VIL;
	
	Command command;
	Register register;
	Channel ccc;

	initial begin		//Reset and initial clk setup
		clk = 0;
		rst_n = 0;
		repeat(2) @(negedge clk);
		rst_n = 1;
	end
	
	always				//Clock generation
		#5 clk = ~clk;

	cmd_cfg DUT (
			.clk(clk),
			.rst_n(rst_n),
			.cmd(cmd),
			.cmd_rdy(cmd_rdy),
			.resp_sent(resp_sent),
			.rd_done(rd_done),
			.set_capture_done(set_capture_done),
			.rdataCH1(rdataCH1),
			.rdataCH2(rdataCH2),
			.rdataCH3(rdataCH3),
			.rdataCH4(rdataCH4),
			.rdataCH5(rdataCH5),
			.resp(resp),
			.send_resp(send_resp),
			.clr_cmd_rdy(clr_cmd_rdy),
			.strt_rd(strt_rd),
			.trig_pos(trig_pos),
			.decimator(decimator),
			.maskL(maskL),
			.maskH(maskH),
			.matchL(matchL),
			.matchH(matchH),
			.baud_cntL(baud_cntL),
			.baud_cntH(baud_cntH),
			.TrigCfg(TrigCfg),
			.CH1TrigCfg(CH1TrigCfg),
			.CH2TrigCfg(CH2TrigCfg),
			.CH3TrigCfg(CH3TrigCfg),
			.CH4TrigCfg(CH4TrigCfg),
			.CH5TrigCfg(CH5TrigCfg),
			.trig_posH(trig_posH),
			.trig_posL(trig_posL),
			.VIH(VIL),
			.VIL(VIL));
		
	initial begin		//Main Testbench Logic
		@(posedge rst_n); //This will occur at a negedge of clk
		
endmodule