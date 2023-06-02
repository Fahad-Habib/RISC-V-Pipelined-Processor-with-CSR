`timescale 1ns / 1ps


module Processor(input logic clk, reset, input logic [1:0] interrupt);
    logic [31:0] plus4, next_index, wdata, rdata, index, A, B, B_i, A_r, B_r, instruction, alu_out;
    logic [3:0] alu_op;
    logic [2:0] mask, br_type;
    logic [1:0] wb_sel;
    logic reg_wr, rd_en, wr_en, sel_A, sel_B, br_taken;
    
    logic [31:0] IR_fetch_decode, PC_fetch_decode, ALU_execute_memory, WD_execute_memory, PC_execute_memory, IR_execute_memory, A_for, B_for;
    logic [1:0] wb_selMW;
    logic reg_wrMW, rd_enMW, wr_enMW, For_A, For_B, Stall, Stall_MW, Flush, Br_taken;

	logic CSR_reg_wr, CSR_reg_rd, CSR_reg_wrMW, CSR_reg_rdMW, is_mret, is_mretMW, CSR_epc_taken;
	logic [1:0]  CSR_interrupt;
	logic [11:0] CSR_addr;
	logic [31:0] CSR_wdata, CSR_rdata, CSR_PC, CSR_epc, CSR_prior_PC;

    PC					pc					(.clk(clk), .reset(reset), .stall(Stall), .B(next_index), .A(index));
    Add4				add4				(.A(index), .B(plus4));
    Mux2				select_PC_1			(.A(plus4), .B(ALU_execute_memory), .sel(br_taken), .C(CSR_prior_PC));
    Mux2				select_PC_2			(.A(CSR_prior_PC), .B(CSR_epc), .sel(CSR_epc_taken), .C(next_index));
    
    InstructionMemory	instr_memory		(.addr(index), .instruction(instruction));
    
    Controller			control_unit 		(.instruction(IR_fetch_decode), .alu_op(alu_op), .mask(mask), .br_type(br_type), .reg_wr(reg_wr), .sel_A(sel_A), .sel_B(sel_B), .rd_en(rd_en), .wr_en(wr_en), .CSR_reg_rd(CSR_reg_rd), .CSR_reg_wr(CSR_reg_wr), .is_mret(is_mret), .wb_sel(wb_sel));
    
    PipelineControl 	control				(.clk(clk), .reg_wr(reg_wr), .wr_en(wr_en), .rd_en(rd_en), .stall(Stall_MW), .csr_reg_rd(CSR_reg_rd), .csr_reg_wr(CSR_reg_wr), .is_mret(is_mret), .wb_sel(wb_sel), .reg_wrMW(reg_wrMW), .wr_enMW(wr_enMW), .rd_enMW(rd_enMW), .csr_reg_rdMW(CSR_reg_rdMW), .csr_reg_wrMW(CSR_reg_wrMW), .is_mretMW(is_mretMW), .wb_selMW(wb_selMW));
    ForwardingUnit		forwarding			(.pre_inst(IR_execute_memory), .new_inst(IR_fetch_decode), .reg_wrMW(reg_wrMW), .br_taken(br_taken), .is_mret(is_mretMW), .interrupt(interrupt), .For_A(For_A), .For_B(For_B), .Stall(Stall), .Stall_MW(Stall_MW), .Flush(Flush));
    
    //	Fetch <----> Decode & Execute

    Pipeline_IR		 	Fetch_Decode_IR 	(.clk(clk), .stall(Stall), .flush(Flush), .in(instruction), .out(IR_fetch_decode));
    PipelineRegister 	Fetch_Decode_PC 	(.clk(clk), .stall(Stall), .in(index), .out(PC_fetch_decode));

    RegisterFile 		register_file 		(.clk(clk), .reset(reset), .reg_wr(reg_wrMW), .raddr1(IR_fetch_decode[19:15]), .raddr2(IR_fetch_decode[24:20]), .waddr(IR_execute_memory[11:7]), .wdata(wdata), .rdata1(A_r), .rdata2(B_r));
    ImmediateGenerator	imm_generator		(.clk(clk), .instruction(IR_fetch_decode), .imm_out(B_i));
    
    Mux2 				select_A_r			(.A(A_r), .B(ALU_execute_memory), .sel(For_A), .C(A_for));
    Mux2				select_B_r			(.A(B_r), .B(ALU_execute_memory), .sel(For_B), .C(B_for));

    Mux2 				select_A 			(.A(PC_fetch_decode), .B(A_for), .sel(sel_A), .C(A));
    Mux2 				select_B 			(.A(B_for), .B(B_i), .sel(sel_B), .C(B));
    BranchCondition 	branch_cond 		(.rs1(A_for), .rs2(B_for), .br_type(br_type), .opcode(IR_fetch_decode[6:0]), .br_taken(Br_taken));

    ALU 				alu 				(.A(A), .B(B), .alu_op(alu_op), .C(alu_out));
    
    //	Decode & Execute <----> Memory & Writeback
    
    PipelineRegister 	Execute_Memory_ALU 	(.clk(clk), .stall(Stall_MW), .in(alu_out), .out(ALU_execute_memory));
    PipelineRegister 	Execute_Memory_WD 	(.clk(clk), .stall(Stall_MW), .in(B_for), .out(WD_execute_memory));
    PipelineRegister 	Execute_Memory_PC 	(.clk(clk), .stall(Stall_MW), .in(PC_fetch_decode), .out(PC_execute_memory));
    Pipeline_IR		 	Execute_Memory_IR 	(.clk(clk), .stall(Stall_MW), .flush(Flush), .in(IR_fetch_decode), .out(IR_execute_memory));
    Pipeline_Branch 	Execute_Memory_BR 	(.clk(clk), .stall(Stall_MW), .flush(Flush), .in(Br_taken), .out(br_taken));
    
    DataMemory 			data_memory 		(.addr(ALU_execute_memory), .wdata(ALU_execute_memory), .mask(mask), .wr_en(wr_enMW), .rd_en(rd_enMW), .clk(clk), .rdata(rdata));
    WriteBack 			writeback 			(.A(ALU_execute_memory), .B(rdata), .C(PC_execute_memory), .D(CSR_rdata), .wb_sel(wb_selMW), .wdata(wdata));
    
    CSR_RegisterFile	CSR_register_file	(.clk(clk), .reset(reset), .reg_wr(CSR_reg_wrMW), .reg_rd(CSR_reg_rdMW), .is_mret(is_mretMW), .addr(CSR_addr[11:0]), .wdata(CSR_wdata), .PC(PC_execute_memory), .interrupt(interrupt), .epc_taken(CSR_epc_taken), .rdata(CSR_rdata), .exc_pc(CSR_epc));
    
    CSR_buffer 			CSR_DATA			(.clk(clk), .reset(reset), .in(A_for), .out(CSR_wdata));
    CSR_buffer 			CSR_ADDR			(.clk(clk), .reset(reset), .in(B_i), .out(CSR_addr));

endmodule
