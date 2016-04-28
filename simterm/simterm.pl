#!/usr/bin/perl

# The MIT License (MIT)
#
# Copyright (c) 2016 Veit Jahns
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
use warnings;

use String::Similarity;
use Text::CSV;

my @myTerms = ();
my @allTerms = ();

my $csv = Text::CSV->new({binary => 1}) or die Text::CSV->error_diag();
my $counter = 0;

open my $btv, "<:encoding(utf8)", "btv.csv" or die $!;
while (my $row = $csv->getline($btv)) {
	push @allTerms, $row->[0];
	push @myTerms, $row->[0] if $counter > 700 and $counter < 752;
	$counter++;
}
close $btv;

my @columnNames = ();
@columnNames = @myTerms;
unshift @columnNames, "Other Terms";

open my $out, ">:encoding(utf8)", "simbtv.csv" or die $!;

$csv = Text::CSV->new({binary => 1}) or die Text::CSV->error_diag();
$csv->eol("\r\n");
$csv->print($out, \@columnNames);

foreach my $otherTerm (@allTerms) {
	my @row = ();
	push @row, $otherTerm;
	foreach my $myTerm (@myTerms) {
		push @row, similarity $myTerm, $otherTerm;
	}
	$csv->print($out, \@row);
}
close $btv;
