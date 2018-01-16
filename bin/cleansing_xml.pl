#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: cleansing_xml.pl
#
#        USAGE: ./cleansing_xml.pl <xmlfile> 
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Heince Kurniawan
#       EMAIL : heince.kurniawan@itgroupinc.asia
# ORGANIZATION: IT Group Indonesia
#      VERSION: 1.0
#      CREATED: 01/09/18 19:31:23
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Carp;
use v5.10.1;
use XML::LibXML;
use Config::General;
use FindBin qw|$Bin|;

die "Error: XML File Required\n" unless $ARGV[0];

die "Error: $ARGV[0] size exceed 104857600 byte\n" if -s "$ARGV[0]" > 104857600;

my $xml     = XML::LibXML->load_xml(location => $ARGV[0]);
my $conf    = Config::General->new(-ConfigFile => "$Bin/../etc/cleansing.conf", -SplitPolicy => 'equalsign');
my %config  = $conf->getall;
my $state   = 0; # track if this is element with attribute or child, 1 if its already handled as attribute

process_node($xml->documentElement);

open my $fh, '>', $ARGV[0] or die "$!\n";
binmode $fh;
$xml->toFH($fh);
close $fh;

sub process_attribute
{
    my $node = shift;

    if ($node->hasAttributes())
    {
        #say "$node has attribute";

        for my $attr ($node->attributes())
        {
            my $key = get_nodename($node) . ' ' . get_nodename($attr);
            #say "$node key = $key";

            if (exists $config{$key})
            {
                $attr->setValue($config{$key});
                #say "$key detected";
                $state = 1;
            }
        }
    }
}

sub get_nodename
{
    my $node = shift;

    return $node->nodeName;
}

sub process_node 
{
    my $node = shift;
    my $nodename = $node->nodeName;

    process_attribute($node);

    if ($state == 0)
    {
        if (exists $config{$nodename})
        {
            #say $nodename . " detected";
            #say "value = " . $node->nodeValue if $node->nodeValue;
            $node->removeChildNodes();
            $node->appendText($config{$nodename});
        }
    }
        
    $state = 0; # reset back, so the next child node will not be skipped

    #print $node->nodePath, " nodename: ", $node->nodeName, "\n";

    for my $child ($node->childNodes) 
    {
        # Call process_node recursively.
        process_node($child);
    }
}
