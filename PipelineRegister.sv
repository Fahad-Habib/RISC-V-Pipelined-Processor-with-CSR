module PipelineRegister(input logic clk, stall, input logic [31:0] in, 
						output logic [31:0] out);
	always_ff @(posedge clk) begin
		if (~stall) out <= in;
	end
endmodule
