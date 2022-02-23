# ip-alloc

![Build](https://img.shields.io/github/workflow/status/impliedchaos/ip-alloc/IP%20Allocation%20data%20build?logo=github)

You can view the generated data at [this link](https://impliedchaos.github.io/ip-alloc/).

I needed a count of IP addresses allocated by country.  Wikipedia has [this page](https://en.wikipedia.org/wiki/List_of_countries_by_IPv4_address_allocation),
but it's out of date and in need of updating.

So I made this instead.

### Sources:

* Population and Country name data comes from geoname.org's [countryInfo.txt file](https://download.geonames.org/export/dump/countryInfo.txt).
* IP Address counts come from the delegation statistics of all 5 RIRs:
  1. AFRINIC <https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest>
  2. APNIC <https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest>
  3. ARIN <https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest>
  4. LACNIC <https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest>
  5. RIPE NCC <https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest>

RIPE NCC has several IP assignments listing the country as "EU".  So the data for RIPE NCC is preprocessed and the country for those subnets is attempted to be discerned with a whois query.  This works in several cases but in others it doesn't, so "Europe" shows up as a nation in the listing.

### IP Address Counting

IPv4 IPs are counted by adding the size of each block minus 2.  This is to account for the ones and zeroes broadcast addresses of the subnetwork.  This does not account for all the other subnetting done to the blocks by their owners (which further reduces useable address space).

The IPv6 address space is enourmous.  The counts are astronomical, and kind of pointless, but I added it for completeness.

- Dave Maez