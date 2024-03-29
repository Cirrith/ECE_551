	
	logic [7:0] Mem_Rec [ENTRIES-1:0];
	logic [7:0] Mem_Copy [ENTRIES-1:0];
	logic [LOG2-1:0] Address;
	integer dump_file;
	
	task Initialize;
		UART_triggering = 0;
		SPI_triggering = 0;
		
		UART_Start = 0;
		UART_Data = 0;
		
		SPI_Start = 0;
		SPI_Pos_Edge = 0;
		SPI_Width8 = 0;
		SPI_Data = 0;
		
		Tran_Cmd = 0; //16 Bit Command
		Send_Cmd = 0; //Yes or no
		Clr_Rec_Rdy = 0;
		
		Address = 0;
		
		RST_n = 0;
		repeat(2) @(negedge REF_CLK);
		//@(posedge locked);
		RST_n = 1;
	endtask

	task SendCmd (input Command Cmd, input Register Reg, input [7:0] Data, input Channel Chan, output [7:0] Status);
		if(Cmd == ReadReg) begin
			Tran_Cmd = {2'h0, Reg, 8'h00};
		end else if(Cmd == WriteReg) begin
			Tran_Cmd = {2'h1, Reg, Data};
		end else if(Cmd == Dump) begin
			Tran_Cmd = {2'h2, 3'h0, Chan, 8'h00};
			Address = DUT.waddr;
			
			if (Chan == CH1) begin //Make a copy of the memory to be send
				Mem_Copy = DUT.iRAMCH1.mem;
				$display("Copied RAM 1");
			end else if (Chan == CH2) begin
				$display("Copied RAM 2");
				Mem_Copy = DUT.iRAMCH2.mem; 
			end else if (Chan == CH3) begin
				$display("Copied RAM 3");
				Mem_Copy = DUT.iRAMCH3.mem; 
			end else if (Chan == CH4) begin
				$display("Copied RAM 4");
				Mem_Copy = DUT.iRAMCH4.mem; 
			end else if (Chan == CH5) begin
				$display("Copied RAM 5");
				Mem_Copy = DUT.iRAMCH5.mem; 
			end else begin
				$display("Entered Bad Channel");
				$stop;
			end
		end
		else
			$display("Bad command Entered");
		@(negedge clk);
		Send_Cmd = 1;
		@(negedge clk);
		Send_Cmd = 0;

		fork : captainFork
			begin 
				repeat(10000) @(negedge clk);
				$display("10000 Cycles to send is quite a while");
				$stop;
			end
			
			begin
				@(posedge Cmd_Cmplt);
				//$display("Command Sent at %t", $time);
				disable captainFork;
			end
		join
		
		if ((Cmd == ReadReg) | (Cmd == WriteReg)) begin
			ChkResp (Cmd, Reg, Data, Status);
		end	else begin
			RcvDump(Chan);
		end
	endtask

	task ChkResp (input Command Cmd, input Register Reg, input [7:0] Data, output [7:0] Status);	//Caleld by SendCmd
		repeat(2) @(negedge clk);
		fork : mrforky
			begin
				repeat(10000) @(negedge clk);
				$display("10000 Cycles on a response is quite a while");
				$stop;
			end
			
			begin
				@(posedge Rec_Rdy);
				//$display("Command Received at %t", $time);
				disable mrforky;
			end		
		join
		
		if(Cmd == ReadReg) begin
			if(Rec_Data == NCK) begin
				$display("Read Failure");
				$stop;
			end else begin
				//$display("Read %h from Register %s", Rec_Data, Reg);
				Status = Rec_Data;
			end
		end else if (Cmd == WriteReg) begin
			if(Rec_Data == ACK) begin
				case(Reg) //Make sure it acctually wrote
					TrigCfg_Reg : 		if(Data != {2'h0, DUT.iDIG.TrigCfg}) begin $display("Didn't Write, Start?"); end
					CH1TrigCfg_Reg : 	if(Data != {3'h0, DUT.iDIG.CH1TrigCfg}) begin $display("Didn't Write"); $stop; end
					CH2TrigCfg_Reg : 	if(Data != {3'h0, DUT.iDIG.CH2TrigCfg}) begin $display("Didn't Write"); $stop; end
					CH3TrigCfg_Reg : 	if(Data != {3'h0, DUT.iDIG.CH3TrigCfg}) begin $display("Didn't Write"); $stop; end
					CH4TrigCfg_Reg : 	if(Data != {3'h0, DUT.iDIG.CH4TrigCfg}) begin $display("Didn't Write"); $stop; end
					CH5TrigCfg_Reg : 	if(Data != {3'h0, DUT.iDIG.CH5TrigCfg}) begin $display("Didn't Write"); $stop; end
					decimator_Reg : 	if(Data != {4'h0, DUT.iDIG.decimator}) begin $display("Didn't Write"); $stop; end
					VIH_Reg : 			if(Data != {DUT.iDIG.VIH}) begin $display("Didn't Write"); $stop; end
					VIL_Reg : 			if(Data != {DUT.iDIG.VIL}) begin $display("Didn't Write"); $stop; end
					matchH_Reg : 		if(Data != {DUT.iDIG.matchH}) begin $display("Didn't Write"); $stop; end
					matchL_Reg : 		if(Data != {DUT.iDIG.matchL}) begin $display("Didn't Write"); $stop; end
					maskH_Reg : 		if(Data != {DUT.iDIG.maskH}) begin $display("Didn't Write"); $stop; end
					maskL_Reg : 		if(Data != {DUT.iDIG.maskL}) begin $display("Didn't Write"); $stop; end
					baud_cntH_Reg : 	if(Data != {DUT.iDIG.baud_cntH}) begin $display("Didn't Write"); $stop; end
					baud_cntL_Reg : 	if(Data != {DUT.iDIG.baud_cntL}) begin $display("Didn't Write"); $stop; end
					trig_posH_Reg : 	if(Data != {DUT.iDIG.cmd_unit.trig_posH}) begin $display("Didn't Write"); $stop; end
					trig_posL_Reg : 	if(Data != {DUT.iDIG.cmd_unit.trig_posL}) begin $display("Didn't Write"); $stop; end
				endcase
				
				Status = 1;
				
			end else if (Rec_Data == NCK) begin
				$display("Write Failed");
				$stop;
			end else begin
				$display("Unexpected Response, %h", Rec_Data);
				$stop;
			end
		end else begin
			$display("You should probably not be here");
			$stop;
		end
	endtask
	
	task PollCapDone(output [7:0] Status);		//Called by Start
		fork : sailorforky
			forever begin
				SendCmd(Command'(ReadReg), Register'(TrigCfg_Reg), {2'h0, (DUT.iDIG.TrigCfg & ~6'h30)}, '{ERR}, Status);
		
				if(Rec_Data[5] == 1) begin
					$display("Capture Done");
					Clr_Rec_Rdy = 1;
					@(negedge clk);
					Clr_Rec_Rdy = 0;
					disable sailorforky;
				end else begin
					Clr_Rec_Rdy = 1;
					@(negedge clk);
					Clr_Rec_Rdy = 0;
				end
			end
			
			begin				//Timeout
				repeat(100000) @(negedge clk);
				$display("100000 Cycles is quite a while for a Capture");
				$stop;
			end
		join
		SendCmd(Command'(ReadReg), Register'(TrigCfg_Reg), {2'h0, (DUT.iDIG.TrigCfg & ~6'h30)}, '{ERR}, Status);
	endtask
	
	task RcvDump(input Channel Chan); //Called by SendCmd
		integer i;
		fork : senorforky
			begin				//Receive data. See if there is a better way than a for loop
				for(i = 0; i < ENTRIES; i = i + 1) begin
					//$display("%d", i);
					@(posedge Rec_Rdy);
					Mem_Rec[i] = Rec_Data;
					@(posedge clk);
					@(negedge clk);
					Clr_Rec_Rdy = 1;
					@(negedge clk);
					Clr_Rec_Rdy = 0;		
				end
				disable senorforky;
			end
			
			begin				//Timeout for making a recieve
				repeat(10000000) @(negedge clk);
				$display("Errored out when recieving a DUMP, heh, dump");
				$stop;
			end
		join
		
		if (Chan == CH1) begin //Check to make sure RAM wasn't changed
			if (Mem_Copy != DUT.iRAMCH1.mem) begin
				$display("There were changes made to the memory");
				$stop;
			end
			dump_file = $fopen("CH1dmp.txt","w");
		end else if (Chan == CH2) begin
			if (Mem_Copy != DUT.iRAMCH2.mem) begin
				$display("There were changes made to the memory");
				$stop;
			end
			dump_file = $fopen("CH2dmp.txt","w");
		end else if (Chan == CH3) begin
			if (Mem_Copy != DUT.iRAMCH3.mem) begin
				$display("There were changes made to the memory");
				$stop;
			end
			dump_file = $fopen("CH3dmp.txt","w");
		end else if (Chan == CH4) begin
			if (Mem_Copy != DUT.iRAMCH4.mem) begin
				$display("There were changes made to the memory");
				$stop;
			end
			dump_file = $fopen("CH4dmp.txt","w");
		end else if (Chan == CH5) begin
			if (Mem_Copy != DUT.iRAMCH5.mem) begin
				$display("There were changes made to the memory");
				$stop;
			end
			dump_file = $fopen("CH5dmp.txt","w");
		end else begin
			$display("Entered Bad Channel");
			$stop;
		end
		
		$display("Checked RAM %d", Chan);
		
		for (i = 0; i < ENTRIES; i = i + 1) begin //Check that it send the right data
			//$display("%d", i);
			if(Mem_Rec[i] != Mem_Copy[Address]) begin
				$display("Dump Recieved did not match up");
				$stop;
			end
			$fwrite(dump_file, "%h\n", Mem_Rec[i]);
			if(Address == ENTRIES-1) begin
				Address = 0;
			end else begin
				Address = Address + 1;
			end
		end
	endtask
	
	task Start(output [7:0] Status);
		repeat(2) @(negedge clk);
		
		SendCmd(Command'(WriteReg), Register'(TrigCfg_Reg),  {2'h0, DUT.iDIG.TrigCfg | 6'h10} , Channel'(ERR), Status);
		if(UART_triggering) begin
			UART_Start = 1'h1;
			repeat(2)@(negedge clk);
			UART_Start = 1'h0;
		end else if(SPI_triggering) begin
			SPI_Start = 1'h1;
			repeat(2)@(negedge clk);
			SPI_Start = 1'h0;
		end
		PollCapDone(Status);
	endtask
	
	task SPI(input Length, input Edge, input [15:0] Data, output [7:0] Status);
		SPI_triggering = 1;
		SPI_Data = Data;
		SPI_Pos_Edge = Edge;
		SPI_Width8 = Length;
		
		SendCmd(Command'(WriteReg), Register'(TrigCfg_Reg), {2'h0, 2'h0, Edge, Length, 1'h0, 1'h1}, '{ERR}, Status); //Set Edge and Length and Disable UART
		$display("SPI Setup Sucessfull");
		repeat(2)@(negedge clk);
		Start(Status);
		SPI_triggering = 0;
	endtask
		
	task UART(input [7:0] Data, output [7:0] Status);
		UART_triggering = 1;
		UART_Data = Data;

		SendCmd(Command'(WriteReg), Register'(TrigCfg_Reg), 8'h02, '{ERR}, Status); //Enable UART and disable SPI
		$display("UART Setup Sucessfull");
		while(DUT.iDIG.Trigger.Prot_Trig.uart.state != 1'h0)
		repeat(2)@(negedge clk);
		Start(Status);
		UART_triggering = 0;
	endtask
	