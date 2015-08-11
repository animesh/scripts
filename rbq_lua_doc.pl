# !/usr/bin/perl

# rbq_lua_doc.pl	:	script to scan the cpp source file which holds the rbq - lua interface functions and create html documentation from it.

# history
#
# Date			Author		Version		Descrip
# 2003-04-15	WK			001			Created. It works.
# 2003-04-15	WK						Modified group section so it supports multiple groups.

# note: refer to associated lua_lib_doc.pl for better documentation of the subroutines (they are similar to the ones in this file)

use strict;

	my $f_sScriptName = "rbq_lua_doc.pl";
	my @f_fiTags = ( "descrip", "params", "returns", "notes", "seealso", "group" );
	my $f_iCurLine = 0;
	my %f_group = ();
	my $f_sHdrFile = "~rbq_lua_hdr.tmp";
	my $f_sIndexFile = "~rbq_lua_index.tmp";
	my $f_sMainFile = "~rbq_lua.tmp";
	my $f_sFtrFile = "~rbq_lua_ftr.tmp";
	my $f_sOutFile = "rbq_lua.html";
#	my $f_sCopyCmd = "copy $f_sOutFile ..\\..\\doc\\html";
	my $f_out;

#-----------------------------------------------------------------------------------------------------------------
# IsCommentTag
#-----------------------------------------------------------------------------------------------------------------
sub IsCommentTag
	{
	my $sTag = shift;

	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
		{
		if( $sTag eq $f_fiTags[$iTag] )
			{ return 1; }
		}
	return 0;
	}# IsCommentTag

#-----------------------------------------------------------------------------------------------------------------
# GetTagIndex
#-----------------------------------------------------------------------------------------------------------------
sub GetTagIndex
	{
	my $sTag = shift;
	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
		{
		if( $sTag eq $f_fiTags[$iTag] )
			{ return $iTag; }
		}
	return -1;
	}# GetTagIndex

#-----------------------------------------------------------------------------------------------------------------
# ClearFuncInfo
#-----------------------------------------------------------------------------------------------------------------
sub ClearFuncInfo
{
	my $hrFuncInfo = shift;

	# clear tag contents
	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
	{
		my $sTag = $f_fiTags[$iTag];
		$$hrFuncInfo{$sTag} = undef;
	}

	# set current tag position
	$$hrFuncInfo{'iCurTag'} = -1;

}# ClearFuncInfo

#-----------------------------------------------------------------------------------------------------------------
# HtmlSub
#
# descrip:
#		Substitutes certain characters with special meaning in HTML unless escaped.  In this case, the
#		definition of escaping is to repeat the character. 
#		Example: '<' will be substituted to '&lt;' unless followed by another '<', in which case the second
#		character is dropped:
#
#			'<' 	=> 	'&lt;'
#			'<<' 	=> 	'<'
#
#-----------------------------------------------------------------------------------------------------------------
sub HtmlSub
{
	my $sContent = shift;
	my $sContentRet = "";

	my 	%subChars = 
		( 
			'<' =>  "&lt;", 
			'>' =>  "&gt;", 
		);
	my $iLen = length( $sContent );
	my $iChar;
	for( $iChar = 0; $iChar < $iLen; ++$iChar )
	{
		my $sChar = substr( $sContent, $iChar, 1 );

		# check if char has a substition
		my $sSub = $subChars{$sChar};
		if( $sSub )
		{
			# check for escape of character substitution
			if( ($iChar < $iLen - 1) && (substr( $sContent, $iChar + 1, 1 ) eq $sChar))
			{
				$sContentRet = $sContentRet . $sChar;
				++$iChar;
				next;
			}

			$sContentRet = $sContentRet . $sSub;
		}
		else
		{
			$sContentRet = $sContentRet . $sChar;
		}
	}

	return $sContentRet;
}# HtmlSub

