pragma circom 2.0.6;

include "fib.circom";

template fibonancci(n)
{
    signal input fib1;
    signal input fib2;
    signal output fibn;

    fibn <== fibtest(fib1, fib2, n) * fib1;

}

component main = fibonancci(10000);