# circom-examples
Some Circom example for lerning ZKP. This repo is just for learning purpose. Any new example is welcome. You can just create a folder for your circuit and add your circuit and result files there and then create a pull request.

Branch `full_example` is the directory that have all the files and you can just simply run verification or even read the related json file.\
Branch `main` is just the circom files and you can create witness with your desired inputs and tweak with each circom file and other stuff. 

**Wish you happy proving!**


# Requirements
- [Node.js](https://nodejs.org/en/download/) (v16 or later)
- [Circom](https://docs.circom.io/getting-started/installation/)
- SnarkJS: <code>npm install snarkjs</code>

# Building
You can build and get the verification by running the build script. Just add you circuit file with proper name. You main Circom file should have the same name as your folder. Example of stucture can be seen in already circuits (e.g., add, fibonacci).\
You just need to run `build.sh` and then pass the name of your circuit file (without `.circom` extension).\
Next section I showed each command too, you can manually follow the next section too.

# Commands
Here is the commands to run the example in this repo. You can just copy and paste them in your terminal.\
I will describe each command just shortly.

## Generate r1cs, wasm and sym file
r1cs is the circuit file, wasm is the compiled circuit and sym is the symbol file that contains the variable names and their indexes. sym is not necessary but it is useful for debugging and understanding the circuit.
<pre><code>circom CIRCUIT_NAME.circom --r1cs --wasm --sym</code></pre>

## Generate witness with input
You need to create a `input.json` file that contains the input values for the circuit. The input file should be in JSON format and should match the input variables defined in the circuit. `witness.wtns` is the output file that contains the witness values for the circuit. This file is used to generate the proof. This file is not human readable. If you want to see the witness values in a human readable format, you can use the `snarkjs wtns export json` command ([Some utility functions](#some-utility-functions)).
<pre><code>node CIRCUIT_NAME_js/generate_witness.js CIRCUIT_NAME_js/CIRCUIT_NAME.wasm input.json witness.wtns</code></pre>

## Some utility functions
This command will give you some information about the circuit like number of constraints, number of variables, etc.
<pre><code>snarkjs r1cs info CIRCUIT_NAME.r1cs</code></pre>

This command will print the circuit constraints in a human readable format. It will show you the variable names and their indexes, which is useful for debugging and understanding the circuit.
<pre><code>snarkjs r1cs print CIRCUIT_NAME.r1cs CIRCUIT_NAME.sym</code></pre>

This command will export the circuit constraints in JSON format. This is useful for debugging and understanding the circuit.
<pre><code>snarkjs r1cs export json CIRCUIT_NAME.r1cs CIRCUIT_NAME.r1cs.json</code></pre>

This command will check the witness file for consistency and correctness. It will verify that the witness file is valid and matches the circuit constraints.
<pre><code>snarkjs wtns check witness.wtns</code></pre>

This command will export the witness file in JSON format. This is useful for debugging and understanding the witness values.
<pre><code>snarkjs wtns export json witness.wtns witness.json</code></pre>

## Setup for Powers of Tau
In repo root directory run the following:
<pre><code>mkdir powersoftau && cd powersoftau</code></pre>
Now you have two options, you can either generate the Powers of Tau file from scratch or you can download a pre-generated file.

### Option 1: Generate Powers of Tau file from scratch
This will take a long time and will require a lot of memory. You can use the `snarkjs powersoftau` command to generate the Powers of Tau file. The following commands will generate the Powers of Tau file from scratch.\
It will create a file named `phase1_pot12_00.ptau` in the `powersoftau` directory. You can change the name of the file if you want. The `-v` flag is for verbose output.\
Naming: <PHASE_NO>\_<power_of_tau><POWER_OF_SIZE_OF_CIRCUIT>\_<CONTRIBUTION_INCREMENTER>.ptau. Here; first phase for powers of tau with a circuit size of $2^{12}$ and first contribution. Circuit size refers to the number of gates (constraints).
<pre><code>snarkjs powersoftau new bn128 12 phase1_pot12_00.ptau -v</code></pre>
Then you can contribute to the Powers of Tau file by running the following commands. Each contribution will create a new file with a different name. The `-e` flag is for the entropy used in the contribution. You can change the name and entropy text as you wish. Higher contributions will make the Powers of Tau file more secure. The `-n` flag is for the name of the contribution.
<pre><code>snarkjs powersoftau contribute phase1_pot12_00.ptau phase1_pot12_01.ptau --name="First contribution" -v -e="Random text 1"
snarkjs powersoftau contribute phase1_pot12_01.ptau phase1_pot12_02.ptau --name="Second contribution" -v -e="Random text 2"</code></pre>
After that, you can export a challenge from the Powers of Tau file. This will create a file named `phase1_challenge_01` in the `powersoftau` directory. You can change the name of the file if you want. The purpose of this challenge is to allow participants to contribute to the Powers of Tau file. The `-e` flag is for the entropy used in the challenge.\
This step shows that, we can use third party tools to contribute to the Powers of Tau file. You can use any third party tool that supports the Powers of Tau format.\
Then you can import the response from the third party tool and create a new Powers of Tau file with the response. The `-n` flag is for the name of the contribution.\
The important note is, that third party doesn't have direct access to the current ptau file.\
First we `export challenge` from the current Powers of Tau file. This file contains data that someone else can use to make a contribution.
<pre><code>snarkjs powersoftau export challenge phase1_pot12_02.ptau phase1_challenge_03</code></pre>
Now the challenge file can be sent to another participant who can contribute to the Powers of Tau file (here, we just demonstrating, but we can send it to someone else for further processing). The participant can use the `snarkjs powersoftau challenge contribute` command to contribute to the Powers of Tau file. The `-e` flag is for the entropy used in the contribution. The `-n` flag is for the name of the contribution.\
<pre><code>snarkjs powersoftau challenge contribute bn128 phase1_challenge_03 phase1_response_03 -e="Random Text"</code></pre>
And then we just import the response into the Powers of Tau file. This will create a new Powers of Tau file with the response. The `-n` flag is for the name of the contribution.\
<pre><code>snarkjs powersoftau import response phase1_pot12_02.ptau phase1_response_03 phase1_pot12_03.ptau -n="Third contribution"</code></pre>
Finally you use beacon for the final contribution to the Powers of Tau file. Purpose of this beacon is to add an additional layer of security and randomness to the Powers of Tau file.
<pre><code>snarkjs powersoftau beacon phase1_pot12_03.ptau phase1_pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
snarkjs powersoftau prepare phase2 phase1_pot12_beacon.ptau phase1_pot12_final.ptau -v</code></pre>
And now you have the final Powers of Tau file named `phase1_pot12_final.ptau` in the `powersoftau` directory. You can use this file for the next steps. You can use the following for verifying it.
<pre><code>snarkjs powersoftau verify phase1_pot12_final.ptau</code></pre>

### Option 2: Download a pre-generated Powers of Tau file
You can download a pre-generated Powers of Tau file from the internet. You can use [Snarkjs](https://github.com/iden3/snarkjs?tab=readme-ov-file#7-prepare-phase-2) iteslf to download some prepared Power of Tau files. Then you just need to copy the Powers of Tau file in the `powersoftau` directory.


## Generate proving key (zkey file)
In repo root directory run the following:
<pre><code>mkdir zkey && cd zkey</code></pre>

Now you need to create a setup for Plonk. You can use the `snarkjs plonk setup` command to create the setup. The following commands will create the setup for Plonk.\
Pass your Powers of Tau file and r1cs file and you will have a proving key in `zkey` directory.
<pre><code>snarkjs plonk setup CIRCUIT_NAME.r1cs powersoftau/POT_FINAL.ptau zkey/CIRCUIT_NAME_POWER_PLONK.zkey</code></pre>

## Generated the key for verifier
In `zkey` directory run the following command to generate the verification key for the verifier. This will create a file named `verification_key_plonk.json` in the `zkey` directory which is your verification key.
<pre><code>snarkjs zkey export verificationkey CIRCUIT_NAME_POWER_PLONK.zkey verification_key_plonk.json</code></pre>

## Generate the proof (solution)
Go back into the repo root directory and run the following command to generate the proof itself. Pass your proving key (`zkey/CIRCUIT_NAME_POWER_PLONK.zkey`) and witness file (`witness.wtns`). Outputs are, the `proof.json` file which contain the proof itself, and the `public_info.json` file that contain the public inputs/outputs for the circuit.
<pre><code>snarkjs plonk prove zkey/CIRCUIT_NAME_POWER_PLONK.zkey witness.wtns proof.json public_info.json</code></pre>

## Verify the proof
In repo root directory you can verify the proof with the verification key and the public inputs/outputs. The `verification_key_plonk.json` file contains the verification key for the circuit.
<pre><code>snarkjs plonk verify zkey/verification_key_plonk.json public_info.json proof.json</code></pre>

# DICLAIMER
This repository is for learning purposes only. Do not use the proving and verification keys here for any production or sensitive applications.