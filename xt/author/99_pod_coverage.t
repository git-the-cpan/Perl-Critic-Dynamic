#!perl

##############################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-Dynamic-0.05/xt/author/99_pod_coverage.t $
#    $Date: 2010-09-24 11:59:12 -0700 (Fri, 24 Sep 2010) $
#   $Author: thaljef $
# $Revision: 3933 $
##############################################################################

use strict;
use warnings;
use Test::More;
use English qw<-no_match_vars>;

#-----------------------------------------------------------------------------

our $VERSION = '0.05';

#-----------------------------------------------------------------------------

eval 'use Test::Pod::Coverage 1.04';
plan skip_all => 'Test::Pod::Coverage 1.00 requried to test POD' if $EVAL_ERROR;

{
    # HACK: Perl::Critic::Violation uses Pod::Parser to extract the
    # DIAGNOSTIC section of the POD in each Policy module.  This
    # happens when the Policy first C<uses> the Violation module.
    # Meanwhile, Pod::Coverage also uses Pod::Parser to extract the
    # POD and compare it with the subroutines that are in the symbol
    # table for that module.  For reasons I cannot yet explain, using
    # Pod::Parser twice this way causes the symbol table to get very
    # wacky and this test script dies with "Can't call method 'OPEN'
    # on IO::String at line 1239 of Pod/Parser.pm".

    # For now, my workaround is to temporarily redefine the import()
    # method in the Violation module so that it doesn't do any Pod
    # parsing.  I'll look for a better solution (or file a bug report)
    # when / if I have better understanding of the problem.

    no warnings qw(redefine once);
    require Perl::Critic::Violation;
    *Perl::Critic::Violation::import = sub { 1 };
}

my @trusted_methods  = get_trusted_methods();
my $method_string = join ' | ', @trusted_methods;
my $trusted_rx = qr{ \A (?: $method_string ) \z }xms;
all_pod_coverage_ok( {trustme => [$trusted_rx]} );

#-----------------------------------------------------------------------------

sub get_trusted_methods {
    return qw(
        new
        initialize_if_enabled
        violates
        violates_dynamic
        applies_to
        default_themes
        default_severity
        supported_parameters
        description
        Fields
    );
}

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
