pragma circom 2.0.0;

include "../util/mux.circom";
include "../util/compare.circom";

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

template NextPC() {
    signal input topvl;
    signal input pc;
    signal input opcode;
    signal input operand;
    signal output pc_next;

    signal pc_candidates[3];

    component mux = SinglMux(3);
    component cmp_halt = IsEqual();
    component cmp_jmp = IsEqual();
    component cmp_jz = IsEqual();
    component cmp_top_zero = IsZero();

    signal is_halt, is_jmp, is_jz, is_top_zero;
    signal is_jz_tz, is_jump;

    cmp_halt.in[0] <== opcode;
    cmp_halt.in[1] <== 0;
    cmp_halt.out ==> is_halt;

    cmp_jmp.in[0] <== opcode;
    cmp_jmp.in[1] <== 7;
    cmp_jmp.out ==> is_jmp;

    cmp_jz.in[0] <== opcode;
    cmp_jz.in[1] <== 8;
    cmp_jz.out ==> is_jz;

    cmp_top_zero.in <== topvl;
    cmp_top_zero.out ==> is_top_zero;

    is_jz_tz <== is_jz * is_top_zero; // is_jz AND is_top_zero
    is_jump <== is_jmp + is_jz_tz - is_jmp * is_jz_tz; // is_jmp OR is_jz_tz

    // If we halt, context is 2
    // If we jump, context is 1
    // Otherwise, context is 0
    var context = is_halt + is_jump * 2;

    pc_candidates[0] <== pc + 1;  // No jump; next instruction
    pc_candidates[1] <== operand; // Jump to operand
    pc_candidates[2] <== pc;      // Halt: do nothing

    mux.sel <== context;
    mux.inp <== pc_candidates;
    pc_next <== mux.out;
}

