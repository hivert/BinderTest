# coding=utf-8
r"""
Check for coding / decoding and action on rook and code

The primary goal is to check that Definition \ref{defactioncode} is correct.
"""

def mcode_ref(c):
    r"""
    Fonction m (Definition \ref{def_r_code})

    EXAMPLES::

        sage: mcode_ref((1, 2, 8, 3, 6, 4, 2, 7))
        5
        sage: mcode_ref((3, 6, 4, -4, 2, 9, 4, -3, 5, 2, 5, 3, 8))
        6
        sage: mcode_ref((3, 6, 4, -4, 2, 9, 4, -3))
        3
        sage: mcode_ref((0, 2, 1, -1, 1, 2, 5, 4))
        4
    """
    if not c:
        return 0
    d = c[-1]
    if d <= 0:
        return -d
    mw = mcode_ref(c[:-1])
    if d <= mw + 1:
        return mw + 1
    else:
        return mw

def mcode(c):
    r"""
    Faster Implementation of m, only agree with m on codes

    TESTS::

        sage: for n in range(7):
        ....:     for c in codes(n):
        ....:         assert(mcode_ref(c) == mcode(c))
    """
    n = len(c) + 1
    k = 0
    for i in range(1, n):
        if c[-i] <= 0:
            k = i
            break
    if k == 0:
        return n-1
    else :
        k1 = -c[-k]
        k2 = 0
        for i in range(-k+1, 0):
            if c[i] <= k1+k2+1:
                k2 += 1
        return k1 + k2

def is_code(c):
    r"""
    Test for code (Definition \ref{def_r_code})

    EXAMPLES::

        sage: is_code((0,))
        True
        sage: is_code((1,))
        True
        sage: is_code((2,))
        False
        sage: is_code((-1,))
        False
        sage: is_code((1, -1, -1))
        True
        sage: is_code((1, -1, -2))
        False
    """
    for i in range(0, len(c)):
        if not -mcode(c[:i]) <= c[i] <= i+1:
            return False
    return True

def code_iter(n):
    """
    Iterate on codes according to Definition \ref{def_r_code}

    See codes for tests
    """
    if n == 0:
        yield ()
    else:
        for c in code_iter(n-1):
            for i in range(n, -mcode(c)-1, -1):
                yield c + (i,)

@cached_function
def codes(n):
    """
    List of codes according to Definition \ref{def_r_code}

    EXAMPLES::

        sage: codes(1)
        [(1,), (0,)]
        sage: codes(2)
        [(1, 2), (1, 1), (1, 0), (1, -1), (0, 2), (0, 1), (0, 0)]

    TESTS::

        sage: "|".join("".join(str(l) for l in w) for w in codes(3))
        '123|122|121|120|12-1|12-2|113|112|111|110|11-1|11-2|103|102|101|100|1-13|1-12|1-11|1-10|1-1-1|023|022|021|020|013|012|011|010|01-1|003|002|001|000'
        sage: for i in range(7):
        ....:     for c in codes(i): assert(is_code(c))
        sage: for i in range(7): assert(len(codes(i)) == r(i))
    """
    return list(code_iter(n))

def encode(r):
    r"""
    Encode a rook (Definition \ref{def_encode})

    EXAMPLES::

        sage: encode((2, 0, 3, 0, 4))
        (0, 1, 2, 4, -1)
        sage: encode((0, 2, 4, 0, 1))
        (1, 1, -1, 2, 0)

    TESTS::

        sage: for n in range(7):
        ....:     for c in codes(n):
        ....:         assert(c == encode(decode(c)))
    """
    n = len(r)
    r = list(r)
    res = []
    for i in range(n, 0, -1):
        if i in r:
            pos = r.index(i)
            res.append(pos+1)
            del r[pos]
        else:
            pos = r.index(0)
            res.append(-pos)
            del r[pos]
    return tuple(res[::-1])

def decode(c):
    r"""
    Decode a code (Definition \ref{def_decode})

    EXAMPLE::

        sage: decode((1, 1, -1, 2, 0))
        (0, 2, 4, 0, 1)
        sage: decode((0, 1, 2, 4, -1))
        (2, 0, 3, 0, 4)
    """
    res = []
    for i in range(len(c)):
        if c[i] > 0:
            res.insert(c[i]-1, i+1)
        elif c[i] == 0:
            res.insert(0, 0)
        else:
            res.insert(-c[i], 0)
    return tuple(res)

