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