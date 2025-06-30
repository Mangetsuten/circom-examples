#!/bin/bash

set -e

# Prompt for circuit name (without extension)
read -p "Enter the circuit name (without .circom): " CIRCUIT_NAME

# Prompt for ptau option
read -p "Do you want to generate a custom ptau file (custom contain 3 contributions)? (y/n): " CUSTOM_PTAU

# Prompt for utility functions
read -p "Do you want to use utility functions (exporting json for some steps to get humand-readable json files)? (y/n): " USE_UTILITY

ROOT_DIR="$(pwd)/$CIRCUIT_NAME"

# Compile circuit
cd "$ROOT_DIR"
circom "$CIRCUIT_NAME.circom" --r1cs --wasm --sym -l $HOME/.npm-global/lib/node_modules
node "${CIRCUIT_NAME}_js/generate_witness.js" "${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm" input.json witness.wtns

if [[ "$USE_UTILITY" == "y" || "$USE_UTILITY" == "Y" ]]; then
    # Export human-readable JSON files
    snarkjs r1cs export json "$ROOT_DIR/$CIRCUIT_NAME.r1cs" "$ROOT_DIR/$CIRCUIT_NAME.r1cs.json"
    snarkjs wtns export json "$ROOT_DIR/witness.wtns" "$ROOT_DIR/witness.json"
else
    echo "Skipping JSON export for r1cs and witness."
fi
snarkjs wtns check "$ROOT_DIR/$CIRCUIT_NAME.r1cs" "$ROOT_DIR/witness.wtns"

# Setup ptau
cd "$ROOT_DIR"
mkdir -p powersoftau
cd powersoftau

if [[ "$CUSTOM_PTAU" == "y" || "$CUSTOM_PTAU" == "Y" ]]; then
    PTAU_FILE="phase1_pot12_final.ptau"
    if [[ -f "$PTAU_FILE" ]]; then
        echo "Found existing custom ptau file: $PTAU_FILE"
        echo "Using previously generated ptau. If you want to regenerate, delete the powersoftau folder first."
    else
        echo "Generating custom ptau file..."
        snarkjs powersoftau new bn128 12 phase1_pot12_00.ptau -v
        snarkjs powersoftau contribute phase1_pot12_00.ptau phase1_pot12_01.ptau --name="First contribution" -v -e="Random text 1"
        snarkjs powersoftau contribute phase1_pot12_01.ptau phase1_pot12_02.ptau --name="Second contribution" -v -e="Random text 2"
        snarkjs powersoftau export challenge phase1_pot12_02.ptau phase1_challenge_03
        snarkjs powersoftau challenge contribute bn128 phase1_challenge_03 phase1_response_03 -e="Random Text"
        snarkjs powersoftau import response phase1_pot12_02.ptau phase1_response_03 phase1_pot12_03.ptau -n="Third contribution"
        snarkjs powersoftau beacon phase1_pot12_03.ptau phase1_pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
        snarkjs powersoftau prepare phase2 phase1_pot12_beacon.ptau phase1_pot12_final.ptau -v
        snarkjs powersoftau verify phase1_pot12_final.ptau
    fi
else
    PTAU_FILE="powersOfTau28_hez_final_08.ptau"
    if [[ -f "$PTAU_FILE" ]]; then
        echo "Found existing downloaded ptau file: $PTAU_FILE"
        echo "Using previously downloaded ptau. If you want to re-download, delete the powersoftau folder first."
    else
        echo "Downloading ptau file..."
        wget -O powersOfTau28_hez_final_08.ptau https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_08.ptau
    fi
fi

# Create the key for prover
cd "$ROOT_DIR"
mkdir -p zkey
cd zkey
snarkjs plonk setup "../$CIRCUIT_NAME.r1cs" "../powersoftau/$PTAU_FILE" "phase1_${CIRCUIT_NAME}_power_plonk.zkey"

# Create the key for verifier
snarkjs zkey export verificationkey "phase1_${CIRCUIT_NAME}_power_plonk.zkey" verification_key_plonk.json

# Generate the proof
cd "$ROOT_DIR"
snarkjs plonk prove "zkey/phase1_${CIRCUIT_NAME}_power_plonk.zkey" witness.wtns proof.json public.json

# Verify the proof
snarkjs plonk verify zkey/verification_key_plonk.json public.json proof.json