#-----------------------------------------------------------------------------------------------------------------
# ScanCommentBlockLine
#
# Inside of a comment block, we expect either a tag line or tag content lines which follow the tag line.
# Content lines are appended to a string associated with the current tag.  The current tag is determined
# as the most recent defined tag in the hash, as ordered by the array of tag names in f_fiTags.
#
#-----------------------------------------------------------------------------------------------------------------
sub ScanCommentBlockLine
{
	my $hrFuncInfo = shift;
	my $sLine = shift;

	# get rid of CR
	$sLine =~ s/\r//;
	$sLine =~ s/\n//;

	# get first word after comment
	my ($f1, $f2 ) = split( ' ', $sLine, 2 );
	
	# if empty line, we're done
	if( !defined( $f2 ))
		{ return; }

	# check for tag word
	if( $f2 =~ /:$/ )
	{
		# get tag
		my $sTag = substr( $f2, 0, length( $f2 ) - 1 );
		if( !IsCommentTag( $sTag ))
			{ die( "Error: invalid comment tag '$sTag' found on line $f_iCurLine" ); }

		# get tag idx
		my $iTagIdx = GetTagIndex( $sTag );
		if( $iTagIdx < 0 )
			{ die( "Error: failed getting index for tag '$sTag'" ); }

		# make sure tag is in order
		my $iCurTagIdx = $$hrFuncInfo{'iCurTag'};
		if( $iTagIdx != $iCurTagIdx + 1 )
			{ die( "Error: out-of-order tag found: curTagIdx=$iCurTagIdx, newTagIdx=$iTagIdx" ); }

		# make sure current tag contents is defined before going to next tag
		if( $iCurTagIdx >= 0 )
		{
			my $sCurTag = $f_fiTags[$iCurTagIdx];
			if( !defined( $$hrFuncInfo{$sCurTag} ))
				{ die( "Error: current tag '$sCurTag' contents are not defined" ); }
		}

		# set new current tag idx 
		$$hrFuncInfo{'iCurTag'} = $iTagIdx;
		# set empty tag contents
		$$hrFuncInfo{$sTag} = "";
		return;
	}# end if tag word

	# add stripped line to tag contents
	my $iCurTagIdx = $$hrFuncInfo{'iCurTag'};
	if( $iCurTagIdx < 0 )
		{ return; }
	my $sCurTag = $f_fiTags[$iCurTagIdx];
	my $sEol = " ";
	if( ($sCurTag eq "params") or ($sCurTag eq "returns") )
		{ $sEol = " <br>"; }

	my $sContent = $f2;

	# add hrefs for 'seealso' line
	if( $sCurTag eq "seealso" )
	{
		$sContent =~ s/(\w+)(\(\))/<a href=\"#$1\">$&<\/a>/g;
	}

	# in 'notes' section, do html subs except for escaped chars
	if( $sCurTag eq "notes" )
	{
		$sContent = HtmlSub( $sContent );
	}

	# add line to current tag content
	$$hrFuncInfo{$sCurTag} = $$hrFuncInfo{$sCurTag} . $sContent . $sEol;

}# ScanCommentBlockLine

#-----------------------------------------------------------------------------------------------------------------
# EndCommentBlock
#-----------------------------------------------------------------------------------------------------------------
sub EndCommentBlock
	{
	my $hrFuncInfo = shift;

	my $sFuncName = $$hrFuncInfo{'name'};

	print( $f_out "<hr><h2><a name=\"$sFuncName\">$sFuncName</a></h2>\n" );
	# check for undefined tag info
	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
		{
		my $sTag = $f_fiTags[$iTag];
		if( !defined( $$hrFuncInfo{$sTag} ))
			{
			die( "Error: function info tag '$sTag' is not defined for function $sFuncName" );
			}
		# skip group content
		if( $sTag eq "group" )
			{ next; }
		my $sContent = $$hrFuncInfo{$sTag};
		print( $f_out "<h3>$sTag</h3>\n" );
		print( $f_out "$sContent\n" );
		}

	# add func name to 'all' list
	my $raAllList = $f_group{"All"};
	push( @$raAllList, $sFuncName );

	# get group names
	my $sGroupContent = $$hrFuncInfo{'group'};
	$sGroupContent =~ s/\s+//g;
	# check for empty content
	if( !defined( $sGroupContent ) || length( $sGroupContent ) < 1 )
		{ 
		die( "Error: group content not defined for function $sFuncName" );
		}
	# add func name to each group in section
	my @groups = split( ',', $sGroupContent );
	my $sGroup;
	foreach $sGroup (@groups)
		{
		my $raGroupList = $f_group{$sGroup};
		# allocate list if needed
		if( !defined( $raGroupList ))
			{
			my @funcList = ( $sFuncName );
			$f_group{$sGroup} = \@funcList;
			$raGroupList = $f_group{$sGroup};
			}
		else
			{ push( @$raGroupList, $sFuncName ); }
		}

	}# EndCommentBlock

