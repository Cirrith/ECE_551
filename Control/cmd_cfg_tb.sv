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
	
	parameter LOG2 = 9;
	parameter ENTRIES = 384;
	
	typedef enum logic [1:0] {ReadReg, WriteReg, Dump} Command;
	typedef enum logic [2:0] {CH1, CH2, CH3, Ch4, Ch5} Channel;
	typedef enum logic [5:0] {TrigCfg_Reg, CH1TrigCfg_Reg, CH2TrigCfg_Reg, CH3TrigCfg_Reg, CH4TrigCfg_Reg, CH5TrigCfg_Reg, decimator_Reg, VIH_Reg, VIL_Reg, matchH_Reg, matchL_Reg, maskH_Reg, maskL_Reg, baud_cntH_Reg, baud_cntL_Reg, trig_posH_Reg, trig_posL_Reg} Register;
	
	/////***** cmd_cfg Variables *****\\\\\
	
	logic clk;
	logic rst_n;

	logic [15:0] cmd;
	logic cmd_rdy;
	logic resp_sent;
	logic set_capture_done;

	logic [LOG2-1:0] waddr;

	logic [7:0] resp;
	logic send_resp;
	logic clr_cmd_rdy;
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
	logic [7:0] VIH;
	logic [7:0] VIL;
	
	/////***** Testbench Variables *****\\\\\
	
	logic [7:0] Mem [0:383];
	logic [7:0] Read_Data [4:0];
	logic [LOG2-1:0] raddr;
	logic [7:0] Data;
	logic [7:0] Comp;
	logic [7:0] ACK = 8'hA5;
	logic [7:0] NAK = 8'hEE;
	logic [LOG2-1:0] i;
	logic set_cmd_rdy;
	
	logic [7:0] reg_retur; //Expected value to be returned in a read
	
	Command Cmd;
	Register Reg;
	Channel CCC;

	cmd_cfg DUT (
			.clk(clk),
			.rst_n(rst_n),
			.cmd(cmd),
			.cmd_rdy(cmd_rdy),
			.resp_sent(resp_sent),
			.set_capture_done(set_capture_done),
			.waddr(waddr),
			.rdataCH1(Read_Data[0]),
			.rdataCH2(Read_Data[1]),
			.rdataCH3(Read_Data[2]),
			.rdataCH4(Read_Data[3]),
			.rdataCH5(Read_Data[4]),
			.raddr(raddr),
			.resp(resp),
			.send_resp(send_resp),
			.clr_cmd_rdy(clr_cmd_rdy),
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
			.VIH(VIH),
			.VIL(VIL));
	
	RAMqueue ram [4:0] (.clk(clk), .we(1'h0), .waddr(9'h000), .wdata(8'h00), .raddr(raddr), .rdata(Read_Data)); //Default Size (ENTRIES = 384, Data Width = 8, LOG2 = 9)
	
	initial begin		//Reset and initial clk setup
		rst_n = 1'h0;
		$readmemh("RAMData.txt", Mem);
		ram[0].mem = Mem;
		ram[1].mem = Mem;
		ram[2].mem = Mem;
		ram[3].mem = Mem;
		ram[4].mem = Mem;
		waddr = 9'h000;
		
		clk = 1;
		resp_sent = 1'h0;
		set_capture_done = 1'h0;
		repeat(2) @(negedge clk);
		rst_n = 1;
	end
	
	always				//Clock generation
		#5 clk = ~clk;
	
	always_comb begin
		case(Reg)		//What what is expected from read
			TrigCfg_Reg 			: begin reg_retur = {2'h0, TrigCfg}; 		Comp = {2'h0, Data[5:0]}; end
			CH1TrigCfg_Reg 	: begin reg_retur = {3'h0, CH1TrigCfg}; 	Comp = {3'h0, Data[4:0]}; end
			CH2TrigCfg_Reg 	: begin reg_retur = {3'h0, CH2TrigCfg}; 	Comp = {3'h0, Data[4:0]}; end
			CH3TrigCfg_Reg 	: begin reg_retur = {3'h0, CH3TrigCfg}; 	Comp = {3'h0, Data[4:0]}; end
			CH4TrigCfg_Reg 	: begin reg_retur = {3'h0, CH4TrigCfg}; 	Comp = {3'h0, Data[4:0]}; end
			CH5TrigCfg_Reg 	: begin reg_retur = {3'h0, CH5TrigCfg}; 	Comp = {3'h0, Data[4:0]}; end
			decimator_Reg 		: begin reg_retur = {4'h0, decimator}; 	Comp = {4'h0, Data[3:0]}; end
			VIH_Reg 				: begin reg_retur = VIH; 						Comp = Data; end
			VIL_Reg 				: begin reg_retur = VIL; 						Comp = Data; end
			matchH_Reg 			: begin reg_retur = matchH; 					Comp = Data; end
			matchL_Reg 			: begin reg_retur = matchL; 					Comp = Data; end
			maskH_Reg 			: begin reg_retur = maskH; 					Comp = Data; end
			maskL_Reg 			: begin reg_retur = maskL; 					Comp = Data; end
			baud_cntH_Reg 		: begin reg_retur = baud_cntH; 				Comp = Data; end
			baud_cntL_Reg 		: begin reg_retur = baud_cntL; 				Comp = Data; end
			trig_posH_Reg 		: begin reg_retur = trig_pos[15:8]; 			Comp = Data; end
			trig_posL_Reg 		: begin reg_retur = trig_pos[7:0]; 			Comp = Data; end
		endcase	
	end
	
	initial begin		//Main Testbench Logic
		@(posedge rst_n); //This will occur at a negedge of clk
		
		//Random Portion of Testbench
		repeat(16) begin
			Cmd = '{$urandom_range(2,0)}; 		//Generate random valid command between 0 and 2
			Reg = '{$urandom_range(16,0)};		//Generate random valid register for operation
			Data = $urandom_range(255,0); 	//Generate random data to write in
			CCC = '{$urandom_range(5,1)};		//Generate random channel for dump commands		
			
			if(Cmd == ReadReg | Cmd == WriteReg) begin
				cmd = {Cmd, Reg, Data}; //2 Bits + 6 Bits + 8 Bits = 16 bits. Data doesn't matter for read
			end
			else if (Cmd == Dump) begin //This is going to be complex
				cmd = {Cmd, 3'h0, CCC, 8'h00};
			end
			
			@(negedge clk);
			
			$display("Entered Fork %t", $time);
			
			fork : Forky
				begin : timeout
					repeat (50000) @(negedge clk);
					$display("50000 ns, that is quite a many, check Cmd else their moduel");
					$stop;
				end
				
				begin
					cmd_rdy = 1'h1;
					//$display("Cmd Rdy at %t", $time);
					#10;
					//$display("Cmd Low at %t", $time);
					cmd_rdy = 1'h0;
				end
				
				begin
					if(Cmd == ReadReg) begin
						$display("Got into ReadReg");
						@(posedge send_resp);
						@(posedge clk);
						@(negedge clk);
						if(resp != reg_retur) begin
							$display("A read messed up. Trying to read Register %s", Reg);
							$stop;
						end
						$display("Read Successful");
						disable Forky;
					end
				end
				
				begin
					if (Cmd == WriteReg) begin
						$display("Got into WriteReg @ time %t", $time);
						@(posedge send_resp);
						@(posedge clk);
						@(negedge clk);
						$display("Trigger resp");
						if((resp != ACK) | (reg_retur != Comp)) begin
							$display("A write messed up. Trying to write Regsiter %s", Reg);
							$stop;
						end
						$display("Write Successful, @ %t", $time);
						disable Forky;
					end
				end
				
				begin
					if (Cmd == Dump) begin
						i = waddr;
						repeat(ENTRIES) begin
							$display("Got into Dump @ %t", $time);
							@(posedge send_resp);
							if(resp != Mem[i]) begin
								$display("A Dump messed up. Tring to access address %d", i);
								$stop;
							end
							if(i == ENTRIES-1)
								i = 0;
							else
								i = i + 1;
								
							repeat (20) @(negedge clk); //Wait 20 clock cycles for 'transmitting'
							resp_sent = 1'h1;
							@(negedge clk);
							resp_sent = 1'h0;
						end
						$display("Dump Successful");
						disable Forky;
					end
				end
			join
			@(negedge clk);
			cmd_rdy = 1'h0;
			$display("Exit Fork at %t", $time);
			repeat (2) @ (negedge clk);
		end
		$stop;
	end
		
endmodule