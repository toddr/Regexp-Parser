# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Regexp-Parser.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 89 };

my $WARNING;

{
  package Regexp::Catch;
  use base 'Regexp::Parser';
  main::ok( 1 );

  sub warn {
    my ($self, $enum, $err, @args) = @_;
    $WARNING = sprintf $err, @args;
  }

  sub error {
    my ($self, $enum, $err, @args) = @_;
    $self->{errmsg} = sprintf $err, @args;
    die "$self->{errmsg}\n";
  }
}

my $R = Regexp::Catch->new;

while (<DATA>) {
  chomp;
  last if $_ eq "";
  my ($e, $rx, $w) = split /\t+/;
  ok( $R->parse($rx) );
  ok( $WARNING, $w );
}

{
  my ($e, $rx, $w) = split /\t+/, <DATA>;
  ok( !$R->parse($rx) );
  ok( $R->errmsg, $w );
}

while (<DATA>) {
  # chomp;
  my ($e, $rx, $w) = split /\t+/;
  ok( !$R->regex($rx) );
  ok( $R->errmsg, $w );
}

__DATA__
BADESC	\A\y		Unrecognized escape \y passed through
BADESC	[\A]		Unrecognized escape \A in character class passed through
BADFLG	(?g)		Useless (?g) -- use /g modifier
BADFLG	(?o)		Useless (?o) -- use /o modifier
BADFLG	(?c)		Useless (?c) -- use /gc modifier
BADFLG	(?-g)		Useless (?-g) -- don't use /g modifier
BADFLG	(?-o)		Useless (?-o) -- don't use /o modifier
BADFLG	(?-c)		Useless (?-c) -- don't use /gc modifier
FRANGE	[a-\d]		False [] range "a-\d"
FRANGE	[\d-a]		False [] range "\d-"
LOGDEP	(?p{1})		(?p{}) is deprecated -- use (??{})
NULNUL	\b+		\b+ matches null string many times
OUTPOS	abc[:alnum:]	POSIX syntax [: :] belongs inside character classes
ZQUANT	\b{2,3}		Quantifier unexpected on zero-length expression

BGROUP	(a)\1\2		Reference to nonexistent group
BADPOS	[[:fake:]]	POSIX class [:fake:] unknown
BCURLY	x{5,2}		Can't do {n,m} with n > m
BRACES	\NALPHA		Missing braces on \N{}
EMPTYB	\p		Empty \p{}
EQUANT	+a		Quantifier follows nothing
ESLASH	abc\		Trailing \
IRANGE	[z-a]		Invalid [] range "z-a"
LBRACK	[a-z		Unmatched [
LPAREN	(abc		Unmatched (
NESTED	a++		Nested quantifiers
NOTBAL	(?{abc		Sequence (?{...}) not terminated or not {}-balanced
NOTBAL	(??{abc		Sequence (?{...}) not terminated or not {}-balanced
NOTBAL	(?{ab{c})	Sequence (?{...}) not terminated or not {}-balanced
NOTBAL	(??{ab{c})	Sequence (?{...}) not terminated or not {}-balanced
NOTERM	(?#...		Sequence (?#... not terminated
NOTREC	(?%abc)		Sequence (?%...) not recognized
NOTREC	(??%abc)	Sequence (??%...) not recognized
NOTREC	(?i%abc)	Sequence (?i%...) not recognized
RBRACE	\N{ALPHA	Missing right brace on \N{}
RBRACE	\p{Lower	Missing right brace on \p{}
RBRACE	\P{Lower	Missing right brace on \P{}
RBRACE	\x{12		Missing right brace on \x{}
RPAREN	abc)		Unmatched )
SEQINC	abc(?		Sequence (? incomplete
SEQINC	abc(?(?R)a|b)	Sequence (? incomplete
SWBRAN	(?(1)a|b|c)	Switch (?(condition)... contains too many branches
SWBRAN	(?(1)a|b|c|d)	Switch (?(condition)... contains too many branches
SWNREC	(?(1.)a|b)	Switch condition not recognized
SWUNKN	(?(a)b|c)	Unknown switch condition (?(a)
