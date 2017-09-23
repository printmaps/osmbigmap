#!/usr/bin/perl
# ---------------------------------------
# Program : BigMap.pl (load big map from OSM)
# Version : see below
#
# Copyright (C) 2014-2016 Klaus Tockloth <freizeitkarte@googlemail.com>
# - based on a generated script from openstreetmap.gryph.de/bigmap.cgi/ (abandoned)
#
# Remarks:
# - Tiles are 256 * 256 pixel PNG files.
# - Each zoom level is a directory, each column is a subdirectory, and each tile in that column is a file.
# - Filename(url) format is /zoom/x/y.png.
#
# Program code formatted with "perltidy".
# ---------------------------------------

use strict;
use warnings;
use English '-no_match_vars';

use Getopt::Long;
use Math::Trig;
use File::Basename;
use LWP;
use GD;

# pseudo constants
my $EMPTY = q{};

my $VERSION = '1.5.1 - 2016/10/18';

# program startup
# ---------------
my $programName = basename ( $PROGRAM_NAME );
my $programInfo = "$programName - Load a large map from OSM";
printf {*STDERR} ( "\n%s, %s\n\n", $programInfo, $VERSION );

# command line parameters
my $help             = $EMPTY;
my $latitude         = $EMPTY;
my $longitude        = $EMPTY;
my $zoomlevel        = 0;
my $number_of_xtiles = 0;
my $number_of_ytiles = 0;
my $proxy_server     = $EMPTY;
my $source_server    = $EMPTY;
my $pause_after      = 4;


# get the command line parameters
GetOptions ( 'help|?'   => \$help,
             'lat=s'    => \$latitude,
             'long=s'   => \$longitude,
             'zoom=s'   => \$zoomlevel,
             'xtiles=s' => \$number_of_xtiles,
             'ytiles=s' => \$number_of_ytiles,
             'proxy=s'  => \$proxy_server,
             'source=s' => \$source_server,
             'pause=s'  => \$pause_after,
             );

if ( $help
     || (    ( $latitude eq $EMPTY )
          && ( $longitude eq $EMPTY )
          && ( $zoomlevel eq $EMPTY )
          && ( $number_of_xtiles eq $EMPTY )
          && ( $number_of_ytiles eq $EMPTY ) ) )
{
    show_help ();
}

# check parameters
if ( ( $zoomlevel < 1 ) || ( $zoomlevel > 19 ) ) {
    show_help ();
}
if ( ( $number_of_xtiles < 1 ) || ( $number_of_xtiles > 40 ) ) {
    show_help ();
}
if ( ( $number_of_ytiles < 1 ) || ( $number_of_ytiles > 40 ) ) {
    show_help ();
}

# calculate tile numbers
my ( $dest_xtile, $dest_ytile ) = getTileNumber ( $latitude, $longitude, $zoomlevel );

# control output
printf {*STDERR} ( "latitude of top left corner  : %f\n",   $latitude );
printf {*STDERR} ( "longitude of top left corner : %f\n\n", $longitude );
printf {*STDERR} ( "zoomlevel of osm source map  : %d\n\n", $zoomlevel );

printf {*STDERR} ( "number of x tiles to load    : %d\n", $number_of_xtiles );
printf {*STDERR} ( "number of y tiles to load    : %d\n", $number_of_ytiles );
printf {*STDERR} ( "number of tiles to load      : %d\n", ( $number_of_xtiles * $number_of_ytiles ) );
printf {*STDERR} ( "1 sec pause after n tiles    : %d\n", $pause_after );

printf {*STDERR} ( "starting x tile number       : %d\n",   $dest_xtile );
printf {*STDERR} ( "starting y tile number       : %d\n\n", $dest_ytile );

my $x_pixels = ( $number_of_xtiles * 256 );
printf {*STDERR} ( "picture size in x direction  : %d\n", $x_pixels );
my $y_pixels = ( $number_of_ytiles * 256 );
printf {*STDERR} ( "picture size in y direction  : %d\n\n", $y_pixels );

