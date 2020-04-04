use v6;

# Uncomment for quick results on any test failure
BEGIN %*ENV<RAKU_TEST_DIE_ON_FAIL> = True;

use Test;

# L<S03/List infix precedence/"the sequence operator">

# Test a sequence by seed and endpoint, with the given description
# and the expected result.
#
# The expected result is expected to either be a List (in which case
# the ...^, ^... and ^...^ results will be calculated by removing values
# from beginning and end as appropriate).  Or it can be an Array, in which
# case it is expected to slip into 4 lists, one for each of the ...
# operator forms.
#
# If a result contains exactly 10 elements, the sequence is expected not
# to end.  If the expected result list has fewer elements, then it is
# supposed to contain the exact result of the sequence.
#
# If the endpoint is Whatever, then the tests will automatically also be
# performed with Inf as the endpoint.

sub test-seq($description, \seed, \endpoint, \list) {
    my $result;
    my $resultV;
    my $Vresult;
    my $VresultV;

    # unique results
    if list ~~ Array {
        my @result is List = list.map: { $_ ~~ Seq ?? .Slip !! $_ }
        $result   := @result[0].List;
        $resultV  := @result[1].List;
        $Vresult  := @result[2].List;
        $VresultV := @result[3].List;
    }

    # easily calculated results
    else {
        $result   := list.List;
        $resultV  := $result.elems == 10 ??  $result !! $result[0..*-2];
        $Vresult  := $result[1..*-1];
        $VresultV := $result.elems == 10 ?? $Vresult !! $result[1..*-2];
    }

    # run the tests
    subtest $description => {
        plan 4;
        is-deeply infix:<...>(  seed, endpoint).head(10).List, $result,
          " ...  {$result.raku}";
        is-deeply infix:<...^>( seed, endpoint).head(10).List, $resultV,
          " ...^ {$resultV.raku}";
        is-deeply infix:<^...>( seed, endpoint).head(9).List, $Vresult,
          "^...  {$Vresult.raku}";
        is-deeply infix:<^...^>(seed, endpoint).head(9).List, $VresultV,
          "^...^ {$VresultV.raku}";
    }

    # optionally run same test for Inf as endpoint
    test-seq($description, seed, Inf, [$result,$resultV,$Vresult,$VresultV])
      if endpoint ~~ Whatever;
}

