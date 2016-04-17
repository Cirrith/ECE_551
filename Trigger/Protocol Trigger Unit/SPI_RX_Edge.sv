/********************************************************************************************************
/		MODULE: SPI_RX_Edge
/		PURPOSE: Given a system clock (clk) and an SPI clock (SCLK), determine when the specified edge (edg)
/					occurs. Need to flop clk twice for metastability, then edge detect. 
/
/		INPUTS: clk - System Clock 100MHZ
/				rst_n - Reset for sequential ?Don't know if needed
/				edg - Which edge to detect
/					0 - Shift on fall of SCLK
/					1 - Shift on rise of SCLK
/				SCLK - SPI clock to be sampled
/
/		OUTPUTS: shift - Detected an edge to trigger on
/
/		INTERNAL: 
/				det [2:0] - Samples of SCLK, flopped twice for metastability
/				pos - Detected posedge
/				neg - Detected negedge
********************************************************************************************************/
module SPI_RX_Edge(clk, rst_n, edg, SCLK, shift);

input clk;
input rst_n;

input edg;
input SCLK;

output shift;

logic [2:0] det; //Store previous three samples, det[2] is oldest
logic pos;
logic neg;

assign pos = (det[2] == 0) & (det[1] == 1);
assign neg = (det[2] == 1) & (det[1] == 0);

assign shift = edg ? pos : neg;

always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		det <= 2'b0;
	else begin
		det[2] <= det[1];
		det[1] <= det[0];
		det[0] <= SCLK;
	end
end
endmodule