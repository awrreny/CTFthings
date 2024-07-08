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