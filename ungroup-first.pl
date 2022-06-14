#!/usr/bin/perl
use strict;
use warnings;
 
use Text::CSV;
 
my $fname = $ARGV[0] or die "Usage: $0 input_file.csv\n\tUse \"-\" as filename to read from stdin.";

my $csv = Text::CSV->new({binary => 1});

# Neither three arg "open" nor OOP use of Text::CSV auto-handle "-", so do it manually
my $fh = undef;
if($fname eq "-"){
	$fh = *STDIN;
}else{
	open($fh, '<:encoding(utf8)', $fname) or die "Could not open '$fname' $!\n";
}

while (my $fields = $csv->getline( $fh ))
{
	my @ungrouped = split(/, /, $fields->[0]);
	foreach(@ungrouped)
	{
        my @row = @$fields; # make a copy
		$row[0] = $_;
        $csv->say(*STDOUT, \@row);
    }
}
close $fh unless $fname eq "-";
