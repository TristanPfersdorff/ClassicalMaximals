# Return the subgroup of <M>SL(n, p ^ e)</M> induced by the subgroup of
# <M>GL(n, p ^ e)</M> generated by <M>GL(n, p ^ f)</M> and the center
# <M>Z(GL(n, p ^ e))</M> (i.e. all scalar matrices), where <C>GF(p ^ f)</C> is
# a subfield of <C>GF(p ^ e)</C>. Note that this means <A>f</A> must be a
# divisor of <A>e</A>. We further demand that <A>p</A> be a prime number and
# that the quotient <C>f / e</C> be a prime number as well, i.e. <C>GF(p ^ e)
# </C> is a prime extension of <C>GF(p ^ f)</C>.
# Construction as in Proposition 8.1 of [HR05] 
BindGlobal("SubfieldSL", 
function(n, p, e, f)
    local F, AandB, C, D, c, k, lambda, zeta, omega, z, X,
        size;
    if e mod f <> 0 or not IsPrimeInt(QuoInt(e, f)) then
        ErrorNoReturn("the quotient of <e> by <f> must be a prime");
    fi;

    F := GF(p ^ e);
    AandB := ShallowCopy(GeneratorsOfGroup(SL(n, p ^ f)));
    zeta := PrimitiveElement(F);
    k := Gcd(p ^ e - 1, n);
    c := QuoInt((k * Lcm(p ^ f - 1, QuoInt((p ^ e - 1), k))), (p ^ e - 1));
    C := zeta ^ (QuoInt(p ^ e - 1, k)) * IdentityMat(n, F);

    # Size according to Table 2.8 of [BHR13]
    size := SizeSL(n, p ^ f) * Gcd(QuoInt(p ^ e - 1, p ^ f - 1), n);

    if c = Gcd(p ^ f - 1, n) then
        return MatrixGroupWithSize(F, Concatenation(AandB, [C]), size);
    fi;

    omega := zeta ^ QuoInt(p ^ e - 1, p ^ f - 1);
    D := DiagonalMat(Concatenation([omega], List ([2..n], i -> zeta^0))) ^ c;

    # solving the congruence lambda * n = z (mod p ^ e - 1) by solving the
    # matrix equation (n, p ^ e - 1) * (lambda, t) ^ T = z over the integers
    z := c * QuoInt(p ^ e - 1, p ^ f - 1);
    lambda := SolutionIntMat([[n], [p ^ e - 1]], [z])[1];
    X := zeta ^ (-lambda) * IdentityMat(n, F);

    return MatrixGroupWithSize(F, Concatenation(AandB, [C, X * D]), size);
end);

# Construction as in Proposition 8.3 of [HR05]
BindGlobal("UnitarySubfieldSU",
function(d, p, e, f)
    local F, AandB, C, D, c, k, q, matrixForCongruence, lambda, zeta, omega, z, X,
        size, result;

    if e mod f <> 0 or not IsPrimeInt(QuoInt(e, f)) or not IsOddInt(QuoInt(e, f)) then
        ErrorNoReturn("the quotient of <e> by <f> must be an odd prime");
    fi;

    q := p ^ e;
    F := GF(q ^ 2);
    AandB := ShallowCopy(GeneratorsOfGroup(ConjugateToSesquilinearForm(SU(d, p ^ f),
                                                                       "U",
                                                                       AntidiagonalMat(d, F))));
    zeta := PrimitiveElement(F);
    k := Gcd(q + 1, d);
    c := QuoInt(k * Lcm(p ^ f + 1, QuoInt(q + 1, k)), q + 1);
    # generates the center of SU(d, q)
    C := zeta ^ QuoInt(q ^ 2 - 1, k) * IdentityMat(d, F);

    # Size according to Table 2.8 of [BHR13]
    size := SizeSU(d, p ^ f) * Gcd(QuoInt(q + 1, p ^ f + 1), d);

    if c = Gcd(p ^ f + 1, d) then
        result := MatrixGroupWithSize(F, Concatenation(AandB, [C]), size);
        SetInvariantSesquilinearForm(result, rec(matrix := AntidiagonalMat(d, F)));
        return ConjugateToStandardForm(result, "U");
    fi;

    # a primitive element of GF(p ^ (2 * f))
    omega := zeta ^ QuoInt(q ^ 2 - 1, p ^ (2 * f) - 1);
    D := DiagonalMat(Concatenation([omega], 
                                   List([2..d - 1], i -> zeta ^ 0),
                                   [omega ^ (-p ^ f)])) ^ c;
    
    # det(D) = zeta ^ z
    z := - c * QuoInt(q ^ 2 - 1, p ^ f + 1);
    # solving the congruence lambda * (q - 1) * d = -z (mod q ^ 2 - 1)
    # by calculating (d / k) ^ (-1) (mod (q + 1) / k).
    lambda := - QuoInt(z, (q - 1) * k) * ((d / k) ^ (-1) mod ((q + 1) / k));
    # det(X) = 1 by construction of lambda
    X := zeta ^ (lambda * (q - 1)) * IdentityMat(d, F);

    result := MatrixGroupWithSize(F, Concatenation(AandB, [C, X * D]), size);
    SetInvariantSesquilinearForm(result, rec(matrix := AntidiagonalMat(d, F)));
    return ConjugateToStandardForm(result, "U");
end);

