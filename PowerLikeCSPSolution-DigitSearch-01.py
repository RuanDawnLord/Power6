import copy
#import datetime
import random
import math
import itertools as it

from datetime import datetime
from collections import Counter
from heapq import heappush, heappop, heapreplace

samplingPoints = 500    # result of nCr(41, 3)=10660
power = 4
a = 422481 
numOfWeights = power-1    # how many numbers, power-1
numOfDigits = len(str(a))     # how many digits, the same as the length of a
lengthLimit = 100
actionTypes = 3     
smallActions = [0, -1, 1]

ns = [0,0,0]   # manually set b, c, and d. a^p=b^p+c^p+d^p

#ns = [0,0,0,0,0]   # manually set b, c, d, e, f. a^p=b^p+c^p+d^p+e^p+f^p

found = False

def nCr(n,r):
    'calculate permutation for '       
    f = math.factorial
    return f(n) // f(r) // f(n-r)

def getSumAfterPower():
    sum=0
    for i in range(numOfWeights):
        sum += ns[i]**power
    return sum
    
def getDifference():
    return a**power - getSumAfterPower()

def printCurrentTime():
    currentDT = datetime.now()
    print ("Current Time is: ", str(currentDT))

def printInfoNS(counterWhileLoop=None):
    print("While Loop Iteration: ", counterWhileLoop)
    print("a: ", a, "a after power: ", a**power)
    print("Sum After Power: ", getSumAfterPower())
    print("Difference: ", getDifference())
    print(ns)

def main():
    print(a)

main()