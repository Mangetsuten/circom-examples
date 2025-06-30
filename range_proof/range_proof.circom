pragma circom 2.0.6;

include "circomlib/circuits/bitify.circom";

template RangeProof(){

    // 0 <= x < 100
    signal input x;
    signal output r;

    component xBits = Num2Bits(7);
    xBits.in <== x;

    // x - 100 < 0
    signal result;
    component resultBits = Num2Bits(8);
    resultBits.in <== 99 - x + 128; // or x - 100 + 128, but flip the [7] bit at the end
    // x + 0 > 0 doesn't get checked, because we can not pass negative value to x as input in Circom.

    r <== resultBits.out[7];
}

component main = RangeProof();
