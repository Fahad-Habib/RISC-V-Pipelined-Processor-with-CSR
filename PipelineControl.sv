module PipelineControl(input logic clk, reg_wr, wr_en, rd_en, stall, csr_reg_rd, csr_reg_wr, is_mret, input logic [1:0] wb_sel, 
						output logic reg_wrMW, wr_enMW, rd_enMW, csr_reg_rdMW ,csr_reg_wrMW, is_mretMW, output logic [1:0] wb_selMW);
	always_ff @(posedge clk) begin
		if (~stall) begin
			reg_wrMW <= reg_wr;
			wr_enMW  <= wr_en;
			rd_enMW  <= rd_en;
			wb_selMW <= wb_sel;
			csr_reg_rdMW <= csr_reg_rd;
			csr_reg_wrMW <= csr_reg_wr;
			is_mretMW <= is_mret;
		end
	end
endmodule
