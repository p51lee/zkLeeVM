#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage:"
    echo "  $0 build                   Build the circuit"
    echo "  $0 exec <input file> <size> Execute with the given input file and size"
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

# Handle the build command
if [ "$1" = "build" ]; then
    # Check if arguments are valid (only the "build" command without additional arguments)
    if [ $# -ne 1 ]; then
        show_help
        exit 1
    fi

    # Step 1: Check if there's a directory named "build" and create it if it doesn't exist
    if [ ! -d "build" ]; then
        mkdir build
    fi

    # Step 2: Run the circom command
    circom circuits/leevm.circom --r1cs --wasm --sym --output build/

    # Step 3: Print completion message
    echo "Circuit build complete."

# Handle the exec command
elif [ "$1" = "exec" ]; then
    # Check if the correct number of arguments are provided
    if [ $# -ne 3 ]; then
        show_help
        exit 1
    fi

    # Step 0: Check if there's a directory named "inputs" and create it if it doesn't exist
    if [ ! -d "inputs" ]; then
        mkdir inputs
    fi

    INPUT_FILE="$2"
    SIZE="$3"

    # Step 1: Run the python command for parsing
    python parser/parse.py "$INPUT_FILE" inputs/parsed_input.json -s "$SIZE"

    # Step 2: Print parsing complete message
    echo "Parsing complete."

    # Step 3: Run the node command for witness generation
    node build/leevm_js/generate_witness.js build/leevm_js/leevm.wasm inputs/parsed_input.json build/witness.wtns

else
    # Invalid command
    show_help
    exit 1
fi