if ( $source_server eq $EMPTY ) {
    $source_server = 'tile.openstreetmap.org';
}
my $user_agent = 'bigmap.pl';
printf {*STDERR} ( "map source server(s)         : %s\n",   $source_server );
printf {*STDERR} ( "program user agent           : %s\n",   $user_agent );
printf {*STDERR} ( "local proxy server           : %s\n\n", $proxy_server );

printf {*STDERR} ( "You have read and understood the OSM tile usage policy?\n" );
printf {*STDERR} ( "http://wiki.openstreetmap.org/wiki/Tile_usage_policy\n\n" );

printf {*STDERR} ( "Continue with tile download (y/n)?\n" );
chomp ( my $answer = <STDIN> );
if ( lc ( $answer ) ne 'y' ) {
    printf {*STDERR} ( "\nProgram terminated, nothing loaded.\n\n" );
    exit ( 2 );
}

printf {*STDERR} ( "\nStarting tile download ...\n", $latitude );

my $img = GD::Image->new ( $x_pixels, $y_pixels, 1 );
my $white = $img->colorAllocate ( 248, 248, 248 );
$img->filledRectangle ( 0, 0, $x_pixels, $y_pixels, $white );

my $ua = LWP::UserAgent->new ( $user_agent );
if ( $proxy_server ne $EMPTY ) {
    $ua->proxy ( 'http', 'http://' . $proxy_server );
}

my $total_tiles = 0;
for ( my $x = 0 ; $x < $number_of_xtiles ; $x++ ) {

    for ( my $y = 0 ; $y < $number_of_ytiles ; $y++ ) {
        my $xx = $x + $dest_xtile;
        my $yy = $y + $dest_ytile;

        my $url_list = $EMPTY;
        my $url_list_flag = 0;
        foreach my $base (split ( /\|/, $source_server ) ) {
        	if ($url_list_flag == 1) {
        		$url_list .= '|';
        	}
        	$url_list .= sprintf ("http://$base/$zoomlevel/!x/!y.png");
        	$url_list_flag = 1;
        }

        my $base_layer = 1;
        foreach my $base (split ( /\|/, $url_list ) ) {
            my $url = $base;
            $url =~ s/!x/$xx/g;
            $url =~ s/!y/$yy/g;
            print STDERR "$url ... ";

            my $resp = $ua->get ( $url );
            print STDERR $resp->status_line;
            print STDERR "\n";

            # first recovery
            if (! $resp->is_success) {
                print STDERR "trying again after 2 seconds ... \n";
                sleep (2);
                $resp = $ua->get ( $url );
                print STDERR $resp->status_line;
                print STDERR "\n";
            }

            # second recovery
            if (! $resp->is_success) {
                print STDERR "trying again after 10 seconds ... \n";
                sleep (10);
                $resp = $ua->get ( $url );
                print STDERR $resp->status_line;
                print STDERR "\n";
            }

            next unless $resp->is_success;
            my $tile = GD::Image->new ( $resp->content );
            next if ( $tile->width == 1 );

            if ( $base_layer == 0 ) {
                my $black = $tile->colorClosest ( 0, 0, 0 );
                $tile->transparent ( $black );
            }
            $base_layer = 0;

            $img->copy ( $tile, $x * 256, $y * 256, 0, 0, 256, 256 );

            # sleep after n tiles
            $total_tiles++;
            if ( $total_tiles % $pause_after == 0 ) {
                sleep (1);
            }
        }
    }
}

binmode STDOUT;
print $img->png ();

exit ( 0 );


# -----------------------------------------
# Calculate starting tiles.
# Source: http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
# -----------------------------------------
sub getTileNumber {
    my ( $lat, $lon, $zoom ) = @_;

    my $xtile = int ( ( $lon + 180 ) / 360 * 2**$zoom );
    my $ytile = int ( ( 1 - log ( tan ( deg2rad ( $lat ) ) + sec ( deg2rad ( $lat ) ) ) / pi ) / 2 * 2**$zoom );

    return ( $xtile, $ytile );
}