# Construction as in Proposition 8.5 of [HR05]
BindGlobal("SymplecticSubfieldSU",
function(d, q)
    local F, generators, zeta, k, C, c, result, D, form, size;

    if IsOddInt(d) then
        ErrorNoReturn("<d> must be even");
    fi;

    F := GF(q ^ 2);
    form := AntidiagonalMat(Concatenation(List([1..d / 2], i -> One(F)),
                                          List([1..d / 2], i -> -1)) * Z(q ^ 2)^0,
                            F);
    generators := ShallowCopy(GeneratorsOfGroup(ConjugateToSesquilinearForm(Sp(d, q), 
                                                                            "S", 
                                                                            form)));
    zeta := PrimitiveElement(F);
    k := Gcd(q + 1, d);
    # generates the center of SU(d, q)
    C := zeta ^ QuoInt(q ^ 2 - 1, k) * IdentityMat(d, F);
    Add(generators, C);
    c := QuoInt(Gcd(2, q - 1) * Gcd(q + 1, d / 2), Gcd(q + 1, d));

    if c <> 1 then
        # q is odd and d = 0 mod 4 if c <> 1
        #
        # D preserves the standard symplectic form Antidiag(1, ..., 1, -1, ..., -1) 
        # up to a factor of -1. det(D) = 1 since d = 0 mod 4.
        D := DiagonalMat(Concatenation(List([1..d / 2], i -> zeta ^ ((q + 1) / 2)),
                                       List([1..d / 2], i -> - zeta ^ (- (q + 1) / 2))));
        Add(generators, D);
    fi;
    
    # Size according to Table 2.8 of [BHR13]
    size := SizeSp(d, q) * Gcd(q + 1, d / 2);
    result := MatrixGroupWithSize(F, generators, size);
    if IsOddInt(q) then
        # The result preserves the unitary form given by 
        # - zeta ^ ((q + 1) / 2) * Antidiag(1, ..., 1, -1, ..., -1);
        # we conjugate it to preserve the standard unitary form given by
        # Antidiag(1, ..., 1).
        SetInvariantSesquilinearForm(result, 
                                     rec(matrix := - zeta ^ QuoInt(q + 1, 2) * form));
    else
        # The result preserves the unitary form given by
        # Antidiag(1, ..., 1).
        SetInvariantSesquilinearForm(result, rec(matrix := AntidiagonalMat(d, F)));
    fi;
    
    return ConjugateToStandardForm(result, "U");
end);

