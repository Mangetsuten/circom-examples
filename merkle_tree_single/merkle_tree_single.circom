pragma circom 2.0.6;

include "circomlib/circuits/poseidon.circom";

template MerkleTreeSingle() {

    // Here we are proving that we know a single leaf and giving the root as output.
    // Use case can be for validating a single leaf in the tree.

    signal input leaf; // The leaf we want to prove knowledge of
    signal input pathElements[2]; // Sibling nodes on the path to the root
    signal input pathIndices[2]; // Indices of the sibling nodes (0 for left, 1 for right)
    signal output root;

    // Calculate the first level of the tree
    component leafHasher = Poseidon(1);
    leafHasher.inputs[0] <== leaf; // Hash the leaf
    // Use pathIndices[1] to determine order: 0=level1 goes left, 1=level1 goes right  

    // Calculate inputs for level1 hasher
    signal leafToLeft;
    signal siblingToLeft;
    signal level1Left; // Final left input to level1 hasher

    leafToLeft <== (1 - pathIndices[0]) * leafHasher.out;
    siblingToLeft <== pathIndices[0] * pathElements[0];
    level1Left <== leafToLeft + siblingToLeft;
    
    signal leafToRight;
    signal siblingToRight;
    signal level1Right; // Final right input to level1 hasher

    leafToRight <== pathIndices[0] * leafHasher.out;
    siblingToRight <== (1 - pathIndices[0]) * pathElements[0];
    level1Right <== leafToRight + siblingToRight;
    
    // Calculate the node
    component level1Hasher = Poseidon(2);
    level1Hasher.inputs[0] <== level1Left;
    level1Hasher.inputs[1] <== level1Right;
    
    // Calculate inputs for level2 hasher
    signal nodeToLeft;
    signal pathToLeft;
    signal rootLeft; // Final left input to root hasher
    
    nodeToLeft <== (1 - pathIndices[1]) * level1Hasher.out;
    pathToLeft <== pathIndices[1] * pathElements[1];
    rootLeft <== nodeToLeft + pathToLeft;
    
    signal nodeToRight;
    signal pathToRight;
    signal rootRight; // Final right input to root hasher

    nodeToRight <== pathIndices[1] * level1Hasher.out;
    pathToRight <== (1 - pathIndices[1]) * pathElements[1];
    rootRight <== nodeToRight + pathToRight;

    // Calculate the root
    component rootHasher = Poseidon(2);
    rootHasher.inputs[0] <== rootLeft;
    rootHasher.inputs[1] <== rootRight;

    root <== rootHasher.out;
}

component main = MerkleTreeSingle();