# Set up tests, in order: description, LHS, RHS, result (either an Array,
# or someting that can be coerced to a List).
my @tests = (
  'single term sequence numeric',
    1, 1, 1,

  'single term sequence stringy',
    "a", "a", "a",

  'simple sequence with one item on the LHS',
    1, 5, 1..5,

  'simple decreasing sequence with one item on the LHS',
    1, -3, (1,0,-1,-2,-3),

  'simple additive sequence with two items on the LHS',
    (1,3), 9, (1,3,5,7,9),

  'simple decreasing sequence with two items on the LHS',
    (1,0), -3, (1,0,-1,-2,-3),

  'simple decreasing additive sequence with two items on the LHS',
    (1,-1), -3, (1,-1,-3),

  'simple additive sequence with three items on the LHS',
    (1,3,5), 9, (1,3,5,7,9),

  'simple descreasing additive sequence with three items on the LHS',
    (9,7,5), 1, (9,7,5,3,1),

  'simple multiplicative sequence with three items on the LHS',
    (1,3,9), 81, (1,3,9,27,81),

  'decreasing multiplicative sequence with three items on the LHS',
    (81,27,9), 1, (81,27.0,9.0,3.0,1.0),  # XXX

  'simple sequence with one item and block closure on the LHS',
    (1,*+2), 9, (1,3,5,7,9),

  'simple sequence with one item and closure on the LHS',
    (1,{$_-2}), -7, (1,-1,-3,-5,-7),

  'simple sequence with three items and block closure on the LHS',
    (1,3,5,{$_+2}), 13, (1,3,5,7,9,11,13),

  'tricky sequence with one item and closure on the LHS',
    (1,{1/((1/$_)+1)}), 0.2, (1,0.5,1/3,0.25,0.2),

  'simple alternating sequence with one item and closure on the LHS',
    (1,{-$_}), 1, 1,

  'simple unending alternating sequence with one item and closure on the LHS',
    (1,{-$_}), 3, |(1,-1) xx 5,

  'simple unending alternating sequence with one item and closure on the LHS',
    (1,{-$_}), 0, |(1,-1) xx 5,

  'sequence with one scalar containing Code on the LHS',
    {3+2}, *, 5 xx 10,

  'simple sequence with two extra terms on the RHS',
    1, (5,4,3), [(1,2,3,4,5,4,3),(1,2,3,4,4,3),(2,3,4,5,4,3),(2,3,4,4,3)],

  'simple sequence with two extra terms on the RHS',
    1, (5.5,4,3), [(1,2,3,4,5,4,3) xx 2,(2,3,4,5,4,3) xx 2],

  'simple sequence with two further terms on the RHS',
    1, (5.5,6,7), [(1,2,3,4,5,6,7) xx 2,(2,3,4,5,6,7) xx 2],

  'simple sequence with two weird items on the RHS',
    1, (5.5,'a','b'), [(1,2,3,4,5,'a','b') xx 2,(2,3,4,5,'a','b') xx 2],

  'simple sequence with two weird items on the RHS',
    1, (5,'a','b'), [(1,2,3,4,5,'a','b'),(1,2,3,4,'a','b'),(2,3,4,5,'a','b'),(2,3,4,'a','b')],

  'simple sequence with one item on the LHS',
    1, 5.5, [(1,2,3,4,5) xx 2, (2,3,4,5) xx 2],

  'simple decreasing sequence with one item on the LHS',
    1, -3.5, [(1,0,-1,-2,-3) xx 2, (0,-1,-2,-3) xx 2],

  'simple additive sequence with two items on the LHS',
    (1,3), 10, [(1,3,5,7,9) xx 2, (3,5,7,9) xx 2],

  'simple decreasing additive sequence with two items on the LHS',
    (1,0), -3.5, [(1,0,-1,-2,-3) xx 2, (0,-1,-2,-3) xx 2],

  'simple additive sequence with three items on the LHS',
    (1,3,5), 10, [(1,3,5,7,9) xx 2, (3,5,7,9) xx 2],

  'simple multiplicative sequence with three items on the LHS',
    (1,3,9), 100, [(1,3,9,27,81) xx 2, (3,9,27,81) xx 2],

  'decreasing multiplicative sequence with three items on the LHS',
    (81,27,9), 8/9, [(81,27.0,9.0,3.0,1.0) xx 2,(27.0,9.0,3.0,1.0) xx 2],

  'simple sequence with one item and block closure on the LHS',
    (1,{$_+2}), 10, (1,3,5,7,9,11,13,15,17,19),

  'simple sequence with one item and * closure on the LHS',
    (1,*+2), 10, (1,3,5,7,9,11,13,15,17,19),

  'simple sequence with three items and block closure on the LHS',
    (1,3,5,{$_+2}), 14, (1,3,5,7,9,11,13,15,17,19),

  'tricky sequence with one item and closure on the LHS',
    (1,{1/((1/$_)+1)}), 11/60, (1,0.5,1/3,0.25,0.2,1/6,1/7,0.125,1/9,0.1),

  'simple sequence with one item on the LHS',
    1, *, 1..10,

  'simple additive sequence with two items on the LHS',
    (1,3), *, (1,3,5,7,9,11,13,15,17,19),

  'simple decreasing additive sequence with two items on the LHS',
    (1,0), *, (1,0,-1,-2,-3,-4,-5,-6,-7,-8),

  'simple decreasing additive sequence with three items on the LHS',
    (8,7,6), *, (8,7,6,5,4,3,2,1,0,-1),

  'simple multiplicative sequence with three items on the LHS',
    (1,3,9), *, (1,3,9,27,81,243,729,2187,6561,19683),

  'decreasing multiplicative sequence with three items on the LHS',
    (81,27,9), *, (81,27.0,9.0,3.0,1.0,1/3,1/9,1/27,1/81,1/243),

  'simple sequence with one item and block closure on the LHS',
    (1,{$_+2}), *, (1,3,5,7,9,11,13,15,17,19),

  'simple sequence with one item and * closure on the LHS',
    (1,*+2), *, (1,3,5,7,9,11,13,15,17,19),

  'simple sequence with one item and closure on the LHS',
    (1,{$_-2}), *, (1,-1,-3,-5,-7,-9,-11,-13,-15,-17),

  'simple sequence with three items and block closure on the LHS',
    (1,3,5,{$_+2}), *, (1,3,5,7,9,11,13,15,17,19),

  'tricky sequence with one item and closure on the LHS',
    (1,{1/((1/$_)+1)}), *, (1,0.5,1/3,0.25,0.2,1/6,1/7,0.125,1/9,0.1),

  'simple alternating sequence with one item and closure on the LHS',
    (1,{-$_}), *, (1,-1,1,-1,1,-1,1,-1,1,-1),

  'simple sequence with two further terms on the RHS',
    1, (*,6,7), 1..10,

  'simple sequence with two extra terms on the RHS',
    1, (*,4,3), 1..10,

  'simple sequence with two weird items on the RHS',
    1, (*,"foo","bar"), 1..10,

  'constant sequence started with letter and identity closure',
    ('c',{$_}), *, 'c' xx 10,

  'constant sequence started with two letters',
    ('c','c'), *, 'c' xx 10,

  'constant sequence started with three letters',
    ('c','c','c'), *, 'c' xx 10,

  'constant sequence started with two numbers',
    (1,1), *, 1 xx 10,

  'constant sequence started with three numbers',
    (1,1,1), *, 1 xx 10,

  'sequence started with three identical numbers, but then goes arithmetic',
    (1,1,1,2,3), 7, (1,1,1,2,3,4,5,6,7),

  'sequence started with three identical numbers, but then goes geometric',
    (1,1,1,2,4), 16, (1,1,1,2,4,8,16),

  'geometric sequence started in one direction and continues in the other',
    (4,2,1,2,4), 16, (4,2,1,2,4,8,16),

  'alternating False and True',
    (False,&prefix:<!>), *, |(False,True) xx 5,

  'alternating False and True',
    (False,{!$_}), *, |(False,True) xx 5,

  'using &[+] works',
    (1,2,&[+]), 8, (1,2,3,5,8),

  'geometric sequence that never reaches its limit',
    (1,1/2,1/4), 0, (1,1/2,1/4,1/8,1/16,1/32,1/64,1/128,1/256,1/512),

  'alternating geometric sequence that never reaches its limit',
    (1,-1/2,1/4), 0, (1,-1/2,1/4,-1/8,1/16,-1/32,1/64,-1/128,1/256,-1/512),

  'no more: limit value is on the wrong side',
    (1,2), 0, (),

  '-3 ... ^3 produces just one zero',
    -3, ^3, [(-3,-2,-1,0,1,2),(-3,-2,-1,1,2),(-2,-1,0,1,2),(-2,-1,1,2)],
);

# Run the tests
for @tests -> \description, \seed, \endpoint, \result {
    test-seq(description, seed, endpoint, result)
}

done-testing;
