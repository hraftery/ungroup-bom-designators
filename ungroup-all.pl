#!/usr/bin/perl
use strict;
use warnings;

use Switch;
use File::Basename; 
use Text::CSV;

my $cmd = fileparse($0, qr/\.[^.]*/);
my $fname = $ARGV[0] or die "Usage: $0 input_file.csv\n\tUse \"-\" as filename to read from stdin.";

my $csv = Text::CSV->new({binary => 1});

# Neither three arg "open" nor OOP use of Text::CSV auto-handle "-", so do it manually
my $fh = undef;
if($fname eq "-"){
	$fh = *STDIN;
}else{
	open($fh, '<:encoding(utf8)', $fname) or die "Could not open '$fname' $!\n";
}

group_references_setup($csv, $fh) if $cmd eq "group-references";

while (my $fields = $csv->getline( $fh ))
{
	switch($cmd)
	{
		case "group-references"	{ group_references_loop($csv, $fields)	}
		case "ungroup-first"	{ ungroup_first_loop($csv, $fields) 	}
		else					{ ungroup_all_loop($csv, $fields)		}
	}
}
close $fh unless $fname eq "-";


###
# subs below
###

sub ungroup_all_loop
{
    my ($csv, $fields) = @_;
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

sub ungroup_first_loop
{
    my ($csv, $fields) = @_;
	my @ungrouped = split(/, /, $fields->[0]);
	foreach(@ungrouped)
	{
        my @row = @$fields; # make a copy
		$row[0] = $_;
        $csv->say(*STDOUT, \@row);
    }
}

sub group_references_setup
{
	my ($csv, $fh) = @_;
    $csv->getline( $fh ); # first line is just "sep=,", skip it
    my $headers = $csv->getline( $fh ); # second line is headers
    unshift(@$headers, "designator");
    $csv->say(*STDOUT, $headers);
}

sub group_references_loop
{
    my ($csv, $fields) = @_;
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
