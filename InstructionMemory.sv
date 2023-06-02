module InstructionMemory(input logic [31:0] addr, 
                         output logic [31:0] instruction);
    logic [31:0] instruction_memory [31:0];    
    initial begin
        $readmemh("", instruction_memory);	// Put Absolute Path of the machine code
    end
    assign instruction = instruction_memory[addr[31:2]];
endmodule
