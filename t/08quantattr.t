# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Regexp-Parser.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 57 };

{
  package Regexp::QuantAttr::__object__;

  sub set_quant {
    my ($self, $min, $max) = @_;
    @$self{qw(min max)} = ($min, $max);
  }

  sub set_greed {
    my ($self, $greed) = @_;
    $self->{greed} = $greed;
  }

  sub min { $_[0]{min} }
  sub max { $_[0]{max} }
  sub greed { $_[0]{greed} }

  sub visual {
    my $self = shift;
    my $vis = $self->NEXT::visual();

    # if 'min' exists, 'max' does too
    if (exists $self->{min}) {
      my ($min, $max) = ($self->min, $self->max);
      if ($min == 0 and $max eq '') { $vis .= '*' }
      elsif ($min == 1 and $max eq '') { $vis .= '+' }
      elsif ($min == 0 and $max == 1) { $vis .= '?' }
      elsif ($max eq '') { $vis .= "{$min,}" }
      elsif ($min == $max) { $vis .= "{$min}" }
      else { $vis .= "{$min,$max}" }
      $vis .= '?' if $self->greed;
    }

    return $vis;
  }

  package Regexp::QuantAttr::quant;

  sub insert {
    my ($self, $tree) = @_;
    $self->NEXT::insert($tree);

    # now restore this object's data as
    # the most recent addition...
    $tree->[-1] = $self->{data};

    # ... and update its {min} and {max}
    $tree->[-1]->set_quant($self->min, $self->max);
  }

  package Regexp::QuantAttr::minmod;

  sub insert {
    my ($self, $tree) = @_;
    $tree->[-1]->set_greed(1);
  }

  package Regexp::QuantAttr::exact;

  sub merge {
    my ($self) = @_;
    my $tree = $self->{rx}{tree};
    return unless @$tree;

    push @$tree, $self unless $tree->[-1] == $self;
    return unless @$tree > 1;
    my $prev = $tree->[-2];
    return unless $prev->type eq $self->type;
    return if defined $prev->min;

    push @{ $prev->{data} }, @{ $self->{data} };
    push @{ $prev->{vis} }, @{ $self->{vis} };
    pop @$tree;
    return 1;
  }

  package Regexp::QuantAttr;
  use base 'Regexp::Parser';
  use Regexp::Parser::Hierarchy;
  main::ok( 1 );
}


#use Data::Dumper; $Data::Dumper::Indent = 1; print Dumper(Regexp::QuantAttr->new('abc+def?')->root);
#exit;


### self-tests
{
  my $r = Regexp::QuantAttr->new;
  $r->regex('^?(ab)+?');
  ok( $r->visual, '^?(ab)+?' );
  my $w = $r->walker;
  while (my ($n, $d) = $w->()) {
    chomp(my $exp = <DATA>);
    ok( join("\t", $d, $n->family, $n->type, $n->visual), $exp );
  }
  ok( scalar(<DATA>), "DONE\n" );
}

### 01simple.t
{
my $r = Regexp::QuantAttr->new;
my $rx = '^a+b*?c{5,}$';

ok( $r->regex($rx) );

# for this regex, it's ok
# it won't necessarily ALWAYS be
ok( $r->visual, $rx );

ok( "aaabbbcccccc" =~ $r->qr );
ok( "aaabbbccccc"  =~ $r->qr );
ok( "aaabbbcccc"   !~ $r->qr );

ok( "aaabbbccccc" =~ $r->qr );
ok( "aaabbccccc"  =~ $r->qr );
ok( "aaabccccc"   =~ $r->qr );
ok( "aaaccccc"    =~ $r->qr );

ok( "aaabbbccccc" =~ $r->qr );
ok( "aabbbccccc"  =~ $r->qr );
ok( "abbbccccc"   =~ $r->qr );
ok( "bbbccccc"    !~ $r->qr );
}

### 03walker.t
{
my $r = Regexp::QuantAttr->new;
my $rx = '^a+b*?c{5,}d{3}$';

ok( $r->regex($rx) );

for my $arg (-1, 0, 1, 2) {
  ok( my $w = $r->walker($arg) and 1 );
  ok( $w->(-depth) == $arg );
  while (my ($n, $d) = $w->()) {
    chomp(my $exp = <DATA>);
    ok( join("\t", $d, $n->family, $n->type, $n->visual), $exp );
  }
  ok( scalar(<DATA>), "DONE\n" );
}
}


__DATA__
0	anchor	bol	^?
0	open	open1	(ab)+?
1	exact	exact	ab
0	close	close1	
DONE
0	anchor	bol	^
0	exact	exact	a+
0	exact	exact	b*?
0	exact	exact	c{5,}
0	exact	exact	d{3}
0	anchor	eol	$
DONE
0	anchor	bol	^
0	exact	exact	a+
0	exact	exact	b*?
0	exact	exact	c{5,}
0	exact	exact	d{3}
0	anchor	eol	$
DONE
0	anchor	bol	^
0	exact	exact	a+
0	exact	exact	b*?
0	exact	exact	c{5,}
0	exact	exact	d{3}
0	anchor	eol	$
DONE
0	anchor	bol	^
0	exact	exact	a+
0	exact	exact	b*?
0	exact	exact	c{5,}
0	exact	exact	d{3}
0	anchor	eol	$
DONE
}
