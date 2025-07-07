pragma circom 2.0.6;

include "circomlib/circuits/poseidon.circom";

template MerkleTreeAll() {

    // Here we are prooving that we know every leaf and giving the root as output.
    // Use case can be for validating the whole tree and etc.

    // We have a tree with 4 leaves and 3 nodes.
    // The leaves are Alice, Bob, Carol, and Dave.
    // Each leaf is represented by a string of characters.
    // We can also pass the string as a single input like below:
    // Alice = [65, 108, 105, 99, 101] -> 65 × 256^4 + 108 × 256^3 + 105 × 256^2 +  99 × 256^1 + 101 × 256^0 = 1094861636
    // Bob   = [66, 111, 98]           -> 66 × 256^2 + 111 × 256^1 +  98 × 256^0                             = 4326152
    // Carol = [67, 97, 114, 111, 108] -> 67 × 256^4 + 97  × 256^3 + 114 × 256^2 + 111 × 256^1 + 108 × 256^0 = 1134903206
    // Dave  = [68, 97, 118, 101]      -> 68 × 256^3 + 97  × 256^2 + 118 × 256^1 + 101 × 256^0               = 1140850685
    // Leafs as input is: [1094861636, 4326152, 1134903206, 1140850685]
    
    // The tree structure is as follows:
    // l0 = Alice. l1 = Bob, l2 = Carol, l3 = Dave
    // node0 = hash(l0, l1), node1 = hash(l2, l3)
    // root = hash(node0, node1)

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