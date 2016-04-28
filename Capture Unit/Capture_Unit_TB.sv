module Capture_Unit_TB();
	
	//Inputs
	logic clk;
	logic rst_n;
	logic wrt_smpl;
	logic triggered;
	logic [5:0] TrigCfg;
	logic [15:0] trig_pos;
	
	//Outputs
	logic [15:0] waddr;
	logic capture_done;
	logic write;

	logic [3:0] run_ctl;
	logic run;
	logic [15:0] num_smpls;
	logic [15:0] smpl_cnt;
	logic [15:0] write_cnt;
	
	logic [15:0] i;
	
	Capture_Unit cap(.clk(clk), .rst_n(rst_n), .wrt_smpl(wrt_smpl), .triggered(triggered), .TrigCfg(TrigCfg), .trig_pos(trig_pos), .waddr(waddr), .capture_done(capture_done), .write(write));

	always
		#5 clk = ~clk;
		
	always @ write begin
		if(write)
			write_cnt = write_cnt + 1;
	end
	
	initial begin
		clk = 0;
		
		rst_n = 0;
		
		repeat(2)@(posedge clk);
		
		rst_n = 1;
		
		i = 0;
		
		repeat(256) begin : loop
			i = i + 1;
			smpl_cnt = 0;
			write_cnt = 0;
			triggered = 0;
			wrt_smpl = 0;
			
			run_ctl = $urandom_range(15,0); //If == to 0 then run mode = 0
			num_smpls = $urandom; //Number of samples to write before triggering
			trig_pos = $urandom; //Number of samples to write after triggering
			
			@(negedge clk);
			
			if(run_ctl == 0)
				run = 0;
			else
				run = 1;
			
			TrigCfg = {1'b0, run, 4'h0};
			
			repeat(8) @(negedge clk);
			
			if(run == 0) begin
				repeat(32) @(negedge clk); 
				if(cap.state != 0) begin
					$display("On a no run mode cycle it was not in IDLE after 32 cycles");
					$stop;
				end
				disable loop;
			end
			
			while(smpl_cnt != num_smpls) begin
				smpl_cnt = smpl_cnt + 1;
				
				@(negedge clk) wrt_smpl = 1;
				@(negedge clk) wrt_smpl = 0;
				
				if((smpl_cnt + trig_pos) >= 385)
					if(cap.armed != 1) begin
						$display("Armed did not go high");
						$stop;
					end
			end
			
			if(write_cnt != num_smpls) begin
				$display("Write did not occur the correct # of times, did: %d, wanted: %d", write_cnt, num_smpls);
				$stop;
			end else
				$display("Wrote %d samples correctly", write_cnt);
			
			@(negedge clk);
			triggered = 1;
			
			fork : forkmeister
				begin
					repeat((trig_pos + 100000))@(negedge clk);
					$display("Where is the kaboom, there was supposed to be an Earth shattering kaboom?");
					$stop;
				end
				
				begin
					@(posedge capture_done);
					//$display("Broke out of forkmeister");
					TrigCfg = TrigCfg | 6'b100000;
					disable forkmeister;
				end
				
				begin
					forever begin
						@(negedge clk) wrt_smpl = 1;
						@(negedge clk) wrt_smpl = 0;
					end
				end
			join
			
			repeat(16)@(negedge clk);
			
			$display("Loop, %t, %d", $time, i);
			
			@(negedge clk);			
		end
		$stop;
	end
endmodule


