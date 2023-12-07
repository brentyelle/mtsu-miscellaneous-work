#include <iostream>
using namespace std;

// desired functions for Part I, #1 through #4
void Extrema(short x, short y, short z, short &max, short &min);
void GCD(short a, short b, short &gcd);
void FactorialLimit(int limit, int &m, int &factorial);
void Binomial(int n, int k, int &binom);

// helper function for Binomial() above
int RecursiveFactorial(int n);

int main() {
    // user-input values
    short user_x;
    short user_y;
    short user_z;
    short user_a;
    short user_b;
    int user_limit;
    int user_n;
    int user_k;
    // results
    short out_min;
    short out_max;
    short out_gcd;
    int out_m;
    int out_factorial;
    int out_binom;
    
    //grab user input and store them
    cout << "Input values of x, y, and z to find their minimum and maximum: ";
    cin >> user_x >> user_y >> user_z;
    Extrema(user_x, user_y, user_z, out_max, out_min);
    cout << "Maximum: " << out_max << endl;
    cout << "Minimum: " << out_min << endl << endl;
    
    cout << "Input values of a and b (with a >= b) to find their GCD: ";
    cin >> user_a >> user_b;
    GCD(user_a, user_b, out_gcd);
    cout << "Greatest Common Divisor: " << out_gcd << endl << endl;
    
    cout << "Input limit to find the largest m such that m! <= limit: ";
    cin >> user_limit;
    FactorialLimit(user_limit, out_m, out_factorial);
    cout << "m  : " << out_m << endl;
    cout << "m! : " << out_factorial << endl << endl;
    
    cout << "Input n and k to find the binomial coefficient C(n,k): ";
    cin >> user_n >> user_k;
    Binomial(user_n, user_k, out_binom);
    cout << "C(n,k) : " << out_binom << endl;
    
    return 0;
}


// Given memory addresses of three byte-size integers, stores their minimum
// and maximum at the memory addresses provided.
void Extrema(short x, short y, short z, short &max, short &min) {
    // all numbers need to be byte-sized
    short byteX = x % 256;
    short byteY = y % 256;
    short byteZ = z % 256;
    
    // first, assume x is Max and Min by default
    short thisMax = byteX;
    short thisMin = byteX;
    
    // compare y and x
    if (byteY > thisMax) {
        thisMax = byteY;
    } else { // if byteY <= byteX
        thisMin = byteY;
    }
    
    // compare z with results of above
    if (byteZ > thisMax) { // if *z is greater than *x and *y
        thisMax = byteZ;
    } else if (byteZ < thisMin) { // if *z is less than *x and *y
        thisMin = byteZ;
    }
    
    // we used local variables to avoid doing so many memory operations
    max = thisMax;
    min = thisMin;
    return;
}

// Given memory addresses of two word-size integers, determines their GCD
// using Euler's algorithm and stores it at the memory address provided.
void GCD(short a, short b, short &gcd) {
    short dividend = a;
    short divisor = b;
    short remainder = 0;
    
    // implementation of Euler's divison algorithm, as directed
    do {
        remainder = (dividend % divisor);
        dividend = divisor;
        divisor = remainder;
    } while (remainder != 0);
    
    gcd = dividend;
    return;
}


// Given an upper limit in [65536, 100000], find the value *m such that
// (*m)! <= limit, storing both *m and (*m)! in the addresses provided.
void FactorialLimit(int limit, int &m, int &factorial) {
    //by default, we can assume 2^16 <= limit <= 100000
    int i = 1;
    int product = 1;
    while (product * (++i) < limit) { //if multiplying by next i would be okay
        product *= i; //then do it
    }
    m = --i; //once we exit, *m is the last i that we successfully used
    factorial = product; //and *factorial is the last product we made
    return;
}

// A helper function written by me. It implements factorial multiplication
// using recursion.
int RecursiveFactorial(int n) {
    if (n <= 0) {
        return 1;
    } else {
        return (n * RecursiveFactorial(n-1));
    }
}

// PROBLEM 4
// Given memory addresses of *n and *k, computes their binomial
// coefficient C(n,k) and stores the result in the address provided.
void Binomial(int n, int k, int &binom) {
    binom = RecursiveFactorial(n) / (RecursiveFactorial(k) * RecursiveFactorial(n-k));
    return;
}
