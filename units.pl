#!/usr/bin/perl -w

use strict;
use Dudl::DB;
use CGI qw( :standard *table );

my $where = param( 'q' );
my $dudl = new Dudl::DB;
my $db = $dudl->db;

my $query =
	"SELECT ".
		"* ".
	"FROM ".
		"stor_unit ";
$query .= "WHERE ". $where if $where;
$query .= " ORDER BY ".
	"collection, ".
	"colnum";

my $head = "stor_unit: ";
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
print start_table(), Tr( [ th( [ "files", @col ]) ]);

while( $sth->fetch ){
	if( ! (++ $r % 100) ){
		print end_table(), start_table();
	}

	print "<tr>",
		td( a({href=>"files.pl?q=unit_id=".$row{id}},"files"));
	foreach my $c( @col ){
		print td( $row{$c} );
	}
	print "</tr>";
}       

print end_table(),p, "rows: ", $r;

$sth->finish;
$dudl->done;

