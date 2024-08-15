pragma circom 2.0.0;

include "./util/mux4.circom";
include "./util/mux.circom";
include "./core/stack_pointer.circom";
include "./core/program_counter.circom";

// 9-opcode
// 0: HALT (Stop the program)
// 1: PUSH (Push the operand to the stack)
// 2: POP  (Remove the top element of the stack)
// 3: DROP (Remove the bottom element of the stack)
// 4: ADD  (Add the top two elements of the stack)
// 5: SUB  (Subtract the top two elements of the stack)
// 6: PICK (Copy the nth element of the stack to the top of the stack)
// 7: JMP  (Jump to the operand)
// 8: JZ   (Jump if the top element of the stack is zero, and remove it from the stack)

template LeeVM(G) {
    var STACK_SIZE = 16;
    var PROGRAM_SIZE = 16;
    var INSTR_SET_SIZE = 9;

    signal input program[PROGRAM_SIZE][2];  // The program, where each instruction is a pair (opcode, operand)
    signal output result; // Final result after execution; the top of the stack

    var clk;
    
    signal instr[G][2]; // executed instrs: instr[i] = op at clock cycle i

    // states: G+1 states, including the initial state
    signal stack[G+1][STACK_SIZE]; // stack trace; stack[i] = stack before ith op
    signal topvl[G+1]; // stack top value trace
    signal sp[G+1]; // stack pointer trace
    signal pc[G+1]; // program counter log

    component mux_sp_topvl[G]; // stack pointer selects the top value
    component mux_pc_instr[G]; // program counter selects the instruction
    component mux_instr_sp[G]; // instruction selects the next stack pointer
    component mux_instr_pc[G]; // instruction selects the next program counter

    // Initialize the stack
    for (var i = 0; i < STACK_SIZE; i++) {
        stack[0][i] <== 0;
    }
    sp[0] <== 0; // Initialize the stack pointer
    pc[0] <== 0; // Initialize the program counter

    for (clk = 0; clk < G; clk++) {
        mux_sp_topvl[clk] = SinglMux(STACK_SIZE);
        mux_pc_instr[clk] = MultiMux(PROGRAM_SIZE, 2);
        mux_instr_sp[clk] = NextSP();
        mux_instr_pc[clk] = NextPC();

        // Get the top value of the stack
        mux_sp_topvl[clk].sel <== sp[clk];
        mux_sp_topvl[clk].inp <== stack[clk];
        topvl[clk] <== mux_sp_topvl[clk].out;
        
        // Get current opcode and operand
        mux_pc_instr[clk].sel <== pc[clk];
        mux_pc_instr[clk].inp <== program;
        instr[clk] <== mux_pc_instr[clk].out;
        var opcode = instr[clk][0];
        var operand = instr[clk][1];
    
        // Update stack pointer
        mux_instr_sp[clk].sp <== sp[clk];
        mux_instr_sp[clk].opcode <== opcode;
        sp[clk + 1] <== mux_instr_sp[clk].sp_next;

        // Update program counter
        mux_instr_pc[clk].topvl <== topvl[clk];
        mux_instr_pc[clk].pc <== pc[clk];
        mux_instr_pc[clk].opcode <== opcode;
        mux_instr_pc[clk].operand <== operand;
        pc[clk + 1] <== mux_instr_pc[clk].pc_next;

        // TODO: Update the stack

    }

component main = LeeVM(1);
