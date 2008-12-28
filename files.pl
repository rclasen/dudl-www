#!/usr/bin/perl -w

#
# Copyright (c) 2008 Rainer Clasen
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

use strict;
use Dudl::DB;
use CGI qw( :standard *table );

my $where = param( 'q' );
my $album = param( 'album' );
my $dudl = new Dudl::DB;
my $db = $dudl->db;


if( $album =~ /^\s*\d+\s*$/){
	$where .= " AND " if $where;
	$where .= "album_id = $album ";
}

my $query =
	"SELECT ".
		"f.id, ".
		"f.unit_id, ".
		"trim(u.collection) || u.colnum as unit, ".
		"f.dir || '/' || f.fname as file, ".
		"stor_filename(u.collection,u.colnum,f.dir,f.fname) as path, ".
		"f.broken, ".
		"f.cmnt, ".
		"f.title ".
	"FROM ".
		"stor_file f INNER JOIN ".
		"stor_unit u ON ".
			"f.unit_id=u.id ";
$query .= "WHERE ". $where if $where;
$query .= " ORDER BY ".
	"collection, ".
	"colnum, ".
	"dir, ".
	"fname";

my $head = "stor_file: ";
$head .= $where if $where;

print header,
	start_html($head),
	h1($head),
	start_form,
	"where: ", textfield( 
		-name=>'q',
		-default=>$where,
		-override=>1,
		-size=>80,
	),p,
	submit,
	end_form, p;

my $sth = $db->prepare( $query );
if( ! $sth ){
	print $db->errstr ."\nquery: $query\n";
	exit 1;
}

my $res = $sth->execute;
if( ! $res ){
	print $sth->errstr ."\nquery: $query\n";
	exit 1;
}

my @col = @{$sth->{NAME_lc} };
my %row;
$sth->bind_columns( \( @row{ @col } ));

my $r = 0;
print start_table(), Tr( [ th( [ qw(id unit file broken cmnt )] ) ]);

while( $sth->fetch ){
	if( ! (++ $r % 100) ){
		print end_table(), start_table();
	}

	print "<tr>";
	foreach my $c( @col ){
		if( $c eq "unit_id" ){
		} elsif( $c eq "title" ) {
		} elsif( $c eq "path" ) {
		} elsif( $c eq "unit" ){
			print td( a({href=>"units.pl?q=id=".$row{unit_id}},
				$row{unit}));
		} elsif( $c eq "file" ){
			print td( a({href=>"/dudl/files/". $row{path}}, 
				$row{file}));
		} elsif( $c eq "id" && defined $row{title} ){
			print td( a({href=>"titles.pl?q=t.id=".
				$row{id}}, $row{id}));
		} else {
			print td( $row{$c} );
		}
	}
	print "</tr>";
}       

print end_table(),p, "rows: ", $r;

$sth->finish;
$dudl->done;