#-----------------------------------------------------------------------------------------------------------------
# OutputHtmlHeader
#-----------------------------------------------------------------------------------------------------------------
sub OutputHtmlHeader
	{
	my $sDate = localtime();
	my $sTitle = "Index of Rbq - Lua Interface Functions";
	my $iTotalFuncs = shift;

	open( $f_out, ">$f_sHdrFile" ) or die( "Error: failed opening file '$f_sHdrFile' for output" );
	print( $f_out "<html>\n" );
	print( $f_out "<head>\n" );
	print( $f_out "<title>$sTitle</title>\n" );
	print( $f_out "<link rel=stylesheet type=\"text/css\" href=\"style.css\">\n" );
	print( $f_out "</head>\n" );
	print( $f_out "<body>\n" );
	print( $f_out "<div align=right><a href=\"index.html\">[Up]</a></div>\n" );
	print( $f_out "<center>\n" );
	print( $f_out "<h1>$sTitle</h1>\n" );
	print( $f_out "<h3>$iTotalFuncs total function(s)</h3>\n" );
	print( $f_out "<h4>last updated $sDate</h4>\n" );
	print( $f_out "<!-- generated by $f_sScriptName -->\n" );
	print( $f_out "</center>\n" );

	close( $f_out );
	}# OutputHtmlHeader

#-----------------------------------------------------------------------------------------------------------------
# OutputHtmlFooter
#-----------------------------------------------------------------------------------------------------------------
sub OutputHtmlFooter
	{
	open( $f_out, ">$f_sFtrFile" ) or die( "Error: failed opening file '$f_sFtrFile' for output" );
	print( $f_out "</body>\n" );
	print( $f_out "</html>\n" );
	close( $f_out );
	}# OutputHtmlFooter

#-----------------------------------------------------------------------------------------------------------------
# GetAlphaLetter
#-----------------------------------------------------------------------------------------------------------------
sub GetAlphaLetter
	{
	my $sFunc = shift;
	return substr( $sFunc, 4, 1 );
	}# GetAlphaLetter

#-----------------------------------------------------------------------------------------------------------------
# PrintGroupIndex
#-----------------------------------------------------------------------------------------------------------------
sub PrintGroupIndex
	{
	my $sGroup = shift;
	my $raGroupList = shift;

	# build a table with N columns
	my $iTotalCols = 4;
	my @table;
	my $iCol;
	my $iRow;
	for( $iCol = 0; $iCol < $iTotalCols; ++$iCol )
		{
		my @col = ();
		push( @table, \@col );
		}

	# build column lists
	my $sCurAlpha = "";
	my $iFunc = 0;
	my $iTotalFuncs = scalar( @$raGroupList );
	my $iTotalRows = $iTotalFuncs / $iTotalCols;
COL_LOOP:	
	for( $iCol = 0; $iCol < $iTotalCols; ++$iCol )
		{
		my $raCol = $table[$iCol];
		for( $iRow = 0; $iRow < $iTotalRows; ++$iRow )
			{
			# skip rest of column if no more funcs
			if( $iFunc >= $iTotalFuncs )
				{ last COL_LOOP; }
			my $sFunc = $$raGroupList[$iFunc];
			++$iFunc;

			# hack: append alpha letter to func name if new alpha letter
			my $sAlpha = GetAlphaLetter( $sFunc );
			if( $sAlpha ne $sCurAlpha )
				{
				$sFunc = $sFunc . " $sAlpha";
				$sCurAlpha = $sAlpha;
				}

			# add func to col list
			push( @$raCol, $sFunc );
			}
		}

	# output table
	print( $f_out "<hr>\n<h2><a name=\"$sGroup index\">$sGroup Functions</a></h2>\n" );
	print( $f_out "<table>\n" );	
	for( $iRow = 0; $iRow < $iTotalRows; ++$iRow )
		{
		print( $f_out "<tr>\n" );
		for( $iCol = 0; $iCol < $iTotalCols; ++$iCol )
			{
			my $sAlphaLetter = "";
			my $sFunc = "";
			my $raCol = $table[$iCol];
			if( @$raCol > $iRow ) 
				{ 
				$sFunc = $$raCol[$iRow]; 

				# strip alpha letter from func name if any
				my $al;
				($sFunc, $al) = split( ' ', $sFunc );
				if( $al )
					{ $sAlphaLetter = "<b>" . $al . "</b>"; }
				}
			printf( $f_out "<td>$sAlphaLetter<td><a href=\"#$sFunc\">$sFunc</a> " );
			}
		}
	print( $f_out "</table>\n" );	

=old_list
	print( $f_out "<hr>\n<h2><a name=\"$sGroup index\">$sGroup Functions</a></h2>\n" );
	print( $f_out "<ul>\n" );	
	my $iFunc;
	my $iTotalFuncs = scalar( @$raGroupList );
	for( $iFunc = 0; $iFunc < $iTotalFuncs; ++$iFunc )
		{
		my $sFunc = $$raGroupList[$iFunc];
		print( $f_out "<li><a href=\"#$sFunc\">$sFunc</a>\n" );
		}
	print( $f_out "</ul>\n" );	
=cut

	}# PrintGroupIndex

