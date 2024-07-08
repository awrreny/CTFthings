

## Naptime

### Setup
- Implements [Merkle-Hellman](https://en.wikipedia.org/wiki/Merkle%E2%80%93Hellman_knapsack_cryptosystem) but shuffled, and each character is encrypted separately.
---
### tl;dr
- Each character is encrypted separately making brute force very easy.
- Sometime after the CTF I read [a paper on knapsack cryptosystem attacks](http://paper.ijcsns.org/07_book/202009/20200922.pdf) where I learned and implemented the intended lattice-based solution. 
---
### Solution 1 - Brute force
Each character is encrypted separately so I can just loop through each possible ASCII char, encrypt it, store the result in a dictionary, then use the dictionary to directly convert each `ct` element to a character.
```py
import string

def getMappings(a):
    out = dict()
    # for every possible ASCII char
    for char in string.printable:
        out[encrypt(char, a)] = char
    return out

def encrypt(char, a):
    charVal = ord(char)
    total = 0
    for i in range(len(a) - 1, -1, -1):
        if charVal & 1: total += a[i]
        charVal >>= 1
    return total

a =  [66128, 61158, 36912, 65196, 15611, 45292, 84119, 65338]
ct = [273896, 179019, 273896, 247527, 208558, 227481, 328334, 179019, 336714, 292819, 102108, 208558, 336714, 312723, 158973, 208700, 208700, 163266, 244215, 336714, 312723, 102108, 336714, 142107, 336714, 167446, 251565, 227481, 296857, 336714, 208558, 113681, 251565, 336714, 227481, 158973, 147400, 292819, 289507]

mapping = getMappings(a)
print("".join([mapping[element] for element in ct]))
```

---
### Solution 2 - Lattices
I am new to LLL so there may be errors: I apologise in advance!
This writeup is aimed towards those who are new to lattices and knapsack cryptosystems, partially because that was me when I started this challenge.
<!-- 
i just implemented the low density attack from http://paper.ijcsns.org/07_book/202009/20200922.pdf (at theorem 3.2) -->

Wikipedia has a good [explanation](https://en.wikipedia.org/wiki/Merkle%E2%80%93Hellman_knapsack_cryptosystem) of the implemented cryptosystem for the curious, but for this solution all the private information doesn't matter because this solution solves the knapsack problem directly.

This cryptosystem relies on the knapsack problem (subset sum problem) being hard to solve, but in this implementation it isn't hard. 
Because the bit length of the elements of `a` are much larger than the amount of elements, this knapsack has low 'density' and the problem can be solved efficiently with a lattice-based attack.

---

#### Lattices and LLL brief intro


[Video intro to lattices](https://www.youtube.com/watch?v=QDdOoYdb748)

LLL is an algorithm which can quickly find a good, small basis from a bad basis. For example, given (7, 3), (2, 1) it will output (1, 0), (0, 1). Both bases represent the same lattice, so the good basis vectors are each an integer linear combination of the bad basis vectors. 

It can be used in non-lattice cryptosystems by transforming the decryption problem into one involving vectors and a lattice, where public information is represented in the large input basis vectors. The basis is constructed in such a way so that the LLL output contains private information which can be used to solve the problem.

---
Notice that when the message is encoded as a vector (e.g. 010110 -> [0, 1, 0, 1, 1, 0]), it is very short compared to the elements of `a`, so it would be a good idea to try making the message vector the LLL output.
This [paper](http://paper.ijcsns.org/07_book/202009/20200922.pdf) describes the following lattice:
```py
M = [
    [1, 0, 0, ..., 0, -a1],
    [0, 1, 0, ..., 0, -a2],
    [0, 0, 1, ..., 0, -a3],
    [...],
    [0, 0, 0, ..., 1, -an],
    [0, 0, 0, ..., 0, s]
    # where a1, a2, ... are elements of a, and s is their sum
    # forming a square matrix with n + 1 rows and columns
]
```
For this lattice, the intended linear combination is `(all rows with ai in the sum) + (the last vector)`, resulting in `[message] + [0]` (for the last column). For example if `n = 3` and `s = a1 + a3` then one of the output vectors would be `[1, 0, 0, -a1] + [0, 0, 1, -a3] + [0, 0, 0, s]` = `[1, 0, 1, 0]` where the message is `101`.

The last column is constructed so that a correct solution to the knapsack problem will have the last element = `0`, making it a short vector and more likely to appear in the LLL output. However, running LLL on this lattice may still output vectors where the last element is not `0`. To solve this we can multiply the entire last column by some constant, which 'punishes' incorrect solutions by increasing their last element, making the vector larger and less likely to appear in the LLL output. 

The paper also suggests filling the last row with 1/2 but the knapsack's density is low enough so that it works without this adjustment.

---
Solve script:
```py
from sage.all import *


a =  [66128, 61158, 36912, 65196, 15611, 45292, 84119, 65338]
ct = [273896, 179019, 273896, 247527, 208558, 227481, 328334, 179019, 336714, 292819, 102108, 208558, 336714, 312723, 158973, 208700, 208700, 163266, 244215, 336714, 312723, 102108, 336714, 142107, 336714, 167446, 251565, 227481, 296857, 336714, 208558, 113681, 251565, 336714, 227481, 158973, 147400, 292819, 289507]

def find_solution(M):
    for row in M:
        # must sum to s
        # there will be atleast one output vector where this is not zero to maintain the original lattice
        if row[-1] != 0: continue

        solution = row[:-1]
        
        # is solution made of only 0 and 1
        if set(solution) == {0, 1}: 
            return True, solution
    # none found
    return False, []


def decryptChar(s):
    n = len(a)
    N = 100  # this is way bigger than necessary

    M = identity_matrix(ZZ, n + 1)
    for i, ai in enumerate(a):
        M[i, n] = -N*ai
    M[n, n] = N*s

    M = M.LLL()
    print(M)
    validLattice, solution = find_solution(M)
    assert validLattice, M

    return chr(int("".join([str(bit) for bit in solution]), 2))


print("".join(decryptChar(char) for char in ct))
```
