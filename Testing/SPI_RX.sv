/********************************************************************************************************
/		MODULE: SPI_RX
/		PURPOSE: Reciever for an SPI module. Need to flop MOSI three times for metastability and 
/
/		INPUTS: 
/				clk - System clock 100 MHz
/				rst_n - Reset
/				SS_n - Transmitting or not transmitting
/				SCLK - SPI clock
/				MOSI - Data in line
/				edg - which edge to trigger on
/					0 - Shift on fall of SCLK
/					1 - Shift on rise of SCLK
/				len8_16 - Check on lower 8 bits or all 16 bits
/					0 - Full 16 bits comparison
/					1 - Lower 8 bits comparison
/				mask - Mask for don't cares, 1 = don't care
/				match - Data to match to
/
/		OUTPUTS: 
/				SPItrig - Whether there was a match or not
/
/		INTERNAL:
/				met_MOSI [2:0] - metastability flops for MOSI, met_MOSI[2] is oldest
/				met_SS_n [2:0] - metastability flops for SS_n, met_SS_n[2] is oldest
/				
/				shift - Whether an edg has been detected by SPI_RX_Edge
/				
/				stor [15:0] - Shift register for MOSI value
/				
/				mask_match [15:0] - The values that the shift register should match up to, for both 8 and 16 bit compares
/				
/				mask_stor [15:0] - The masked version of what is stored, for both 8 and 16 bit compares
/				
/				match_made - mask_match == mask_stor
/
/				posedge_SS_n - Positive edge of metastable SS_n signal (met_SS_n)
/
/				shift_in - Should shift on next posedge of clk
********************************************************************************************************/
module SPI_RX(clk, rst_n, edg, SS_n, SCLK, MOSI, mask, match, len8_16, SPItrig);

typedef enum logic {SHIFT, COMPARE} state_t;

input clk;
input rst_n;

input edg;

input SS_n;
input SCLK;
input MOSI;

input [15:0] mask;
input [15:0] match;
input len8_16;

output reg SPItrig;

state_t state, nxt_state;

logic shift;

logic [2:0] met_MOSI;
logic [2:0] met_SS_n;
logic [15:0] stor;
logic [15:0] mask_match;
logic [15:0] mask_stor;
logic match_made;

logic shift_in;

assign mask_match = len8_16 ? {8'h00, match[7:0] & ~mask[7:0]} : match & ~mask;		//If don't care assign to 0
assign mask_stor = len8_16 ? {8'h00, stor[7:0] & ~mask[7:0]} : stor & ~mask;		//If don't care assign to 0

assign match_made = mask_match == mask_stor;

assign posedge_SS_n = (met_SS_n[2] == 0) & (met_SS_n[1] == 1);

SPI_RX_Edge spi_edge (.clk(clk), .rst_n(rst_n), .edg(edg), .SCLK(SCLK), .shift(shift));

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		stor <= 16'h0000;
		met_MOSI <= 3'h0;
		met_SS_n <= 3'h7; //Default to not selected
	end 
	else begin
		state <= nxt_state;
		met_MOSI[2] <= met_MOSI[1];
		met_MOSI[1] <= met_MOSI[0];
		met_MOSI[0] <= MOSI;
		met_SS_n[2] <= met_SS_n[1];
		met_SS_n[1] <= met_SS_n[0];
		met_SS_n[0] <= SS_n;
		stor <= shift_in ? {stor[14:0], met_MOSI[2]} : stor;
	end
end

always_comb begin
	SPItrig = 1'h0;
	shift_in = 1'h0;
	nxt_state = SHIFT;
	case(state)
		SHIFT: begin
			if(posedge_SS_n) begin
				nxt_state = COMPARE;
			end 
			else if(shift & ~met_SS_n[2]) begin //Edge Detected and reciever is selected, shift in
				shift_in = 1'h1;
				nxt_state = SHIFT;
			end
		end
		COMPARE: begin
			nxt_state = SHIFT;
			if(match_made)
				SPItrig = 1'h1;
		end
	endcase
end
endmodule





