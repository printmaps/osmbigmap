## bigmap.pl - load a large map from OSM  

**Description**  
bigmap.pl is a command line utility written in Perl.
It can be used on all operating systems where a Perl interpreter is available (eg. Linux, OSX, Windows).
It's purpose is to retrieve prerendered tiles from OSM and montage a large map from them.
This program also works if you are behind an internet proxy server (see options).

**Precondition**  
Please make sure that you have read and understood the OSM tile usage policy. See
http://wiki.openstreetmap.org/wiki/Tile_usage_policy

**Usage**  
```
bigmap.pl - Load a large map from OSM, 1.5.1 - 2016/10/18

Usage   : perl bigmap.pl [Options] -lat=n.m -long=n.m -zoom=n -xtiles=n -ytiles=n  >picturename.png

Example : perl bigmap.pl -lat=51.94844 -long=7.58687 -zoom=18 -xtiles=10 -ytiles=9  >zoo_muenster.png

Example : perl bigmap.pl -lat=52.06 -long=7.46 -zoom=15 -xtiles=28 -ytiles=38  >city_muenster.png

Example : perl bigmap.pl -source="tile.openstreetmap.org"                        \
                         -proxy="applejack:secret88@10.88.180.22:8080"           \
                         -lat=51.94844 -long=7.58687                             \
                         -zoom=18 -xtiles=10 -ytiles=9  >zoo_muenster.png

Parameters:
-lat    : latitude of top left starting point (eg. 51.950)
-long   : longitude of top left starting point (eg. 7.584)
-zoom   : zoom level (1-19)
-xtiles : number of x tiles to download (1-40)
-ytiles : number of y tiles to download (1-40)

Options:
-proxy  : proxy server ([user[:password]@]server[:port])
          eg. 10.88.180.22:8080
          eg. apple777:secret88@10.88.180.22:8080
-source : map server (url)
          eg. tile.openstreetmap.org (standard, default)
          eg. tile.thunderforest.com/cycle (cyclist)
          eg. tile.thunderforest.com/transport (transport)
          eg. otile1.mqcdn.com/tiles/1.0.0/osm (mapquest)
          eg. a.tile.openstreetmap.fr/hot (humanitarian)
          eg. tiles.wmflabs.org/bw-mapnik (monochrom)
          eg. a.tile.opentopomap.org (opentopomap)
-pause  : wait 1 second after n tiles (default 4)

Advanced usage:
Some special maps are providing only a transparent map overlay.
In this case you have to specify a base and an overlay layer.
-source : map server(s) (url)
          eg. tile.openstreetmap.org|www.openfiremap.org/hytiles
          eg. tile.openstreetmap.org|tiles.openseamap.org/seamark

Example : perl bigmap.pl -source="tile.openstreetmap.org|www.openfiremap.org/hytiles"   \
                         -lat=53.547 -long=9.978                                        \
                         -zoom=16 -xtiles=4 -ytiles=4  >hamburg.png

Example : perl bigmap.pl -source="tile.openstreetmap.org|tiles.openseamap.org/seamark"  \
                         -lat=54.193 -long=12.076                                       \
                         -zoom=15 -xtiles=4 -ytiles=4  >warnemuende.png

Remarks:
- size of a single png tile : 256 * 256 pixels
- number of tiles to load   : xtiles * ytiles
- x picture size (width)    : xtiles * 256 pixels
- y picture size (higth)    : ytiles * 256 pixels
```

**History**  
Release 1.5.0 (2016/10/18): Improvements.  
Release 1.4.1 (2015/10/10): Initial version.  
