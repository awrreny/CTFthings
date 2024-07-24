
## Snore

unfinished !!!!!!!!
### Setup
<!-- - Implements the Schnorr signature algorithm
- Generates parameters for the signatures
- Loop 10 times:
    - Generates keys for signatures
    - Generate and print signature for user-chosen message
    - Prompt for forged signature for a different user-chosen message
- If all signatures are correct, prints the flag.

alt: -->
- Implements the Schnorr signature algorithm
- Loop 10 times:
    - Input 2 different messages
    - We are given the signature of one of them, and using that, have to forge the signature of the other.
- If all signatures are correct, we get the flag.
---
### tl;dr
- In `snore_sign()` there is `e = hash((r + m) % p) % q`. Because of the `% p`, for any `i`, `m=i` and `m=i+p` will give the same hash and thus the same signature.
- Each time, use the oracle to get the signature for `m=i` then use that as the signature to `m=i+p`.
---
### Solution
Looking through `main()`, the server lets you sign a message then requires that you forge a signature for a *different* message. Then you do this 10 times to then get the flag.

Searching `cryptography snore signature` gives "[Schnorr signature](https://en.wikipedia.org/wiki/Schnorr_signature)", showing that this is an implementation of a Schnorr signature. There is no mention of the signature scheme being insecure or broken so we can assume that, if implemented correctly, Schnorr signatures are secure.

This means we can find a vulnerability by comparing the secure wikipedia implementation with the code and looking for differences.
There is a custom hash function but it is an extension of `sha512` which is secure, so the hash function is secure.

You may notice a difference in encryption:

`e = hash((r + m)  % p) % q` 

vs. 

`e = H ( r ∥ M )  , where  ∥  denotes concatenation`

The message is added instead of concatenated, and more importantly it is reduced modulo `p` before being hashed, meaning `m = 0` and `m = p` will have the same hash, and consequently the same signature. This can be used to get the flag as follows:
---
Solve script:
```py
from pwn import *

# proc = process(["python3", "chal.py"])
proc = remote("snore-signatures.chal.uiuc.tf", 1337, ssl=True)

# use signing oracle for m = 0 and use signature for m = p
# then m = 1 and m = p + 1
# etc.

p = int(proc.recvline().strip().split()[-1])

for i in range(10):
    proc.sendlineafter(b'm = ', str(i).encode())
    print(f"{i} successes")
    s = proc.recvline().strip().split()[-1]
    proc.sendlineafter(b'm = ', str(p+i).encode())
    proc.sendlineafter(b's = ', s)

proc.recvuntil(b'you win!\n')
print(proc.recvline().strip().decode())

# uiuctf{add1ti0n_i5_n0t_c0nc4t3n4ti0n}
```
<!-- 
TODO: find out why it talks about addition -->