def is_rook(r):
    r"""
    Test for rook

    EXAMPLES::

        sage: is_rook((0, 1, 4, 3, 2))
        True
        sage: is_rook((0, 1, 5, 3, 2))
        True
        sage: is_rook((0, 1, 6, 3, 2))
        False
        sage: is_rook((0, 1, 2, 3, 2))
        False
        sage: is_rook((0, -1, 2, 3, 0))
        False
    """
    n = len(r)
    for i in r:
        if not (0 <= i <= n):
            return False
    for i in range(1, n+1):
        if r.count(i) > 1:
            return False
    return True

def rooks(n):
    r"""
    Lists the Rooks

    EXAMPLES::

        sage: rooks(0)
        [()]
        sage: rooks(1)
        [(1,), (0,)]
        sage: rooks(2)
        [(1, 2), (2, 1), (0, 1), (1, 0), (0, 2), (2, 0), (0, 0)]

    TESTS::

        sage: for n in range(7):
        ....:     for r in rooks(n): assert(is_rook(r))
        sage: len(rooks(3)) == len(set(rooks(3)))
        True
        sage: len(rooks(4)) == len(set(rooks(4)))
        True
    """
    return [decode(c) for c in codes(n)]

def first_zero(r):
    r"""
    The position of the first zero

    EXAMPLES::

        sage: first_zero((1,2,0,2,0))
        2

    TESTS:

        sage: for n in range(7):
        ....:     l = [first_zero(r) for r in rooks(n)]
        ....:     for k in range(n+1):
        ....:         assert(l.count(k) == c(n, k))
    """
    if 0 in r:
        return r.index(0)
    else:
        return len(r)

@cached_function
def c(n, k):
    """
    Rook triangle : count the rook according to the position of the first zero

    Alternative implementation using Lemma \ref{lemma-count-fz}

    EXAMPLES::

        sage: [[c(n, k) for k in range(n+1)] for n in range(8)]
        [[1],
         [1, 1],
         [3, 2, 2],
         [13, 9, 6, 6],
         [73, 52, 36, 24, 24],
         [501, 365, 260, 180, 120, 120],
         [4051, 3006, 2190, 1560, 1080, 720, 720],
         [37633, 28357, 21042, 15330, 10920, 7560, 5040, 5040]]
    """
    if k < 0 or k > n: return 0
    if n == 0: return 1
    return (c(n-1, k)*(n-k-1) + c(n-1, k-1)*k +
            sum(c(n-1, k1) for k1 in range (k, n+1)))

@cached_function
def r(n):
    r"""
    The number of rooks

    EXAMPLES::

        sage: [r(i) for i in range(10)]
        [1, 2, 7, 34, 209, 1546, 13327, 130922, 1441729, 17572114]
        sage: r(10)
        234662231
        sage: sum(c(10, k) for k in range(11))
        234662231
    """
    return sum(binomial(n, r)^2 * factorial(r) for r in range(n+1))

def code2word(c):
    r"""
    Word associated to a code (Definition \ref{def_word_code})

    EXAMPLES::

        sage: code2word((1, 1, -1, 2, 0))
        [1, 2, 1, 0, 1, 3, 2, 4, 3, 2, 1, 0]
    """
    res = []
    for i, ci in enumerate(c):
        if ci <= 0:
            res.append(range(i, -1, -1)+range(1, -ci+1))
        else:
            res.append(range(i, ci-1, -1))
    return flatten(res)

def is_action_reduced(w):
    r"""
    Test for action reduced word (Corollary \ref{action_reduced})

    EXAMPLES::

        sage: is_action_reduced([1, 0])
        True
        sage: is_action_reduced([1, 1])
        False
        sage: is_action_reduced([1, 0, 1])
        True
        sage: is_action_reduced([0, 1, 0])
        True
        sage: is_action_reduced([1, 0, 1, 0])
        True
        sage: is_action_reduced([0, 1, 0, 1])
        False

    TESTS::

        sage: for n in range(7):
        ....:     for c in codes(n):
        ....:         assert(is_action_reduced(code2word(c)))
    """
    if not w:
        return True
    n = max(w) + 1
    r = tuple(range(1, n+1))
    for i in w:
        newr = act_rook(r, i)
        if newr == r:
            return False
        r = newr
    return True