# Construction as in Proposition 8.4 of [HR05]
BindGlobal("OrthogonalSubfieldSU",
function(epsilon, d, q)
    local F, zeta, k, C, generators, SOChangedForm, result,
    generatorsOfOrthogonalGroup, D, E, i, W, n, form, size;

    if IsEvenInt(q) then
        ErrorNoReturn("<q> must be an odd integer");
    elif epsilon = 0 and IsEvenInt(d) then
        ErrorNoReturn("<epsilon> cannot be zero if <d> is even");
    elif epsilon <> 0 and IsOddInt(d) then
        ErrorNoReturn("<epsilon> must be zero if <d> is odd");
    elif not epsilon in [-1, 0, 1] then
        ErrorNoReturn("<epsilon> must be one of -1, 0, 1");
    fi;

    F := GF(q ^ 2);
    zeta := PrimitiveElement(F);
    k := Gcd(q + 1, d);
    # generates the center of SU(d, q)
    C := zeta ^ QuoInt(q ^ 2 - 1, k) * IdentityMat(d, F);
    generators := [C];

    # Size according to Table 2.8 of [BHR13]
    size := SizeSO(epsilon, d, q) * Gcd(q + 1, d);

    if IsOddInt(d) then
        SOChangedForm := ConjugateToSesquilinearForm(SO(d, q),
                                                     "O-B",
                                                     AntidiagonalMat(d, F));
        Append(generators, GeneratorsOfGroup(SOChangedForm));
        result := MatrixGroupWithSize(F, generators, size);
        SetInvariantSesquilinearForm(result, rec(matrix := AntidiagonalMat(d, F)));
        result := ConjugateToStandardForm(result, "U");
    else
        generatorsOfOrthogonalGroup := GeneratorsOfOrthogonalGroup(epsilon, d, q);
        Append(generators, generatorsOfOrthogonalGroup.generatorsOfSO);
        # det(D) = -1 
        D := generatorsOfOrthogonalGroup.D;
        # det(E) = (epsilon * zeta ^ (q + 1)) ^ (d / 2)
        # E scales the standard orthogonal form F by a factor of zeta ^ (q + 1)
        E := generatorsOfOrthogonalGroup.E;
        # Multiplying by zeta ^ (-1) will lead to E preserving the form F *as a
        # unitary form* !!
        # det(E) = (epsilon * zeta ^ (q - 1)) ^ (d / 2)
        E := zeta ^ (-1) * E;

        if epsilon = 1 then
            # We already have generators for Z(SU(d, q)).SO(d, q);
            # additionally, an element W of order 2 mod Z(SU(d, q)).SO(d, q) is
            # needed.
            if IsEvenInt((q + 1) / k) then
                i := QuoInt(q ^ 2 - 1, 2 * k);
                # det(W) = 1 because det(D) = -1 and
                #   zeta ^ (i * d) = zeta ^ ((q ^ 2 - 1) * d / (2 * Gcd(q + 1, d)))
                #                  = zeta ^ ((q ^ 2 - 1) / 2) = -1
                # since d / Gcd(q + 1, d) is an odd integer by assumption.
                #
                # Multiplying D by zeta ^ i will not affect the result
                # preserving our unitary form since i is divisble by q - 1.
                W := zeta ^ i * D;
            elif IsEvenInt(d / k) then
                i := (q - 1) * ((q + 1) / k + 1) / 2;
                # det(W) = 1 because det(E) = (zeta ^ (q - 1)) ^ (d / 2) and
                #   zeta ^ (i * d) = zeta ^ (d * (q - 1) * ((q + 1) / k + 1) / 2)
                #                  = zeta ^ (d * (q - 1) / 2)
                #
                # Multiplying E by zeta ^ (-i) will not affect the result
                # preserving our unitary form since i is divisible by q - 1.
                W := zeta ^ (-i) * E;
            else 
                n := (k / d) mod ((q + 1) / k); 
                i := (q - 1) * n * (d + q + 1) / (2 * k);
                # det(W) = 1 because det(D) = -1, det(E) = zeta ^ (d * (q - 1) / 2)
                # and i * d mod q ^ 2 - 1 is
                #   (q - 1) * n * (d + q + 1) * d / (2 * k)
                #        = (q - 1) * (d + q + 1) / 2 
                #           + (q - 1) * (d + q + 1) * (n * d / k - 1) / 2
                #        = (q - 1) * (d + q + 1) / 2 = det(D * E) ^ (-1)
                # since the second summand is divisible by q - 1 (first
                # factor), by 2 * k (second factor; since d and q + 1 have the
                # same 2-adic valuation here) and by (q + 1) / k (third
                # factor), hence by q ^ 2 - 1.
                #
                # Multiplying D * E by zeta ^ (-i) will not affect the result
                # preserving our unitary form since i is divisible by q - 1.
                W := zeta ^ (-i) * D * E;
            fi;
            Add(generators, W);
            
            result := MatrixGroupWithSize(F, generators, size);
            SetInvariantSesquilinearForm(result, rec(matrix := AntidiagonalMat(d, F)));
            result := ConjugateToStandardForm(result, "U");

        elif epsilon = -1 then

            # similarly to above
            if IsEvenInt((q + 1) / k) then
                i := QuoInt(q ^ 2 - 1, 2 * k);
                W := zeta ^ i * D;
            elif IsEvenInt(d / k) then
                i := (q - 1) * ((q + 1) / k + 1) / 2;
                W := zeta ^ (-i) * E;
            elif IsEvenInt(d / 2) then
                n := (k / d) mod ((q + 1) / k); 
                i := (q - 1) * n * (d + q + 1) / (2 * k);
                W := zeta ^ (-i) * D * E;
            else
                # We have to make an additional exception in the last case if 
                # d / 2 is odd as we have an additional factor of -1 in the
                # determinant in this case due to 
                #   det(E) = (epsilon * zeta ^ (q - 1)) ^ (d  / 2) 
                #          = - zeta ^ ((q - 1) * d / 2) 
                # here.
                n := (k / d) mod ((q + 1) / k); 
                i := (q - 1) * n * (d + q + 1) / (2 * k);
                W := zeta ^ (-i) * E;
            fi;
            Add(generators, W);

            result := MatrixGroupWithSize(F, generators, size);

            # We still have to change the preserved unitary form to the
            # standard GAP unitary form Antidiag(1, ..., 1)
            if IsEvenInt(d * (q - 1) / 4) then
                # The form preserved by the constructed subgroup is given by
                # the matrix Diag(zeta ^ (q + 1), 1, ..., 1).
                form := DiagonalMat(Concatenation([zeta ^ (q + 1)],
                                                  List([2..d], i -> zeta ^ 0)));
            else
                # The form preserved by the constructed subgroup is given by
                # the identity matrix.
                form := IdentityMat(d, F);
            fi;

            SetInvariantSesquilinearForm(result, rec(matrix := form));
            result := ConjugateToStandardForm(result, "U");
        fi;
    fi;
 
    return result;
end);


