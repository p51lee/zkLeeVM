# zk-LeeVM

zk-LeeVM is a simple virtual machine written in Circom that is designed to run
a simple assembly-like language. It is a stack-based virtual machine that uses
a stack to store data and instructions. The virtual machine is designed to be
simple and easy to understand, making it a great tool for learning about
virtual machines with zero-knowledge proofs.

## Supported Instructions

The following instructions are supported by zk-LeeVM:

- `HALT`: Halts the virtual machine.
- `PUSH <value>`: Pushes a value onto the top of the stack.
- `POP`: Pops a value from the top of the stack.
- `DROP`: Drops the bottom value from the stack.
- `ADD`: Pops two values from the stack, adds them together, and pushes the result onto the stack.
- `SUB`: Pops two values from the stack, subtracts the second value from the first value, and pushes the result onto the stack.
- `PICK <index>`: Pushes the value at the specified index onto the stack. (0 is the top of the stack)
- `JMP <label>`: Jumps to the specified label.
- `JZ <label>`: Pops a value from the stack and jumps to the specified label if the value is zero.

An example program that calculates the sum of the numbers 1 to 9 is shown below:

```
  PUSH 0        ; Initialize sum with 0  : [<sum>]
  PUSH 1        ; Initialize counter with 1  : [<counter>, <sum>]
LOOP:
  PICK 0        ; Duplicate the top value of the stack : [<counter>, <counter>, <sum>]
  PUSH 10       ; Push the value 10 onto the stack : [10, <counter>, <counter>, <sum>]
  SUB           ; Subtract 10 from the counter : [<counter - 10>, <counter>, <sum>]
  JZ END        ; If the result is zero, jump to END : [<counter>, <sum>]
  PICK 1        ; Duplicate the sum value : [<sum>, <counter>, <sum>]
  PICK 1        ; Duplicate the counter value : [<counter>, <sum>, <counter>, <sum>]
  ADD           ; Add the counter to the sum : [<new sum = sum + counter>, <counter>, <sum>]
  PICK 1        ; Duplicate the counter value : [<counter>, <new_sum>, <counter>, <sum>]
  DROP          ; Remove the sum from the stack : [<counter>, <new_sum>, <counter>]
  DROP          ; Remove the counter from the stack : [<counter>, <new_sum>]
  PUSH 1        ; Push the value 1 onto the stack : [1, <counter>, <new_sum>]
  ADD           ; Add 1 to the counter : [<new_counter = counter + 1>, <new_sum>]
  JMP LOOP      ; Jump back to LOOP
END:
  POP           ; Remove the counter from the stack : [<sum>]
  HALT          ; Stop the program : [<sum>]
```

Note that `HALT` should be the last instruction in the program.

## Prerequisites

To build and run zk-LeeVM, you will need to have the following installed on your
system:

- Circom
- Python3
- NodeJS
- Maybe some other stuff

## Configuring zk-LeeVM

zk-LeeVM can be configured by editing the three parameters at the bottom
of the `leevm.circom` file:

```circom
// gas limit, stack size, program size
component main = LeeVM(1024, 8, 32);
```

The first parameter is the gas limit, which is the maximum number of steps that
the virtual machine can execute before it is halted. This is used to prevent
infinite loops and other malicious behavior.

The second parameter is the stack size, which is the maximum number of values
that can be stored on the stack at any given time. If the stack overflows, the
behavior of the virtual machine is undefined.

The third parameter is the program size, which is the **maximum** number of
instructions that can be written in the program. If the program size is exceeded,
the parser will throw an error and the program will not be compiled.

## Building zk-LeeVM

To build zk-LeeVM, run

```zsh
zsh leevm.sh build
```

This will compile the zk-LeeVM into R1CS format and WASM.

## Running zk-LeeVM

To run zk-LeeVM, run

```zsh
zsh leevm.sh exec <input program> <program size>
```

This will run the zk-LeeVM with the specified input program and program size.
The `<program size>` parameter should be identical to the third parameter in the
`leevm.circom` file.

Below is an example of running the sum program with a maximum program size of 32:

```zsh
> zsh leevm.sh exec sum.lvm 32
Parsing complete.
result:  45
```


