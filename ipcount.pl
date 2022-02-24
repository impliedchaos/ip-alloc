#!/usr/bin/env perl
# Name:         ipcount.pl                                                    #

use strict;
use warnings;
use JSON;

my (%out,%c,%c6);
my $tot=0;
my $res=0;
my $brd=0;
my $ava=0;

open(my $in, "<", "countryInfo.txt") or die($!);
while (<$in>) {
   next if (/^\s*#/);
   next if (/^\s*$/);
   my @t = split(/\t/,$_);
   next if ($t[0] =~ /AN|CS/);
   $out{$t[0]} = { name=>$t[4], pop=>$t[7] };
   $tot += $t[7];
}
close($in);
$out{Total} = { name=>'World', pop=>$tot };
$out{EU} = { name=>'"Europe"', pop=>0 };

use bignum;
foreach my $f ('afrinic.lst','apnic.lst','arin.lst','lacnic.lst','ripe.lst','iana.lst') {
   open(my $in, '<', $f) or die($!);
   while(<$in>) {
      chomp;
      my @z = split(/\|/,$_);
      next if (scalar(@z) < 7);
      if ($z[2] eq 'ipv4') {
         if ($z[6] eq 'reserved') {
            $res += $z[4];
         } elsif ($z[6] eq 'available') {
            $ava += $z[4]-2;
            $brd += 2;
         } elsif ($z[6] =~ /assigned|allocated/) {
            $c{$z[1]} += $z[4]-2;
            $c{Total} += $z[4]-2;
         }
      } elsif ($z[2] eq 'ipv6') {
         next unless ($z[6] =~ /assigned|allocated/);
         my $t = 2 ** (128 - $z[4]);
         $c6{$z[1]} += $t;
         $c6{Total} += $t;
      }
   }
   close($in);
}
$tot = $c{Total};
foreach my $k (keys %c) {
   $out{$k}->{percentv4} = $c{$k} / $tot * 100;
   $out{$k}->{percentv4} = "$out{$k}->{percentv4}";
   if ($out{$k}->{pop}) {
      $out{$k}->{pcv4} = $c{$k} / $out{$k}->{pop};
      $out{$k}->{pcv4} = "$out{$k}->{pcv4}";
   }
   $out{$k}->{ipv4} = "$c{$k}";
}
$tot = $c6{Total};
foreach my $k (keys %c6) {
   $out{$k}->{percentv6} = $c6{$k} / $tot * 100;
   $out{$k}->{percentv6} = "$out{$k}->{percentv6}";
   if ($out{$k}->{pop}) {
      $out{$k}->{pcv6} = $c6{$k} / $out{$k}->{pop};
      $out{$k}->{pcv6} = "$out{$k}->{pcv6}";
   }
   $out{$k}->{ipv6} = "$c6{$k}";
}
no bignum;
foreach my $k (keys %out) {
   $out{$k}->{ipv4} //= '0';
   $out{$k}->{ipv6} //= '0';
   $out{$k}->{percentv4} //= '0';
   $out{$k}->{percentv6} //= '0';
   $out{$k}->{pcv4} //= '0';
   $out{$k}->{pcv6} //= '0';
   $out{$k}->{ipv4} *= 1;
   $out{$k}->{pcv4} *= 1.0;
   $out{$k}->{percentv4} *= 1.0;
   $out{$k}->{percentv6} *= 1.0;
}
open(JSON, ">", "ip_alloc.json") or die($!);
print JSON encode_json(\%out);
close(JSON);

open(HTML, ">", "ip_alloc.html") or die($!);
print HTML "<h2>IPv4</h2>\n";
print HTML "<table id=\"ipv4\">\n";
print HTML "<tr><th>Rank</th><th>Country</th><th>IP Addresses</th><th>%</th><th>Population</th><th>IP Addresses Per Capita</tr>\n";
print HTML "<tr><td></td><td>Total World Allocation</td><td class=\"num\">".$out{Total}->{ipv4}."</td><td class=\"percent\">100</td><td class=\"num\">".$out{Total}->{pop}."</td><td class=\"pc\">".sprintf("%0.5f",$out{Total}->{pcv4})."</td></tr>\n";
my $c = 1;
foreach my $k (sort {$out{$b}->{ipv4} <=> $out{$a}->{ipv4}} sort {$out{$b}->{pop} <=> $out{$a}->{pop}} sort {$out{$a}->{name} cmp $out{$b}->{name}} keys(%out)) {
   next if ($k eq 'Total');
   printf HTML "<tr><td>%d</td><td>%s</td><td class=\"num\">%d</td><td class=\"percent\">%0.5f</td><td class=\"num\">%d</td><td class=\"pc\">%0.5f</td></tr>\n",$c++, $out{$k}->{name}, $out{$k}->{ipv4}, $out{$k}->{percentv4}, $out{$k}->{pop}, $out{$k}->{pcv4};
}
print HTML "</table>\n";
print HTML "<p>Allocated IPv4 addresses: $out{Total}->{ipv4}</p>\n";
print HTML "<p>Reserved IPv4 addresses: $res</p>\n";
print HTML "<p>Broadcast IPv4 addresses: $brd</p>\n";
print HTML "<p>Available IPv4 addresses: $ava</p>\n";
if ($res+$brd+$ava+$out{Total}->{ipv4} == 2**32) {
   print HTML "<p>Entirety of 32bit IPv4 address space accounted for.</p>"
}
print HTML "<br/>\n";
print HTML "<h2>IPv6</h2>\n<table id=\"ipv6\">\n";
print HTML "<tr><th>Rank</th><th>Country</th><th>IP Addresses</th><th>%</th><th>Population</th>\n";
print HTML "<tr><td></td><td>Total World Allocation</td><td class=\"bignum\">".$out{Total}->{ipv6}."</td><td class=\"percent\">100</td><td class=\"num\">".$out{Total}->{pop}."</td></tr>\n";
$c = 1;
foreach my $k (sort {substr("0" x 50 . $out{$b}->{ipv6},-50) cmp substr("0" x 50 . $out{$a}->{ipv6},-50)} sort {$out{$b}->{pop} <=> $out{$a}->{pop}} sort {$out{$a}->{name} cmp $out{$b}->{name}} keys(%out)) {
   next if ($k eq 'Total');
   printf HTML "<tr><td>%d</td><td>%s</td><td class=\"bignum\">%s</td><td class=\"percent\">%0.5f</td><td class=\"num\">%d</td></tr>\n",$c++, $out{$k}->{name}, $out{$k}->{ipv6}, $out{$k}->{percentv6}, $out{$k}->{pop};
}
print HTML "</table>\n<br/>\n";
close(HTML);