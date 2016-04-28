module dig_core_tb();
	
	dig_core core (
		clk(clk),
		rst_n(rst_n),
		smpl_clk(smpl_clk),
		wrt_smpl(wrt_smpl), 
		decimator(decimator), 
		VIH(VIH), 
		VIL(VIL), 
		CH1L(CH1L), 
		CH1H(CH1H),
		CH2L(CH2L),
		CH2H(CH2H),
		CH3L(CH3L),
		CH3H(CH3H),
		CH4L(CH4L),
		CH4H(CH4H),
		CH5L(CH5L),
		CH5H(CH5H),
		cmd(cmd),
		cmd_rdy(cmd_rdy),
		clr_cmd_rdy(clr_cmd_rdy),
		resp(resp),
		send_resp(send_resp),
		resp_sent(resp_sent),
		LED(LED),
		we(we),
		waddr(waddr),
		raddr(raddr),
		wdataCH1(wdataCH1),
		wdataCH2(wdataCH2),
		wdataCH3(wdataCH3),
		wdataCH4(wdataCH4),
		wdataCH5(wdataCH5),
		rdataCH1(rdataCH1),
		rdataCH2(rdataCH2),
		rdataCH3(rdataCH3),
		rdataCH4(rdataCH4),
		rdataCH5(rdataCH5));
	
	logic clk;
	logic rst_n;
	logic smpl_clk;
	logic wrt_smpl;
	logic decimator;
	logic [7:0] VIH;
	logic [7:0] VIL;
	logic CH1L;
	logic CH1H;
	logic CH2L;
	logic CH2H;
	logic CH3L;
	logic CH3H;
	logic CH4L;
	logic CH4H;
	logic CH5L;
	logic CH5H;
	logic [15:0] cmd;
	logic cmd_rdy;
	logic clr_cmd_rdy;
	logic [7:0] resp;
	logic send_resp;
	logic resp_sent;
	logic LED;
	logic we;
	logic [LOG2-1:0] waddr;
	logic [LOG2-1:0] raddr;
	logic [7:0] wdataCH1;
	logic [7:0] wdataCH2;
	logic [7:0] wdataCH3;
	logic [7:0] wdataCH4;
	logic [7:0] wdataCH5;
	logic [7:0] rdataCH1;
	logic [7:0] rdataCH2;
	logic [7:0] rdataCH3;
	logic [7:0] rdataCH4;
	logic [7:0] rdataCH5;
	
	
	
	task Initialize

	endtask

	task SendCmd

	endtask

	task ChkResp

	endtask

	task PollCapDone

	endtask

	task RcvDump

	endtask

endmodule