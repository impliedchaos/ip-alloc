# ip-alloc

![Build](https://github.com/impliedchaos/ip-alloc/actions/workflows/build.yml/badge.svg)

You can view the generated data at [this link](https://impliedchaos.github.io/ip-alloc/).  It is generated daily.

I needed a count of IP addresses allocated by country.  Wikipedia has [this page](https://en.wikipedia.org/wiki/List_of_countries_by_IPv4_address_allocation),
but it's out of date.

So I made this instead.

## Sources

* Population and Country name data comes from geoname.org's [countryInfo.txt export file](https://download.geonames.org/export/dump/countryInfo.txt).
* IP Address counts come from the latest delegation statistics of all 5 RIRs:
  * AFRINIC <https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest>
  * APNIC <https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest>
  * ARIN <https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest>
  * LACNIC <https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest>
  * RIPE NCC <https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest>
* The contents of the `iana.lst` file comes from the [IANA IPv4 Special-Purpose Address Registry](https://www.iana.org/assignments/iana-ipv4-special-registry/iana-ipv4-special-registry.xhtml).

RIPE NCC has several IP assignments listing the country as "EU".  So the statistics for RIPE NCC is preprocessed and the country for those subnets is attempted to be discerned with a whois query.  This works in several cases but in others it doesn't, so "Europe" can sometimes show up as a nation in the listing.

## IP Address Counting

IPv4 addresses are counted by adding the size of each block minus 2.  This is to account for the ones and zeroes broadcast addresses of the subnetwork not being assignable.  Network blocks with a length that isn't a power of two have another 2 addresses subtracted since it will take at least two subnetworks for the block. This does not account for all the other subnetting done to the blocks by their owners (which further reduces useable address space).

The IPv6 address space is enormous.  The counts are astronomical and kind of silly, but I added it for completeness.

## Other Stuff

Since we're going through the trouble of parsing the RIR delegation stats every night, this project also creates the `GeoIP-whois.dat` file that can be used to determine the correct whois server for an IP (for those of us that do automated whois queries).  The following countries in the file should be mapped to the corresponding whois server:

* AP, Asia/Pacific Region - whois.apnic.net
* EU, Europe - whois.ripe.net
* MX, Mexico - whois.lacnic.net
* O1, Other - whois.iana.org
* US, United States - whois.arin.net
* ZA, South Africa - whois.afrinic.net

Example usage:

```bash
$ geoiplookup -f ./GeoIP-whois.dat 0.0.0.1
GeoIP Country Edition: O1, Other
$ whois -h whois.iana.org 0.0.0.1
...
$ geoiplookup -f ./GeoIP-whois.dat 1.0.0.1
GeoIP Country Edition: AP, Asia/Pacific Region
$ whois -h whois.apnic.net 1.0.0.1
...
$ geoiplookup -f ./GeoIP-whois.dat 2.0.0.1
GeoIP Country Edition: EU, Europe
$ whois -h whois.ripe.net 2.0.0.1
...
$ geoiplookup -f ./GeoIP-whois.dat 3.0.0.1
GeoIP Country Edition: US, United States
$ whois -h whois.arin.net 3.0.0.1
...
$ geoiplookup -f ./GeoIP-whois.dat 41.0.0.1
GeoIP Country Edition: ZA, South Africa
$ whois -h whois.afrinic.net 41.0.0.1
...
$ geoiplookup -f ./GeoIP-whois.dat 177.0.0.1
GeoIP Country Edition: MX, Mexico
$ whois -h whois.lacnic.net 177.0.0.1
...

```

You can schedule nightly downloads of the file by accessing it here: <https://github.com/impliedchaos/ip-alloc/raw/main/GeoIP-whois.dat>

Author: Dave Maez
