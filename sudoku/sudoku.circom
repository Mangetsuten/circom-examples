pragma circom 2.0.6;


function inRange(x) {
    return x * (x - 1) * (x - 2) * (x - 3) * (x - 4) * (x - 5) * (x - 6) * (x - 7) * (x - 8) * (x - 9);
}

template IsEqual() {
    signal input in[2];
    signal output out;

    // Calculate the difference
    signal diff;
    diff <== in[0] - in[1];
    // We want to have out = 1 if in[0] == in[1], otherwise out = 0
    // Intial formula would be out + (diff * inverseOfDiff) = 1
    // Rearranging gives us (out = 1 - (diff * inverseOfDiff))
    // diff  = 0 -> 0 = 1 - out -> out = 1
    // diff != 0 -> 1 = 1 - out -> out = 0
    // For futher information of how diff * inverseOfDiff = 1, checkout README.md for div example
    
    signal inverse <-- diff == 0 ? 0 : 1/diff;
    out <== 1 - diff * inverse;
    out * diff === 0;
}

template IsUnique(n) {
    signal input in[n];
    component eq[n][n];

    for (var i = 0; i < n; i++) {
        var sum = 0;
        for (var j = 0; j < n; j++) {
            eq[i][j] = IsEqual();
            eq[i][j].in[0] <== i + 1;
            eq[i][j].in[1] <== in[j];
            sum += eq[i][j].out;
        }
        sum === 1;
    }
}

template Sudoku(n, boxSize) {

    // Key Thinking Points:
    // 1. What constraints do you need?
    //  Row constraints: Each row has numbers 1-9 exactly once
    //  Column constraints: Each column has numbers 1-9 exactly once
    //  Box constraints: Each 3x3 box has numbers 1-9 exactly once
    //  Puzzle constraints: Solution matches the given puzzle (where puzzle ≠ 0)
    // 2. How to represent the constraints?
    //  How do you check "each number 1-9 appears exactly once"?
    //  How do you iterate through rows, columns, and 3x3 boxes?
    //  How do you ensure solution[i][j] = puzzle[i][j] when puzzle[i][j] ≠ 0?
    // 3. Circuit structure questions:
    //  How many signal inputs do you need?
    //  What should be the output? (Just a validity flag?)
    //  How do you handle the 9x9 grid in Circom?

    signal input puzzle[n][n];
    signal input solution[n][n];
    signal output valid;

    signal puzzelRangeCheck[n][n];
    signal solutionRangeCheck[n][n];
    for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
            // Ensure each cell in the puzzle and solution is in range 1-9
            puzzelRangeCheck[i][j] <-- inRange(puzzle[i][j]);
            solutionRangeCheck[i][j] <-- inRange(solution[i][j]);
            puzzelRangeCheck[i][j] === 0;
            solutionRangeCheck[i][j] === 0;

            // Check if the puzzle and solution are the same sudoku puzzle
            //  when puzzle[i][j] == 0 -> (0 - x) * 0 === 0
            //  when puzzle[i][j] == x -> (x - x) * x === 0
            (puzzle[i][j] - solution[i][j]) * puzzle[i][j] === 0;
        }
    }

    component uniqueRow[n];
    component uniqueCol[n];

    for (var i = 0; i < n; i++) {
        uniqueRow[i] = IsUnique(n);
        uniqueRow[i].in <== solution[i];
        uniqueCol[i] = IsUnique(n);
        for (var j = 0; j < n; j++) {
            uniqueCol[i].in[j] <== solution[j][i];
        }
    }

    component uniqueBox[n];
    var boxIdx = 0;
    for (var boxRow = 0; boxRow < n; boxRow += boxSize) {
        for (var boxCol = 0; boxCol < n; boxCol += boxSize) {
            uniqueBox[boxIdx] = IsUnique(n);
            for (var i = 0; i < boxSize; i++) {
                for (var j = 0; j < boxSize; j++) {
                    uniqueBox[boxIdx].in[i * boxSize + j] <== solution[boxRow + i][boxCol + j];
                }
            }
            boxIdx++;
        }
    }

    valid <== 1;
}

component main = Sudoku(9, 3);