#-----------------------------------------------------------------------------------------------------------------
# OutputIndexFile
#-----------------------------------------------------------------------------------------------------------------
sub OutputIndexFile
	{
	open( $f_out, ">$f_sIndexFile" ) or die( "Error: failed opening file $f_sIndexFile for output" );

	my @groupNames;
	my @groups = keys( %f_group );
	@groups = sort( @groups );

	# create top-level list
	print( $f_out "<h2>Function Categories</h2>\n" );
	print( $f_out "<ul>\n" );
	my $g;
	foreach $g ( @groups )
		{
		print( $f_out "<li><a href=\"#$g index\">$g Functions</a>\n" );
		}
	print( $f_out "</ul>\n" );

	# output each group list
	foreach $g ( @groups )
		{
		my $raGroupList = $f_group{$g};
		PrintGroupIndex( $g, $raGroupList );
		}

	close( $f_out );

	}# OutputIndexFile

#-----------------------------------------------------------------------------------------------------------------
# OutputFile
#-----------------------------------------------------------------------------------------------------------------
sub OutputFile
	{
	my $sInfile = shift;
	open( FIN, "<$sInfile" ) or die( "Error: failed opening file $sInfile for input" );
	my $sLine;
	while( $sLine = <FIN> )
		{
		print( $f_out $sLine );
		}
	close( FIN );
	}# OutputFile

#-----------------------------------------------------------------------------------------------------------------
# ConcatFiles
#-----------------------------------------------------------------------------------------------------------------
sub ConcatFiles
	{

	# open outfile
	open( $f_out, ">$f_sOutFile" ) or die( "Error: failed opening file $f_sOutFile for output" );
	
	OutputFile( $f_sHdrFile );
	OutputFile( $f_sIndexFile );
	OutputFile( $f_sMainFile );
	OutputFile( $f_sFtrFile );

	close( $f_out );

	}# ConcatFiles

#-----------------------------------------------------------------------------------------------------------------
# main
#-----------------------------------------------------------------------------------------------------------------
	if( @ARGV < 1 )
	{
		printf( "usage: $f_sScriptName <cppFile>\n" );
		printf( "\n" );
		printf( "scans cpp file with rbq - lua interface functions and creates html docs\n" );
		exit( 0 );
	}

	# init 'all' list in group hash
	my @allFuncsList = ( );
	$f_group{"All"} = \@allFuncsList;

	my $bInCommentBlock = 0;
	my %funcInfo;
	
	my $iTotalFuncs = 0;
	my $sCppFile = shift;
	my $sLine;

	$f_out = *FOUT;

	# reference FOUT again to get rid of stupid warning
	my $duh = *FOUT;

	# open infile
	open( FIN, "<$sCppFile" ) or die( "Error: failed opening file $sCppFile for input" );

	# open outfile
	open( $f_out, ">$f_sMainFile" ) or die( "Error: failed opening file $f_sMainFile for output" );

	# process each line in file
	while( $sLine = <FIN> )
	{
		++$f_iCurLine;

		# trim leading ws
		$sLine =~ s/^\s+//;

		# format: function documentation block begins with '// rbq_'
		# followed by '// descrip', '// params', etc.

		my $bCommentLine = ( $sLine =~ /^\/\// );

		# check for start of comment block
		if( $sLine =~ /^\/\/ rbq_/ )
		{
			# make sure not already in a comment block
			if( $bInCommentBlock) 
				{ die( "Error: found start of comment block while already in a comment block at line $f_iCurLine" ); }

			++$iTotalFuncs;
			$bInCommentBlock = 1;

			my ($f1, $f2) = split( ' ', $sLine );
			if( not defined( $f2 ))
				{ die( "Error: failed parsing function name on line $f_iCurLine" ); }

			ClearFuncInfo( \%funcInfo );
			$funcInfo{'name'} = $f2;
		}
		# check for end of comment block
		elsif( $bInCommentBlock && !$bCommentLine )
		{
			EndCommentBlock( \%funcInfo );
			$bInCommentBlock = 0;
		}
		# scan comment block lines
		elsif( $bInCommentBlock )
		{
			ScanCommentBlockLine( \%funcInfo, $sLine );
		}
		
	}# end for all lines in file

	close( $f_out );
	close( FIN );

	printf( "$f_iCurLine line(s) read, $iTotalFuncs function(s) processed.\n" );

	# output index file
	OutputIndexFile();

	# output html files
	OutputHtmlHeader( $iTotalFuncs );
	OutputHtmlFooter();

	# combine hdr, index and main and ftr files
	ConcatFiles();

	# delete intermediate files

	# report
	printf( "Rbq-Lua html documentation output to '$f_sOutFile'\n" );

	# copy to dst
#	my $rc = system( $f_sCopyCmd );
#	if( $rc != 0 )
#		{
#		print( "Error: system command '$f_sCopyCmd' failed\n" );
#		}

