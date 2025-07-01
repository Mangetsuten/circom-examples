pragma circom 2.0.6;

include "circomlib/circuits/bitify.circom";

function sum(nums, n) {
    var c = 0;
    for (var i = 0; i < n; i++) {
        c += nums[i];
    }

    return c;
}


template Vote() {
    var NUM_VOTERS = 10;
    var MAJORITY_THRESHOLD = NUM_VOTERS / 2;  // Integer division
    var OFFSET = 16;
    
    signal input votes[NUM_VOTERS];
    signal output result;

    signal total;
    total <== sum(votes, NUM_VOTERS);
    // total > MAJORITY_THRESHOLD => total - MAJORITY_THRESHOLD > 0 => result <== 1, otherwise result <== 0
    component tBits = Num2Bits(5);
    tBits.in <== total - MAJORITY_THRESHOLD + OFFSET;

    result <== tBits.out[4];
}

component main = Vote();
