#!/usr/bin/env perl

use strict;
use warnings;

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
   $out{bits} = $bits;
   return \%out;
}

sub getnetr {
   my $start = shift;
   my $end = shift;
   my $bits = 32 - (log($end-$start)/log(2));
   my $net = ($start >> 24) . '.' . ($start >> 16 & 255) . '.' . ($start >> 8 & 255). '.' . ($start & 255);
   return "$net/$bits";
}

my (%cn);
my $tot=0;
my $res=0;
my $ava=0;
my $brd=0;

my %IA = (
   AFRINIC=>'afrinic.lst',
   APNIC=>'apnic.lst',
   ARIN=>'arin.lst',
   LACNIC=>'lacnic.lst',
   RIPE_NCC=>'ripe.lst',
   IANA=>'iana.lst',
);
my %IW = (
   AFRINIC=>'whois.afrinic.net',
   APNIC=>'whois.apnic.net',
   ARIN=>'whois.arin.net',
   LACNIC=>'whois.lacnic.net',
   RIPE_NCC=>'whois.ripe.net',
   IANA=>'whois.iana.org',
);
sub genlist {
   $tot=0;
   $res=0;
   $ava=0;
   $brd=0;
   open(OUT,">","netlist.unsort.txt") or die($!);
   foreach my $f (keys %IA) {
      open(IN, '<', $IA{$f}) or die($!);
      while(<IN>) {
         chomp;
         my @z = split(/\|/,$_);
         next if (scalar(@z) < 7);
         next if ($z[2] ne 'ipv4');
         next if ($z[6] !~ /assigned|allocated|reserved|available/);
         my $x = getnet($z[3],$z[4]);
         my $pow2 = 1;
         $pow2 = 0 if ($x->{bits} - int($x->{bits}) > 0);
         if ($z[6] =~ /assigned|allocated/) {
            $tot += $z[4] - 2;
            $brd += 2;
            if (! $pow2) {
               $tot -= 2;
               $brd += 2;
            }
         } elsif ($z[6] =~ /reserved/) {
            $res += $z[4];
         } elsif ($z[6] =~ /available/) {
            $ava += $z[4]-2;
            $brd += 2;
            if (! $pow2) {
               $ava -= 2;
               $brd += 2;
            }
         }
         if (! $pow2) {
            print OUT $x->{sint}.' '.$x->{eint}.' '.$f.' '.$z[6].' '.$x->{start}.'-'.$x->{end}."\n";
         } else {
            print OUT $x->{sint}.' '.$x->{eint}.' '.$f.' '.$z[6].' '.$x->{cidr}."\n";
         }
      }
      close(IN);
   }
   close(OUT);

   `sort -g netlist.unsort.txt > netlist.txt`;
}

genlist();
# Attempt to fix any overlaps.
my @over;
open(IN, "<", "netlist.txt") or die($!);
my @l = (-1,-1);
while (<IN>) {
   my @a = split(/\s+/,$_);
   if($a[0] < ($l[1]+1)) {
      my $err = "Network block overlap: $l[2] $l[3] $l[4] and $a[2] $a[3] $a[4].";
      my $ip = $l[4] =~ s/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*$/$1/r;
      if ($l[2] eq 'IANA' && $l[3] eq 'reserved') {
         `sed -i -e '/$ip/d' $IA{$a[2]}`;
         $err .= "  Resolved.  Removed reserved block from $a[2].";
      } elsif ($a[2] eq 'IANA' &&  $a[3] eq 'reserved') {
         `sed -i -e '/$ip/d' $IA{$l[2]}`;
         $err .= "  Resolved.  Removed reserved block from $l[2].";
      } else {
         my $w1 = `whois -h $IW{$l[2]} $ip`;
         my $w2 = `whois -h $IW{$a[2]} $ip`;
         if ($w1 =~ /transferred/i && $w2 !~ /transferred/i) {
            `sed -i -e '/$ip/d' $IA{$l[2]}`;
            $err .= "  Resolved.  $l[2] transferred block to $a[2].";
         } elsif ($w1 !~ /transferred/i && $w2 =~ /transferred/i) {
            `sed -i -e '/$ip/d' $IA{$a[2]}`;
            $err .= "  Resolved.  $a[2] transferred block to $l[2].";
         }
      }
      push(@over,$err) if $err =~ /Resolved/;
   }
   @l = @a;
}
close(IN);

genlist();

open(OUT,">", "ipv4status.html") or die($!);
print OUT "<table><tr><th colspan=2>IPv4 Address Space Status</th></tr>\n";
print OUT "<tr><td>Allocated IP addresses</td><td class=\"num\">$tot</td></tr>\n";
print OUT "<tr><td>Available IP addresses</td><td class=\"num\">$ava</td></tr>\n";
print OUT "<tr><td>Broadcast IP addresses</td><td class=\"num\">$brd</td></tr>\n";
print OUT "<tr><td>Reserved IP addresses</td><td class=\"num\">$res</td></tr>\n";
print OUT "<tr><td>Total (should equal 2<sup>32</sup>)</td><td class=\"num\">".($tot+$ava+$brd+$res)."</td></tr>\n";
if ($tot+$ava+$brd+$res == 2**32) {
   print OUT "<tr><td class=\"sumok\" colspan=2>Entirety of IPv4 address space accounted for.</td></tr>\n";
} else {
   my $diff = ($tot+$ava+$brd+$res) - 2**32;
   print OUT "<tr><td class=\"sum\" colspan=2>Off by $diff IP addresses.</td></tr>\n";
}
print OUT "</table>\n";
open(IN, "<", "netlist.txt") or die($!);
@l = (-1,-1);
while (<IN>) {
   my @a = split(/\s+/,$_);
   if ($a[0] > ($l[1]+1)) {
      my $net = getnetr($l[1]+1,$a[0]);
      print OUT "<p class=\"err\">Network block $net not found.</p>\n";
   } elsif($a[0] < ($l[1]+1)) {
      print OUT "<p class=\"err\">Network block overlap: $l[2] $l[3] $l[4] and $a[2] $a[3] $a[4].</p>\n";
   }
   @l = @a;
}
foreach (@over) {
   print OUT "<p class=\"ok\">$_</p>\n";
}
close(IN);
close(OUT);
