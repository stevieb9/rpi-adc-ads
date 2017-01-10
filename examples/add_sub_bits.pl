use warnings;
use strict;
use feature 'say';

my $b = 128;
my $t = 10;
my $x = 13;

$b = $b + $t;

printf("$b: %b\n", $b);

$b = $b - $t + $x;

printf("$b: %b\n", $b);

$b = $b - $x + $t;

printf("$b: %b\n", $b);

