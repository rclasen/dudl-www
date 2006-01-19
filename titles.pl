#!/usr/bin/perl -w

use strict;
use Dudl::DB;
use CGI qw( :standard *table );

my $where = param( 'q' );
my $dudl = new Dudl::DB;
my $db = $dudl->db;

my $query =
	"SELECT ".
		"t.id, ".
		"al.artist_id as aa_id, ".
		"ala.nname as a_artist, ".
		"t.album_id as a_id, ".
		"al.album, ".
		"t.album_pos, ".
		"t.artist_id as ta_id, ".
		"ta.nname as t_artist, ".
		"t.title, ".
		"t.cmnt ".
	"FROM ".
		"stor_file t ,".
		"mus_album al, ".
		"mus_artist ala, ".
		"mus_artist ta ".
	"WHERE ".
		"al.artist_id=ala.id AND ".
		"t.album_id=al.id AND ".
		"t.artist_id=ta.id ";
$query .= "AND ". $where if $where;
$query .= " ORDER BY ".
	"lower(ala.nname), ".
	"lower(al.album), ".
	"t.album_pos";

my $head = "stor_file ";
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
print start_table(), Tr( [ th( [ qw( files id aartist album album_pos tartist title cmnt ) ]) ]);

while( $sth->fetch ){
	if( ! (++ $r % 100) ){
		print end_table(), start_table();
	}

	print "<tr>",
		td( a({href=>"files.pl?q=f.id=".$row{id}}, "files"));
	foreach my $c( @col ){
		if( $c eq "a_id" ){
		} elsif( $c eq "album" ){
			print td( a({href=>"albums.pl?q=a.id=".$row{a_id}},
				$row{$c}));
		} elsif( $c eq "ta_id" || $c eq "aa_id" ){
		} elsif( $c eq "t_artist" ){
			print td( a({href=>"artists.pl?q=id=".$row{ta_id}},
				$row{$c}));
		} elsif( $c eq "a_artist" ){
			print td( a({href=>"artists.pl?q=id=".$row{aa_id}},
				$row{$c}));
		} else {
			print td( $row{$c} );
		}
	}
	print "</tr>";
}       

print end_table(),p, "rows: ", $r;

$sth->finish;
$dudl->done;

