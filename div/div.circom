pragma circom 2.0.6;

template Div() {
    signal input a;
    signal input b;
    signal output c;

    signal inverse;
    inverse <-- b == 0 ? 0 : 1/b;  // Assign 0 when b is 0, otherwise 1/b
    signal isZero;
    isZero <-- b * inverse;
    isZero === 1;

    c <== a * inverse;
}

component main = Div();