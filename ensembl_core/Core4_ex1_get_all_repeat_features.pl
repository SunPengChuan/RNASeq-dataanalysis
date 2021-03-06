#!/usr/bin/perl -w
use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
        -host =>'ensembldb.ensembl.org',
        -user => 'anonymous'
        );

my $slice_adaptor = $registry->get_adaptor('Human', 'Core', 'Slice');

# get repeat features for first 500k on chr20
my $slice = $slice_adaptor->fetch_by_region('chromosome', '20', 1, 500000);
my @repeats = @{$slice->get_all_RepeatFeatures};

for my $rep (@repeats){
    print $rep->display_id. "\t";
    print $rep->start, " - ", $rep->end, "\n";
}
print "There are a total of ", scalar(@repeats), " repeat features.\n\n";
