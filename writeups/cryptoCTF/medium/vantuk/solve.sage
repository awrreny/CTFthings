from sage.all import *
from sage.libs.singular import *
from Crypto.Util.number import long_to_bytes

A = 6080057478320734754578252336954411086329731226445881868123716230995225973869803901199434606333357820515656618869146654158788168766842914410452961599054518002813068771365518772891986864276289860125347726759503163130747954047189098354503529975642910040243893426023284760560550058749486622149336255123273699589/10166660077500992696786674322778747305573988490459101951030888617339232488971703619809763229396514541455656973227690713112602531083990085142454453827397614
U = 3225614773582213369706292127090052479554140270383744354251548034114969532022146352828696162628127070196943244336606099417210627640399143341122777407316956319347428454301338989662689983156270502206905873768685192940264891098471650041034871787036353839986435/9195042623204647899565271327907071916397082689301388805795886223781949921278129819112624089473306486581983153439866384171645444456400131619437018878598534536108398238424609
V = 1971582892158351181843851788527088806814104010680626247728311504906886858748378948163011806974145871263749452213375101951129675358232283650086419295655854343862361076089682606804214329522917382524296561295274823374483828323983651110722084223144007926678084087/9195042623204647899565271327907071916397082689301388805795886223781949921278129819112624089473306486581983153439866384171645444456400131619437018878598534536108398238424609

# A = a + 1/17a
# a large so A ~= a
# so a = round(A)

a = round(A)
# alternatively could solve above eqn

# let x = m1, y = m2, h = x^2 + y^2
# U*h = (h+a)x-y
# V*h = -x+(h-a)y

# sage can just solve() the 2 equations

# but lets do it manually so we understand
# tl;dr use resultant https://en.wikipedia.org/wiki/Resultant


R.<x, y> = PolynomialRing(QQ)
f = U*x^2 + U*y^2 - x^3 - x*y^2 - a*x + y
g = V*x^2 + V*y^2 + x + a*y - y*x^2 - y^3

# TODO explain how resultant is used for multivariate

# resultant is 0 iff f and g share a solution (x,y).
# we are solving the simultaneous equations f and g so they must share a solution
# so resultant == 0
# resultant w.r.t. y is a polynomial in terms of x so we get the polynomial p(x) = 0
# this polynomial can be solved giving solutions for x
# knowing x, it is easy to find y

# throughout this there are multiple sols for x and y but we know that they are integers representing ASCII strings
resultant = f.resultant(g, y)

# convert resultant to symbol expression so sage can solve it
# SR = symbolic ring
symbolicDet = SR(resultant) 

x = var('x')
sols = solve(symbolicDet == 0, x)

for sol in sols:
    # gets the (num) in `x == (num)`
    xi = sol.rhs()

    # if valid solution, save part 1 of the message, otherwise go to next x sol
    if xi == 0: continue
    try: m1 = long_to_bytes(int(xi)).decode()
    except: continue

    # uses first part to find second part
    # substitute known value of x
    f_substituted = f.subs(x=Integer(xi))

    y = var('y')
    ysols = solve(SR(f_substituted), y)
    
    for ysol in ysols:
        yi = ysol.rhs()

        if yi == 0: continue
        try: m2 = long_to_bytes(int(yi)).decode()
        except: continue

        print(m1+m2)


# CCTF{d!D_y0U_5oLv3_7HiS_eQu4T!On_wItH_uSing_c0mPlEx_Num8erS!!?}

