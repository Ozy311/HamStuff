#!/usr/bin/perl -s
#(C)2014 K6OZY

#EDIT $HOSTNAME AND INSERT YOUR TILE SERVER INFO THERE.

use Math::Trig;
use LWP::Simple;
use LWP::Useragent;
use File::Fetch;
use File::Basename;

my $hostname = "http://localhost/tiles" ;

my $prog = basename($0);
my $url;
my $filename;
my $dir;

sub getTileNumber {
  my ($lat,$lon,$zoom) = @_;
  my $xtile = int( ($lon+180)/360 * 2**$zoom ) ;
  my $ytile = int( (1 - log(tan(deg2rad($lat)) + sec(deg2rad($lat)))/pi)/2 * 2**$zoom ) ;
  return ($xtile, $ytile);
}
sub print_usage
{
    warn <<"EOF";
Usage:
	
	tile_fetch_range.pl [Starting Lat] [Starting Long] [Ending Lat] [Ending Long] [Zoom]
	
	Upper Left Coords must be used for Start.
	Lower Right Coords must be used for End.
	
	Example: tile_fetch_range.pl 33.8 -112.5 33.2 -111.6 10
	
		Will fetch the Phoenix Metro area tiles at zoom level 10.
	
EOF
}	
		
if( @ARGV < 5) # is less than five arguments
   {    
      print print_usage();    exit 0;
   }

my ($xstart, $ystart) = &getTileNumber($ARGV[0], $ARGV[1], $ARGV[4] );
my ($xend, $yend) = &getTileNumber($ARGV[2], $ARGV[3], $ARGV[4] );

print "Ozy's Tile Fetcher v1.0 (c)2014 K6OZY\n\n";

print "Starting Coords: $xstart, $ystart at Zoom $ARGV[4]\n";
print "  Ending Coords: $xend, $yend at Zoom $ARGV[4]\n\n";

mkdir $ARGV[4];

for (my $i=$xstart ; $i <= $xend ; $i++ ) {
	mkdir "$ARGV[4]/$i" ;
	$dir = "$ARGV[4]/$i" ; 
	for (my $j=$ystart ; $j <= $yend ; $j++) {
		my $url = "$hostname/$ARGV[4]/$i/$j.png" ;
		my $filename = $url;
		$filename =~ m/.*\/(.*)$/;
		$filename = $1;
		print "Saving $hostname/$dir/$filename ...";
		my $ua = LWP::UserAgent->new();
		my $response = $ua->get($url);
		die $response->status_line if !$response->is_success;
		my $file = $response->decoded_content( charset => 'none' );
		my $save = "$dir/$filename";
		getstore($url,$save);
		print " Done\n";
	}
#	print "$i\n"
}