module test();

logic a = 1;
logic b = 0;

RAMqueue ram [4:0] (.clk(1'b0), .we(1'h0), .waddr(9'h000), .wdata(8'h00), .raddr(0), .rdata(0)); //Default Size (ENTRIES = 384, Data Width = 8, LOG2 = 9)

	always begin
		fork : Upper
			begin : Timeout
				#20;
				$display("Timeout");
				$stop;
			end
			
			begin : Closer
				#10;
				$display("Init");
				disable Upper;
			end
		join
		$stop;
	end
endmodule