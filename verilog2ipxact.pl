#!/usr/bin/perl

use strict;
use Verilog::Netlist;
# http://search.cpan.org/~wsnyder/Verilog-Perl-3.316/Parser/Parser.pm
# http://www.veripool.org/projects/verilog-perl/wiki/Manual-verilog-perl

# User Define
my $INTEG = 1; # if $INTEG = 0 output tsetbench template

my @FileList = ('aq_axi4ls.v');
my $IntegModule = 'test_integ';

#
#vendor
#library
#name
#version
#busInterface
#model
#choices
#fileSets
#description
#parameters
#vendorExtensions

# 
my $VenderName = 'aquaxis';
my $LibraryName = 'ip';
my $IpName = 'aq_axi4ls';
my $Version = '1.0';
my @Model = ($VenderName, $LibraryName, $IpName, $Version);

# Main
my $NetList = new Verilog::Netlist;
ReadVerilogFiles($NetList, \@FileList);

PrintIPXACT($NetList, \@Model);

#PrintModuleHead($NetList, $IntegModule);
#PrintPortsDefine($NetList);
#PrintInstance($NetList);

exit(0);

############################################################
# Read Verilog File
sub ReadVerilogFiles {
    my ($netlist, $r_filelist) = @_;

    foreach my $file (@{$r_filelist}) {
	$netlist->read_file(filename=>$file);
    }

    $netlist->link(); # connection resolve
}

############################################################
# Output IP-XACT
sub PrintIPXACT {
    my ($netlist, $model) = @_;

    print @{$model}[0]."\n";
}

#
sub PrintModuleHead {
    my ($netlist, $integmodule) = @_;

    print "module $integmodule";
    if ($INTEG) { print " (\n"; }
    else { print ";\n" }

    return if (!$INTEG);

    my @ports;
    foreach my $module ($netlist->modules_sorted) {
	push(@ports, $module->ports_sorted);
    }

    for (my $index=0; $index < $#ports; $index++) {
	print ' 'x4, $ports[$index]->name, ",\n";
    }
    print ' 'x4, $ports[$#ports]->name, ",\n";

    print ");\n";
}

#
sub PrintPortsDefine {
    my ($netlist) = @_;

    my @ports;
    foreach my $module ($netlist->modules_sorted) {
	push(@ports, $module->ports_sorted);
    }

    print "\n";
    for (my $index=0; $index <= $#ports; $index++) {
# direction
	if ($ports[$index]->direction eq 'in') {
	    if ($INTEG) { print ' 'x4,"input";}
	    else { print ' 'x4,"reg";}
	} else {
	    if ($INTEG) { print ' 'x4,"output ";}
	    else { print ' 'x4,"wire ";}
	}
# msb/lsb
	if (defined($ports[$index]->net->width)){
	    print '[',$ports[$index]->net->msb;
	    print ':',$ports[$index]->net->lsb,'] ';
	} else {
	    print ' 'x6;
	}
# port name
	print $ports[$index]->name,";\n";
    }

}

#
sub PrintInstance {
    my ($netlist) = @_;

    foreach my $module ($netlist->modules_sorted) {
	print "\n";
	print ' 'x4, $module->name,' ', $module->name, " (\n";

	my @ports = $module->ports_sorted;
	for (my $index=0; $index <= $#ports; $index++) {
	    print ' 'x8, '.', $ports[$index]->name;
	    print ' ( ', $ports[$index]->name, ' )';
	    if ($index != $#ports) {
		print ",\n";
	    } else {
		print "\n";
	    }
	}

	print ' 'x4,");\n";
    }

    print "\n";
    print "endmodule\n";
}
