#!/usr/bin/perl -w
use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $reg = "Bio::EnsEMBL::Registry";
$reg->load_registry_from_url('mysql://anonymous@ensembldb.ensembl.org');

# 3. ex3 Count the number of duplication events in tree of a zebrafish gene
my $gene_member_adaptor = $reg->get_adaptor("Multi", "compara", "GeneMember");

my $gene_tree_adaptor = $reg->get_adaptor("Multi", "compara", "GeneTree");

my $gene_member = $gene_member_adaptor->fetch_by_source_stable_id("ENSEMBLGENE", "ENSDARG00000003399");

my $tree = $gene_tree_adaptor->fetch_default_for_Member($gene_member);

## Tip: will make the traversal of the tree faster
$tree->preload();

## Will iterate over all the nodes of a tree
sub count_duplications_iterative {
    my $root = shift;

    my $n_dup = 0;
    foreach my $node (@{$root->get_all_nodes()}) {
        if ((not $node->is_leaf()) and ($node->get_tagvalue('node_type') eq 'duplication')) {
            print "There is a duplication at the taxon '", $node->get_tagvalue('taxon_name'), "'\n";
            $n_dup++;
        }
    }    
    return $n_dup;
}

## Will call recursively children() to go through all the branches
sub count_duplications_recursive {
    my $node = shift;

    ## Is it a leaf or an internal node ?
    if ($node->is_leaf()) {
        return 0;
    }    
    my $s = 0;
    
    if ($node->get_tagvalue('node_type') eq 'duplication') {
        $s++;
        print "There is a duplication at the taxon '", $node->get_tagvalue('taxon_name'), "'\n";
    }
    
    foreach my $child_node (@{$node->children()}) {
        $s += count_duplications_recursive($child_node);
    }
    
    return $s;
}

print "The tree ", $tree->stable_id(), " contains ", count_duplications_recursive($tree->root), " duplication nodes.\n";
print "The tree ", $tree->stable_id(), " contains ", count_duplications_iterative($tree->root), " duplication nodes.\n";
