#!/usr/bin/env perl
#-----------------------------------------------------------------------------#
# Try to resolve the "EU" assigments in RIPE NCC to actual countries.         #
#-----------------------------------------------------------------------------#

use strict;
use warnings;

while(<>) {
   chomp;
   my @t = split(/\|/,$_);
   if (@t > 6 && $t[1] eq 'EU' && $t[2] =~ /ipv[46]/ && $t[6] =~ /assigned|allocated/) {
      my $w = `whois -h whois.ripe.net $t[3]`;
      if ($w =~ /^country:\s*([A-Z]{2,2})/m) {
         $t[1] = $1;
      }
      print join('|',@t)."\n";
   } else {
     print $_."\n";
   }
}
