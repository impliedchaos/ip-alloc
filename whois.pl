#!/usr/bin/env perl
use strict;
use warnings;
use JSON;

sub getnet {
   my $start = shift;
   my $len = shift;
   my %out;

   my $bits = 32 - (log($len)/log(2));
   $out{cidr} = $start.'/'.$bits;
   my @q = split(/\./,$start);
   my $sint = ($q[0] << 24) + ($q[1] << 16) + ($q[2] << 8) + $q[3];
   my $eint = $sint + $len - 1;
   my $end = ($eint >> 24) . '.' . ($eint >> 16 & 255) . '.' . ($eint >> 8 & 255) . '.' . ($eint & 255);
   $out{start} = $start;
   $out{end} = $end;
   $out{sint} = $sint;
   $out{eint} = $eint;
   return \%out;
}
my $tot=0;

my %w = (
   'afrinic.lst'=>'ZA,whois.afrinic.net',
   'apnic.lst'=>'AP,whois.apnic.net',
   'arin.lst'=>'US,whois.arin.net',
   'lacnic.lst'=>'MX,whois.lacnic.net',
   'ripe.lst'=>'EU,whois.ripe.net',
   'iana.lst'=>'O1,whois.iana.org',
);

open(OUT,'>','GeoIP-whois.csv') or die($!);
foreach my $f (keys %w) {
   open(IN, '<', $f) or die($!);
   while(<IN>) {
      chomp;
      my @z = split(/\|/,$_);
      next if (scalar(@z) < 7);
      next if ($z[2] ne 'ipv4');
      my $x = getnet($z[3],$z[4]);
      print OUT "$x->{start},$x->{end},$x->{sint},$x->{eint},$w{$f}\n";
   }
   close(IN);
}
close(OUT);

print `/usr/lib/geoip/geoip-generator -4 -v -i "whois map" -o GeoIP-whois.dat GeoIP-whois.csv`;
