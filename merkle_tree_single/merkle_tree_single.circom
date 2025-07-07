pragma circom 2.0.6;

include "circomlib/circuits/poseidon.circom";

template MerkleTreeSingle() {

    // Here we are proving that we know a single leaf and giving the root as output.
    // Use case can be for validating a single leaf in the tree.

    // We have a tree with 4 leaves and 3 nodes.
    // The leaves are Alice, Bob, Carol, and Dave.
    // Leafs: [1094861636, 4326152, 1134903206, 1140850685]
    // So our Tree would be like this:
    // Alice  = 1094861636
    // Bob    = 4326152
    // Carol  = 1134903206
    // Dave   = 1140850685
    // HAlice = hash(1094861636)     = 10043962727192070154785400858353716520956551778235685074459220481076594860912
    // HBob   = hash(4326152)        = 11980289813790642896255155454627015586350570283570973689633419774222083174439
    // HCarol = hash(1134903206)     = 11265103472039827640029020859339837176692273098739786580935347993247203991254
    // HDave  = hash(1140850685)     = 8485573735375677496821834533685787098901270742075471867357862127350533400129
    // Hnode0 = hash(HAlice, HBob )  = 3631451287813791705673014803696775796874500128914640882961006094149917713332
    // Hnode1 = hash(HCarol, HDave)  = 15159972336041854699025628455382500572946569397575500527875451570086543610549
    // root   = hash(Hnode0, Hnode1) = 11603047984200278528560667444463872103367407312554151724745181633630050055953
    // Just for demonstrate, the whole tree would be like following:
    //       root
    //     /      \
    // node0       node1
    // /    \      /    \
    // A     B    C      D
    // L0    L1   L2     L3
    // Alice Bob  Carol Dave
    // Our input is Carol which is 1134903206, so this is what we have and know:
    //       root
    //            \         <-- RIGHT
    //             node1
    //             /        <-- LEFT
    //            C      
    //            L2     
    //            Carol 
    // pathIndices: [0, 1] -> From Carol, first LEFT (0) and then RIGHT (1) to reach the root.
    //   Remember the path is from root, but for traversin we use this traversing.
    // We also know the leaf which is the secret value that we are trying to prove that we know.
    // Also we know the path elements (sibling nodes) and path to reach the root.

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