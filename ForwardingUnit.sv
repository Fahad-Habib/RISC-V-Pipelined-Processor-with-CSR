module ForwardingUnit(input logic [31:0] pre_inst, new_inst, input logic reg_wrMW, br_taken, is_mret, input logic [1:0] interrupt,
					  output logic For_A, For_B, Stall, Stall_MW, Flush);
	always_comb begin
		if (reg_wrMW) begin
			/*
			if (pre_inst[6:0] == 7'b0000011) begin	// Load
				case (new_inst[6:0])
					7'b0110011: begin		// R-type
						Stall <= ((new_inst[19:15] == pre_inst[11:7]) | (new_inst[24:20] == pre_inst[11:7]));
						Stall_MW <= ((new_inst[19:15] == pre_inst[11:7]) | (new_inst[24:20] == pre_inst[11:7]));
					end
					7'b0010011: begin		// I-type
						Stall <= (new_inst[19:15] == pre_inst[11:7]);
						Stall_MW <= (new_inst[19:15] == pre_inst[11:7]);
					end
				endcase
			end */
			case (new_inst[6:0])
				7'b0110011: begin		// R-type
					if (new_inst[19:15] == 0) For_A <= 0;
					else For_A <= new_inst[19:15] == pre_inst[11:7];
					if (new_inst[24:20] == 0) For_B <= 0;
					else For_B <= new_inst[24:20] == pre_inst[11:7];
					Stall <= 0;
					Stall_MW <= 0;
					Flush <= 0;
				end
				7'b0010011: begin		// I-type
					if (new_inst[19:15] == 0) For_A <= 0;
					else For_A <= new_inst[19:15] == pre_inst[11:7];
					For_B <= 0;
					Stall <= 0;
					Stall_MW <= 0;
					Flush <= 0;
				end
				default: begin
					For_A <= 0;
					For_B <= 0;
					Stall <= 0;
					Stall_MW <= 0;
					Flush <= 0;
				end
			endcase
			if (br_taken) begin 
				For_A <= 0;
				For_B <= 0;
				Stall <= 0;
				Stall_MW <= 0;
				Flush <= 1;
			end
		end else if (br_taken) begin
			For_A <= 0;
			For_B <= 0;
			Stall <= 0;
			Stall_MW <= 0;
			Flush <= 1;
		end else begin
			For_A <= 0;
			For_B <= 0;
			Stall <= 0;
			Stall_MW <= 0;
			Flush <= 0;
		end
		if (interrupt == 1 | is_mret) begin
			For_A <= 0;
			For_B <= 0;
			Stall <= 0;
			Stall_MW <= 0;
			Flush <= 1;
		end
	end
endmodule
