from sage.all import *



a =  [66128, 61158, 36912, 65196, 15611, 45292, 84119, 65338]
ct = [273896, 179019, 273896, 247527, 208558, 227481, 328334, 179019, 336714, 292819, 102108, 208558, 336714, 312723, 158973, 208700, 208700, 163266, 244215, 336714, 312723, 102108, 336714, 142107, 336714, 167446, 251565, 227481, 296857, 336714, 208558, 113681, 251565, 336714, 227481, 158973, 147400, 292819, 289507]

def find_solution(M):
    for row in M:
        # must sum to s
        if row[-1] != 0: continue

        solution = row[:-1]
        
        # is solution made of only 0 and 1
        if set(solution) == {0, 1}: 
            return True, solution
    # none found
    return False, []


def decryptChar(s):
    n = len(a)
    N = 100  # bigger is better?

    M = identity_matrix(ZZ, n + 1)
    for i, ai in enumerate(a):
        M[i, n] = -N*ai
    M[n, n] = N*s

    M = M.LLL()

    validLattice, solution = find_solution(M)
    assert validLattice, M

    return chr(int("".join([str(bit) for bit in solution]), 2))



print("".join(decryptChar(char) for char in ct))