# Construction as in Proposition 8.2 of [HR05]
BindGlobal("SubfieldSp",
function (d, p, e, f)
    local field, q0, b, gens, l, zeta, omega, zetaPower, C, gen, result;

    if IsOddInt(d) then
    	ErrorNoReturn("<d> must be even");
    fi;

    if e mod f <> 0 then
        ErrorNoReturn("<f> must be a divisor of <e>");
    fi;

    b := QuoInt(e, f);

    if not IsPrime(b) then
        ErrorNoReturn("the quotient of <e> by <f> must be a prime");
    fi;

    field := GF(p ^ e);
    q0 := p ^ f;
    gens := List(GeneratorsOfGroup(Sp(d, q0)));
    l := QuoInt(d, 2);

    if Gcd(2, b, p - 1) = 1 then
        # In this case the embedding of Sp(d, q0) in Sp(d, q) is already
        # the C5-subgroup, so we just need to adjust the base field.
        result := MatrixGroupWithSize(field, gens, SizeSp(d, q0));
    else
        zeta := PrimitiveElement(field);
        omega := PrimitiveElement(GF(q0));
        zetaPower := zeta ^ - QuoInt(q0 + 1, 2);

        # This matrix C preserves the form and is constructed to
        # have determinant 1, but it is not in Sp(d, q0). Therefore it is
        # our missing generator to extend Sp(d, q0) to a C5-subgroup, since
        # C is in the normalizer of Sp(d, q0) in Sp(d, q).
        C := DiagonalMat(Concatenation(ListWithIdenticalEntries(l, omega * zetaPower), ListWithIdenticalEntries(l, zetaPower)));
        Add(gens, C);

        # Size according to Table 2.8 in [BHR13]
        result := MatrixGroupWithSize(field, gens, SizeSp(d, q0) * 2);
    fi;

    SetInvariantBilinearForm(result, rec(matrix := AntidiagonalMat(Concatenation(
        ListWithIdenticalEntries(l, One(field)), ListWithIdenticalEntries(l, -One(field))), field)));

    return ConjugateToStandardForm(result, "S");
end);

