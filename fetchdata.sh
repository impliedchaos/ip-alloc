#!/bin/bash

wget -O afrinic.lst "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest" && \
wget -O afrinic.md5 "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest.md5" && \
wget -O apnic.lst "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest" && \
wget -O apnic.md5 "https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest.md5" && \
wget -O arin.lst "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" && \
wget -O arin.md5 "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest.md5" && \
wget -O lacnic.lst "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest" && \
wget -O lacnic.md5 "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest.md5" && \
wget -O ripe.lst "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest" && \
wget -O ripe.md5 "https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest.md5" && \
wget -O countryInfo.txt "https://download.geonames.org/export/dump/countryInfo.txt"

echo AFRINIC stats Timestamp..........$(date -u --date=@$(stat --format %Y afrinic.lst)) > timestamp
echo APNIC stats Timestamp............$(date -u --date=@$(stat --format %Y apnic.lst)) >> timestamp
echo ARIN stats Timestamp.............$(date -u --date=@$(stat --format %Y arin.lst)) >> timestamp
echo LACNIC stats Timestamp...........$(date -u --date=@$(stat --format %Y lacnic.lst)) >> timestamp
echo RIPE NCC stats Timestamp.........$(date -u --date=@$(stat --format %Y ripe.lst)) >> timestamp
echo countryInfo.txt Timestamp........$(date -u --date=@$(stat --format %Y ripe.lst)) >> timestamp