module BranchCondition(input logic [31:0] rs1, rs2, input logic [2:0] br_type, input logic [6:0] opcode,
					   output logic br_taken);
	logic branch, jump;
	always_comb begin
		if (opcode == 7'b1101111) jump <= 1; else jump <= 0;
	end
	always_comb begin
		if (opcode == 7'b1100011) begin
			case (br_type)
				3'b000: branch <= rs1 == rs2;
				3'b001: branch <= rs1 != rs2;
				3'b100: branch <= rs1 < rs2;
				3'b101: branch <= rs1 >= rs2;
				3'b110: branch <= $signed(rs1) < $signed(rs2);
				3'b111: branch <= $signed(rs1) >= $signed(rs2);
				default: branch <= 0;
			endcase
		end 
		else branch <= 0;
	end
	
	assign br_taken = (branch | jump);
endmodule
