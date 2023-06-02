module Pipeline_IR(input logic clk, stall, flush, input logic [31:0] in, 
				   output logic [31:0] out);
	always_ff @(posedge clk) begin
		if (flush) out <= 19;
		else if (~stall) out <= in;
	end
endmodule
