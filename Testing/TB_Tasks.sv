	
	logic [7:0] Mem [ENTRIES-1:0];
	
	task Initialize;
		UART_triggering = 0;
		SPI_triggering = 0;
		
		UART_Start = 0;
		UART_Data = 0;
		
		SPI_Start = 0;
		SPI_Pos_Edge = 0;
		SPI_Width8 = 0;
		
		Tran_Cmd = 0; //16 Bit Command
		Send_Cmd = 0; //Yes or no
		Clr_Rec_Rdy = 0;

		RST_n = 0;
		@(negedge locked);
		RST_n = 1;
		
		
	endtask

	task SendCmd (input [1:0] Cmd, input [5:0] Reg, input [7:0] Data, input [1:0] Chan, output Status);
		if(Cmd == ReadReg) begin
			Tran_Cmd = {2'h0, 1'h0, Reg, 8'h00};
		end
		else if(Cmd == WriteReg) begin
			Tran_Cmd = {2'h1, 1'h0, Reg, Data};
		end
		else if(Cmd == Dump) begin
			Tran_Cmd = {2'h2, 3'h0, Chan, 8'h00};
		end
		else
			$display("Bad command Entered");
		
		Send_Cmd = 1;
		@(negedge clk);
		Send_Cmd = 0;

		fork : captainFork
			begin 
				repeat(10000) @(negedge clk);
				$display("10000 Cycles to send is quite a while");
				Status = 0;
				disable captainFork;
			end
			
			begin
				@(posedge Cmd_Cmplt);
				$display("Command Sent at %t", $time);
				Status = 1;
				disable captainFork;
			end
		join
	endtask

	/*
	task ChkResp (input [1:0] Cmd, input [5:0] Reg);
		fork : mrforky
			begin
				repeat(10000) @(negedge clk);
				$display("10000 Cycles on a response is quite a while");
				$stop;
			end
			
			begin
				@(posedge resp_rdy);
				$display("Command Received at %t", $time);
				disable mrforky;
			end		
		join
		
		if(Cmd == ReadReg) begin
			if(resp == NCK) begin
				$display("Read Failure");
			end
			else begin
				$display("Read %h from Register %s", resp, Reg);
				$stop;
			end
		end
		else if (Cmd == WriteReg) begin
			if(resp == ACK) begin
				$display("Write Success");
			end
			else if (resp == NCK) begin
				$display("Write Failed");
				$stop;
			end
			else begin
				$display("Unexpected Response");
				$stop;
			end
		end
		else
			$display("You should probably not be here");
	endtask
	
	task PollCapDone;
		fork : saliorforky
			begin				//Timeout
				repeat(100000) @(negedge clk);
				$display("100000 Cycles is quite a while for a Response");
				$stop;
			end
			
			begin				//Check for Capture Done in Response
				forever begin
					@(posedge resp_rdy);
					if(resp[5] == 1) begin
						$display("Capture Done");
						clr_resp_rdy = 1;
						@(negedge clk);
						clr_resp_rdy = 0;
						disable saliorforky;
					end
					clr_resp_rdy = 1;
					@(negedge clk);
					clr_resp_rdy = 0;
				end
			end
			
			begin				//Send the Read command to TrigCfg Register
				forever begin
					@(posedge resp_rdy);
					host_cmd = {ReadReg, 8'h00, 8'h00};
					send_cmd = 1;
					@(negedge clk);
					send_cmd = 0;
					@(posedge cmd_sent);
				end
			end
		join
	endtask
	
	task RcvDump;
		integer i;
		fork : senorforky
			begin				//Receive data. See if there is a better way than a for loop
				for(i = 0; i < ENTRIES; i = i + 1) begin
					@(posedge resp_rdy);
					Mem[i] = resp;
					//if(resp != ??????.resp) begin //Self checking portion of this paid programming
					//	$display("The data does not match");
					//	$stop;
					//end
					@(posedge clk);
					@(negedge clk);
					clr_resp_rdy = 1;
					@(negedge clk);
					clr_resp_rdy = 0;		
				end
				disable senorforky;
			end
			
			begin				//Timeout for making a recieve
				repeat(100000) @(negedge clk);
				$display("Errored out when recieving a DUMP, heh, dump");
				$stop;
			end
		join
	endtask
	*/
	