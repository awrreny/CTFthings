
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
### sol
We have to give 2 different messages such that either:
    1. one of the signatures gives enough private information to forge a signature
    2. they have the same signature, or
    3. the signature of one can be [transformed](https://en.wikipedia.org/wiki/Malleability_%28cryptography%29) into the other

2,3 require the oracle while 1. does not
because schnorr signatures (when implemented correctly) are secure, we need to compare the [wikipedia description](https://en.wikipedia.org/wiki/Schnorr_signature) (secure) with the given implementation (insecure) and look for differences.
Notice, in `snore_sign()` the hash function eliminates (3) as a possibility and also we see that (2) is possible
the hash is secure because `sha512` is used




---


old writeup


Searching `cryptography snore signature` shows that this is an implementation of a Schnorr signature.

Looking through `main()`, the server lets you sign a message then requires that you forge a signature for a *different* message. Then you do this 10 times to then get the flag.

Looking through the implementation of the Schnorr signature and comparing it with its [wikipedia description](https://en.wikipedia.org/wiki/Schnorr_signature), you may notice a difference in encryption:

`e = hash((r + m)  % p) % q` 

vs. 

`e = H ( r ∥ M )  , where  ∥  denotes concatenation`

The message is added instead of concatenated and there is also a modulo `p`, meaning `m = 0` and `m = p` will have the same hash, and the same signature.
---
Solve script:
```py
from pwn import *

# proc = process(["python3", "chal.py"])
proc = remote("snore-signatures.chal.uiuc.tf", 1337, ssl=True)

# use oracle for m = 0 and use signature for m = p
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

