pragma circom 2.0.6;

include "circomlib/circuits/poseidon.circom";

template MerkleTreeAll() {

    // Here we are prooving that we know every leaf and giving the root as output.
    // Use case can be for validating the whole tree and etc.

    signal input leafs[4];
    signal output root;
    
    
    // Tree construction
    
    // Hash the leafs
    component hasherl0 = Poseidon(1);
    hasherl0.inputs[0] <== leafs[0];
    component hasherl1 = Poseidon(1);
    hasherl1.inputs[0] <== leafs[1];
    component hasherl2 = Poseidon(1);
    hasherl2.inputs[0] <== leafs[2];
    component hasherl3 = Poseidon(1);
    hasherl3.inputs[0] <== leafs[3];
    
    // Calculate nodes
    component hasherN0 = Poseidon(2);
    hasherN0.inputs[0] <== hasherl0.out;
    hasherN0.inputs[1] <== hasherl1.out;
    component hasherN1 = Poseidon(2);
    hasherN1.inputs[0] <== hasherl2.out;
    hasherN1.inputs[1] <== hasherl3.out;

    // Hash nodes and get the root
    component hasherf = Poseidon(2);
    hasherf.inputs[0] <== hasherN0.out;
    hasherf.inputs[1] <== hasherN1.out;
    root <== hasherf.out;
    
}

component main = MerkleTreeAll();