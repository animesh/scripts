#!/usr/bin/perl -w

use strict;

my $f_sScript = "renumPdb.pl";
my $f_sUsage = "usage: $f_sScript <sInFile> <iStartSerial> [iStartRes]\n";
my $f_sDescrip = "Renumbers serial numbers [and residue numbers] for ATOM records of a PDB file\n";

# from PDB Spec 2.1

# field format: 'name', 'startCol', 'len'
my @f_atomRecordFields = 
(
	"atomSerial", 	[ 6, 5,],
	"unused1", 		[11, 1,],
	"atomName",		[12, 4,],
	"altLoc",		[16, 1,],
	"resName", 		[17, 3,],
	"unused2", 		[20, 1,],
	"chainId", 		[21, 1,],
	"resSeq", 		[22, 4,],
	"iCode", 		[26, 4,],
	"xCoord", 		[30, 8,],
	"yCoord", 		[38, 8,],
	"zCoord", 		[46, 8,],
	"occup", 		[55, 6,],
	"temp", 		[61, 6,],
	"unused3", 		[67, 6,],
	"segId", 		[73, 4,],
	"element", 		[77, 2,],
	"charge", 		[79, 2,],
);
my %f_atomRecordField = @f_atomRecordFields;

#-------------------------------------------------------------------------------------------------------------------
# GetArfFormat
#
# descrip:
#	'GetAtomRecordField', returns substring from param string that is the field of param name in an ATOM record.
#
# params:
#		my $sFieldName
#
# returns:
#		my $iStartCol
#		my $iFieldLen
#
#-------------------------------------------------------------------------------------------------------------------
sub GetArfFormat
{
	my $sFieldName = shift;

	# get field format
	my $raFmt = $f_atomRecordField{$sFieldName};
	if( !defined( $raFmt ) )
	{
		die "invalid ATOM record field name '$sFieldName'";
	}
	my $iStartCol = $$raFmt[0];
	my $iLen = $$raFmt[1];

	return $iStartCol, $iLen;
}# GetArfFormat

#-------------------------------------------------------------------------------------------------------------------
# GetArf
#
# descrip:
#	'GetAtomRecordField', returns substring from param string that is the field of param name in an ATOM record.
#
# params:
#		my $sRecord = ATOM record
#		my $sFieldName
#
# returns:
#		my $sFieldValue or die
#
#-------------------------------------------------------------------------------------------------------------------
sub GetArf
{
	my $sRecord = shift;
	my $sFieldName = shift;

	# get field format
	my ($iStartCol, $iLen ) = GetArfFormat( $sFieldName );

	# validate that record is big enough to hold the field
	if( length( $sRecord ) <= $iStartCol )
	{
		die "record ends before start of field $sFieldName";
	}

	# extract field value
	my $sVal = substr( $sRecord, $iStartCol, $iLen ); 

	# validate field value length
	if( length( $sVal ) != $iLen )
	{
		die "value is too short for field $sFieldName";
	}

	return $sVal;
}# GetArf

#-------------------------------------------------------------------------------------------------------------------
# SubAtomRecordFields
#
# descrip:
#		Reads all ATOM records in param file, substitutes atom serial nums and residue nums, starting
#		with param values.
#
# params:
#		$sFile
#		$iSerialStart
#		$iResStart
#
# returns:
#
# notes:
#		Prints all PDB file lines, including modified atom record lines, to stdout.
#		
#		If $iResStart == -1, then the residue numbers will not be changed.
#
#-------------------------------------------------------------------------------------------------------------------
sub SubAtomRecordFields
{
	my $sFile = shift;
	my $iSerialStart = shift;
	my $iResStart = shift;

	open( FIN, "<$sFile" ) or die "Error: failed opening file '$sFile' for input";

	my $iNewSerial = $iSerialStart;
	my $iNewResNumOffset;

	my $iAtomRecord = -1;
	my $sLine;
	while( $sLine = <FIN> )
	{
		# skip non-ATOM and non-HETATM records
		if( !($sLine =~ /^ATOM/ ) and !($sLine =~ /^HETATM/ ))
		{
			print( $sLine );
			next;
		}
#		my $iSerial = GetArf( $sLine, "atomSerial" );
#		print( "Read serial $iSerial\n" );

		++$iAtomRecord;

		# get current serial and res num
		my $iOldSerial = GetArf( $sLine, "atomSerial" );
		my $iOldResNum = GetArf( $sLine, "resSeq" );

		# set res num offset at first atom record
		if( $iAtomRecord == 0 )
		{
			$iNewResNumOffset = $iOldResNum - $iResStart;
		}

		# substitute atom serial
		my $sFld = "atomSerial";
		my ($iStartCol, $iLen ) = GetArfFormat( $sFld );
		my $sFmt = "%${iLen}d";
		my $sNewSerial = sprintf( $sFmt, $iNewSerial++ );
		my $sPre = substr( $sLine, 0, $iStartCol );
		my $sPost = substr( $sLine, $iStartCol + $iLen );
		my $sNewRecord = $sPre . $sNewSerial . $sPost;

		# substitute res num
		if( $iResStart != -1 )
		{
			my $iNewResNum = $iOldResNum - $iNewResNumOffset;
			if( $iNewResNum <= 0 )
			{
				die "Error: orign atom serial $iOldSerial: got negative new residue sequence number, orig num = $iOldResNum, new start num = $iResStart";
			}
			$sFld = "resSeq";
			($iStartCol, $iLen ) = GetArfFormat( $sFld );
			$sFmt = "%${iLen}d";
			my $sNewResNum = sprintf( $sFmt, $iNewResNum );
			$sPre = substr( $sNewRecord, 0, $iStartCol );
			$sPost = substr( $sNewRecord, $iStartCol + $iLen );
			$sNewRecord = $sPre . $sNewResNum . $sPost;
		}

		# output new record
		print( $sNewRecord );
	}
	close( FIN );

}# SubAtomRecordFields

#-------------------------------------------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------------------------------------------

	if( @ARGV < 2 ) 
	{
		print( $f_sUsage . $f_sDescrip );
		exit( 0 );
	}

	my $sFile = shift;
	my $iStartSerial = shift;

	my $iStartRes = -1;
	if( @ARGV )
	{ 
		$iStartRes = shift;
	}

	SubAtomRecordFields( $sFile, $iStartSerial, $iStartRes );
		
