
## Determined

### Setup:
- The flag is encrypted with RSA in `gen.py`. We can find `p` and `q` because they are reused in `server.py`.
- `server.py` accepts input, forms a matrix containing `p`, `q` and user inputs, then computes and outputs a function of the matrix.
---
### tldr:
- Replacing `p`, `q`, `r` with `sympy` symbols makes `server.py` output an expression e.g `p*q - p*r - q + r`
- Giving the same input to the actual server will give you the number which is equal to the expression, e.g `6914370386314159269442068348 = p*q - p*r - q + r`
- Repeat this to get at least 3 equations which can be solved.
- Alternate solution: It is also possible to solve this with one ncat request with a input such that the output equals `q`.
---
### Solution 1
`server.py` takes in user input, and uses it to create a matrix.
This matrix contains the input as well as the numbers `p`, `q` and `r`.

```py
M = [
    [p , 0 , i1, 0 , i2],
    [0 , i3, 0 , i4, 0 ],
    [i5, 0 , i6, 0 , i7],
    [0 , q , 0 , r , 0 ],
    [i8, 0 , i9, 0 , 0 ]
]
# i1, i2, ... are user inputs
```
Then it computes some function `fun(M)` of the matrix and prints the output.
(`fun(M)` is actually the determinant of the matrix but knowing this is not required)

In the local `server.py` we can replace `p`, `q` and `r` with `sympy` symbols, so that the output will be in terms of the variables `p`, `q` and `r`.

```py
# from SECRET import FLAG, p, q, r
from sympy import symbols
p, q, r = symbols('p q r')
```
Now we can give an input to the local `server.py`, giving us an expression with `p`, `q`, `r`, then give the same input to the server at `determined.chal.uiuc.tf`, giving us the number which is equal to the expression.

```
$ py server.py
...
(input only ones)
...
[DET] Have fun: p*q - p*r - q + r

$ ncat --ssl determined.chal.uiuc.tf 1337
...
(input only ones)
...
[DET] Have fun: 6914370386......9442068348
(the actual number is very long)
```
This tells us that `6914370386......9442068348 = p*q - p*r - q + r`. Repeat this for different inputs to get many equations which can be solved by simultaneous equations.

In my case, my 2nd equation had the first input as `2` and the rest as `1`, giving `6914370386......66118301362 = p*q - p*r - 2*q + 2*r`.
Then I had only my 3rd input as `2` and the rest as `1` giving `-2050722897......5305854526 = p*q - 2*p*r - q + 2*r`

Using `sympy` to solve these equations, we can find `p` and `q` and decrypt the flag.

---
Solution 1 script:
```python
# from gen.txt
n = 158794636700752922781275926476194117856757725604680390949164778150869764326023702391967976086363365534718230514141547968577753309521188288428236024251993839560087229636799779157903650823700424848036276986652311165197569877428810358366358203174595667453056843209344115949077094799081260298678936223331932826351
e = 65535
c = 72186625991702159773441286864850566837138114624570350089877959520356759693054091827950124758916323653021925443200239303328819702117245200182521971965172749321771266746783797202515535351816124885833031875091162736190721470393029924557370228547165074694258453101355875242872797209141366404264775972151904835111


# outputs of $ ncat --ssl determined.chal.uiuc.tf 1337
# all ones
out1 = 69143703864818353130371867063903344721913499237213762852365448402106351546379534901008421404055139746270928626550203483668654060066917995961156948563756758160310602854329852071039981874388564191274850542349182490083881348633205451737697677971069061869428981062350490771144358405734467651517359001029442068348

# all ones except first input is 2
out2 = 69143703864818353130371867063903344721913499237213762852365448402106351546379534901008421404055139746270928626550203483668654060066917995961156948563756752700538511697695076762773965531010748006659492973112024174525746367374237063293523650725957257590333321191693876781172827116596771133374732236966118301362

# all ones except third input is 2
out3 = -20507228971116216520532192348387428412930727130252865244433881346657061233264632589951133278253086042176373261041141001240445189387352296505922127124480310700616103779947395254171594969854050256012376773564149098369780795085927063724185033941229309990221008472272741624740684057095906609100892782375305854526



# solve simultaneous equations with sympy
from sympy import Eq, solve, symbols

p, q, r = symbols('p q r')

eq1 = Eq(out1, p*q - p*r - q + r)
eq2 = Eq(out2, p*q - p*r - 2*q + 2*r)
eq3 = Eq(out3, p*q - 2*p*r - q + 2*r)

sols = solve((eq1, eq2, eq3), p, q, r)[0]
p = int(sols[0])
q = int(sols[1])



# typical RSA decryption when p and q are known
phi = (p-1)*(q-1)
d = pow(e,-1,phi)
m = pow(c,d,n)

from Crypto.Util.number import long_to_bytes
print(long_to_bytes(m).decode())
```


### Solution 2
---

After the CTF ended, I heard that it was possible to solve this challenge with only one equation (one ncat request): let's see how we can do this.

We need to create an input such that `p` or `q` can be easily extracted from the output. To help me see how to do this I changed all the inputs to sympy symbols, giving:
 ```py
i2*i4*i6*i8*q - i1*i4*i7*i8*q - i2*i4*i5*i9*q + i4*i7*i9*p*q - i2*i3*i6*i8*r + i1*i3*i7*i8*r + i2*i3*i5*i9*r - i3*i7*i9*p*r 
```
Having `r` does not help me so I want to eliminate it. All the terms which have `r` also have `i3` so setting `i3` to 0 eliminates `r`.

  

Now we get:
```py
i2*i4*i6*i8*q - i1*i4*i7*i8*q - i2*i4*i5*i9*q + i4*i7*i9*p*q
``` 
and that is already enough information to get `q` (because we have `n = p*q`). Still, let's simplify it further.

Setting `i7` and `i9` to 0 leaves us with a single term 
```py
i2*i4*i6*i8*q
```
Setting all other inputs to 1 makes the output just `q`. From here we can use `n = p*q` to find `p`, then decrypt the flag as normal.

---
Solution 2 script:
```python
# from gen.txt
n = 158794636700752922781275926476194117856757725604680390949164778150869764326023702391967976086363365534718230514141547968577753309521188288428236024251993839560087229636799779157903650823700424848036276986652311165197569877428810358366358203174595667453056843209344115949077094799081260298678936223331932826351
e = 65535
c = 72186625991702159773441286864850566837138114624570350089877959520356759693054091827950124758916323653021925443200239303328819702117245200182521971965172749321771266746783797202515535351816124885833031875091162736190721470393029924557370228547165074694258453101355875242872797209141366404264775972151904835111


inputs = [1]*9
inputs[2] = 0  # i3 = 0
inputs[6] = 0  # i7 = 0
inputs[8] = 0  # i9 = 0

# use pwntools to automatically send the input and read the output
# it's probably faster to do this manually :/
from pwn import *

# context.log_level='debug'

proc = remote("determined.chal.uiuc.tf", 1337, ssl=True)

for i in inputs:
    toSend = str(i).encode()
    proc.sendlineafter(b' = ', toSend)

proc.recvuntil(b'[DET] Have fun: ')
q = int(proc.recvline().strip())


p = n // q
assert p * q == n, "Invalid q!!!"


# typical RSA decryption when p and q are known
phi = (p-1)*(q-1)
d = pow(e,-1,phi)
m = pow(c,d,n)

from Crypto.Util.number import long_to_bytes
print(long_to_bytes(m).decode())

# uiuctf{h4rd_w0rk_&&_d3t3rm1n4t10n}
```

