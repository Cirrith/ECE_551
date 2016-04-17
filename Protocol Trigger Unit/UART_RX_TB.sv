
module UART_RX_TB();
	
	/////GENERAL STUFF\\\\\
	logic clk;
	logic rst_n;
	logic line;
	logic [1:0] mat;
	
	/////RX STUFF\\\\\
	logic [15:0] baud_cnt;
	logic [7:0] mask;
	logic [7:0] match;
	logic UARTtrig;
	
	/////TX STUFF\\\\\
	logic trmt;
	logic [7:0] tx_data;
	logic tx_done;
	
	
	
	UART_tx tx (.clk(clk), .rst_n(rst_n), .TX(line), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done));
	
	UART_RX rx (.clk(clk), .rst_n(rst_n), .RX(line), .baud_cnt(baud_cnt), .mask(mask), .match(match), .UARTtrig(UARTtrig));
	
	initial
		clk = 0;

	always
		#5 clk = ~clk;
		
	initial begin
		rst_n = 0;
		@(negedge clk);
		rst_n = 1;
		
		baud_cnt = 108;		//Can't set it to anything else without a corresponding transmit
		
		repeat(16) begin
			tx_data = $urandom_range(256, 0);
			mat = $urandom_range(3, 0);
			match = $urandom_range(256, 0);
			mask = $urandom_range(256, 0);
			
			if(mat == 3)
				match = tx_data;
			
			trmt = 1;
			
			fork : forky
			
				begin
					repeat (100000) @(negedge clk);
					$display("100000 Cycles, that is quite a bit");
					disable forky;
				end
				
				begin
					@(posedge UARTtrig);
					$display("UARTtrig");
					disable forky;
				end
				
				begin
					@(posedge tx_done);
					$display("Done");
					disable forky;
				end
			join
			
			@(negedge clk);
			
			$display("UARTtrig = %b", UARTtrig);
			$display("Match | Mask = %h", match | mask);
			$display("Tx_Data | Mask = %h", tx_data | mask);
			
			
			if(UARTtrig & ((match | mask) == (tx_data | mask)))
				$display("Successful Match");
			else if (!UARTtrig & ((match | mask) != (tx_data | mask)))
				$display("Successful Not Match");
			else if ((match | mask) == (tx_data | mask)) begin
				$display("You didn't trigger");
				$stop;
			end
			else if (UARTtrig) begin
				$display("You triggered when you shouldn't have");
				$stop;
			end
			else begin
				$display("Something went wrong");
				$stop;
			end
			
			if(!tx_done)
				@(posedge tx_done);
			
		end
		$stop;
	end
endmodule