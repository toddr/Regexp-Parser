package Regexp::Parser::Hierarchy;

our %hier = (
  __object__ => [qw(
    anchor reg_any alnum space digit anyof
    anyof_char anyof_range anyof_class anyof_close
    prop clump branch exact quant group open close
    tail ref assertion groupp flags minmod
  )],

  anchor => [qw(
    bol bound gpos eol
  )],

  assertion => [qw(
    ifmatch unlessm suspend
    ifthen eval logical
  )],

  branch => [qw(
    or
  )],
);


sub import {
  my $class = shift;
  my $prefix = caller;

  for my $setup (\%hier, {@_}) {
    while (my ($parent, $kids) = each %$setup) {
      push @{ "${prefix}::${parent}::ISA" }, ();
      for (@$kids) {
        push @{ "${prefix}::${_}::ISA" }, "${prefix}::$parent";
      }
    }
  }
}

1;

__END__

=head1 NAME

Regexp::Parser::Hierarchy - builds the Regexp::Parser hierarchy

=head1 SYNOPSIS

  package MyRxPkg;
  use base 'Regexp::Parser';

  use Regexp::Parser::Hierarchy;
  # or
  use Regexp::Parser::Hierarchy (
    __object__ => [qw( new_top_level_nodes )],
    anchor     => [qw( new_anchors         )],
    assertion  => [qw( new_assertions      )],
    branch     => [qw( new_branches        )],
  );

=head1 DESCRIPTION

Use this module after C<use base 'Regexp::Parser'> to install the object
hierarchy for your class.

If you are introducing new objects, you need to declare them here.  As
the example in the synopsis shows, you pass a list of pairs.  Each pair
is an abstract class and an array reference of the new objects that
inherit from it.

If you are creating a new top-level object, you put it in the array
reference for I<__object__>.  If you are creating a new anchor object,
you put it in the array reference for I<anchor>.  If you are creating
an entire new abstract class and elements for it, include the abstract
class in the I<__object__> array reference, and put its sub-classes in
its array reference:

  use Regexp::Parser::Hierarchy (
    __object__ => [qw( jump )],
    jump       => [qw( skip hop leap )],
  );

=head1 SEE ALSO

L<Regexp::Parser>, L<Regexp::Parser::Handlers>,
L<Regexp::Parser::Objects>.

=head1 AUTHOR

Jeff C<japhy> Pinyan, F<japhy@perlmonk.org>

=head1 COPYRIGHT

Copyright (c) 2004 Jeff Pinyan F<japhy@perlmonk.org>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

