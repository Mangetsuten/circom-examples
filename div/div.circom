pragma circom 2.0.6;

template Div() {
    signal input a;
    signal input b;
    signal output c;

    signal inverse;
    inverse <-- b == 0 ? 0 : 1/b;  // Assign 0 when b is 0, otherwise 1/b
    // b = 0 => inverse = 0 => 0 * 0 = 0 != 1
    // b != 0 => inverse = 1/b => b * 1/b = 1
    // Further details is available in README.md
    signal isNotZero;
    isNotZero <-- b * inverse;
    isNotZero === 1;

    c <== a * inverse;
}

component main = Div();