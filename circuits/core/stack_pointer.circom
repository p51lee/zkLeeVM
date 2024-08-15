pragma circom 2.0.0;

include "../util/mux.circom";

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

template NextSP() {
    var INSTR_SET_SIZE = 9;
    signal input sp;
    signal input opcode;
    signal output sp_next;

    signal sp_candidates[INSTR_SET_SIZE];

    component mux = SinglMux(INSTR_SET_SIZE);

    sp_candidates[0] <== sp;     // HALT
    sp_candidates[1] <== sp + 1; // PUSH
    sp_candidates[2] <== sp - 1; // POP
    sp_candidates[3] <== sp - 1; // DROP
    sp_candidates[4] <== sp - 1; // ADD
    sp_candidates[5] <== sp - 1; // SUB
    sp_candidates[6] <== sp + 1; // PICK
    sp_candidates[7] <== sp;     // JMP
    sp_candidates[8] <== sp - 1; // JZ

    mux.sel <== opcode;
    mux.inp <== sp_candidates;
    sp_next <== mux.out;
}
