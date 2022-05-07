pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matElemMul.circom";
include "../../node_modules/circomlib-matrix/circuits/matSub.circom";
include "../../node_modules/circomlib-matrix/circuits/matElemSum.circom";
include "../../node_modules/circomlib/circuits/gates.circom";

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    component mul[n];
    component sum[n];
    component sub = matSub(n, 1);
    component finalSum = matElemSum(n,1);
    component not = NOT();

    // compute ax
    for (var i=0; i<n; i++) {
        mul[i] = matElemMul(n,1);
        sum[i] = matElemSum(n,1);

        for(var j=0; j<n; j++) {
            mul[i].a[j][0] <== x[j];
            mul[i].b[j][0] <== A[i][j];
        }

        for(var j=0; j<n; j++) {
            sum[i].a[j][0] <== mul[i].out[j][0];
        }

        sub.a[i][0] <== sum[i].out;
        sub.b[i][0] <== b[i];
    }

    for (var i=0; i<n; i++) {
        finalSum.a[i][0] <== sub.out[i][0];
    }

    not.in <== finalSum.out;
    out <== not.out;
}

component main {public [A, b]} = SystemOfEquations(3);