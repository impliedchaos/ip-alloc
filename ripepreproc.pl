#!/usr/bin/env perl
#-----------------------------------------------------------------------------#
# Try to resolve the "EU" assigments in RIPE NCC to actual countries.         #
#-----------------------------------------------------------------------------#

use strict;
use warnings;

open(IN,"<","countryInfo.txt") or die($!);
my (%CO,%CC);
while(<IN>) {
   next if (/^\s*#/);
   my @c = split(/\t/,$_);
   $CO{$c[4]} = $c[0];
   $CC{$c[5]} = $c[0];
}
close(IN);
while(<>) {
   chomp;
   my @t = split(/\|/,$_);
   if (@t > 6 && $t[1] eq 'EU' && $t[2] =~ /ipv[46]/ && $t[6] =~ /assigned|allocated/) {
      my $w = `whois -h whois.ripe.net $t[3]`;
      if ($w =~ /^country:\s*([A-Z]{2,2})/m) {
         $t[1] = $1;
      }
      if ($t[1] eq 'EU') {
         print STDERR "WHOIS for $t[3] still showing as EU.\n";
         print STDERR "Attempting Country lookup from address lines.\n";
         while ($w =~ /^address:\s*(.*)$/mg && $t[1] eq 'EU') {
            my $addr = $1;
            foreach my $c (keys %CO) {
               if ($addr =~ /$c/i) {
                  print STDERR "Found $c in address \"$addr\".\n";
                  $t[1] = $CO{$c};
                  last;
               }
            }
         }
      }
      if ($t[1] eq 'EU') {
         print STDERR "Attempting Capital City lookup from address lines.\n";
         while ($w =~ /^address:\s*(.*)$/mg && $t[1] eq 'EU') {
            my $addr = $1;
            foreach my $c (keys %CC) {
               if ($addr =~ /$c/i) {
                  print STDERR "Found $c in address \"$addr\".\n";
                  $t[1] = $CC{$c};
                  last;
               }
            }
         }
      }
      if ($t[1] eq 'EU') {
         print STDERR "COUNTRY NOT FOUND. I give up, I'm just a dumb script.\n";
      }
      print join('|',@t)."\n";
   } else {
     print $_."\n";
   }
}