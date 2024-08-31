pragma circom 2.0.0;

include "./util/mux.circom";
include "./core/stack_pointer.circom";
include "./core/program_counter.circom";
include "./core/stack.circom";

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

template LeeVM(G, STACK_SIZE, PROGRAM_SIZE) {
    var INSTR_SET_SIZE = 9;

    signal input program[PROGRAM_SIZE][2];  // The program, where each instruction is a pair (opcode, operand)
    signal output result; // Final result after execution; the top of the stack

    var clk;

    signal instr[G][2]; // executed instrs: instr[i] = op at clock cycle i

    // states: G+1 states, including the initial state
    signal stack[G+1][STACK_SIZE]; // stack trace; stack[i] = stack before ith op
    signal topvl[G]; // stack top value trace
    signal sp[G+1]; // stack pointer trace
    signal pc[G+1]; // program counter log

    component mux_sp_topvl[G]; // stack pointer selects the top value
    component mux_pc_instr[G]; // program counter selects the instruction
    component mux_final = SinglMux(STACK_SIZE); // final result is the top value of the stack
    component next_sp[G];
    component next_pc[G];
    component next_stack[G];

    // Initialize the stack
    for (var i = 0; i < STACK_SIZE; i++) {
        stack[0][i] <== 0;
    }
    sp[0] <== 0; // Initialize the stack pointer
    pc[0] <== 0; // Initialize the program counter

    for (clk = 0; clk < G; clk++) {
        mux_sp_topvl[clk] = SinglMux(STACK_SIZE);
        mux_pc_instr[clk] = MultiMux(PROGRAM_SIZE, 2);
        next_sp[clk] = NextSP();
        next_pc[clk] = NextPC();
        next_stack[clk] = NextStack(STACK_SIZE);

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
        next_sp[clk].sp <== sp[clk];
        next_sp[clk].opcode <== opcode;
        sp[clk + 1] <== next_sp[clk].sp_next;

        // Update program counter
        next_pc[clk].topvl <== topvl[clk];
        next_pc[clk].pc <== pc[clk];
        next_pc[clk].opcode <== opcode;
        next_pc[clk].operand <== operand;
        pc[clk + 1] <==next_pc[clk].pc_next;

        // Update stack
        next_stack[clk].stack <== stack[clk];
        next_stack[clk].sp <== sp[clk];
        next_stack[clk].opcode <== opcode;
        next_stack[clk].operand <== operand;
        stack[clk + 1] <== next_stack[clk].stack_next;
    }

    var final_stack[STACK_SIZE] = stack[G];
    mux_final.inp <== final_stack;
    mux_final.sel <== sp[G];
    result <== mux_final.out;
    log("result: ", result);
}

// gas limit, stack size, program size
component main = LeeVM(1024, 8, 32);

