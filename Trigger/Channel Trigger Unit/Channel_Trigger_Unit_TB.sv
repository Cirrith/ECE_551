module Channel_Trigger_Unit_TB();
	
	logic clk;
	logic rst_n;
	logic [4:0] CHxTrigCfg;
	logic CHxHff5;
	logic CHxLff5;
	logic armed;
	logic CHxTrig;

	Channel_Trigger_Unit sohcahtoa (
		.clk(clk),
		.rst_n(rst_n),
		.CHxTrigCfg(CHxTrigCfg),
		.CHxHff5(CHxHff5),
		.CHxLff5(CHxLff5),
		.armed(armed),
		.CHxTrig(CHxTrig));
	
	logic [2:0] Trig_Ctl; //
	
	always
		#5 clk = ~clk;
		
	initial begin
		
		clk = 0;
		rst_n = 0;
		repeat(2) @ (negedge clk);
		rst_n = 1;
		
		repeat(1024) begin
			Trig_Ctl = $urandom_range(4,0);
			
			armed = 0;
			
			CHxHff5 = 0;
			CHxLff5 = 1;
			
			repeat(2) @(negedge clk);
			
			if(Trig_Ctl == 4) begin			//Posedge
				CHxTrigCfg = {1'h1, 4'h0};
				$display("Posedge");
			end
			else if (Trig_Ctl == 3) begin	//Negedge
				CHxTrigCfg = {1'h0, 1'h1, 3'h0};
				$display("Negedge");
			end
			else if (Trig_Ctl == 2)	begin	//High Level
				CHxTrigCfg = {2'h0, 1'h1, 2'h0};
				$display("High Level");
			end
			else if (Trig_Ctl == 1)	begin	//Low Level
				CHxTrigCfg = {3'h0, 1'h1, 1'h0};
				$display("Low Level");
			end
			else if (Trig_Ctl == 0)	begin	//No Trig
				CHxTrigCfg = {4'h0, 1'h1};
				$display("No Trig");
			end
			
			@(negedge clk);
			
			fork : forky
				begin
					repeat(100) @(negedge clk);
					$display("Nothing to report sir");
					disable forky;
				end
				
				begin
					@(posedge CHxTrig);
					$display("Activity on the enemy front, prepare for war!!");
					$stop;
				end
			join
			
			@(negedge clk);
			armed = 1;
			
			fork : meforky
				begin
					forever begin
						@(negedge clk);
						CHxHff5 = ~CHxHff5;
						CHxLff5 = ~CHxLff5;
					end
				end
				
				begin
					@(posedge CHxTrig);
					if(Trig_Ctl != 0) begin
						$display("Successful");
						disable meforky;
					end
					else if (Trig_Ctl == 0) begin
						$display("Captain, ummm, probablys shouldn't have done that");
						$stop;
					end
				end	

				begin
					repeat(100) @(negedge clk);
					if(Trig_Ctl == 0) begin
						$display("Successful");
						disable meforky;
					end
					else begin
						$display("I should not have told you that");
						$stop;
					end
				end
			join

			@(negedge clk);			
		end
		$stop;
	end
endmodule