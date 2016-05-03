module Prot_TB();
	
	logic clk;
	logic rst_n;

	logic line;
		
	logic [15:0] baud_cnt;
		
	logic trmt;
	logic [7:0] tx_data;
	logic tx_done;
	
	logic trigger;
	
	UART_tx_Prot tx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .baud_cnt(baud_cnt), .tx_done(tx_done), .TX(line));
	UART_RX_Prot rx(.clk(clk), .rst_n(rst_n), .RX(line), .baud_cnt(baud_cnt), .mask(8'h00), .match(tx_data), .UARTtrig(trigger));
	
	always
		#5 clk = ~clk;
		
	initial begin
		clk = 0;
		rst_n = 0;
		repeat(2)@(negedge clk);
		rst_n = 1;
		
		repeat(1024) begin
			tx_data = $urandom;
			baud_cnt = $urandom_range(255, 16);
			
			trmt = 1;
			@(negedge clk);
			trmt = 0;
			
			fork : billyforky
				begin
					repeat(1000000)@(negedge clk);
					$display("Failed");
					$stop;
				end
				
				begin
					@(posedge trigger);
					@(posedge tx_done);
					$display("Success");
					disable billyforky;
				end
			join
			repeat(2)@(negedge clk);
		end
		$stop;
	end
	
endmodule