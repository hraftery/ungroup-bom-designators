#!/usr/bin/perl
use strict;
use warnings;
 
use Text::CSV;
 
my $fname = $ARGV[0] or die "Usage: $0 input_file.csv\n\tUse \"-\" as filename to read from stdin.";

my $csv = Text::CSV->new({binary => 1});

# Neither three arg "open" nor OOP use of Text::CSV auto-handle "-", so do it manually.
my $fh = undef;
if($fname eq "-"){
	$fh = *STDIN;
}else{
	open($fh, '<:encoding(utf8)', $fname) or die "Could not open '$fname' $!\n";
}

$csv->getline( $fh ); # first line is just "sep=,", skip it
my $headers = $csv->getline( $fh ); # second line is headers
unshift(@$headers, "designator");
$csv->say(*STDOUT, $headers);

while (my $fields = $csv->getline( $fh ))
{
    last if scalar @$fields < 22;
    my $designator = $fields->[1];
    foreach my $i (8..22)
    {
        last if length $fields->[$i] == 0;
        $designator .= ", $fields->[$i]";
    }
    
    unshift(@$fields, $designator);
    $csv->say(*STDOUT, $fields);
}
close $fh unless $fname eq "-";
