module CSR_buffer(input logic clk, reset, input logic [31:0] in, 
				  output logic [31:0] out);
	always_ff @(posedge clk) begin
		if (reset) out <= 0;
		else out <= in;
	end
endmodule