# Construction as in Proposition 8.1 of [HR10]
BindGlobal("SubfieldOmega",
function (epsilon, d, p, e, f, epsilon_0)
    local r, q0, field, one, zeta, lambda, lambdaInv, m,
    A, F, ABlock, FBlock, i, orthogonalType, gens, result;

    if epsilon = 0 then
        if IsEvenInt(d) then
            ErrorNoReturn("<d> must be odd");
        fi;
    elif epsilon in [-1, 1] then
        if IsOddInt(d) then
            ErrorNoReturn("<d> must be even");
        fi;
    else
        ErrorNoReturn("<epsilon> must be in [-1, 0, 1]");
    fi;

    if IsEvenInt(p) and IsOddInt(d) then
        ErrorNoReturn("<d> must be even if <q> is even");
    fi;

    if e mod f <> 0 then
        ErrorNoReturn("<f> must be a divisor of <e>");
    fi;

    r := QuoInt(e, f);

    if not IsPrime(r) then
        ErrorNoReturn("the quotient of <e> by <f> must be a prime");
    fi;

    if not epsilon_0 in [-1, 0, 1] then
        ErrorNoReturn("<epsilon_0> must be in [-1, 0, 1]");
    elif epsilon_0 ^ r <> epsilon then
        ErrorNoReturn("<epsilon_0> ^ (<e> / <f>) must be equal to <epsilon>");
    fi;

    q0 := p ^ f;

    if IsOddInt(d) then
        if r = 2 then
            return ConjugateToStandardForm(SO(0, d, q0), "O");
        else
            return Omega(0, d, q0);
        fi;
    fi;

    if IsEvenInt(p) then
        return Omega(epsilon_0, d, q0);
    fi;

    if r <> 2 then
        return Omega(epsilon_0, d, q0);
    fi;

    # from now on we assume r = 2, d even and epsilon = 1
    if epsilon_0 = 1 then
        if d mod 4 = 2 and q0 mod 4 = 1 then
            return ConjugateToStandardForm(SO(epsilon_0, d, q0), "O+");
        fi;
    else
        if not (d mod 4 = 2 and q0 mod 4 = 1) then
            return ConjugateToStandardForm(SO(epsilon_0, d, q0), "O-");
        fi;
    fi;
    
    field := GF(p ^ e);
    one := One(field);
    zeta := PrimitiveElement(field);
    lambda := zeta ^ QuoInt(q0 + 1, 2);
    lambdaInv := lambda ^ -1;
    m := QuoInt(d, 2);

    if epsilon_0 = 1 then

        A := lambda * IdentityMat(d, field);
        A{[m + 1..d]}{[m + 1..d]} := lambdaInv * IdentityMat(m, field);
        F := StandardOrthogonalForm(epsilon, d, q0).F;
        orthogonalType := "O+";

    else

        A := NullMat(d, d, field);
        F := NullMat(d, d, field);
        ABlock := one * [[lambda, 0], [0, lambdaInv]];
        FBlock := AntidiagonalMat(2, field);
        for i in [1..m - 1] do
            A{[2 * i - 1..2 * i]}{[2 * i - 1..2 * i]} := ABlock;
            F{[2 * i - 1..2 * i]}{[2 * i - 1..2 * i]} := FBlock;
        od;
        A[d - 1, d] := -lambdaInv;
        A[d, d - 1] := lambda;
        F[d - 1, d - 1] := one;
        F[d, d] := lambda ^ 2;
        orthogonalType := "O-";

    fi;

    gens := List(GeneratorsOfGroup(ConjugateToSesquilinearForm(SO(epsilon_0, d, q0), "O-B", F)));
    Add(gens, A);
    result := MatrixGroupWithSize(field, gens, SizeSO(epsilon, d, q0) * 2);
    return ConjugateToStandardForm(result, orthogonalType);
end);