# -----------------------------------------
# Show help and exit.
# -----------------------------------------
sub show_help {

    printf {*STDERR} (
        "Usage   : perl $programName [Options] -lat=n.m -long=n.m -zoom=n -xtiles=n -ytiles=n  >picturename.png\n\n"            #
            . "Example : perl $programName -lat=51.94844 -long=7.58687 -zoom=18 -xtiles=10 -ytiles=9  >zoo_muenster.png\n\n"    #
            . "Example : perl $programName -lat=52.06 -long=7.46 -zoom=15 -xtiles=28 -ytiles=38  >city_muenster.png\n\n"        #
            . "Example : perl $programName -source=\"tile.openstreetmap.org\"                        \\\n"                      #
            . "                         -proxy=\"applejack:secret88\@10.88.180.22:8080\"           \\\n"                        #
            . "                         -lat=51.94844 -long=7.58687                             \\\n"                           #
            . "                         -zoom=18 -xtiles=10 -ytiles=9  >zoo_muenster.png\n"                                     #
            . "\nParameters:\n"                                                                                                 #
            . "-lat    : latitude of top left starting point (eg. 51.9505)\n"                                                   #
            . "-long   : longitude of top left starting point (eg. 7.5836)\n"                                                   #
            . "-zoom   : zoom level (1-19)\n"                                                                                   #
            . "-xtiles : number of x tiles to download (1-40)\n"                                                                #
            . "-ytiles : number of y tiles to download (1-40)\n"                                                                #
            . "\nOptions:\n"                                                                                                    #
            . "-proxy  : proxy server ([user[:password]\@]server[:port])\n"                                                     #
            . "          eg. 10.88.180.22:8080\n"                                                                               #
            . "          eg. apple777:secret88\@10.88.180.22:8080\n"                                                            #
            . "-source : map server (url)\n"                                                                                    #
            . "          eg. tile.openstreetmap.org (standard, default)\n"                                                      #
            . "          eg. tile.thunderforest.com/cycle (cyclist)\n"                                                          #
            . "          eg. tile.thunderforest.com/transport (transport)\n"                                                    #
            . "          eg. otile1.mqcdn.com/tiles/1.0.0/osm (mapquest)\n"                                                     #
            . "          eg. a.tile.openstreetmap.fr/hot (humanitarian)\n"                                                      #
            . "          eg. tiles.wmflabs.org/bw-mapnik (monochrom)\n"                                                         #
            . "          eg. a.tile.opentopomap.org (opentopomap)\n"                                                            #
            . "-pause  : wait 1 second after n tiles (default $pause_after)\n"                                                  #
            . "\nAdvanced usage:\n"                                                                                             #
            . "Some special maps are providing only a transparent map overlay.\n"                                               #
            . "In this case you have to specify a base and an overlay layer.\n"                                                 #
            . "-source : map server(s) (url)\n"                                                                                 #
            . "          eg. tile.openstreetmap.org|www.openfiremap.org/hytiles\n"                                              #
            . "          eg. tile.openstreetmap.org|tiles.openseamap.org/seamark\n\n"                                           #
            . "Example : perl $programName -source=\"tile.openstreetmap.org|www.openfiremap.org/hytiles\"   \\\n"               #
            . "                         -lat=53.547 -long=9.978                                        \\\n"                    #
            . "                         -zoom=16 -xtiles=4 -ytiles=4  >hamburg.png\n\n"                                         #
            . "Example : perl $programName -source=\"tile.openstreetmap.org|tiles.openseamap.org/seamark\"  \\\n"               #
            . "                         -lat=54.193 -long=12.076                                       \\\n"                    #
            . "                         -zoom=15 -xtiles=4 -ytiles=4  >warnemuende.png\n"                                       #
            . "\nRemarks:\n"                                                                                                    #
            . "- size of a single png tile : 256 * 256 pixels\n"                                                                #
            . "- number of tiles to load   : xtiles * ytiles\n"                                                                 #
            . "- x picture size (width)    : xtiles * 256 pixels\n"                                                             #
            . "- y picture size (higth)    : ytiles * 256 pixels\n\n",                                                          #
    );

    exit ( 1 );
}
