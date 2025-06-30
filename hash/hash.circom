pragma circom 2.0.6;

include "circomlib/circuits/poseidon.circom";

template Hash() {
    // Input signal for 11 characters
    // For example: 
    //   "Password123" = [80, 97, 115, 115, 119, 111, 114, 100, 49, 50, 51]
    // We can also pass the string as a single input like below:
    //   80 × 256^10 + 97 × 256^9 + 115 × 256^8 + 115 × 256^7 + 119 × 256^6 + 111 × 256^5 + 114 × 256^4 + 100 × 256^3 + 49 × 256^2 + 50 × 256^1 + 51 × 256^0 = 23618153904663136866254116135179
    // By passing 23618153904663136866254116135179 as a single input, we can avoid the array of characters.
    //   "Password123" = 236181539046631368662541161351
    // Nonce is the randomness to get a unique result for each round (even when the input is same in all rounds).

    signal input x[11];
    signal input nonce; // Optional: Random value to make output unique
    signal output r;

    component hasher = Poseidon(12);
    for (var i = 0; i < 11; i++) {
        hasher.inputs[i] <== x[i];
    }
    hasher.inputs[11] <== nonce; // Optional: Add nonce for uniqueness

    r <== hasher.out;
}

component main = Hash();