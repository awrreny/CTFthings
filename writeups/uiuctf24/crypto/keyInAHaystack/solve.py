from Crypto.Util.Padding import unpad
from Crypto.Cipher import AES

from hashlib import md5


# slightly modified from chal.py
def decrypt(key, ct):
    pt = AES.new(
        key = md5(b"%d" % key).digest(),
        mode = AES.MODE_ECB
    ).decrypt(ct)
    return unpad(pt, 16).decode()

# from server
enc_flag = bytes.fromhex("734aa343a8e1e4ec4acab8365b063e9e6514eb56941a39ac3ddc2837d596017fcb366400c3e192e88c17a5b6b3370a9c")

# 
key = 859914774577
print(decrypt(key, enc_flag))
