module AFE(smpl_clk,VIH_PWM,VIL_PWM,CH1L,CH1H,CH2L,CH2H,CH3L,CH3H,
           CH4L,CH4H,CH5L,CH5H);
		   
  input smpl_clk;			// new sample presented every clock
  input VIH_PWM, VIL_PWM;	// PWM inputs that specify thresholds.
							// thresholds assumed at 0.33 and 0.66 till first PWM period completes
  output CH1L,CH1H;			// Logic low and logic high outputs for CH1
  output CH2L,CH2H;			// Logic low and logic high outputs for CH2
  output CH3L,CH3H;			// Logic low and logic high outputs for CH3
  output CH4L,CH4H;			// Logic low and logic high outputs for CH4
  output CH5L,CH5H;			// Logic low and logic high outputs for CH5
  
  reg [7:0] CH1mem[65535:0];		// 2^16 entries of 8-bits analog for CH1
  reg [7:0] CH2mem[65535:0];		// 2^16 entries of 8-bits analog for CH2
  reg [7:0] CH3mem[65535:0];		// 2^16 entries of 8-bits analog for CH3
  reg [7:0] CH4mem[65535:0];		// 2^16 entries of 8-bits analog for CH4 
  reg [7:0] CH5mem[65535:0];		// 2^16 entries of 8-bits analog for CH5

  reg [15:0] ptr;					// pointer into CHXmem used for comparison
  reg [7:0] VIL,VIH;				// VIL & VIH as 8-bit quantities, start at .33 and .66
  reg en_VIL_PWM,en_VIH_PWM;
  reg [9:0] VIL_cntr,VIH_cntr;		// counters for capturing duty cycle of PWM signals.  
  
  initial begin
    ptr = 16'h0000;
	$readmemh("CH1mem.txt",CH1mem);
	$readmemh("CH2mem.txt",CH2mem);
	$readmemh("CH3mem.txt",CH3mem);
	$readmemh("CH4mem.txt",CH4mem);
	$readmemh("CH5mem.txt",CH5mem);
	VIL = 8'h55;	// starts at 0.33 then modified according to duty of VIL_PWM
	VIH = 8'hAA;	// starts at 0.66 then modified according to duty of VIH_PWM
	en_VIL_PWM = 0;
	en_VIH_PWM = 0;
  end
  
  always @(posedge smpl_clk)
    ptr <= ptr + 1;
	
  always @(posedge VIL_PWM)		// don't start monitoring VIL_PWM till positive edge occurs
    begin
      en_VIL_PWM <= 1;
	  VIL_cntr <= 0;			// zero the counter on pos edge and capture on neg edge
	end
	
  always @(posedge VIH_PWM)		// don't start monitoring VIL_PWM till positive edge occurs
    begin
      en_VIH_PWM <= 1;
	  VIH_cntr <= 0;			// zero the counter on pos edge and capture on neg edge
	end

  always @(posedge smpl_clk)
    if ((en_VIL_PWM) && (VIL_PWM))	// if monitoring VIL_PWM and it is high then
	  VIL_cntr <= VIL_cntr + 1;		// increment the VIL_cntr
	  
  always @(posedge smpl_clk)
    if ((en_VIH_PWM) && (VIH_PWM))	// if monitoring VIH_PWM and it is high then
	  VIH_cntr <= VIH_cntr + 1;	  	// increment the VIH_cntr
	
  always @(negedge VIL_PWM)		// on negative edge we capture new VIL value
    if (en_VIL_PWM)
	  VIL <= VIL_cntr[9:2];
	  
  always @(negedge VIH_PWM)		// on negative edge we capture new VIH value
    if (en_VIH_PWM)
	  VIH <= VIH_cntr[9:2];

  /////////////////////////////////////////////////////////////
  // Now model comparator function for the various channels //
  ///////////////////////////////////////////////////////////
  assign CH1L = (CH1mem[ptr]<VIL) ? 1'b0 : 1'b1;
  assign CH1H = (CH1mem[ptr]>VIH) ? 1'b1 : 1'b0; 

  assign CH2L = (CH2mem[ptr]<VIL) ? 1'b0 : 1'b1;
  assign CH2H = (CH2mem[ptr]>VIH) ? 1'b1 : 1'b0; 

  assign CH3L = (CH3mem[ptr]<VIL) ? 1'b0 : 1'b1;
  assign CH3H = (CH3mem[ptr]>VIH) ? 1'b1 : 1'b0; 

  assign CH4L = (CH4mem[ptr]<VIL) ? 1'b0 : 1'b1;
  assign CH4H = (CH4mem[ptr]>VIH) ? 1'b1 : 1'b0; 

  assign CH5L = (CH5mem[ptr]<VIL) ? 1'b0 : 1'b1;
  assign CH5H = (CH5mem[ptr]>VIH) ? 1'b1 : 1'b0; 

endmodule  
	
  
	