def act_rook(r, i):
    r"""
    Right action on a rook (Definition \ref{def_Ro_fun})

    EXAMPLES::

        sage: act_rook((1, 2, 3), 1)
        (2, 1, 3)
        sage: act_rook((1, 2, 3), 2)
        (1, 3, 2)
        sage: act_rook((1, 2, 3), 0)
        (0, 2, 3)
        sage: act_rook((3, 1, 2), 0)
        (0, 1, 2)
        sage: act_rook((3, 1, 2), 1)
        (3, 1, 2)
        sage: act_rook((3, 1, 2), 2)
        (3, 2, 1)
    """
    if i == 0:
        return (0,) + r[1:]
    elif r[i-1] >= r[i]:
        return r
    else:
        return r[:i-1]+(r[i], r[i-1])+r[i+1:]

def act_rook_w(r, w):
    r"""
    Right action of a word on a rook (Definition \ref{def_Ro_fun})

    TESTS::

        sage: for n in range(7):
        ....:     for c in codes(n):
        ....:         assert(act_rook_w(tuple(range(1, n+1)), code2word(c)) ==
        ....:                decode(c))
    """
    for i in w:
        r = act_rook(r, i)
    return r

def act_code(c, t, print_rule = False):
    r"""
    Right action on a code (Definition \ref{defactioncode})

    EXAMPLES::

        sage: act_code((1, 2, 3, 4, -2, 1, 2, 6, -4), 5)
        (1, 2, 3, 4, -2, 1, 2, 6, -4)
    """
    n = len(c)
    if n == 1:
        assert(t == 0)
        return (0,)
    cn = c[-1]
    if cn >= 1:  # Pos
        if t == cn:      # a
            if print_rule: print "Pos.a",
            return c
        elif t == cn-1:  # b
            if print_rule: print "Pos.b",
            return c[:-1] + (cn-1,)
        elif t < cn -1:  # c
            if print_rule: print "Pos.c",
            return act_code(c[:-1], t) + (cn,)
        else:            # d
            if print_rule: print "Pos.d",
            return act_code(c[:-1], t-1) + (cn,)
    else:        # Neg
        i = -cn
        if t == i:       # a
            if print_rule: print "Neg.a",
            return c
        elif 0 < t < i:      # b
            if print_rule: print "Neg.b",
            return act_code(c[:-1], t) + (cn,)
        elif t > i + 1:  # c
            if print_rule: print "Neg.c",
            return act_code(c[:-1], t-1) + (cn,)
        elif t == 0:     # d
            if print_rule: print "Neg.d",
            return act_code_w(c[:-1], range(i)) + (0,)
        else:            # e
            if mcode(c[:-1]) == i:  # alpha
                if print_rule: print "Neg.e.alpha",
                return c
            else:                   # beta
                if print_rule: print "Neg.e.beta",
                return c[:-1]+(-(i+1),)

def act_code_w(c, w):
    r"""
    Right action of a word on a code (Definition \ref{defactioncode})

    TESTS::

        sage: for n in range(7):
        ....:     for c in codes(n):
        ....:          assert(decode(c) ==
        ....:                 act_rook_w(tuple(range(1, n+1)), code2word(c)))
    """
    for i in w:
        c = act_code(c, i)
    return c

