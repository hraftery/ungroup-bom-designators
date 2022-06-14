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
	my @ungrouped_fields = map {my @s = split /, /; \@s} @$fields;
    my $group_i = 0;
	foreach(@{$ungrouped_fields[0]})
	{
        my @row;
        push(@row, $_);
		foreach(@ungrouped_fields[1 .. $#ungrouped_fields])
        {
            my @deref = @$_;
            my $field = ($#deref > $group_i) ? $deref[$group_i] : $deref[-1];
            $field =~ s/`/,/g if $field;
            push(@row, $field);
        }
        $group_i++;

        $csv->say(*STDOUT, \@row);
    }
}
close $fh unless $fname eq "-";
