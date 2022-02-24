#!/usr/bin/env perl
# Name:         ipcount.pl                                                    #

use strict;
use warnings;
use JSON;

my (%out,%c,%c6,%ci);
my $tot=0;

open(my $in, "<", "countryInfo.txt") or die($!);
while (<$in>) {
   next if (/^\s*#/);
   next if (/^\s*$/);
   my @t = split(/\t/,$_);
   next if ($t[0] =~ /AN|CS/);
   $ci{$t[0]} = { name=>$t[4], pop=>$t[7] };
   $tot += $t[7];
}
close($in);
$out{Total} = { name=>'World', pop=>$tot };
$out{EU} = { name=>'"Europe"', pop=>'--'};

use bigint;
foreach my $f ('afrinic.lst','apnic.lst','arin.lst','lacnic.lst','ripe.lst') {
   open(my $in, '<', $f) or die($!);
   while(<$in>) {
      chomp;
      my @z = split(/\|/,$_);
      next if (scalar(@z) < 7);
      next if ($z[6] ne 'allocated' && $z[6] ne 'assigned');
      if ($z[2] eq 'ipv4') {
         $c{$z[1]} += $z[4]-2;
         $c{Total} += $z[4]-2;
      } elsif ($z[2] eq 'ipv6') {
         my $t = 2 ** (128 - $z[4]);
         $c6{$z[1]} += $t;
         $c6{Total} += $t;
      }
   }
   close($in);
}
foreach my $k (keys %c) {
   $out{$k}->{ipv4} = "$c{$k}";
}
foreach my $k (keys %c6) {
   $out{$k}->{ipv6} = "$c6{$k}";
}
no bigint;
foreach my $k (keys %out) {
   next if ($k =~ /Total|EU/);
   $out{$k}->{name} = $ci{$k}->{name} || $k;
   $out{$k}->{pop} = $ci{$k}->{pop} || 0;
   $out{$k}->{ipv4} *= 1;
   $out{$k}->{ipv6} //= '0';
}
open(JSON, ">", "ip_alloc.json") or die($!);
print JSON encode_json(\%out);
close(JSON);

open(HTML, ">", "ip_alloc.html") or die($!);
print HTML "<h2>IPv4</h2>\n";
print HTML "<table id=\"ipv4\">\n";
print HTML "<tr><th>Rank</th><th>Country</th><th>IP Addresses</th><th>Population</th></tr>\n";
print HTML "<tr><td></td><td>Total World Allocation</td><td>".$out{Total}->{ipv4}."</td><td>".$out{Total}->{pop}."</td></tr>\n";
my $c = 1;
foreach my $k (sort {$out{$b}->{ipv4} <=> $out{$a}->{ipv4}} sort {$out{$b}->{pop} <=> $out{$a}->{pop}} sort {$out{$a}->{name} cmp $out{$b}->{name}} keys(%out)) {
   next if ($k eq 'Total');
   printf HTML "<tr><td>%d</td><td>%s</td><td class=\"num\">%d</td><td class=\"num\">%d</td></tr>\n",$c++, $out{$k}->{name}, $out{$k}->{ipv4}, $out{$k}->{pop};
}
print HTML "</table>\n<br/>\n<h2>IPv6</h2>\n<table id=\"ipv6\">\n";
print HTML "<tr><th>Rank</th><th>Country</th><th>IP Addresses</th><th>Population</th></tr>\n";
print HTML "<tr><td></td><td>Total World Allocation</td><td>".$out{Total}->{ipv6}."</td><td>".$out{Total}->{pop}."</td></tr>\n";
$c = 1;
foreach my $k (sort {substr("0" x 50 . $out{$b}->{ipv6},-50) cmp substr("0" x 50 . $out{$a}->{ipv6},-50)} sort {$out{$b}->{pop} <=> $out{$a}->{pop}} sort {$out{$a}->{name} cmp $out{$b}->{name}} keys(%out)) {
   next if ($k eq 'Total');
   printf HTML "<tr><td>%d</td><td>%s</td><td class=\"num\">%s</td><td class=\"num\">%d</td></tr>\n",$c++, $out{$k}->{name}, $out{$k}->{ipv6}, $out{$k}->{pop};
}
print HTML "</table>\n<br/>\n";
close(HTML);