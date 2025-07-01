pragma circom 2.0.6;

include "circomlib/circuits/bitify.circom";

function count(nums, size, ch) {
    var res = 0;
    for (var i = 0; i != size; i++) {
        if (nums[i] == ch) {
            res++;
        }
    }
    return res;
}

function winner_candidate(a, b, c, wasted) {
    var res;
    var max_val = 0;
    if (a > b) {
        res = 1;
        max_val = a;
    }
    else {
        res = 2;
        max_val = b;
    }
    if (c > max_val) {
        res = 3;
        max_val = c;
    }
    if (wasted > max_val) {
        res = 0;
        max_val = wasted;
    }
    return res;
}
template Vote() {
    var NUM_VOTERS = 10;
    
    // "votes": [a, b, b, c, a, b, a, e, a, b]
    // "votes": [1, 2, 2, 3, 1, 2, 1, 4, 1, 2]
    // a: 4, b: 4, c: 1, wasted: 1
    // 1: 4, 2: 4, 3: 1, 4: 1
    // Right now, tie candidate is not handled yet.
    
    signal input votes[NUM_VOTERS];
    signal output candidate_a;
    signal output candidate_b;
    signal output candidate_c;
    signal output wasted;
    signal output result;

    signal num_voters_a <-- count(votes, NUM_VOTERS, 1); 
    signal num_voters_b <-- count(votes, NUM_VOTERS, 2); 
    signal num_voters_c <-- count(votes, NUM_VOTERS, 3); 
    
    candidate_a <== num_voters_a;
    candidate_b <== num_voters_b;
    candidate_c <== num_voters_c;
    wasted <==  NUM_VOTERS - (candidate_a + candidate_b + candidate_c);

    signal result_candidate <-- winner_candidate(candidate_a, candidate_b, candidate_c, wasted);

    result <== result_candidate;
}

component main = Vote();