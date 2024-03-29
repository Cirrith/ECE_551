`timescale 100ps / 10ps
module pll8x_updated(ref_clk,RST_n,out_clk,locked);
  //////////////////////////////////////////////
  // A rather cheesy model of a PLL to perform 8X clock multiplication.
  // `timescale require to be 100ps as above.  Period of ref clock 
  // should be 200 time units minimum (100 high, 100 low).
  //////////////////////////////////////////////

  input ref_clk;
  input RST_n;
  output reg out_clk;
  output locked;
  
  reg [9:0] ref_period, smpl_period,match;
  reg smpl_clk;
  reg [1:0] locked_cnt;
  
  
  //// Setup a sample clock at 10GHz to sample the      ///
  //// reference clock and discover it relative period /////
  initial
    smpl_clk = 0;
	
  always
    #0.5 smpl_clk = ~smpl_clk;
	
  ////////////////////////////////////////////////////////////////
  // ref_period will hold the period of the reference clock in //
  // terms of number of smpl_clk's.  smpl_period is a running //
  // counter of smpl_clks that is reset every positive edge  //
  // of ref_clk.  This verilog would never synthesize and   //
  // violates many standard coding practices.              //
  //////////////////////////////////////////////////////////
  always @(posedge ref_clk, negedge RST_n)
    if (!RST_n)
	  begin
	    ref_period <= 0;
		locked_cnt <= 2'b00;
	  end
    else begin
	  ref_period <= smpl_period;
	  if (locked_cnt<2'b11) locked_cnt <= locked_cnt + 1;
	end
	
  always @(posedge smpl_clk, posedge ref_clk, negedge RST_n)
    if (!RST_n) begin
		smpl_period <= 0;
	end
	else if (ref_clk)
		smpl_period <= 0;
	else begin
		smpl_period <= smpl_period + 1;
	end
	
   //////////////////////////////////////////////////////////
   // Toggling out_clk every 1/16 of a clock cycle.  This //
   // may be fractional for the high time of out_clk.    //
   ///////////////////////////////////////////////////////
   always @(posedge smpl_clk, posedge ref_clk, negedge RST_n)
     if (!RST_n)
	   out_clk <= 1'b1;
	 else if (ref_clk)
		match <= 10'h000;
	 else if ((smpl_period==match+(ref_period>>4)) && (out_clk)) begin
	   out_clk <= 1'b0;
	   match <= match + (ref_period>>3);
	 end else if ((smpl_period==match) && (!out_clk))
	   out_clk <= 1'b1;
	 
   assign locked = &locked_cnt;
   
   always @(posedge locked)
     if (ref_period<200)
       $display("WARNING: this PLL model should be used with a ref_clk with period 200 or greater");
	 
   
endmodule
	
	