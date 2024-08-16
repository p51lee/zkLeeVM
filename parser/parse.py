import json
import argparse

# Define the opcodes
OPCODES = {
    "HALT": 0,
    "PUSH": 1,
    "POP": 2,
    "DROP": 3,
    "ADD": 4,
    "SUB": 5,
    "PICK": 6,
    "JMP": 7,
    "JZ": 8
}

def parse_vm_program(assembly_code, program_size):
    program = []
    label_map = {}

    # Split the assembly code into lines
    lines = assembly_code.strip().splitlines()

    # First pass to collect label positions
    current_line = 0
    for line in lines:
        # Remove comments
        line = line.split(';', 1)[0].strip()

        if not line:
            continue

        parts = line.split()

        if parts[0][-1] == ":":  # Label definition
            label = parts[0][:-1]
            label_map[label] = current_line
        else:
            current_line += 1

    # Second pass to generate the program
    for line in lines:
        # Remove comments
        line = line.split(';', 1)[0].strip()

        if not line:
            continue

        parts = line.split()

        if parts[0][-1] == ":":  # Skip label lines
            continue

        operation = parts[0].upper()
        opcode = OPCODES.get(operation)

        if opcode is None:
            raise ValueError(f"Unknown operation: {operation}")

        # Handle operand
        if len(parts) > 1:
            operand_str = parts[1]
            if operand_str.isdigit():
                operand = int(operand_str)
            else:
                operand = label_map.get(operand_str)
                if operand is None:
                    raise ValueError(f"Undefined label: {operand_str}")
        else:
            operand = 0

        # Append the parsed instruction to the program list
        program.append([opcode, operand])

    if program[-1][0] != OPCODES["HALT"]:
        raise ValueError("Program must end with HALT instruction")

    # Check if the program size is correct
    if len(program) > program_size:
        raise ValueError(f"Program size exceeds the specified size of {program_size}")
    else:
        # Fill the rest of the program with HALT instructions
        program.extend([[OPCODES["HALT"], 0]] * (program_size - len(program)))

    # Return the JSON object
    return json.dumps({"program": program}, indent=2)

def main():
    # Argument parser setup
    parser = argparse.ArgumentParser(description="Parse a VM assembly file.")
    parser.add_argument("-s", "--program-size", type=int, required=True, help="The maximum size of the parsed program.")
    parser.add_argument('input_file', type=str, help='The input file containing the assembly code.')
    parser.add_argument('output_file', type=str, help='The output file to write the parsed JSON.')

    args = parser.parse_args()

    # Read the input file
    with open(args.input_file, 'r') as infile:
        assembly_code = infile.read()

    # Parse the assembly code
    parsed_result = parse_vm_program(assembly_code, args.program_size)

    # Write the output file
    with open(args.output_file, 'w') as outfile:
        outfile.write(parsed_result)

if __name__ == "__main__":
    main()


