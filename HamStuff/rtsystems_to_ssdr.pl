#!/usr/bin/perl

#(C)2014 Chris Johnson K6OZY
#k6ozy[@]arrl dot net
 
use Text::CSV;
use Getopt::Std;

use POSIX;
my $date = strftime "%Y-%m-%d_%H-%M-%S", localtime;

my $opt_string = 'hf:o:g:';
getopts( "$opt_string", \%opt);

print "\nFlex 6000 Series RT Systems To SmartSDR CSV Memory Converter v0.2\n(C)2014 Chris Johnson K6OZY k6ozy[at]arrl.net\n";

usage() if $opt{h};

if (!$opt{f}){
		usage();
		exit;
}

my $owner = "OWNER"; 
my $group = "GROUP"; 

if ($opt{o}) {
	print  "Custom Name: $opt{o}\n";
	$owner = $opt{o};
}

if ($opt{g}) {
	print  "Custom Group: $opt{g}\n";
	$group = $opt{g};
}


my $csv = Text::CSV->new(); 
my $file = $opt{f};
my $ssdrfile = "SSDR_Memories_$date.csv";

my $rows = 0;
my $ssdr_rows = 0;
my @fields; 
my @ssdr_fields;
my $tone_mode = "Off";
my $tone_value = 0;
my $offset_direction = "Simplex";
my $repeater_offset = 0;

open(my $data, "<$file") or die "Could not open '$file' $!\n";
open(my $ssdr_data, ">$ssdrfile") or die "Could not open '$ssdrfile' $!\n";

$/ = "\r\n"; # Strip Windows CRLF

#Set Column Names
$csv->column_names ( my $line = <$data> ) ;


while ($line = <$data>) {
  chomp $line;
 
  if ($csv->parse($line)) {
 
      push(@fields , [$csv->fields]);
      $rows++;
 
  } else {
 		die "Line could not be parsed: $line\n";
  }
}
close $data;
print "$rows lines consumed.\n";

		print $ssdr_data "NA,OWNER,GROUP,FREQ,NAME,MODE,STEP,OFFSET_DIRECTION,REPEATER_OFFSET,TONE_MODE,TONE_VALUE,RF_POWER,RX_FILTER_LOW,RX_FILTER_HIGH,HIGHLIGHT,HIGHLIGHT_COLOR\r\n";


foreach my $row (@fields) {;

	#Only process entries within 2M RX range on 6700
	if ( @$row[1] > 135 && @$row[1] < 165 ) {
#		print @$row[4];

		#Munge Offset
		if (@$row[4] eq "Minus") { 
			$offset_direction = "Down" ;
		} elsif (@$row[4] eq "Plus") {  
			$offset_direction = "Up" ; 
		} else {
			$offset_direction = "Simplex" ; 
		}

		#Munge Repeater Offset
		if (@$row[3] =~ /MHz/ ) {
		$repeater_offset = @$row[3] + 0;		
		}
		elsif ( @$row[3] =~ /kHz/ ) {
		$repeater_offset = @$row[3] + 0;
		$repeater_offset = @$row[3] * .001 ;
		}else{
			$repeater_offset = 0 ;
		}
		
		#Munge Tone Mode
		if (@$row[7] =~ /Tone/ || @$row[7] =~ /T Sql/ ) { 
			$tone_mode = "CTCSS_TX" ;
		}else {
			$tone_mode = "Off";	
		}

		#Munge Tone Value
		$tone_value = @$row[8] + 0 ;

		print $ssdr_data "MEMORY,$owner,$group,@$row[1],@$row[6],FM,100,$offset_direction,$repeater_offset,$tone_mode,$tone_value,100,-10000,10000,0,0\r\n";
		
	}
}
close $ssdr_data;

sub usage ()
{
	print STDERR "\nUsage: $0 -f RT Systems CSV File [-o owner] [-g group]\n\n\t-f\t: Exported CSV from RT Systems Programmer\n\t-o\t: Owner of imported Memories [optional]\n\t-g\t: Group name of imported memories [optional]\n\n";
	
}
