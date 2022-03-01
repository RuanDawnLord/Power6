#include <stdio.h>
#include <iostream> 
using namespace std; 

//const int threadAmount = 512;       //12345, 2m44s
//const int threadAmount = 256;   //12345, 2m28s
//const int threadAmount = 128;   //12345, 2m26s
//const int threadAmount = 64;   //12345, 2m27s
const int threadAmount = 32;   //12345, 3m17s
//const int threadAmount = 2;   //12345, 3m15s

__host__
double getUpperC(double a, int b){
    return pow((a-b), 1.0f/6) * 
           pow((a+b), 1.0f/6) *
           pow(a, 1.0f/6) *
           pow(a, 1.0f/6) *
           pow((a-b+(b/a)*b), 1.0f/6) *
           pow((a+b+(b/a)*b), 1.0f/6);
}

__host__
double getLowerC(double a, int b){
    return pow((a-b), 1.0f/6) * 
           pow((a+b), 1.0f/6) *
           pow(a, 1.0f/6) *
           pow(a, 1.0f/6) *
           pow((a-b+(b/a)*b), 1.0f/6) *
           pow((a+b+(b/a)*b), 1.0f/6)/pow(4, 1.0f/6);
}

__host__
double getUpperD(double a, int b, int c){
    return a * pow((1-(b/a)*(b/a)*(b/a)*(b/a)*(b/a)*(b/a)-(c/a)*(c/a)*(c/a)*(c/a)*(c/a)*(c/a)),1.0f/6);
}

__host__
double getLowerD(double a, int b, int c){
    return a * pow((1-(b/a)*(b/a)*(b/a)*(b/a)*(b/a)*(b/a)-(c/a)*(c/a)*(c/a)*(c/a)*(c/a)*(c/a)),1.0f/6)/pow(3,1.0f/6);
}

__host__
int host_getModOf6Power(uint64_t base, int mod){
    int exp = 6;
    int res = 1;
    while (exp > 0) {
       if (exp % 2 == 1)
          res= (res * base) % mod;
       exp = exp >> 1;
       base = (base * base) % mod;
       //base = ((base % mod) * (base % mod)) % mod;
    }
    return res;

}

__host__
int getLeftModSubIn3Numbers(int prime, int a, int b, int c){
    int result = host_getModOf6Power(a, prime) - host_getModOf6Power(b, prime) - host_getModOf6Power(c, prime);
    while (result < 0){
        result += prime;
    }
    return result;
}
__host__
bool isDecomposableIn3Numbers(int a, int b, int c){
    //bool result = true;
    //int primes[4] = {13,19,31,37};
    int tmp = getLeftModSubIn3Numbers(7,a,b,c);
    
    switch(tmp){  case 5:  case  6:return false;}
    if(getLeftModSubIn3Numbers(13,a,b,c) == 10)return false;

    tmp = getLeftModSubIn3Numbers(19,a,b,c);
    switch(tmp){ case  5 :  case  16 :  case 17: return false;}

    tmp = getLeftModSubIn3Numbers(31,a,b,c);
    //switch(tmp){  case 15 :  case 23 :  case  27 :  case  29:  case 30) return false;
    switch(tmp){
        case 15: case 23: case 27: case 29: case 30:
            return false;

    }

    tmp = getLeftModSubIn3Numbers(37,a,b,c);
    switch(tmp){  case 4:  case  5:  case  6:  case  7:  case  8:  case  14:  case  24:  case  34: 
        return false; 
    }
    return true;
}


/////////////////////////on Device
__device__
int getModOf6Power(uint64_t base, int mod){
    int exp = 6;
    int res = 1;
    while (exp > 0) {
       if (exp % 2 == 1)
          res= (res * base) % mod;
       exp = exp >> 1;
       base = (base * base) % mod;
       //base = ((base % mod) * (base % mod)) % mod;
    }
    return res;

}

__device__
double getUpperE(double a, int b, int c, int d){
    return a * pow((1-(b/a)*(b/a)*(b/a)*(b/a)*(b/a)*(b/a)-(c/a)*(c/a)*(c/a)*(c/a)*(c/a)*(c/a)-(d/a)*(d/a)*(d/a)*(d/a)*(d/a)*(d/a)), 1.0f/6);
}

__device__
double getLowerE(double a, int b, int c, int d){
    return a * pow((1-(b/a)*(b/a)*(b/a)*(b/a)*(b/a)*(b/a)-(c/a)*(c/a)*(c/a)*(c/a)*(c/a)*(c/a)-(d/a)*(d/a)*(d/a)*(d/a)*(d/a)*(d/a))/2, 1.0f/6);
}

__device__
double getUpperF(double a, int b, int c, int d, int e){
    return a * pow((1-(b/a)*(b/a)*(b/a)*(b/a)*(b/a)*(b/a)-(c/a)*(c/a)*(c/a)*(c/a)*(c/a)*(c/a)-(d/a)*(d/a)*(d/a)*(d/a)*(d/a)*(d/a)-(e/a)*(e/a)*(e/a)*(e/a)*(e/a)*(e/a)), 1.0f/6);
}

__device__
int getLeftModSubIn2Numbers(int prime, int a, int b, int c, int d){
    int result = getModOf6Power(a, prime) - getModOf6Power(b, prime) - getModOf6Power(c, prime) - getModOf6Power(d, prime);
    while (result < 0){
        result += prime;
    }
    return result;
}
__device__
int getLeftModSubIn1Numbers(int prime, int a, int b, int c, int d, int e){
    int result = getModOf6Power(a, prime) - getModOf6Power(b, prime) - getModOf6Power(c, prime) - getModOf6Power(d, prime) - getModOf6Power(e, prime);
    while (result < 0){
        result += prime;
    }
    return result;
}


__device__
bool isABCDEFModEqual(int a, int b, int c, int d, int e, int f){
    //there are 168 primes up to 1000
    //int primes1000[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997};
    int primes1000[] = {2, 3, 5, 7};
    //for(int i = 0; i < 168; i++){
    for(int i = 0; i < 4; i++){
        int result = getModOf6Power(a, primes1000[i]) - getModOf6Power(b, primes1000[i]) - 
                    getModOf6Power(c, primes1000[i]) - getModOf6Power(d, primes1000[i]) - 
                     getModOf6Power(e, primes1000[i]) - getModOf6Power(f, primes1000[i]);
        // printf("getModOf6Power(a, primes1000[i]): %d\n", getModOf6Power(a, primes1000[i]));
        // printf("getModOf6Power(b, primes1000[i]): %d\n", getModOf6Power(b, primes1000[i]));
        // printf("getModOf6Power(c, primes1000[i]): %d\n", getModOf6Power(c, primes1000[i]));
        // printf("getModOf6Power(d, primes1000[i]): %d\n", getModOf6Power(d, primes1000[i]));
        // printf("getModOf6Power(e, primes1000[i]): %d\n", getModOf6Power(e, primes1000[i]));
        // printf("getModOf6Power(f, primes1000[i]): %d\n", getModOf6Power(f, primes1000[i]));
        // printf("primes1000[i]: %d\n", primes1000[i]);
        // printf("aInt: %d, bInt: %d, cInt: %d, dInt: %d, eInt: %d, fInt: %d, i: %d\n", a, b, c, d, e, f, i);
        // printf("result before while: %d\n", result);
        
        while (result < 0){
            result += primes1000[i];
        }
        if(result != 0){
            // printf("getModOf6Power(a, primes1000[i]): %d\n", getModOf6Power(a, primes1000[i]));
            // printf("getModOf6Power(b, primes1000[i]): %d\n", getModOf6Power(b, primes1000[i]));
            // printf("getModOf6Power(c, primes1000[i]): %d\n", getModOf6Power(c, primes1000[i]));
            // printf("getModOf6Power(d, primes1000[i]): %d\n", getModOf6Power(d, primes1000[i]));
            // printf("getModOf6Power(e, primes1000[i]): %d\n", getModOf6Power(e, primes1000[i]));
            // printf("getModOf6Power(f, primes1000[i]): %d\n", getModOf6Power(f, primes1000[i]));
            // printf("aInt: %d, bInt: %d, cInt: %d, dInt: %d, eInt: %d, fInt: %d, i: %d\n", a, b, c, d, e, f, i);
            // printf("primes1000[i]: %d\n", primes1000[i]);
            // printf("i in isABCDEFModEqual is :%d, result is: %d.\n", i, result);
            return false;
        }
    }

    return true;
}


