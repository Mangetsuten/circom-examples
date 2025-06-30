pragma circom 2.0.6;

include "circomlib/circuits/bitify.circom";

template Comparator() {

    // Ensuring that a and b are both in valid range (4 bits)
    signal input a;
    signal input b;
    component aBits = Num2Bits(4);
    component bBits = Num2Bits(4);
    aBits.in <== a;
    bBits.in <== b;

    signal output c;
    
    component cBits = Num2Bits(5);
    cBits.in <== a - b + 16;
    
    // The top bit (bit 5) tells us if a > b
    c <== cBits.out[4];

    // Example:
    // a = 5, b = 6
    // cBits = 5 - 6 + 16 = 15 == 01111 ==> c <== 0
    // a = 10, b = 6
    // cBits = 10 - 6 + 16 = 20 == 10100 ==> c <== 1
}

component main = Comparator();