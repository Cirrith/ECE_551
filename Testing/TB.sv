`timescale 100ps / 10ps

module TB();

	typedef enum logic [1:0] {ReadReg, WriteReg, Dump} Command;
	typedef enum logic [2:0] {ERR, CH1, CH2, CH3, CH4, CH5} Channel;
	typedef enum logic [5:0] {TrigCfg_Reg, CH1TrigCfg_Reg, CH2TrigCfg_Reg, CH3TrigCfg_Reg, CH4TrigCfg_Reg, CH5TrigCfg_Reg, decimator_Reg, VIH_Reg, VIL_Reg, matchH_Reg, matchL_Reg, maskH_Reg, maskL_Reg, baud_cntH_Reg, baud_cntL_Reg, trig_posH_Reg, trig_posL_Reg} Register;
	//typedef enum logic [1:0] {RUN, }
	
	localparam ACK = 8'hA5;
	localparam NCK = 8'hEE;
	
	parameter ENTRIES = 384;		// defaults to 384 for simulation, use 12288 for DE-0 and 384 for sim
	parameter LOG2 = 9;				// Log base 2 of number of entries, use 14 for DE-0 and 9 for sim
	
	Register REG;
	Command CMD;
	Channel CHAN;
	
	//File TB Stuff
	integer file;
	integer r;
	string command;
	//logic [80*8:1] command; 
	string arg1;
	//logic [7:0] arg1;
	logic [17:0] arg2; 
	logic UART_triggering;
	logic SPI_triggering;
	logic START;
	logic [7:0] Stat;
	
	//Clock Stuff
	logic REF_CLK;
	logic clk400MHz;
	logic locked;
	logic clk;
	logic RST_n;
	logic [1:0] clk_div;
	
	//Channel Input Stuff
	logic VIH_PWM;
	logic VIL_PWM;
	logic CH1L, CH2L, CH3L, CH4L, CH5L;
	logic CH1H, CH2H, CH3H, CH4H, CH5H;
	logic CH1L_in, CH2L_in, CH3L_in;
	logic CH1H_in, CH2H_in, CH3H_in;
	
	//TB - DUT Communication - Main
	logic 			RX;
	logic 			TX;
	logic [15:0]	Tran_Cmd; 		//Command to Transmit
	logic 			Send_Cmd; 		//Send Command
	logic 			Clr_Rec_Rdy; 	//Clear Response Ready
	logic 			Cmd_Cmplt; 		//Command has finished transmitting
	logic [7:0] 	Rec_Data;
	logic 			Rec_Rdy;
	
	//TB - DUT Communication - UART
	logic 			TX_UART;		//TX line for protocol triggering
	logic 			UART_Start;		//Start transmitting 
	logic [7:0]		UART_Data;
	logic 			UART_Done;
	
	//TB - DUT Communication - SPI
	logic SS_n;
	logic SCLK;
	logic SPI_Start;
	logic SPI_Done;
	logic [15:0] SPI_Data;
	logic MOSI;
	logic SPI_Pos_Edge;
	logic SPI_Width8;
	logic Length;
	logic Edge;
	logic [15:0] Data;
	
	//Data Generator
	AFE analog_front_end(
		.smpl_clk(clk400MHz),
		.VIH_PWM(VIH_PWM),
		.VIL_PWM(VIL_PWM),
		.CH1L(CH1L),
		.CH1H(CH1H),
		.CH2L(CH2L),
		.CH2H(CH2H),
		.CH3L(CH3L),
		.CH3H(CH3H),
		.CH4L(CH4L),
		.CH4H(CH4H),
		.CH5L(CH5L),
		.CH5H(CH5H));
	
	//DUT Stuff
	LA_dig DUT(
		.clk400MHz(clk400MHz),
		.RST_n(RST_n),
		.locked(locked),
		.VIH_PWM(VIH_PWM),
		.VIL_PWM(VIL_PWM),
		.CH1L(CH1L_in),
		.CH1H(CH1H_in),
		.CH2L(CH2L_in),
		.CH2H(CH2H_in),
		.CH3L(CH3L_in),
		.CH3H(CH3H_in),
		.CH4L(CH4L),
		.CH4H(CH4H),
		.CH5L(CH5L),
		.CH5H(CH5H),
		.RX(TX),
		.TX(RX),
		.LED());

	//Clock Stuff
	pll8x iPLL(
		.ref_clk(REF_CLK),
		.RST_n(RST_n),
		.out_clk(clk400MHz),
		.locked(locked));
		
	//Main communication between DUT and TB
	CommMaster commmaster(
		.clk(clk),
		.rst_n(RST_n),
		.cmd(Tran_Cmd),
		.snd_cmd(Send_Cmd),
		.clr_rec_rdy(Clr_Rec_Rdy),
		.RX(RX),
		.cmd_cmplt(Cmd_Cmplt),
		.TX(TX),
		.rec_data(Rec_Data),
		.rec_rdy(Rec_Rdy));
	/*
	//UART Module for testing protocol triggering
	UART_tx uart_tx(
		.clk(clk),
		.rst_n(RST_n),
		.TX(TX_UART),
		.trmt(UART_Start),
		.tx_data(UART_Data),
		.tx_done(UART_Done));
	*/
	
	UART_tx_Prot uart_tx(
		.clk(clk),
		.rst_n(RST_n),
		.trmt(UART_Start),
		.tx_data(UART_Data),
		.baud_cnt({DUT.iDIG.baud_cntH, DUT.iDIG.baud_cntL}),
		.tx_done(UART_Done),
		.TX(TX_UART));
	
	//SPI Module for testing protocol triggering
	SPI_mstr spi_tx(
		.clk(clk),
		.rst_n(RST_n),
		.SS_n(SS_n),
		.SCLK(SCLK),
		.wrt(SPI_Start),
		.done(SPI_Done),
		.data_out(SPI_Data),
		.MOSI(MOSI),
		.pos_edge(SPI_Pos_Edge),
		.width8(SPI_Width8));		
	
	assign {CH1H_in,CH1L_in} = (UART_triggering) ? {2{TX_UART}} : (SPI_triggering) ? {2{SS_n}}: {CH1H,CH1L};
	assign {CH2H_in,CH2L_in} = (SPI_triggering) ? {2{SCLK}}: {CH2H,CH2L};	
	assign {CH3H_in,CH3L_in} = (SPI_triggering) ? {2{MOSI}}: {CH3H,CH3L};
	
	`include "TB_Tasks.sv"
	
	always
		#100 REF_CLK = ~REF_CLK;
	
	always @(posedge clk400MHz, negedge locked)
		if (~locked)
			clk_div <= 2'b00;
		else
			clk_div <= clk_div+1;
	assign clk = clk_div[1];
	
	initial begin : file_block 
		REF_CLK = 0;
		START = 0;
		file = $fopen("Rise_Edge_1.txt", "r");

		if (file == 0) begin
			$display("File Not Found");
			$stop;
		end
		@(posedge REF_CLK);
		START = 1;
	end
	
	initial begin
		@(posedge START);
		forever begin			
			r = $fscanf(file, " %s %s %h \n", command, arg1, arg2); 
			
			$display("Enter Command Interpt, %s", command);
			
			if($feof(file)) begin
				$display("Reached end of file");
				$stop;		
			end
			
			arg1 = arg1.tolower();
			
			case(arg1)
				"trigcfg" : REG = '{TrigCfg_Reg};
				"ch1trigcfg" : REG = '{CH1TrigCfg_Reg};
				"ch2trigcfg" : REG = '{CH2TrigCfg_Reg};
				"ch3trigcfg" : REG = '{CH3TrigCfg_Reg};
				"ch4trigcfg" : REG = '{CH4TrigCfg_Reg};
				"ch5trigcfg" : REG = '{CH5TrigCfg_Reg};
				"decimator" : REG = '{decimator_Reg};
				"vih" : REG = '{VIH_Reg};
				"vil" : REG = '{VIL_Reg};
				"matchh" : REG = '{matchH_Reg};
				"matchl" : REG = '{matchL_Reg};
				"maskh" : REG = '{maskH_Reg};
				"maskl" : REG = '{maskL_Reg};
				"baud_cnth" : REG = '{baud_cntH_Reg};
				"baud_cntl" : REG = '{baud_cntL_Reg};
				"trig_posh" : REG = '{trig_posH_Reg};
				"trig_posl" : REG = '{trig_posL_Reg};
				"1" : CHAN = '{CH1};
				"2" : CHAN = '{CH2};
				"3" : CHAN = '{CH3};
				"4" : CHAN = '{CH4};
				"5" : CHAN = '{CH5};
				"null" : REG = '{TrigCfg_Reg};
				default : begin
					if(command != "SPI" | command != "UART") begin
						$display("Unhandled Input %s", arg1);
					end
				end
			endcase
			
			if (command[0] != "/") begin
				case (command)
					"INIT" : begin
						Initialize;
						$display("Initialize Successful @ %t", $time);
					end
					
					"READ" : begin
						//$display("Read @ %t", $time);
						CMD = '{ReadReg};
						SendCmd(CMD, REG, 8'h00, '{ERR}, Stat);
						$display("Read -> Register: %s, Read: %h", REG, Stat);
					end
					
					"WRITE" : begin
						CMD = '{WriteReg};
						SendCmd(CMD, REG, arg2[7:0], '{ERR}, Stat);
						if (Stat == 1) begin
							$display("Write -> Register: %s, Success", REG);
						end else begin
							$display("Write -> Register: %s, Failure", REG);
							$stop;
						end
					end
					
					"DUMP" : begin
						REG = '{TrigCfg_Reg};
						CMD = '{Dump};
						SendCmd(CMD, REG, 8'h00, CHAN, Stat);
						$display("Dump -> %d, Success", CHAN);
					end
					
					"RUN" : begin
						Start(Stat);
						$display("Run -> Success");
					end
					
					"SPI" : begin
						$display("Data: %h", arg2);
						Length = arg2[17];
						Edge = arg2[16];
						Data =  arg2[15:0];
						SPI(Length, Edge, Data, Stat);
					end
					
					"UART" : begin
						Data = {8'h00, arg2[7:0]};
						$display("Data %h", Data);
						UART(Data[7:0], Stat);
					end
					
					"END" : begin
						$display("Reached End");
						$stop;
					end
					default : begin
						$display("Unknown command '%0s'", command);
						$stop;
					end
				endcase
			end //End Comment skipper
		end //End Forever
	end //End Initial
endmodule
		
