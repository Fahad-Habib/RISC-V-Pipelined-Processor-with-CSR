module CSR_RegisterFile(input logic clk, reset, reg_wr, reg_rd, is_mret, input logic [11:0] addr, input logic [31:0] wdata, PC, input logic [1:0] interrupt,
						output logic epc_taken, output logic [31:0] rdata, exc_pc);

    logic [31:0] mstatus, mie, mepc, mip, mtvec, mcause;
    
    

    always_ff @(posedge clk) begin
		if (reset) begin
			mstatus	<= 0;
			mie		<= 0;
			mip		<= 2176;
			mtvec	<= 0;
			mcause	<= 0;
		end
		else if (reg_wr) begin
			case (addr)
				768: mstatus <= wdata;
				772: mie	 <= wdata;
				773: mtvec	 <= wdata;
			endcase
        end
    end

    always_comb begin
		rdata <= 0;
        if (reg_rd) begin
			case (addr)
				768: rdata <= mstatus;
				772: rdata <= mie;
				773: rdata <= mtvec;
			endcase
        end
    end
		
    always_comb begin
    	if (interrupt == 1) begin
    		mepc <= PC;
    		epc_taken <= 1;
    		exc_pc <= 4;
    	end else if (is_mret) begin
    		epc_taken <= 1;
    		exc_pc <= mepc;
    	end
    	else epc_taken <= 0;
    end

endmodule