def check_act(n, print_rule = False):
    r"""
    Check for Lemma \ref{codebiendef} and Corollary \ref{code_action_commute}

    TESTS::

        sage: for n in range(7): check_act(n)

        sage: check_act(2, True)
        Pos.c Code=(1, 2), i=0, w=[], r=(1, 2), r.i=(0, 2), c.i=(0, 2)
        Pos.b Code=(1, 2), i=1, w=[], r=(1, 2), r.i=(2, 1), c.i=(1, 1)
        Pos.b Code=(1, 1), i=0, w=[1], r=(2, 1), r.i=(0, 1), c.i=(1, 0)
        Pos.a Code=(1, 1), i=1, w=[1], r=(2, 1), r.i=(2, 1), c.i=(1, 1)
        Neg.a Code=(1, 0), i=0, w=[1, 0], r=(0, 1), r.i=(0, 1), c.i=(1, 0)
        Neg.e.beta Code=(1, 0), i=1, w=[1, 0], r=(0, 1), r.i=(1, 0), c.i=(1, -1)
        Neg.d Code=(1, -1), i=0, w=[1, 0, 1], r=(1, 0), r.i=(0, 0), c.i=(0, 0)
        Neg.a Code=(1, -1), i=1, w=[1, 0, 1], r=(1, 0), r.i=(1, 0), c.i=(1, -1)
        Pos.c Code=(0, 2), i=0, w=[0], r=(0, 2), r.i=(0, 2), c.i=(0, 2)
        Pos.b Code=(0, 2), i=1, w=[0], r=(0, 2), r.i=(2, 0), c.i=(0, 1)
        Pos.b Code=(0, 1), i=0, w=[0, 1], r=(2, 0), r.i=(0, 0), c.i=(0, 0)
        Pos.a Code=(0, 1), i=1, w=[0, 1], r=(2, 0), r.i=(2, 0), c.i=(0, 1)
        Neg.a Code=(0, 0), i=0, w=[0, 1, 0], r=(0, 0), r.i=(0, 0), c.i=(0, 0)
        Neg.e.alpha Code=(0, 0), i=1, w=[0, 1, 0], r=(0, 0), r.i=(0, 0), c.i=(0, 0)

    """
    for c in codes(n):
        for i in range(n):
            ac = act_code(c, i)
            if print_rule:
                print "Code=%s, i=%s, w=%s, r=%s, r.i=%s, c.i=%s"%(
                    c, i, code2word(c), decode(c),
                    act_rook(decode(c), i), act_code(c, i, True))
            assert(is_code(ac))
            assert(decode(ac) == act_rook(decode(c), i))

def canonize(w):
    r"""
    Canonize a word

    EXAMPLES::

        sage: canonize([1, 0, 1, 0])
        [0, 1, 0]
        sage: canonize([1, 0, 1, 0, 2])
        [0, 1, 0, 2]
        sage: canonize([1, 0, 1, 2])
        [1, 0, 1, 2]
        sage: canonize([0, 1, 0, 1, 2])
        [0, 1, 0, 2]
    """
    n = max(w) + 1
    res = act_code_w(tuple(range(1,n+1)), w)
    return code2word(res)

def canonwords(n):
    r"""
    List of canonical words

    EXAMPLES::

        sage: canonwords(0)
        [[]]
        sage: canonwords(1)
        [[], [0]]
        sage: canonwords(2)
        [[], [1], [1, 0], [1, 0, 1], [0], [0, 1], [0, 1, 0]]

    TESTS::

        sage: "|".join("".join(str(l) for l in w) for w in canonwords(3))
        '|2|21|210|2101|21012|1|12|121|1210|12101|121012|10|102|1021|10210|101|1012|10121|101210|1012101|0|02|021|0210|01|012|0121|01210|012101|010|0102|01021|010210'
    """
    return [code2word(c) for c in codes(n)]

def prod_rook(r1, r2):
    r"""
    Product in the 0-rook monoid

    TESTS::

        sage: for n in range(4):
        ....:     for r1, r2, r3 in cartesian_product(([rooks(n)]*3)):
        ....:         assert(prod_rook(r1, prod_rook(r2, r3)) ==
        ....:                prod_rook(prod_rook(r1, r2), r3))
    """
    return act_rook_w(r1, code2word(encode(r2)))


"""
Example \ref{exmpl_decode}

sage: c = (0, 1, 3, 2, 3, -2)
sage: r = decode(c); r
(2, 4, 0, 5, 0, 3)
sage: act_code(c, 0)
(0, 0, 3, 1, 3, 0)
sage: decode(act_code(c, 0))
(0, 4, 0, 5, 0, 3)
"""