__device__
bool isDecomposableIn2Numbers(int a, int b, int c, int d){
    //bool result = true;
    //int primes[12] = {7,13,19,31,37,43,61,67,73,79,109,139};
    int tmp = getLeftModSubIn2Numbers(7,a,b,c,d);
    switch(tmp){ case  4:  case  5:  case  6:
        return false;
    }
    
    tmp = getLeftModSubIn2Numbers(13,a,b,c,d);
    switch(tmp){  case 3:  case  4:  case  9:  case  10:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(19,a,b,c,d);
    switch(tmp){  case 4:  case  5:  case  6:  case  9:  case  10:  case  13:  case  15:  case  16:  case  17:
        return false;
    }

    tmp = getLeftModSubIn2Numbers(31,a,b,c,d);
    switch(tmp){  case 7:  case  11:  case  13:  case  14:  case  15:  case  19: case  21:  case  22:  case  23:  case  25:  case  26:  case  27: case  28:  case  29:  case  30:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(37,a,b,c,d);
    switch(tmp){  case 3:  case  4: case 5:  case  6:  case  7:  case  8:  case  13: case 14:  case  18:  case  19:  case  23:  case  24:  case  29:  case  30: case  31:  case  32:  case  33:  case  34:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(43,a,b,c,d);
    switch(tmp){  case 6:  case  7:  case  10:  case  18: case  23:  case  24:  case  26: case  28:  case  29:  case  30:  case  31:  case  34:  case  38:  case  40:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(61,a,b,c,d);
    switch(tmp){  case 5:  case  13:  case  15:  case  16:  case  22:  case  39: case  45:  case  46:  case  48:  case  56:
        return false;
    }

    tmp = getLeftModSubIn2Numbers(67,a,b,c,d);
    switch(tmp){  case 3:  case  5:  case  8:  case  27:  case  42:  case  43:  case  45: case  52:  case  53:  case  58:  case  66:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(73,a,b,c,d);
    switch(tmp){  case 13:  case  14:  case  20:  case  29:  case  31:  case  34:  case  39: case  42:  case  44:  case  53:  case  59:  case  60:
        return false;
    }

    tmp = getLeftModSubIn2Numbers(79,a,b,c,d);
    switch(tmp){  case 12:  case  14:  case  15:  case  17:  case  27:  case  33:  case  41: case  57:  case  58:  case  61:  case  69:  case  71:  case  78:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(109,a,b,c,d);
    switch(tmp){  case 6:  case  10:  case  13:  case  14:  case  24:  case  40:  case  51: case  52:  case  53:  case  56:  case  57:  case  58:  case  69:  case  85: case  95:  case  96: case  99:  case  103:
        return false;
    }
    tmp = getLeftModSubIn2Numbers(139,a,b,c,d);
    switch(tmp){  case 8:  case  10:  case  14:  case  23:  case  27:  case  33:  case  39: case  48:  case  59:  case  60:  case  62:  case  74:  case  75:  case  76: case  82:  case  84:  case  87:  case  94:  case  95:  case  103:  case  105: case  133:  case  138:
        return false;
    }
    return true;
}

__device__
bool isDecomposableIn1Numbers(int a, int b, int c, int d, int e){
    //bool result = true;
    //int primes[12] = {7,13,19,31,37,43,61,67,73,79,109,139};
    //int primes[15] = {3,5,7,11,13,17,19,23,29,31,37,41,43,47,53};
    int tmp = getLeftModSubIn1Numbers(3,a,b,c,d,e);
    switch(tmp){  case 2:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(5,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:
    return false;
    }
    tmp = getLeftModSubIn1Numbers(7,a,b,c,d,e);
    switch(tmp){  case 3:  case  4:  case  5:  case  6:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(11,a,b,c,d,e);
    switch(tmp){  case 2:  case  6:  case  7:  case  8:  case  10:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(13,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  8:  case  9:  case  10:  case  11:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(17,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  10:  case  11:  case  12:  case  14:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(19,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  8:  case  9:  case  10:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(23,a,b,c,d,e);
    switch(tmp){  case 5:  case  7:  case  10:  case  11:  case  14:  case  15:  case  17:  case  19:  case  20:  case  21:  case  22:
        return false;
    }    
    tmp = getLeftModSubIn1Numbers(29,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  8:  case  10:  case  11:  case  12:  case  14:  case  15:  case  17:  case  18:  case  19:  case  21:  case  26:  case  27:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(31,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(37,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  8:  case  9:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(41,a,b,c,d,e);
    switch(tmp){  case 3:  case  6:  case  7:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  19:  case  22:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  34:  case  35:  case  38:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(43,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  19:  case  20:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  36:  case  37:  case  38:  case  39:  case  40:  case  42:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(47,a,b,c,d,e);
    switch(tmp){  case 5:  case  10:  case  11:  case  13:  case  15:  case  19:  case  20:  case  22:  case  23:  case  26:  case  29:  case  30:  case  31:  case  33:  case  35:  case  38:  case  39:  case  40:  case  41:  case  43:  case  44:  case  45:  case  46:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(53,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  8:  case  12:  case  14:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  26:  case  27:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  39:  case  41:  case  45:  case  48:  case  50:  case  51:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(59,a,b,c,d,e);
    switch(tmp){  case 2:  case  6:  case  8:  case  10:  case  11:  case  13:  case  14:  case  18:  case  23:  case  24:  case  30:  case  31:  case  32:  case  33:  case  34:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  47:  case  50:  case  52:  case  54:  case  55:  case  56:  case  58:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(61,a,b,c,d,e);
    switch(tmp){  case 2:  case  4:  case  5:  case  6:  case  7:  case  8:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  53:  case  54:  case  55:  case  56:  case  57:  case  59:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(67,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  8:  case  10:  case  11:  case  12:  case  13:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  23:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  60:  case  61:  case  63:  case  65:  case  66:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(71,a,b,c,d,e);
    switch(tmp){  case 7:  case  11:  case  13:  case  14:  case  17:  case  21:  case  22:  case  23:  case  26:  case  28:  case  31:  case  33:  case  34:  case  35:  case  39:  case  41:  case  42:  case  44:  case  46:  case  47:  case  51:  case  52:  case  53:  case  55:  case  56:  case  59:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(73,a,b,c,d,e);
    switch(tmp){  case 2:  case  4:  case  5:  case  6:  case  7:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  66:  case  67:  case  68:  case  69:  case  71:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(79,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  9:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  19:  case  20:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  47:  case  48:  case  49:  case  50:  case  51:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  63:  case  66:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(83,a,b,c,d,e);
    switch(tmp){  case 2:  case  5:  case  6:  case  8:  case  13:  case  14:  case  15:  case  18:  case  19:  case  20:  case  22:  case  24:  case  32:  case  34:  case  35:  case  39:  case  42:  case  43:  case  45:  case  46:  case  47:  case  50:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  60:  case  62:  case  66:  case  67:  case  71:  case  72:  case  73:  case  74:  case  76:  case  79:  case  80:  case  82:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(89,a,b,c,d,e);
    switch(tmp){  case 3:  case  6:  case  7:  case  12:  case  13:  case  14:  case  15:  case  19:  case  23:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  33:  case  35:  case  37:  case  38:  case  41:  case  43:  case  46:  case  48:  case  51:  case  52:  case  54:  case  56:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  70:  case  74:  case  75:  case  76:  case  77:  case  82:  case  83:  case  86:
        return false;
    }
    tmp = getLeftModSubIn1Numbers(97,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  13:  case  14:  case  15:  case  16:  case  17:  case  19:  case  20:  case  21:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  48:  case  49:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  71:  case  72:  case  73:  case  74:  case  76:  case  77:  case  78:  case  80:  case  81:  case  82:  case  83:  case  84:  case  86:  case  87:  case  88:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:
        return false;
    }
    
    
    tmp = getLeftModSubIn1Numbers(101,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  7:  case  8:  case  10:  case  11:  case  12:  case  15:  case  18:  case  26:  case  27:  case  28:  case  29:  case  32:  case  34:  case  35:  case  38:  case  39:  case  40:  case  41:  case  42:  case  44:  case  46:  case  48:  case  50:  case  51:  case  53:  case  55:  case  57:  case  59:  case  60:  case  61:  case  62:  case  63:  case  66:  case  67:  case  69:  case  72:  case  73:  case  74:  case  75:  case  83:  case  86:  case  89:  case  90:  case  91:  case  93:  case  94:  case  98:  case  99:
    return false;}
    tmp = getLeftModSubIn1Numbers(103,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  10:  case  11:  case  12:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  31:  case  32:  case  33:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  62:  case  63:  case  65:  case  67:  case  68:  case  69:  case  70:  case  71:  case  73:  case  74:  case  75:  case  77:  case  78:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:
    return false;}
    tmp = getLeftModSubIn1Numbers(107,a,b,c,d,e);
    switch(tmp){  case 2:  case  5:  case  6:  case  7:  case  8:  case  15:  case  17:  case  18:  case  20:  case  21:  case  22:  case  24:  case  26:  case  28:  case  31:  case  32:  case  38:  case  43:  case  45:  case  46:  case  50:  case  51:  case  54:  case  55:  case  58:  case  59:  case  60:  case  63:  case  65:  case  66:  case  67:  case  68:  case  70:  case  71:  case  72:  case  73:  case  74:  case  77:  case  78:  case  80:  case  82:  case  84:  case  88:  case  91:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  103:  case  104:  case  106:
    return false;}
    tmp = getLeftModSubIn1Numbers(109,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  35:  case  36:  case  37:  case  39:  case  40:  case  41:  case  42:  case  44:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  65:  case  67:  case  68:  case  69:  case  70:  case  72:  case  73:  case  74:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  106:  case  107:
    return false;}
    tmp = getLeftModSubIn1Numbers(113,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  10:  case  12:  case  17:  case  19:  case  20:  case  21:  case  23:  case  24:  case  27:  case  29:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  45:  case  46:  case  47:  case  48:  case  54:  case  55:  case  58:  case  59:  case  65:  case  66:  case  67:  case  68:  case  70:  case  71:  case  73:  case  74:  case  75:  case  76:  case  78:  case  79:  case  80:  case  84:  case  86:  case  89:  case  90:  case  92:  case  93:  case  94:  case  96:  case  101:  case  103:  case  107:  case  108:  case  110:
    return false;}
    tmp = getLeftModSubIn1Numbers(127,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  33:  case  34:  case  35:  case  36:  case  37:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  48:  case  49:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  74:  case  75:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  118:  case  119:  case  120:  case  121:  case  123:  case  124:  case  125:  case  126:
    return false;}
    tmp = getLeftModSubIn1Numbers(131,a,b,c,d,e);
    switch(tmp){  case 2:  case  6:  case  8:  case  10:  case  14:  case  17:  case  18:  case  19:  case  22:  case  23:  case  24:  case  26:  case  29:  case  30:  case  31:  case  32:  case  37:  case  40:  case  42:  case  47:  case  50:  case  51:  case  54:  case  56:  case  57:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  76:  case  78:  case  79:  case  82:  case  83:  case  85:  case  86:  case  87:  case  88:  case  90:  case  92:  case  93:  case  95:  case  96:  case  97:  case  98:  case  103:  case  104:  case  106:  case  110:  case  111:  case  115:  case  116:  case  118:  case  119:  case  120:  case  122:  case  124:  case  126:  case  127:  case  128:  case  130:
    return false;}
    tmp = getLeftModSubIn1Numbers(137,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  10:  case  12:  case  13:  case  20:  case  21:  case  23:  case  24:  case  26:  case  27:  case  29:  case  31:  case  33:  case  35:  case  40:  case  41:  case  42:  case  43:  case  45:  case  46:  case  47:  case  48:  case  51:  case  52:  case  53:  case  54:  case  55:  case  57:  case  58:  case  62:  case  66:  case  67:  case  70:  case  71:  case  75:  case  79:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  89:  case  90:  case  91:  case  92:  case  94:  case  95:  case  96:  case  97:  case  102:  case  104:  case  106:  case  108:  case  110:  case  111:  case  113:  case  114:  case  116:  case  117:  case  124:  case  125:  case  127:  case  131:  case  132:  case  134:
    return false;}
    tmp = getLeftModSubIn1Numbers(139,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  35:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  53:  case  54:  case  56:  case  58:  case  59:  case  60:  case  61:  case  62:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  78:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  111:  case  113:  case  114:  case  115:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  130:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:
    return false;}
    tmp = getLeftModSubIn1Numbers(149,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  8:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  18:  case  21:  case  23:  case  27:  case  32:  case  34:  case  38:  case  40:  case  41:  case  43:  case  44:  case  48:  case  50:  case  51:  case  52:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  62:  case  65:  case  66:  case  70:  case  71:  case  72:  case  74:  case  75:  case  77:  case  78:  case  79:  case  83:  case  84:  case  87:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  97:  case  98:  case  99:  case  101:  case  105:  case  106:  case  108:  case  109:  case  111:  case  115:  case  117:  case  122:  case  126:  case  128:  case  131:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  141:  case  146:  case  147:
    return false;}
    tmp = getLeftModSubIn1Numbers(151,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  45:  case  46:  case  47:  case  48:  case  49:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  69:  case  70:  case  71:  case  73:  case  74:  case  75:  case  76:  case  77:  case  79:  case  80:  case  82:  case  83:  case  85:  case  87:  case  88:  case  89:  case  90:  case  92:  case  93:  case  95:  case  96:  case  97:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  126:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  149:  case  150:
    return false;}
    tmp = getLeftModSubIn1Numbers(157,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  57:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  91:  case  92:  case  94:  case  95:  case  96:  case  97:  case  98:  case  100:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  109:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  142:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  154:  case  155:
    return false;}
    tmp = getLeftModSubIn1Numbers(163,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  23:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  39:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  54:  case  55:  case  56:  case  57:  case  59:  case  60:  case  62:  case  63:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  84:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  127:  case  128:  case  129:  case  130:  case  131:  case  134:  case  137:  case  138:  case  139:  case  141:  case  142:  case  143:  case  144:  case  145:  case  147:  case  148:  case  149:  case  151:  case  152:  case  153:  case  154:  case  156:  case  157:  case  159:  case  160:  case  161:  case  162:
    return false;}
    tmp = getLeftModSubIn1Numbers(167,a,b,c,d,e);
    switch(tmp){  case 5:  case  10:  case  13:  case  15:  case  17:  case  20:  case  23:  case  26:  case  30:  case  34:  case  35:  case  37:  case  39:  case  40:  case  41:  case  43:  case  45:  case  46:  case  51:  case  52:  case  53:  case  55:  case  59:  case  60:  case  67:  case  68:  case  69:  case  70:  case  71:  case  73:  case  74:  case  78:  case  79:  case  80:  case  82:  case  83:  case  86:  case  90:  case  91:  case  92:  case  95:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  109:  case  110:  case  111:  case  113:  case  117:  case  118:  case  119:  case  120:  case  123:  case  125:  case  129:  case  131:  case  134:  case  135:  case  136:  case  138:  case  139:  case  140:  case  142:  case  143:  case  145:  case  146:  case  148:  case  149:  case  151:  case  153:  case  155:  case  156:  case  158:  case  159:  case  160:  case  161:  case  163:  case  164:  case  165:  case  166:
    return false;}
    tmp = getLeftModSubIn1Numbers(173,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  7:  case  8:  case  11:  case  12:  case  17:  case  18:  case  19:  case  20:  case  26:  case  27:  case  28:  case  30:  case  32:  case  39:  case  42:  case  44:  case  45:  case  46:  case  48:  case  50:  case  53:  case  58:  case  59:  case  61:  case  62:  case  63:  case  65:  case  66:  case  68:  case  69:  case  70:  case  71:  case  72:  case  74:  case  75:  case  76:  case  79:  case  80:  case  82:  case  86:  case  87:  case  91:  case  93:  case  94:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  110:  case  111:  case  112:  case  114:  case  115:  case  120:  case  123:  case  125:  case  127:  case  128:  case  129:  case  131:  case  134:  case  141:  case  143:  case  145:  case  146:  case  147:  case  153:  case  154:  case  155:  case  156:  case  161:  case  162:  case  165:  case  166:  case  168:  case  170:  case  171:
    return false;}
    tmp = getLeftModSubIn1Numbers(179,a,b,c,d,e);
    switch(tmp){  case 2:  case  6:  case  7:  case  8:  case  10:  case  11:  case  18:  case  21:  case  23:  case  24:  case  26:  case  28:  case  30:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  40:  case  41:  case  44:  case  50:  case  53:  case  54:  case  55:  case  58:  case  62:  case  63:  case  69:  case  71:  case  72:  case  73:  case  78:  case  79:  case  84:  case  86:  case  90:  case  91:  case  92:  case  94:  case  96:  case  97:  case  98:  case  99:  case  102:  case  103:  case  104:  case  105:  case  109:  case  111:  case  112:  case  113:  case  114:  case  115:  case  118:  case  119:  case  120:  case  122:  case  123:  case  127:  case  128:  case  130:  case  131:  case  132:  case  133:  case  134:  case  136:  case  137:  case  140:  case  143:  case  148:  case  150:  case  152:  case  154:  case  157:  case  159:  case  160:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  170:  case  174:  case  175:  case  176:  case  178:
    return false;}
    tmp = getLeftModSubIn1Numbers(181,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  40:  case  41:  case  43:  case  44:  case  45:  case  47:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  57:  case  58:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  115:  case  116:  case  118:  case  119:  case  120:  case  121:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  134:  case  136:  case  137:  case  138:  case  140:  case  141:  case  142:  case  143:  case  144:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  153:  case  155:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  177:  case  178:  case  179:
    return false;}
    tmp = getLeftModSubIn1Numbers(191,a,b,c,d,e);
    switch(tmp){  case 7:  case  11:  case  14:  case  19:  case  21:  case  22:  case  28:  case  29:  case  31:  case  33:  case  35:  case  37:  case  38:  case  41:  case  42:  case  44:  case  47:  case  53:  case  55:  case  56:  case  57:  case  58:  case  61:  case  62:  case  63:  case  66:  case  70:  case  71:  case  73:  case  74:  case  76:  case  82:  case  83:  case  84:  case  87:  case  88:  case  89:  case  91:  case  93:  case  94:  case  95:  case  99:  case  101:  case  105:  case  106:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  119:  case  122:  case  123:  case  124:  case  126:  case  127:  case  131:  case  132:  case  137:  case  139:  case  140:  case  141:  case  142:  case  143:  case  145:  case  146:  case  148:  case  151:  case  152:  case  155:  case  157:  case  159:  case  161:  case  164:  case  165:  case  166:  case  167:  case  168:  case  171:  case  173:  case  174:  case  175:  case  176:  case  178:  case  179:  case  181:  case  182:  case  183:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:
    return false;}
    tmp = getLeftModSubIn1Numbers(193,a,b,c,d,e);
    switch(tmp){  case 2:  case  4:  case  5:  case  6:  case  7:  case  10:  case  11:  case  12:  case  13:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  68:  case  70:  case  71:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  123:  case  125:  case  127:  case  128:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  167:  case  168:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  180:  case  181:  case  182:  case  183:  case  186:  case  187:  case  188:  case  189:  case  191:
    return false;}
    tmp = getLeftModSubIn1Numbers(197,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  8:  case  11:  case  12:  case  13:  case  14:  case  17:  case  18:  case  20:  case  21:  case  27:  case  30:  case  31:  case  32:  case  35:  case  38:  case  44:  case  45:  case  46:  case  48:  case  50:  case  52:  case  56:  case  57:  case  58:  case  66:  case  67:  case  68:  case  69:  case  71:  case  72:  case  73:  case  74:  case  75:  case  77:  case  78:  case  79:  case  80:  case  82:  case  84:  case  86:  case  87:  case  89:  case  91:  case  94:  case  95:  case  98:  case  99:  case  102:  case  103:  case  106:  case  108:  case  110:  case  111:  case  113:  case  115:  case  117:  case  118:  case  119:  case  120:  case  122:  case  123:  case  124:  case  125:  case  126:  case  128:  case  129:  case  130:  case  131:  case  139:  case  140:  case  141:  case  145:  case  147:  case  149:  case  151:  case  152:  case  153:  case  159:  case  162:  case  165:  case  166:  case  167:  case  170:  case  176:  case  177:  case  179:  case  180:  case  183:  case  184:  case  185:  case  186:  case  189:  case  192:  case  194:  case  195:
    return false;}
    tmp = getLeftModSubIn1Numbers(199,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  91:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  100:  case  101:  case  102:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  112:  case  113:  case  115:  case  118:  case  119:  case  120:  case  122:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  141:  case  142:  case  143:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  183:  case  184:  case  185:  case  186:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:
    return false;}
    


    
    tmp = getLeftModSubIn1Numbers(211,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  6:  case  7:  case  8:  case  9:  case  10:  case  12:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  56:  case  57:  case  59:  case  60:  case  61:  case  62:  case  63:  case  66:  case  67:  case  68:  case  69:  case  70:  case  72:  case  73:  case  74:  case  75:  case  77:  case  78:  case  80:  case  81:  case  83:  case  84:  case  85:  case  86:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  108:  case  110:  case  111:  case  112:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  145:  case  146:  case  147:  case  149:  case  150:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  170:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  185:  case  186:  case  187:  case  189:  case  190:  case  191:  case  192:  case  194:  case  195:  case  196:  case  197:  case  198:  case  200:  case  201:  case  202:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:
    return false;}
    tmp = getLeftModSubIn1Numbers(223,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  9:  case  10:  case  11:  case  12:  case  13:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  29:  case  31:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  57:  case  58:  case  59:  case  61:  case  62:  case  63:  case  65:  case  67:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  113:  case  114:  case  116:  case  117:  case  118:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  129:  case  130:  case  131:  case  133:  case  134:  case  135:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  165:  case  166:  case  167:  case  168:  case  170:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:
    return false;}
    tmp = getLeftModSubIn1Numbers(227,a,b,c,d,e);
    switch(tmp){  case 2:  case  5:  case  6:  case  8:  case  13:  case  14:  case  15:  case  17:  case  18:  case  20:  case  22:  case  24:  case  31:  case  32:  case  35:  case  37:  case  38:  case  39:  case  41:  case  42:  case  45:  case  46:  case  50:  case  51:  case  52:  case  54:  case  55:  case  56:  case  58:  case  60:  case  61:  case  66:  case  67:  case  68:  case  72:  case  80:  case  83:  case  86:  case  88:  case  91:  case  93:  case  94:  case  95:  case  96:  case  98:  case  105:  case  106:  case  107:  case  111:  case  114:  case  115:  case  117:  case  118:  case  119:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  130:  case  135:  case  137:  case  138:  case  140:  case  142:  case  143:  case  145:  case  146:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  156:  case  157:  case  158:  case  162:  case  163:  case  164:  case  165:  case  168:  case  170:  case  174:  case  178:  case  179:  case  180:  case  183:  case  184:  case  187:  case  191:  case  193:  case  194:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  204:  case  206:  case  208:  case  211:  case  215:  case  216:  case  217:  case  218:  case  220:  case  223:  case  224:  case  226:
    return false;}
    tmp = getLeftModSubIn1Numbers(229,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  12:  case  13:  case  14:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  54:  case  55:  case  56:  case  58:  case  59:  case  62:  case  63:  case  65:  case  66:  case  67:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  105:  case  106:  case  107:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  162:  case  163:  case  164:  case  166:  case  167:  case  170:  case  171:  case  173:  case  174:  case  175:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  215:  case  216:  case  217:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  226:  case  227:
    return false;}
    tmp = getLeftModSubIn1Numbers(233,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  10:  case  11:  case  12:  case  17:  case  20:  case  21:  case  22:  case  24:  case  27:  case  34:  case  35:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  47:  case  48:  case  53:  case  54:  case  57:  case  59:  case  61:  case  65:  case  67:  case  68:  case  69:  case  70:  case  73:  case  75:  case  77:  case  78:  case  79:  case  80:  case  82:  case  83:  case  84:  case  86:  case  87:  case  88:  case  90:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  103:  case  106:  case  108:  case  111:  case  114:  case  115:  case  118:  case  119:  case  122:  case  125:  case  127:  case  130:  case  134:  case  136:  case  137:  case  138:  case  139:  case  140:  case  143:  case  145:  case  146:  case  147:  case  149:  case  150:  case  151:  case  153:  case  154:  case  155:  case  156:  case  158:  case  160:  case  163:  case  164:  case  165:  case  166:  case  168:  case  172:  case  174:  case  176:  case  179:  case  180:  case  185:  case  186:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  198:  case  199:  case  206:  case  209:  case  211:  case  212:  case  213:  case  216:  case  221:  case  222:  case  223:  case  227:  case  228:  case  230:
    return false;}
    tmp = getLeftModSubIn1Numbers(239,a,b,c,d,e);
    switch(tmp){  case 7:  case  13:  case  14:  case  19:  case  21:  case  23:  case  26:  case  28:  case  35:  case  37:  case  38:  case  39:  case  41:  case  42:  case  43:  case  46:  case  47:  case  52:  case  53:  case  56:  case  57:  case  59:  case  63:  case  65:  case  69:  case  70:  case  73:  case  74:  case  76:  case  77:  case  78:  case  79:  case  82:  case  84:  case  86:  case  89:  case  92:  case  94:  case  95:  case  97:  case  103:  case  104:  case  105:  case  106:  case  107:  case  111:  case  112:  case  114:  case  115:  case  117:  case  118:  case  119:  case  123:  case  126:  case  129:  case  130:  case  131:  case  137:  case  138:  case  139:  case  140:  case  141:  case  143:  case  146:  case  148:  case  149:  case  151:  case  152:  case  154:  case  156:  case  158:  case  159:  case  164:  case  167:  case  168:  case  171:  case  172:  case  173:  case  175:  case  177:  case  178:  case  179:  case  181:  case  184:  case  185:  case  188:  case  189:  case  190:  case  191:  case  194:  case  195:  case  199:  case  203:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  212:  case  214:  case  215:  case  217:  case  219:  case  221:  case  222:  case  223:  case  224:  case  227:  case  228:  case  229:  case  230:  case  231:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:
    return false;}
    tmp = getLeftModSubIn1Numbers(241,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  29:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  42:  case  43:  case  44:  case  45:  case  46:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  88:  case  89:  case  90:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  115:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  151:  case  152:  case  153:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  178:  case  179:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  195:  case  196:  case  197:  case  198:  case  199:  case  202:  case  203:  case  204:  case  206:  case  207:  case  208:  case  209:  case  210:  case  212:  case  213:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  234:  case  237:  case  238:  case  239:
    return false;}
    tmp = getLeftModSubIn1Numbers(251,a,b,c,d,e);
    switch(tmp){  case 2:  case  6:  case  8:  case  10:  case  11:  case  14:  case  18:  case  19:  case  24:  case  26:  case  29:  case  30:  case  32:  case  33:  case  34:  case  37:  case  40:  case  42:  case  43:  case  44:  case  46:  case  47:  case  50:  case  53:  case  54:  case  55:  case  56:  case  57:  case  59:  case  61:  case  62:  case  70:  case  71:  case  72:  case  76:  case  77:  case  78:  case  82:  case  87:  case  90:  case  95:  case  96:  case  97:  case  98:  case  99:  case  102:  case  104:  case  107:  case  109:  case  111:  case  116:  case  120:  case  126:  case  127:  case  128:  case  129:  case  130:  case  132:  case  133:  case  134:  case  136:  case  137:  case  138:  case  139:  case  141:  case  143:  case  145:  case  146:  case  148:  case  150:  case  151:  case  157:  case  158:  case  159:  case  160:  case  162:  case  163:  case  165:  case  166:  case  167:  case  168:  case  170:  case  171:  case  172:  case  176:  case  177:  case  178:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  191:  case  193:  case  199:  case  200:  case  202:  case  203:  case  206:  case  210:  case  212:  case  213:  case  215:  case  216:  case  220:  case  223:  case  224:  case  226:  case  228:  case  229:  case  230:  case  231:  case  234:  case  235:  case  236:  case  238:  case  239:  case  242:  case  244:  case  246:  case  247:  case  248:  case  250:
    return false;}
    tmp = getLeftModSubIn1Numbers(257,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  10:  case  12:  case  14:  case  19:  case  20:  case  24:  case  27:  case  28:  case  33:  case  37:  case  38:  case  39:  case  40:  case  41:  case  43:  case  45:  case  47:  case  48:  case  51:  case  53:  case  54:  case  55:  case  56:  case  63:  case  65:  case  66:  case  69:  case  71:  case  74:  case  75:  case  76:  case  77:  case  78:  case  80:  case  82:  case  83:  case  85:  case  86:  case  87:  case  90:  case  91:  case  93:  case  94:  case  96:  case  97:  case  101:  case  102:  case  103:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  112:  case  115:  case  119:  case  125:  case  126:  case  127:  case  130:  case  131:  case  132:  case  138:  case  142:  case  145:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  154:  case  155:  case  156:  case  160:  case  161:  case  163:  case  164:  case  166:  case  167:  case  170:  case  171:  case  172:  case  174:  case  175:  case  177:  case  179:  case  180:  case  181:  case  182:  case  183:  case  186:  case  188:  case  191:  case  192:  case  194:  case  201:  case  202:  case  203:  case  204:  case  206:  case  209:  case  210:  case  212:  case  214:  case  216:  case  217:  case  218:  case  219:  case  220:  case  224:  case  229:  case  230:  case  233:  case  237:  case  238:  case  243:  case  245:  case  247:  case  250:  case  251:  case  252:  case  254:
    return false;}
    tmp = getLeftModSubIn1Numbers(263,a,b,c,d,e);
    switch(tmp){  case 5:  case  7:  case  10:  case  14:  case  15:  case  19:  case  20:  case  21:  case  28:  case  29:  case  30:  case  38:  case  40:  case  41:  case  42:  case  45:  case  47:  case  53:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  63:  case  65:  case  67:  case  71:  case  73:  case  76:  case  77:  case  79:  case  80:  case  82:  case  84:  case  85:  case  87:  case  90:  case  91:  case  94:  case  97:  case  101:  case  106:  case  107:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  118:  case  119:  case  120:  case  123:  case  125:  case  126:  case  127:  case  130:  case  131:  case  134:  case  135:  case  139:  case  141:  case  142:  case  146:  case  152:  case  154:  case  155:  case  158:  case  159:  case  160:  case  161:  case  163:  case  164:  case  165:  case  167:  case  168:  case  170:  case  171:  case  174:  case  175:  case  177:  case  180:  case  182:  case  185:  case  188:  case  189:  case  191:  case  193:  case  194:  case  195:  case  197:  case  199:  case  201:  case  202:  case  209:  case  211:  case  212:  case  213:  case  214:  case  215:  case  217:  case  219:  case  220:  case  224:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  245:  case  246:  case  247:  case  250:  case  251:  case  252:  case  254:  case  255:  case  257:  case  259:  case  260:  case  261:  case  262:
    return false;}
    tmp = getLeftModSubIn1Numbers(269,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  7:  case  8:  case  10:  case  12:  case  15:  case  17:  case  18:  case  19:  case  22:  case  26:  case  27:  case  28:  case  29:  case  31:  case  32:  case  33:  case  35:  case  39:  case  40:  case  42:  case  46:  case  48:  case  50:  case  59:  case  60:  case  63:  case  68:  case  69:  case  71:  case  72:  case  74:  case  75:  case  76:  case  77:  case  82:  case  83:  case  85:  case  86:  case  88:  case  90:  case  91:  case  94:  case  95:  case  98:  case  101:  case  102:  case  104:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  122:  case  123:  case  124:  case  128:  case  129:  case  130:  case  132:  case  134:  case  135:  case  137:  case  139:  case  140:  case  141:  case  145:  case  146:  case  147:  case  153:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  165:  case  167:  case  168:  case  171:  case  174:  case  175:  case  178:  case  179:  case  181:  case  183:  case  184:  case  186:  case  187:  case  192:  case  193:  case  194:  case  195:  case  197:  case  198:  case  200:  case  201:  case  206:  case  209:  case  210:  case  219:  case  221:  case  223:  case  227:  case  229:  case  230:  case  234:  case  236:  case  237:  case  238:  case  240:  case  241:  case  242:  case  243:  case  247:  case  250:  case  251:  case  252:  case  254:  case  257:  case  259:  case  261:  case  262:  case  266:  case  267:
    return false;}
    tmp = getLeftModSubIn1Numbers(271,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  29:  case  30:  case  32:  case  33:  case  36:  case  37:  case  38:  case  40:  case  42:  case  43:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  56:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  70:  case  71:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  82:  case  83:  case  84:  case  85:  case  86:  case  88:  case  89:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  120:  case  121:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  140:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  149:  case  150:  case  151:  case  152:  case  153:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  168:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  186:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  243:  case  245:  case  246:  case  249:  case  250:  case  251:  case  253:  case  254:  case  255:  case  256:  case  257:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  269:  case  270:
    return false;}
    tmp = getLeftModSubIn1Numbers(277,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  14:  case  15:  case  17:  case  18:  case  20:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  60:  case  61:  case  62:  case  63:  case  65:  case  67:  case  68:  case  70:  case  71:  case  72:  case  73:  case  75:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  103:  case  104:  case  105:  case  106:  case  107:  case  109:  case  110:  case  111:  case  112:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  121:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  156:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  165:  case  166:  case  167:  case  168:  case  170:  case  171:  case  172:  case  173:  case  174:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  202:  case  204:  case  205:  case  206:  case  207:  case  209:  case  210:  case  212:  case  214:  case  215:  case  216:  case  217:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  248:  case  249:  case  251:  case  252:  case  253:  case  254:  case  255:  case  257:  case  259:  case  260:  case  262:  case  263:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  274:  case  275:
    return false;}
    tmp = getLeftModSubIn1Numbers(281,a,b,c,d,e);
    switch(tmp){  case 3:  case  6:  case  11:  case  12:  case  13:  case  15:  case  19:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  30:  case  37:  case  38:  case  41:  case  42:  case  44:  case  46:  case  47:  case  48:  case  51:  case  52:  case  54:  case  55:  case  60:  case  61:  case  65:  case  67:  case  71:  case  73:  case  74:  case  75:  case  76:  case  77:  case  82:  case  83:  case  84:  case  87:  case  88:  case  89:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  110:  case  113:  case  115:  case  117:  case  120:  case  122:  case  127:  case  129:  case  130:  case  131:  case  133:  case  134:  case  135:  case  139:  case  142:  case  146:  case  147:  case  148:  case  150:  case  151:  case  152:  case  154:  case  159:  case  161:  case  164:  case  166:  case  168:  case  171:  case  173:  case  174:  case  176:  case  177:  case  178:  case  179:  case  182:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  192:  case  193:  case  194:  case  197:  case  198:  case  199:  case  204:  case  205:  case  206:  case  207:  case  208:  case  210:  case  214:  case  216:  case  220:  case  221:  case  226:  case  227:  case  229:  case  230:  case  233:  case  234:  case  235:  case  237:  case  239:  case  240:  case  243:  case  244:  case  251:  case  254:  case  255:  case  257:  case  258:  case  259:  case  260:  case  262:  case  266:  case  268:  case  269:  case  270:  case  275:  case  278:
    return false;}
    tmp = getLeftModSubIn1Numbers(283,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  39:  case  40:  case  41:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  52:  case  53:  case  55:  case  56:  case  57:  case  58:  case  59:  case  62:  case  63:  case  65:  case  67:  case  68:  case  69:  case  70:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  79:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  112:  case  113:  case  114:  case  115:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  153:  case  154:  case  156:  case  157:  case  159:  case  160:  case  162:  case  164:  case  165:  case  166:  case  167:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  176:  case  177:  case  178:  case  179:  case  180:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  200:  case  201:  case  202:  case  203:  case  205:  case  206:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  226:  case  227:  case  228:  case  229:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  241:  case  242:  case  243:  case  245:  case  246:  case  247:  case  248:  case  249:  case  252:  case  254:  case  255:  case  257:  case  258:  case  259:  case  260:  case  261:  case  263:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  274:  case  276:  case  277:  case  278:  case  279:  case  280:  case  282:
    return false;}
    tmp = getLeftModSubIn1Numbers(293,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  7:  case  8:  case  11:  case  12:  case  13:  case  18:  case  19:  case  20:  case  23:  case  27:  case  28:  case  29:  case  30:  case  32:  case  34:  case  41:  case  42:  case  44:  case  45:  case  47:  case  48:  case  50:  case  51:  case  52:  case  62:  case  63:  case  66:  case  70:  case  72:  case  74:  case  75:  case  76:  case  78:  case  79:  case  80:  case  85:  case  86:  case  89:  case  92:  case  93:  case  98:  case  99:  case  101:  case  103:  case  105:  case  106:  case  108:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  125:  case  127:  case  128:  case  129:  case  130:  case  131:  case  134:  case  136:  case  138:  case  139:  case  142:  case  146:  case  147:  case  151:  case  154:  case  155:  case  157:  case  159:  case  162:  case  163:  case  164:  case  165:  case  166:  case  168:  case  171:  case  173:  case  174:  case  175:  case  176:  case  177:  case  179:  case  180:  case  181:  case  182:  case  183:  case  185:  case  187:  case  188:  case  190:  case  192:  case  194:  case  195:  case  200:  case  201:  case  204:  case  207:  case  208:  case  213:  case  214:  case  215:  case  217:  case  218:  case  219:  case  221:  case  223:  case  227:  case  230:  case  231:  case  241:  case  242:  case  243:  case  245:  case  246:  case  248:  case  249:  case  251:  case  252:  case  259:  case  261:  case  263:  case  264:  case  265:  case  266:  case  270:  case  273:  case  274:  case  275:  case  280:  case  281:  case  282:  case  285:  case  286:  case  288:  case  290:  case  291:
    return false;}
    tmp = getLeftModSubIn1Numbers(307,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  7:  case  8:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  18:  case  20:  case  21:  case  22:  case  23:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  69:  case  71:  case  72:  case  73:  case  74:  case  75:  case  78:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  98:  case  99:  case  100:  case  104:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  146:  case  147:  case  148:  case  150:  case  151:  case  152:  case  154:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  168:  case  169:  case  170:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  180:  case  181:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  234:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  251:  case  252:  case  253:  case  254:  case  255:  case  257:  case  258:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  270:  case  271:  case  274:  case  276:  case  277:  case  278:  case  279:  case  281:  case  282:  case  283:  case  284:  case  285:  case  286:  case  287:  case  288:  case  290:  case  291:  case  292:  case  293:  case  294:  case  296:  case  297:  case  298:  case  300:  case  301:  case  302:  case  303:  case  306:
    return false;}
    tmp = getLeftModSubIn1Numbers(311,a,b,c,d,e);
    switch(tmp){  case 11:  case  17:  case  19:  case  22:  case  23:  case  29:  case  31:  case  33:  case  34:  case  37:  case  38:  case  41:  case  43:  case  44:  case  46:  case  51:  case  55:  case  57:  case  58:  case  59:  case  61:  case  62:  case  66:  case  68:  case  69:  case  71:  case  74:  case  76:  case  77:  case  82:  case  85:  case  86:  case  87:  case  88:  case  92:  case  93:  case  95:  case  97:  case  99:  case  101:  case  102:  case  103:  case  110:  case  111:  case  114:  case  115:  case  116:  case  118:  case  119:  case  122:  case  123:  case  124:  case  129:  case  131:  case  132:  case  133:  case  136:  case  138:  case  142:  case  143:  case  145:  case  148:  case  149:  case  151:  case  152:  case  153:  case  154:  case  155:  case  161:  case  164:  case  165:  case  167:  case  170:  case  171:  case  172:  case  174:  case  176:  case  177:  case  181:  case  183:  case  184:  case  185:  case  186:  case  190:  case  191:  case  194:  case  198:  case  199:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  211:  case  213:  case  215:  case  217:  case  220:  case  221:  case  222:  case  227:  case  228:  case  230:  case  231:  case  232:  case  233:  case  236:  case  238:  case  239:  case  241:  case  244:  case  246:  case  247:  case  248:  case  251:  case  255:  case  257:  case  258:  case  259:  case  261:  case  262:  case  263:  case  264:  case  266:  case  269:  case  271:  case  272:  case  275:  case  276:  case  279:  case  281:  case  283:  case  284:  case  285:  case  286:  case  287:  case  290:  case  291:  case  293:  case  295:  case  296:  case  297:  case  298:  case  299:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  309:  case  310:
    return false;}
    tmp = getLeftModSubIn1Numbers(313,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  34:  case  37:  case  38:  case  40:  case  41:  case  42:  case  43:  case  45:  case  46:  case  47:  case  50:  case  51:  case  53:  case  54:  case  55:  case  56:  case  57:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  98:  case  99:  case  100:  case  101:  case  102:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  211:  case  212:  case  213:  case  214:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  250:  case  251:  case  252:  case  253:  case  254:  case  256:  case  257:  case  258:  case  259:  case  260:  case  262:  case  263:  case  266:  case  267:  case  268:  case  270:  case  271:  case  272:  case  273:  case  275:  case  276:  case  279:  case  281:  case  282:  case  283:  case  284:  case  285:  case  287:  case  289:  case  290:  case  291:  case  292:  case  293:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  306:  case  308:  case  309:  case  310:  case  311:
    return false;}
    tmp = getLeftModSubIn1Numbers(317,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  8:  case  12:  case  13:  case  14:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  27:  case  29:  case  30:  case  32:  case  33:  case  35:  case  41:  case  45:  case  46:  case  47:  case  48:  case  50:  case  52:  case  55:  case  56:  case  62:  case  68:  case  69:  case  71:  case  72:  case  74:  case  75:  case  76:  case  78:  case  80:  case  84:  case  86:  case  88:  case  91:  case  93:  case  97:  case  98:  case  102:  case  106:  case  107:  case  108:  case  109:  case  111:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  132:  case  133:  case  134:  case  137:  case  139:  case  140:  case  143:  case  146:  case  147:  case  151:  case  153:  case  154:  case  155:  case  158:  case  159:  case  162:  case  163:  case  164:  case  166:  case  170:  case  171:  case  174:  case  177:  case  178:  case  180:  case  183:  case  184:  case  185:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  195:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  206:  case  208:  case  209:  case  210:  case  211:  case  215:  case  219:  case  220:  case  224:  case  226:  case  229:  case  231:  case  233:  case  237:  case  239:  case  241:  case  242:  case  243:  case  245:  case  246:  case  248:  case  249:  case  255:  case  261:  case  262:  case  265:  case  267:  case  269:  case  270:  case  271:  case  272:  case  276:  case  282:  case  284:  case  285:  case  287:  case  288:  case  290:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  303:  case  304:  case  305:  case  309:  case  312:  case  314:  case  315:
    return false;}
    tmp = getLeftModSubIn1Numbers(331,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  69:  case  71:  case  72:  case  73:  case  75:  case  76:  case  77:  case  78:  case  79:  case  81:  case  82:  case  83:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  97:  case  98:  case  99:  case  101:  case  103:  case  104:  case  106:  case  107:  case  108:  case  109:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  119:  case  121:  case  122:  case  123:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  145:  case  146:  case  147:  case  148:  case  149:  case  151:  case  152:  case  154:  case  156:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  168:  case  169:  case  170:  case  171:  case  173:  case  174:  case  175:  case  176:  case  178:  case  179:  case  181:  case  182:  case  183:  case  184:  case  185:  case  187:  case  188:  case  190:  case  191:  case  192:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  254:  case  255:  case  256:  case  257:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  267:  case  268:  case  269:  case  271:  case  272:  case  273:  case  275:  case  276:  case  277:  case  278:  case  280:  case  281:  case  282:  case  283:  case  284:  case  285:  case  286:  case  287:  case  288:  case  289:  case  290:  case  291:  case  292:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  305:  case  306:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  314:  case  315:  case  317:  case  318:  case  320:  case  322:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:
    return false;}
    tmp = getLeftModSubIn1Numbers(337,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  40:  case  41:  case  44:  case  45:  case  46:  case  50:  case  51:  case  53:  case  54:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  80:  case  81:  case  82:  case  83:  case  84:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  149:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  163:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  174:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  188:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  227:  case  228:  case  229:  case  230:  case  231:  case  232:  case  233:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  253:  case  254:  case  255:  case  256:  case  257:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  274:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  283:  case  284:  case  286:  case  287:  case  291:  case  292:  case  293:  case  296:  case  297:  case  299:  case  300:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  309:  case  311:  case  313:  case  314:  case  315:  case  316:  case  317:  case  318:  case  319:  case  320:  case  321:  case  322:  case  323:  case  324:  case  325:  case  326:  case  327:  case  328:  case  332:  case  333:  case  334:  case  335:
    return false;}
    tmp = getLeftModSubIn1Numbers(347,a,b,c,d,e);
    switch(tmp){  case 2:  case  5:  case  6:  case  7:  case  8:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  32:  case  37:  case  41:  case  45:  case  47:  case  50:  case  51:  case  54:  case  55:  case  57:  case  58:  case  60:  case  62:  case  63:  case  65:  case  66:  case  68:  case  69:  case  70:  case  72:  case  76:  case  77:  case  78:  case  79:  case  80:  case  84:  case  86:  case  88:  case  91:  case  92:  case  96:  case  97:  case  98:  case  101:  case  103:  case  104:  case  106:  case  111:  case  112:  case  118:  case  122:  case  123:  case  125:  case  128:  case  134:  case  135:  case  139:  case  141:  case  142:  case  145:  case  146:  case  148:  case  150:  case  151:  case  153:  case  155:  case  162:  case  163:  case  164:  case  165:  case  166:  case  170:  case  171:  case  174:  case  175:  case  178:  case  179:  case  180:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  193:  case  195:  case  198:  case  200:  case  203:  case  204:  case  207:  case  209:  case  210:  case  211:  case  214:  case  215:  case  216:  case  217:  case  218:  case  220:  case  221:  case  223:  case  226:  case  227:  case  228:  case  230:  case  231:  case  232:  case  233:  case  234:  case  237:  case  238:  case  239:  case  240:  case  242:  case  245:  case  247:  case  248:  case  252:  case  253:  case  254:  case  257:  case  258:  case  260:  case  262:  case  264:  case  265:  case  266:  case  272:  case  273:  case  274:  case  276:  case  280:  case  283:  case  286:  case  288:  case  291:  case  294:  case  295:  case  298:  case  299:  case  301:  case  303:  case  304:  case  305:  case  307:  case  308:  case  309:  case  311:  case  312:  case  313:  case  314:  case  316:  case  317:  case  318:  case  320:  case  322:  case  331:  case  333:  case  334:  case  335:  case  336:  case  337:  case  338:  case  343:  case  344:  case  346:
    return false;}
    tmp = getLeftModSubIn1Numbers(349,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  32:  case  33:  case  34:  case  35:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  46:  case  47:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  61:  case  62:  case  63:  case  65:  case  68:  case  70:  case  71:  case  72:  case  73:  case  74:  case  76:  case  77:  case  78:  case  79:  case  81:  case  82:  case  83:  case  84:  case  85:  case  87:  case  89:  case  90:  case  91:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  111:  case  112:  case  113:  case  114:  case  116:  case  117:  case  119:  case  120:  case  122:  case  123:  case  124:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  169:  case  170:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  179:  case  180:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  225:  case  226:  case  227:  case  229:  case  230:  case  232:  case  233:  case  235:  case  236:  case  237:  case  238:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  250:  case  251:  case  252:  case  253:  case  254:  case  255:  case  256:  case  258:  case  259:  case  260:  case  262:  case  264:  case  265:  case  266:  case  267:  case  268:  case  270:  case  271:  case  272:  case  273:  case  275:  case  276:  case  277:  case  278:  case  279:  case  281:  case  284:  case  286:  case  287:  case  288:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  302:  case  303:  case  305:  case  306:  case  307:  case  309:  case  310:  case  311:  case  314:  case  315:  case  316:  case  317:  case  319:  case  320:  case  321:  case  323:  case  324:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  333:  case  334:  case  335:  case  336:  case  337:  case  338:  case  339:  case  340:  case  341:  case  342:  case  343:  case  344:  case  345:  case  346:  case  347:
    return false;}
    tmp = getLeftModSubIn1Numbers(353,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  10:  case  12:  case  13:  case  14:  case  20:  case  24:  case  26:  case  27:  case  28:  case  31:  case  33:  case  37:  case  40:  case  45:  case  48:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  59:  case  62:  case  63:  case  66:  case  67:  case  69:  case  71:  case  74:  case  75:  case  77:  case  79:  case  80:  case  85:  case  87:  case  89:  case  90:  case  95:  case  96:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  110:  case  112:  case  114:  case  115:  case  117:  case  118:  case  119:  case  123:  case  124:  case  125:  case  126:  case  129:  case  132:  case  133:  case  134:  case  137:  case  138:  case  139:  case  141:  case  142:  case  143:  case  145:  case  147:  case  148:  case  149:  case  150:  case  151:  case  154:  case  158:  case  160:  case  161:  case  163:  case  170:  case  173:  case  174:  case  175:  case  178:  case  179:  case  180:  case  183:  case  190:  case  192:  case  193:  case  195:  case  199:  case  202:  case  203:  case  204:  case  205:  case  206:  case  208:  case  210:  case  211:  case  212:  case  214:  case  215:  case  216:  case  219:  case  220:  case  221:  case  224:  case  227:  case  228:  case  229:  case  230:  case  234:  case  235:  case  236:  case  238:  case  239:  case  241:  case  243:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  257:  case  258:  case  263:  case  264:  case  266:  case  268:  case  273:  case  274:  case  276:  case  278:  case  279:  case  282:  case  284:  case  286:  case  287:  case  290:  case  291:  case  294:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  305:  case  308:  case  313:  case  316:  case  320:  case  322:  case  325:  case  326:  case  327:  case  329:  case  333:  case  339:  case  340:  case  341:  case  343:  case  346:  case  347:  case  348:  case  350:
    return false;}
    tmp = getLeftModSubIn1Numbers(359,a,b,c,d,e);
    switch(tmp){  case 7:  case  13:  case  14:  case  19:  case  21:  case  26:  case  28:  case  29:  case  31:  case  35:  case  38:  case  39:  case  42:  case  43:  case  52:  case  53:  case  56:  case  57:  case  58:  case  59:  case  61:  case  62:  case  63:  case  65:  case  67:  case  70:  case  71:  case  76:  case  77:  case  78:  case  83:  case  84:  case  86:  case  87:  case  89:  case  93:  case  95:  case  97:  case  103:  case  104:  case  105:  case  106:  case  109:  case  112:  case  113:  case  114:  case  116:  case  117:  case  118:  case  119:  case  122:  case  124:  case  126:  case  129:  case  130:  case  134:  case  137:  case  139:  case  140:  case  142:  case  143:  case  145:  case  152:  case  154:  case  155:  case  156:  case  157:  case  159:  case  161:  case  163:  case  166:  case  167:  case  168:  case  171:  case  172:  case  174:  case  175:  case  177:  case  178:  case  179:  case  183:  case  186:  case  189:  case  190:  case  194:  case  195:  case  197:  case  199:  case  201:  case  206:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  215:  case  218:  case  221:  case  223:  case  224:  case  226:  case  227:  case  228:  case  231:  case  232:  case  234:  case  236:  case  238:  case  239:  case  244:  case  248:  case  249:  case  251:  case  252:  case  257:  case  258:  case  259:  case  260:  case  261:  case  263:  case  265:  case  267:  case  268:  case  269:  case  271:  case  274:  case  277:  case  278:  case  279:  case  280:  case  284:  case  285:  case  286:  case  287:  case  290:  case  291:  case  293:  case  295:  case  299:  case  304:  case  305:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  318:  case  319:  case  322:  case  323:  case  325:  case  326:  case  327:  case  329:  case  332:  case  334:  case  335:  case  336:  case  337:  case  339:  case  341:  case  342:  case  343:  case  344:  case  347:  case  348:  case  349:  case  350:  case  351:  case  353:  case  354:  case  355:  case  356:  case  357:  case  358:
    return false;}
    tmp = getLeftModSubIn1Numbers(367,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  10:  case  11:  case  12:  case  13:  case  14:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  48:  case  50:  case  51:  case  53:  case  54:  case  55:  case  57:  case  58:  case  60:  case  61:  case  62:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  73:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  102:  case  103:  case  104:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  115:  case  116:  case  117:  case  118:  case  119:  case  121:  case  123:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  133:  case  136:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  146:  case  147:  case  148:  case  149:  case  150:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  176:  case  177:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  201:  case  202:  case  203:  case  205:  case  206:  case  207:  case  208:  case  210:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  221:  case  222:  case  223:  case  224:  case  227:  case  228:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  254:  case  255:  case  256:  case  257:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  274:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  282:  case  283:  case  284:  case  285:  case  286:  case  287:  case  288:  case  289:  case  290:  case  291:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  316:  case  317:  case  318:  case  319:  case  320:  case  321:  case  324:  case  325:  case  326:  case  328:  case  330:  case  331:  case  333:  case  334:  case  335:  case  336:  case  337:  case  339:  case  341:  case  342:  case  344:  case  345:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  353:  case  354:  case  355:  case  356:  case  357:  case  358:  case  359:  case  360:  case  361:  case  363:  case  365:  case  366:
    return false;}
    tmp = getLeftModSubIn1Numbers(373,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  8:  case  9:  case  10:  case  11:  case  14:  case  15:  case  16:  case  18:  case  19:  case  20:  case  21:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  32:  case  33:  case  34:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  85:  case  88:  case  89:  case  90:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  153:  case  155:  case  157:  case  159:  case  161:  case  162:  case  164:  case  165:  case  166:  case  167:  case  168:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  185:  case  186:  case  187:  case  188:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  205:  case  206:  case  207:  case  208:  case  209:  case  211:  case  212:  case  214:  case  216:  case  218:  case  220:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  255:  case  256:  case  257:  case  258:  case  259:  case  260:  case  261:  case  263:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  274:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  281:  case  283:  case  284:  case  285:  case  288:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  316:  case  317:  case  319:  case  320:  case  321:  case  322:  case  323:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  333:  case  334:  case  335:  case  336:  case  337:  case  338:  case  339:  case  340:  case  341:  case  344:  case  345:  case  347:  case  348:  case  349:  case  350:  case  352:  case  353:  case  354:  case  355:  case  357:  case  358:  case  359:  case  362:  case  363:  case  364:  case  365:  case  367:  case  368:  case  369:  case  370:  case  371:
    return false;}
    tmp = getLeftModSubIn1Numbers(379,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  24:  case  26:  case  27:  case  28:  case  29:  case  31:  case  32:  case  34:  case  35:  case  38:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  68:  case  69:  case  71:  case  72:  case  73:  case  74:  case  75:  case  78:  case  79:  case  80:  case  81:  case  82:  case  85:  case  87:  case  88:  case  89:  case  90:  case  92:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  117:  case  118:  case  120:  case  121:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  140:  case  141:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  160:  case  161:  case  162:  case  163:  case  164:  case  166:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  181:  case  182:  case  183:  case  184:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  197:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  218:  case  219:  case  220:  case  221:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  231:  case  233:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  245:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  254:  case  256:  case  257:  case  258:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  274:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  281:  case  282:  case  283:  case  284:  case  285:  case  286:  case  287:  case  288:  case  289:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  307:  case  308:  case  309:  case  310:  case  312:  case  313:  case  314:  case  315:  case  317:  case  318:  case  319:  case  321:  case  323:  case  324:  case  325:  case  326:  case  328:  case  329:  case  330:  case  332:  case  333:  case  334:  case  336:  case  337:  case  338:  case  340:  case  341:  case  342:  case  343:  case  344:  case  345:  case  346:  case  347:  case  348:  case  349:  case  351:  case  353:  case  354:  case  355:  case  356:  case  357:  case  358:  case  359:  case  360:  case  361:  case  362:  case  363:  case  364:  case  365:  case  366:  case  367:  case  368:  case  369:  case  370:  case  372:  case  373:  case  374:  case  375:  case  376:  case  377:  case  378:
    return false;}
    tmp = getLeftModSubIn1Numbers(383,a,b,c,d,e);
    switch(tmp){  case 5:  case  10:  case  11:  case  13:  case  15:  case  20:  case  22:  case  26:  case  30:  case  33:  case  35:  case  37:  case  39:  case  40:  case  41:  case  44:  case  45:  case  47:  case  52:  case  53:  case  59:  case  60:  case  61:  case  66:  case  70:  case  74:  case  77:  case  78:  case  79:  case  80:  case  82:  case  83:  case  85:  case  88:  case  89:  case  90:  case  91:  case  94:  case  95:  case  97:  case  99:  case  104:  case  105:  case  106:  case  107:  case  109:  case  111:  case  115:  case  117:  case  118:  case  120:  case  122:  case  123:  case  125:  case  127:  case  131:  case  132:  case  135:  case  140:  case  141:  case  145:  case  148:  case  151:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  163:  case  164:  case  166:  case  167:  case  170:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  187:  case  188:  case  190:  case  191:  case  194:  case  197:  case  198:  case  199:  case  208:  case  209:  case  210:  case  211:  case  212:  case  214:  case  215:  case  218:  case  221:  case  222:  case  230:  case  231:  case  233:  case  234:  case  236:  case  237:  case  239:  case  240:  case  241:  case  244:  case  245:  case  246:  case  247:  case  249:  case  250:  case  253:  case  254:  case  255:  case  257:  case  259:  case  262:  case  264:  case  267:  case  269:  case  270:  case  271:  case  273:  case  275:  case  280:  case  281:  case  282:  case  283:  case  285:  case  287:  case  290:  case  291:  case  296:  case  297:  case  299:  case  302:  case  307:  case  308:  case  310:  case  311:  case  312:  case  314:  case  315:  case  316:  case  318:  case  319:  case  320:  case  321:  case  325:  case  326:  case  327:  case  328:  case  329:  case  332:  case  333:  case  334:  case  335:  case  337:  case  340:  case  341:  case  345:  case  347:  case  349:  case  351:  case  352:  case  354:  case  355:  case  356:  case  358:  case  359:  case  360:  case  362:  case  364:  case  365:  case  366:  case  367:  case  369:  case  371:  case  374:  case  375:  case  376:  case  377:  case  379:  case  380:  case  381:  case  382:
    return false;}
    tmp = getLeftModSubIn1Numbers(389,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  8:  case  10:  case  12:  case  14:  case  15:  case  18:  case  21:  case  22:  case  23:  case  26:  case  27:  case  29:  case  31:  case  32:  case  33:  case  34:  case  37:  case  38:  case  39:  case  40:  case  43:  case  47:  case  48:  case  50:  case  51:  case  53:  case  56:  case  57:  case  60:  case  61:  case  70:  case  71:  case  72:  case  75:  case  82:  case  83:  case  84:  case  88:  case  89:  case  90:  case  92:  case  98:  case  101:  case  103:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  115:  case  116:  case  118:  case  123:  case  124:  case  126:  case  128:  case  130:  case  131:  case  132:  case  134:  case  135:  case  136:  case  138:  case  139:  case  145:  case  146:  case  147:  case  148:  case  149:  case  151:  case  152:  case  154:  case  155:  case  156:  case  158:  case  160:  case  161:  case  162:  case  163:  case  165:  case  167:  case  170:  case  172:  case  174:  case  177:  case  182:  case  185:  case  186:  case  188:  case  189:  case  190:  case  191:  case  192:  case  194:  case  195:  case  197:  case  198:  case  199:  case  200:  case  201:  case  203:  case  204:  case  207:  case  212:  case  215:  case  217:  case  219:  case  222:  case  224:  case  226:  case  227:  case  228:  case  229:  case  231:  case  233:  case  234:  case  235:  case  237:  case  238:  case  240:  case  241:  case  242:  case  243:  case  244:  case  250:  case  251:  case  253:  case  254:  case  255:  case  257:  case  258:  case  259:  case  261:  case  263:  case  265:  case  266:  case  271:  case  273:  case  274:  case  279:  case  280:  case  281:  case  282:  case  284:  case  285:  case  286:  case  288:  case  291:  case  297:  case  299:  case  300:  case  301:  case  305:  case  306:  case  307:  case  314:  case  317:  case  318:  case  319:  case  328:  case  329:  case  332:  case  333:  case  336:  case  338:  case  339:  case  341:  case  342:  case  346:  case  349:  case  350:  case  351:  case  352:
    return false;}
    tmp = getLeftModSubIn1Numbers(397,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  5:  case  6:  case  7:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  32:  case  33:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  109:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  121:  case  122:  case  123:  case  125:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  138:  case  139:  case  143:  case  144:  case  145:  case  146:  case  148:  case  149:  case  150:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  164:  case  165:  case  166:  case  168:  case  169:  case  170:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  227:  case  228:  case  229:  case  231:  case  232:  case  233:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  247:  case  248:  case  249:  case  251:  case  252:  case  253:  case  254:  case  258:  case  259:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  272:  case  274:  case  275:  case  276:  case  278:  case  279:  case  280:  case  281:  case  282:  case  283:  case  284:  case  285:  case  286:  case  288:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  315:  case  316:  case  317:  case  318:  case  319:  case  320:  case  321:  case  322:  case  323:  case  324:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  334:  case  335:  case  336:  case  337:  case  338:  case  339:  case  340:  case  341:  case  342:  case  343:  case  344:  case  345:  case  346:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  353:  case  355:  case  356:  case  357:  case  358:  case  359:  case  360:  case  361:  case  364:  case  365:  case  368:  case  369:  case  371:  case  372:  case  373:  case  374:  case  375:  case  376:  case  377:  case  378:  case  379:  case  380:  case  382:  case  383:  case  384:  case  385:  case  386:  case  387:  case  388:  case  389:  case  390:  case  391:  case  392:  case  394:  case  395:
    return false;}
    tmp = getLeftModSubIn1Numbers(409,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  28:  case  29:  case  31:  case  32:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  49:  case  50:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  84:  case  85:  case  86:  case  87:  case  88:  case  90:  case  91:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  100:  case  101:  case  102:  case  104:  case  105:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  144:  case  145:  case  146:  case  148:  case  149:  case  151:  case  152:  case  153:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  181:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  194:  case  195:  case  197:  case  198:  case  199:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  210:  case  211:  case  212:  case  214:  case  215:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  228:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  254:  case  256:  case  257:  case  258:  case  260:  case  261:  case  263:  case  264:  case  265:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  281:  case  282:  case  283:  case  285:  case  286:  case  287:  case  289:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  304:  case  305:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  316:  case  318:  case  319:  case  321:  case  322:  case  323:  case  324:  case  325:  case  328:  case  329:  case  330:  case  331:  case  332:  case  333:  case  334:  case  335:  case  336:  case  337:  case  338:  case  339:  case  342:  case  343:  case  344:  case  346:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  353:  case  354:  case  355:  case  356:  case  357:  case  359:  case  360:  case  362:  case  363:  case  364:  case  365:  case  366:  case  367:  case  368:  case  370:  case  371:  case  372:  case  374:  case  375:  case  376:  case  377:  case  378:  case  380:  case  381:  case  383:  case  385:  case  386:  case  387:  case  388:  case  389:  case  390:  case  391:  case  392:  case  393:  case  394:  case  395:  case  396:  case  397:  case  398:  case  399:  case  400:  case  402:  case  405:  case  406:  case  407:
    return false;}
    tmp = getLeftModSubIn1Numbers(421,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  8:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  32:  case  34:  case  35:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  46:  case  47:  case  50:  case  52:  case  53:  case  54:  case  56:  case  57:  case  58:  case  59:  case  61:  case  62:  case  63:  case  65:  case  66:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  76:  case  77:  case  79:  case  81:  case  82:  case  83:  case  84:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  105:  case  107:  case  108:  case  109:  case  110:  case  111:  case  112:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  126:  case  127:  case  128:  case  129:  case  132:  case  133:  case  134:  case  135:  case  136:  case  137:  case  138:  case  140:  case  141:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  170:  case  171:  case  172:  case  173:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  230:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  248:  case  249:  case  250:  case  251:  case  253:  case  254:  case  255:  case  256:  case  257:  case  258:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  270:  case  271:  case  272:  case  273:  case  274:  case  275:  case  276:  case  277:  case  278:  case  280:  case  281:  case  283:  case  284:  case  285:  case  286:  case  287:  case  288:  case  289:  case  292:  case  293:  case  294:  case  295:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  316:  case  318:  case  319:  case  320:  case  322:  case  323:  case  324:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  332:  case  333:  case  334:  case  335:  case  337:  case  338:  case  339:  case  340:  case  342:  case  344:  case  345:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  355:  case  356:  case  358:  case  359:  case  360:  case  362:  case  363:  case  364:  case  365:  case  367:  case  368:  case  369:  case  371:  case  374:  case  375:  case  378:  case  379:  case  380:  case  381:  case  382:  case  383:  case  384:  case  386:  case  387:  case  389:  case  390:  case  391:  case  392:  case  393:  case  395:  case  396:  case  397:  case  398:  case  399:  case  400:  case  401:  case  402:  case  403:  case  404:  case  405:  case  406:  case  407:  case  408:  case  409:  case  410:  case  411:  case  412:  case  413:  case  415:  case  416:  case  417:  case  418:  case  419:
    return false;}
    tmp = getLeftModSubIn1Numbers(433,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  17:  case  18:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  28:  case  29:  case  30:  case  31:  case  33:  case  34:  case  36:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  50:  case  51:  case  52:  case  53:  case  55:  case  56:  case  57:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  68:  case  69:  case  71:  case  72:  case  73:  case  76:  case  77:  case  78:  case  80:  case  81:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  100:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  109:  case  110:  case  111:  case  112:  case  113:  case  114:  case  116:  case  118:  case  119:  case  120:  case  121:  case  122:  case  123:  case  124:  case  125:  case  126:  case  129:  case  130:  case  131:  case  132:  case  134:  case  135:  case  136:  case  138:  case  139:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  149:  case  151:  case  152:  case  154:  case  155:  case  156:  case  157:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  178:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  200:  case  201:  case  202:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  228:  case  229:  case  231:  case  232:  case  233:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  242:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  255:  case  257:  case  258:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  267:  case  268:  case  269:  case  270:  case  271:  case  272:  case  273:  case  276:  case  277:  case  278:  case  279:  case  281:  case  282:  case  284:  case  286:  case  287:  case  288:  case  289:  case  290:  case  291:  case  292:  case  294:  case  295:  case  297:  case  298:  case  299:  case  301:  case  302:  case  303:  case  304:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  317:  case  319:  case  320:  case  321:  case  322:  case  323:  case  324:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  332:  case  333:  case  335:  case  336:  case  337:  case  338:  case  339:  case  340:  case  341:  case  342:  case  343:  case  344:  case  345:  case  346:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  353:  case  355:  case  356:  case  357:  case  360:  case  361:  case  362:  case  364:  case  365:  case  366:  case  367:  case  368:  case  370:  case  371:  case  372:  case  373:  case  374:  case  375:  case  376:  case  377:  case  378:  case  380:  case  381:  case  382:  case  383:  case  384:  case  385:  case  386:  case  387:  case  388:  case  389:  case  390:  case  391:  case  392:  case  393:  case  394:  case  395:  case  397:  case  399:  case  400:  case  402:  case  403:  case  404:  case  405:  case  407:  case  408:  case  409:  case  410:  case  411:  case  412:  case  413:  case  414:  case  415:  case  416:  case  418:  case  419:  case  420:  case  421:  case  422:  case  423:  case  424:  case  426:  case  427:  case  428:  case  430:
    return false;}
    tmp = getLeftModSubIn1Numbers(439,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  10:  case  11:  case  12:  case  13:  case  15:  case  17:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  29:  case  30:  case  31:  case  33:  case  34:  case  35:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  57:  case  58:  case  59:  case  60:  case  62:  case  66:  case  67:  case  68:  case  69:  case  70:  case  71:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  82:  case  83:  case  84:  case  85:  case  86:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  99:  case  100:  case  101:  case  102:  case  104:  case  105:  case  106:  case  107:  case  108:  case  111:  case  113:  case  114:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  121:  case  123:  case  124:  case  127:  case  129:  case  131:  case  132:  case  133:  case  134:  case  135:  case  136:  case  138:  case  139:  case  140:  case  142:  case  143:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  207:  case  208:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  219:  case  221:
    return false;}
    tmp = getLeftModSubIn1Numbers(457,a,b,c,d,e);
    switch(tmp){  case 3:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  18:  case  19:  case  20:  case  22:  case  23:  case  24:  case  26:  case  28:  case  29:  case  30:  case  31:  case  33:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  49:  case  51:  case  52:  case  53:  case  56:  case  58:  case  59:  case  60:  case  61:  case  62:  case  63:  case  65:  case  66:  case  67:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  85:  case  86:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  97:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  111:  case  112:  case  113:  case  115:  case  116:  case  117:  case  118:  case  119:  case  120:  case  122:  case  123:  case  124:  case  125:  case  126:  case  127:  case  129:  case  130:  case  131:  case  132:  case  133:  case  134:  case  135:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  144:  case  145:  case  146:  case  147:  case  148:  case  149:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  158:  case  159:  case  160:  case  161:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  169:  case  170:  case  171:  case  172:  case  173:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  186:  case  187:  case  188:  case  189:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  209:  case  210:  case  211:  case  212:  case  213:  case  214:  case  217:  case  219:  case  221:  case  222:  case  223:  case  224:  case  225:  case  226:  case  227:  case  230:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  238:  case  240:  case  243:  case  244:  case  245:  case  246:  case  247:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  254:  case  255:  case  258:  case  259:  case  260:  case  261:  case  262:  case  263:  case  264:  case  265:  case  266:  case  267:  case  268:  case  269:  case  270:  case  271:  case  273:  case  274:  case  275:  case  276:  case  277:  case  278:  case  279:  case  280:  case  281:  case  282:  case  284:  case  285:  case  286:  case  287:  case  288:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  308:  case  309:  case  310:  case  311:  case  312:  case  313:  case  314:  case  315:  case  316:  case  317:  case  318:  case  319:  case  320:  case  322:  case  323:  case  324:  case  325:  case  326:  case  327:  case  328:  case  330:  case  331:  case  332:  case  333:  case  334:  case  335:  case  337:  case  338:  case  339:  case  340:  case  341:  case  342:  case  344:  case  345:  case  346:  case  350:  case  351:  case  352:  case  353:  case  354:  case  355:  case  356:  case  358:  case  359:  case  360:  case  361:  case  362:  case  363:  case  364:  case  365:  case  366:  case  367:  case  368:  case  369:  case  371:  case  372:  case  374:  case  375:  case  376:  case  377:  case  378:  case  379:  case  380:  case  381:  case  382:  case  383:  case  384:  case  385:  case  386:  case  387:  case  388:  case  390:  case  391:  case  392:  case  394:  case  395:  case  396:  case  397:  case  398:  case  399:  case  401:  case  404:  case  405:  case  406:  case  408:  case  409:  case  410:  case  411:  case  412:  case  413:  case  414:  case  416:  case  417:  case  418:  case  419:  case  420:  case  421:  case  422:  case  424:  case  426:  case  427:  case  428:  case  429:  case  431:  case  433:  case  434:  case  435:  case  437:  case  438:  case  439:  case  442:  case  443:  case  444:  case  445:  case  446:  case  447:  case  448:  case  450:  case  451:  case  452:  case  454:
    return false;}
    tmp = getLeftModSubIn1Numbers(463,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  16:  case  17:  case  19:  case  20:  case  21:  case  22:  case  23:  case  24:  case  25:  case  26:  case  27:  case  28:  case  29:  case  30:  case  31:  case  32:  case  33:  case  35:  case  36:  case  37:  case  38:  case  39:  case  40:  case  41:  case  42:  case  43:  case  44:  case  45:  case  46:  case  48:  case  50:  case  51:  case  52:  case  53:  case  54:  case  56:  case  59:  case  60:  case  61:  case  62:  case  63:  case  67:  case  68:  case  69:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  79:  case  80:  case  81:  case  82:  case  83:  case  85:  case  87:  case  88:  case  89:  case  90:  case  91:  case  92:  case  93:  case  94:  case  95:  case  96:  case  98:  case  99:  case  101:  case  102:  case  103:  case  104:  case  105:  case  106:  case  107:  case  108:  case  109:  case  110:  case  112:  case  113:  case  114:  case  115:  case  116:  case  117:  case  119:  case  121:  case  122:  case  125:  case  126:  case  127:  case  128:  case  129:  case  130:  case  131:  case  132:  case  133:  case  135:  case  136:  case  137:  case  138:  case  139:  case  140:  case  141:  case  142:  case  143:  case  145:  case  147:  case  148:  case  150:  case  151:  case  152:  case  153:  case  154:  case  155:  case  156:  case  157:  case  160:  case  162:  case  163:  case  164:  case  165:  case  166:  case  167:  case  168:  case  169:  case  170:  case  171:  case  172:  case  173:  case  174:  case  175:  case  176:  case  177:  case  178:  case  179:  case  180:  case  181:  case  182:  case  183:  case  184:  case  185:  case  186:  case  187:  case  188:  case  190:  case  191:  case  192:  case  193:  case  194:  case  195:  case  196:  case  197:  case  198:  case  199:  case  200:  case  201:  case  202:  case  203:  case  204:  case  205:  case  206:  case  207:  case  208:  case  210:  case  211:  case  212:  case  213:  case  214:  case  215:  case  216:  case  217:  case  218:  case  219:  case  220:  case  221:  case  222:  case  223:  case  224:  case  227:  case  228:  case  229:  case  231:  case  232:  case  233:  case  234:  case  235:  case  236:  case  237:  case  238:  case  239:  case  240:  case  241:  case  243:  case  245:  case  246:  case  248:  case  249:  case  250:  case  251:  case  252:  case  253:  case  254:  case  255:  case  256:  case  257:  case  258:  case  259:  case  260:  case  261:  case  263:  case  264:  case  265:  case  267:  case  268:  case  269:  case  271:  case  273:  case  274:  case  275:  case  278:  case  280:  case  281:  case  282:  case  284:  case  285:  case  287:  case  288:  case  289:  case  290:  case  291:  case  292:  case  293:  case  294:  case  295:  case  296:  case  297:  case  298:  case  299:  case  300:  case  301:  case  302:  case  303:  case  304:  case  305:  case  306:  case  307:  case  309:  case  310:  case  311:  case  312:  case  314:  case  315:  case  316:  case  317:  case  318:  case  319:  case  320:  case  321:  case  322:  case  323:  case  325:  case  326:  case  327:  case  328:  case  329:  case  330:  case  331:  case  332:  case  333:  case  335:  case  336:  case  339:  case  340:  case  341:  case  342:  case  343:  case  344:  case  345:  case  347:  case  348:  case  349:  case  350:  case  351:  case  352:  case  353:  case  354:  case  355:  case  359:  case  360:  case  361:  case  363:  case  365:  case  366:  case  368:  case  369:  case  370:  case  371:  case  372:  case  373:  case  374:  case  375:  case  377:  case  378:  case  379:  case  382:  case  384:  case  385:  case  386:  case  387:  case  388:  case  390:  case  391:  case  393:  case  394:  case  395:  case  396:  case  397:  case  398:  case  399:  case  400:  case  401:  case  402:  case  403:  case  404:  case  405:  case  406:  case  408:  case  409:  case  410:  case  413:  case  414:  case  415:  case  416:  case  417:  case  418:  case  420:  case  421:  case  422:  case  423:  case  424:  case  426:  case  427:  case  428:  case  429:  case  430:  case  431:  case  432:  case  433:  case  434:  case  435:  case  437:  case  438:  case  439:  case  441:  case  442:  case  443:  case  444:  case  445:  case  446:  case  447:  case  448:  case  449:  case  450:  case  452:  case  454:  case  455:  case  457:  case  458:  case  459:  case  460:  case  461:  case  462:
    return false;}
    tmp = getLeftModSubIn1Numbers(487,a,b,c,d,e);
    switch(tmp){  case 2:  case  3:  case  4:  case  5:  case  6:  case  7:  case  9:  case  10:  case  11:  case  12:  case  13:  case  14:  case  15:  case  16:  case  17:  case  20:  case  21:  case  22:  case  23:  case  24:  case  26:  case  27:  case  28:  case  30:  case  31:  case  32:  case  33:  case  34:  case  36:  case  37:  case  38:  case  40:  case  42:  case  43:  case  44:  case  45:  case  46:  case  47:  case  48:  case  50:  case  52:  case  53:  case  54:  case  55:  case  56:  case  57:  case  58:  case  59:  case  62:  case  63:  case  65:  case  68:  case  69:  case  70:  case  71:  case  72:  case  73:  case  74:  case  75:  case  76:  case  77:  case  78:  case  79:  case  80:  case  81:  case  82:  case  83:  case  85:
    return false;}
    
    
    return true;
}



/*
__global__ 
void runCalcBCandDRange(int** BCAndDRange, int lowerB, int upperB, int aInt, int aPowerMod7){
    int index = blockIdx.x*blockDim.x + threadIdx.x;

    int bInt = upperB - index;


    int bPowerMod7 = (bInt % 7 == 0) ? 0 : 1;
    // This if is a filter precalculated. The sum of 4 6th power mod 7 cannot make 6
    int aMinusbMod7 = aPowerMod7 - bPowerMod7;
    while (aMinusbMod7 < 0){
        aMinusbMod7 += 7;
    }


    int mod7SumBCDEF = bPowerMod7;
    int lowerC = (int)(getLowerC(aInt, bInt) + 0.5);    //round up
    int upperC = (int)getUpperC(aInt, bInt);            //round down. But don't need it explicity
    upperC = (upperC > bInt) ? bInt : upperC;

    int* localResult;
    //malloc(&localResult, (upperC-lowerC+1)*sizeof(int)*4);
    localResult = (int*)malloc((upperC-lowerC+1)*sizeof(int)*4);
    //printf("%s\n", cudaGetErrorString(cudaGetLastError()));

    int cInt;
    int counter = 0;
    for(cInt = upperC; cInt > lowerC; cInt--){
        int cPowerMod7 = (cInt % 7 == 0) ? 0 : 1;
        mod7SumBCDEF = bPowerMod7 + cPowerMod7;
        if(mod7SumBCDEF > aPowerMod7){
            continue;
        }
        //printf("In c loop: aInt: %d, bInt: %d, cInt: %d, from block: %d, thread: %d\n", aInt, bInt, cInt, blockIdx.x, threadIdx.x);
        if (!isDecomposableIn3Numbers(aInt, bInt, cInt)){
            continue;
        }
        //printf("In c loop: aInt: %d, bInt: %d, cInt: %d, index: %d\n", aInt, bInt, cInt, index);
        int lowerD = (int)(getLowerD(aInt, bInt, cInt)+0.5);    //round up
        int upperD = (int) getUpperD(aInt, bInt, cInt);       //round down. But don't need it explicity

        upperD = (upperD > cInt) ? cInt : upperD;
        //bInt, cInt, lowerD, and UpperD

        
        //for(long long i = 0; i < 4LL*4*1024*1024*512; i += 4*4){
        //    BCAndDRange[i] = bInt;
        //    BCAndDRange[i+1] = cInt;
        //    BCAndDRange[i+2] = lowerD;
        //    BCAndDRange[i+3] = upperD;

        }
        
        
        localResult[counter*4] = bInt;
        localResult[counter*4+1] = cInt;
        localResult[counter*4+2] = lowerD;
        localResult[counter*4+3] = upperD;
        counter++;
    }

    //BCAndDRange[index] = localResult;
    //cudaMemcpy(BCAndDRange[index], localResult, index*4*4*counter, cudaMemcpyDeviceToDevice);
    //memcpy(BCAndDRange[index], localResult, index*4*4*counter, cudaMemcpyDeviceToDevice);
    memcpy(BCAndDRange[index], localResult, index*4*4*counter);
    
  
}
*/

__global__
void runMainComputing(int *d_BCAndDRange, long long counter, int aInt, int aPowerMod7){
    long long index = (blockIdx.x*blockDim.x + threadIdx.x)*4;
    //for(int i = 0; i < counter; i+=4){
    //d_BCAndDRange[i]      //bInt
    //d_BCAndDRange[i+1]    //cInt
    //d_BCAndDRange[i+2]    //lowerD
    //d_BCAndDRange[i+3]    //upperD
    
    int bInt = d_BCAndDRange[index];
    int cInt = d_BCAndDRange[index+1];
    int lowerD = d_BCAndDRange[index+2];
    int upperD = d_BCAndDRange[index+3];
    
    int bPowerMod7 = (bInt % 7 == 0) ? 0 : 1;
    int cPowerMod7 = (cInt % 7 == 0) ? 0 : 1;


    for(int dInt = upperD; dInt > lowerD; dInt--){
        int dPowerMod7 = (dInt % 7 == 0) ? 0 : 1;
        int mod7SumBCDEF = bPowerMod7 + cPowerMod7 + dPowerMod7;

        
        //////////////////////////////
        //cout << aInt << bInt << cInt << dInt << endl;

        if(mod7SumBCDEF >aPowerMod7){
            continue;
        }
        if(!isDecomposableIn2Numbers(aInt,bInt,cInt,dInt)){
            continue;
        }
        //printf("In d loop: aInt: %d, bInt: %d, cInt: %d, dInt: %d, from block: %d, thread: %d, index: %d\n", aInt, bInt, cInt, dInt, blockIdx.x, threadIdx.x, index);
        int lowerE = (int)(getLowerE(aInt, bInt, cInt, dInt)+0.5);    //round up
        int upperE = (int) getUpperE(aInt, bInt, cInt, dInt);       //round down. But don't need it explicity

        upperE = (upperE > dInt) ? dInt : upperE;

        int eInt;
        for(eInt = upperE; eInt > lowerE; eInt--){
            int ePowerMod7 = (eInt % 7 == 0) ? 0 : 1;
            mod7SumBCDEF = bPowerMod7 + cPowerMod7 + dPowerMod7 + ePowerMod7;
            if (mod7SumBCDEF > aPowerMod7){
                continue;
            }
            if (!isDecomposableIn1Numbers(aInt, bInt, cInt, dInt, eInt)){
                //cout << "isDecomposableIn1Numbers is not satisfied."<<endl;
                //cout << aInt<<", " << bInt<<", " << cInt<<", " << dInt<<", " << eInt<<", " << fInt<<", " << endl;
                continue;
            }
            //printf("In e loop: aInt: %d, bInt: %d, cInt: %d, dInt: %d, eInt: %d, from block: %d, thread: %d, index: %d\n", aInt, bInt, cInt, dInt, eInt, blockIdx.x, threadIdx.x, index);
            int upperF = (int)(getUpperF(aInt, bInt, cInt, dInt, eInt)+0.5);
            int lowerF = upperF - 1;

            upperF = (upperF > eInt) ? eInt : upperF;

            int fInt;
            for(fInt = upperF; fInt > lowerF; fInt--){
                
                if(!isABCDEFModEqual(aInt, bInt, cInt, dInt, eInt, fInt)){
                    //cout << "In isABCDEFModEqual:" << aInt<<", " << bInt<<", " << cInt<<", " << dInt<<", " << eInt<<", " << fInt<<", " << endl;
                    //printf("In isABCDEFModEqual (when not equal): aInt: %d, bInt: %d, cInt: %d, dInt: %d, eInt: %d, fInt: %d, from block: %d, thread: %d, index: %d, lowerF: %d, upperF: %d\n", aInt, bInt, cInt, dInt, eInt, fInt, blockIdx.x, threadIdx.x, index, lowerF, upperF);
                    continue;
                }
                
                printf("Found? aInt: %d, bInt: %d, cInt: %d, dInt: %d, eInt: %d, fInt: %d, from block: %d, thread: %d, index: %d\n", aInt, bInt, cInt, dInt, eInt, fInt, blockIdx.x, threadIdx.x, index);
            }
        }
    }
    //printf("Done with thread. In d loop: aInt: %d, bInt: %d, cInt: %d, from block: %d, thread: %d, index: %lld\n", aInt, bInt, cInt, blockIdx.x, threadIdx.x, index);
    //}
}

int main(void){
    //int aInt = 1234567;
    int aInt = 12345;
    //int aInt = 123456;
    //int primes1000[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997};

    //int *d_primes1000;
    //cudaMallocManaged(&d_primes1000, sizeof(primes1000));
    //cudaDeviceSynchronize();
    //printf("%s\n", cudaGetErrorString(cudaGetLastError()));

    //cudaMemcpy(d_primes1000, &primes1000, sizeof(primes1000), cudaMemcpyHostToDevice);
    //cudaDeviceSynchronize();
    //printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    int *BCAndDRange;
    long long sizeLimit = 10*(1LL<<30);    // (1LL<<30) Bytes = 1GB
    BCAndDRange = (int*)malloc(sizeLimit);

    int *d_BCAndDRange;
    cudaMalloc(&d_BCAndDRange, sizeLimit);        
    printf("%s\n", cudaGetErrorString(cudaGetLastError()));


    for(int n = aInt; n < aInt + 1; n++){
        int lowerB = (int)(aInt/pow(5, 1.0f/6) + 0.5); 
        int upperB = aInt - 1;

        int aPowerMod7 = (aInt % 7 == 0) ? 0 : 1;
        if(aPowerMod7 == 0)continue;

        //int numberOfthreads = 256;
        //int numberOfthreads = 4;
        printf("lowerB: %d, upperB: %d\n", lowerB, upperB);
       
        //int **BCAndDRange;
        //cudaMalloc(&BCAndDRange, (upperB-lowerB+1)*sizeof(int*));
        


        //int *d_BCAndDRange;
        //cudaMalloc(&d_BCAndDRange, sizeof(int)*4LL*(1024*1024*512));     //total amount is 8GB for sizeof(int)*4*(1024*1024*512)
        //printf("%s\n", cudaGetErrorString(cudaGetLastError()));

        ////////////////////////////////////////////////
        
        long long counter = 0;

        for(int bInt = upperB; bInt >= lowerB; bInt--){
            if(counter > (sizeLimit/4)){
                    cout<<"Inner Loop. ";
                    cout<<"counter: "<<counter;
                    cout<<". counterLimit: "<<(sizeLimit/4)<<endl;
                    break;
                }
            int bPowerMod7 = (bInt % 7 == 0) ? 0 : 1;
            // This if is a filter precalculated. The sum of 4 6th power mod 7 cannot make 6
            int aMinusbMod7 = aPowerMod7 - bPowerMod7;
            while (aMinusbMod7 < 0){
                aMinusbMod7 += 7;
            }
        
        
            int mod7SumBCDEF = bPowerMod7;
            int lowerC = (int)(getLowerC(aInt, bInt) + 0.5);    //round up
            int upperC = (int)getUpperC(aInt, bInt);            //round down. But don't need it explicity
            upperC = (upperC > bInt) ? bInt : upperC;

            int cInt;
            for(cInt = upperC; cInt > lowerC; cInt--){
                int cPowerMod7 = (cInt % 7 == 0) ? 0 : 1;
                mod7SumBCDEF = bPowerMod7 + cPowerMod7;
                if(mod7SumBCDEF > aPowerMod7){
                    continue;
                }
                //printf("In c loop: aInt: %d, bInt: %d, cInt: %d, from block: %d, thread: %d\n", aInt, bInt, cInt, blockIdx.x, threadIdx.x);
                if (!isDecomposableIn3Numbers(aInt, bInt, cInt)){
                    continue;
                }


                //printf("In c loop: aInt: %d, bInt: %d, cInt: %d, index: %d\n", aInt, bInt, cInt, index);
                int lowerD = (int)(getLowerD(aInt, bInt, cInt)+0.5);    //round up
                int upperD = (int) getUpperD(aInt, bInt, cInt);       //round down. But don't need it explicity

                upperD = (upperD > cInt) ? cInt : upperD;

                BCAndDRange[counter] = bInt;
                BCAndDRange[counter+1] = cInt;
                BCAndDRange[counter+2] = lowerD;
                BCAndDRange[counter+3] = upperD;
                counter+=4;
                if(counter > (sizeLimit/4)){
                    cout<<"Inner Loop. ";
                    cout<<"counter: "<<counter;
                    cout<<". counterLimit: "<<(sizeLimit/4)<<endl;
                    cout<<"bInt: "<<bInt<<", ";
                    cout<<"cInt: "<<cInt<<", ";
                    cout<<"lowerD: "<<lowerD<<", ";
                    cout<<"upperD: "<<lowerD<<endl;

                    cout<<"counter output 1: "<<counter<<endl;
                    

                    cudaMemcpy(d_BCAndDRange, BCAndDRange, sizeLimit, cudaMemcpyHostToDevice);
                    printf("%s\n", cudaGetErrorString(cudaGetLastError()));

                    //////////////////////////////////////////
                    ///// call kernel
                    //long long amount = counter/4;
                    runMainComputing<<<counter/4, threadAmount>>>(d_BCAndDRange, counter, aInt, aPowerMod7);
                    cudaDeviceSynchronize();
                    //////////////////////////////////////////
                    
                    counter=0;
                    continue;
                }
            }
        }


        //this if means the last portion is less than whole memory block
        if (counter != 0 && counter < sizeLimit/4){
            cudaMemcpy(d_BCAndDRange, BCAndDRange, counter * 4, cudaMemcpyHostToDevice);
            printf("%s\n", cudaGetErrorString(cudaGetLastError()));
            //////////////////////////////////////////
            ///// call kernel
            //long long amount = counter/4;
            printf("Starting runMainComputing Threads.\n");
            runMainComputing<<<counter/4, threadAmount>>>(d_BCAndDRange, counter, aInt, aPowerMod7);
            //////////////////////////////////////////
        }
        ////////////////////////////////////////////////




        
        //cout<<"Pause Using cin"<<endl;
        //cout<<"counter: "<<counter<<endl;
        //int age;
        //cin >> age;

        cudaFree(d_BCAndDRange);
        printf("%s\n", cudaGetErrorString(cudaGetLastError()));

        //cudaDeviceSynchronize();
        free(BCAndDRange);
        printf("%s\n", cudaGetErrorString(cudaGetLastError()));

        return 0;
    }
}
