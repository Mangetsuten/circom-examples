pragma circom 2.0.6;

template Div() {
    signal input a;
    signal input b;
    signal output c;

    // Check to see if b is zero (check (1 / b) * b = 1)
    signal inverse;
    inverse <-- 1 / b;
    signal isZero;
    isZero <-- b * inverse;
    isZero === 1;

    c <== a * inverse;
}

component main = Div();