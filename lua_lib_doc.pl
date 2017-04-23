# !/usr/bin/perl

# lua_lib_doc.pl	:	script to scan the system script files in the lua subdir which holds the utility functions and create html documentation from them.

# history
#
# Date			Author		Version		Descrip
# 2003-04-15	WK			001			Created from rbq_lua_doc.pl. It works.
# 2003-08-17	WJ			002			Added html substitution for '<' and '>'

use strict;

# --- module vars

	# name of this script
	my $f_sScriptName = "lua_lib_doc.pl";

	# tags which can be used in a function documentation block
	my @f_fiTags = ( "descrip", "params", "returns", "notes", "seealso", "groups" );

	# required doc tags
	my @f_fiRequiredTags = ( "descrip", "params", "returns" );

	# counter for current input file line
	my $f_iCurLine = 0;

	# list of category names (used to build function indexes)
	my %f_group = ();

	# intermediate output - header html file
	my $f_sHdrFile = "~lua_lib_hdr.tmp";

	# intermediate output - index html file
	my $f_sIndexFile = "~lua_lib_index.tmp";

	# intermediate output - main function doc html file
	my $f_sMainFile = "~lua_lib.tmp";

	# intermediate output - footer html file
	my $f_sFtrFile = "~lua_lib_ftr.tmp";

	# final output file
	my $f_sOutFile = "lua_lib.html";

	# command to update rbq doc/html dir
#	my $f_sCopyCmd = "copy $f_sOutFile ..\\..\\doc\\html";

	# module handle to current output file
	my $f_out;

	# current src file being processed
	my $f_sCurSrcFile;

	# base name of lua src file, used in 'include' section of function block
	my $f_sIncludeFile;

#-----------------------------------------------------------------------------------------------------------------
# Find
#-----------------------------------------------------------------------------------------------------------------
sub Find
{
	my $ra = shift;
	my $sFindItem = shift;
	my $i;
	for( $i = 0; $i < @$ra; ++$i )
	{
		my $sItem = $$ra[$i];
		if( $sItem eq $sFindItem )
			{ 
			return $i; 
			}
	}
	return undef;
}# Find

#-----------------------------------------------------------------------------------------------------------------
# IsDocTag
#
# Returns true if param string is one of the documentation tags (as listed in @f_fiTags).
#
#-----------------------------------------------------------------------------------------------------------------
sub IsDocTag
	{
	my $sTag = shift;

	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
		{
		if( $sTag eq $f_fiTags[$iTag] )
			{ return 1; }
		}
	return 0;
	}# IsDocTag

#-----------------------------------------------------------------------------------------------------------------
# IsRequiredTag
#
# Returns true if param string is one of the required documentation tags (as listed in @f_fiRequiredTags).
#
#-----------------------------------------------------------------------------------------------------------------
sub IsRequiredTag
	{
	my $sTag = shift;

	my $iTag;
	for( $iTag = 0; $iTag < @f_fiRequiredTags; ++$iTag )
		{
		if( $sTag eq $f_fiRequiredTags[$iTag] )
			{ return 1; }
		}
	return 0;
	}# IsRequiredTag

#-----------------------------------------------------------------------------------------------------------------
# GetTagIndex
#
# Returns the position of the named tag in the list of documentation tags (@f_fiTags).
#
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
# GetGroupNameFromFile
#
# Returns name of function category based upon lua source file name.
# 
# File name assumed to have the format XXXXUtil.lua where XXXX is the group name.
#
#-----------------------------------------------------------------------------------------------------------------
sub GetGroupNameFromFile
	{
	my $sSrcFile = shift;
	return substr( $sSrcFile, 0, length( $sSrcFile ) - 8 );
	}# GetGroupNameFromFile

#-----------------------------------------------------------------------------------------------------------------
# ClearFuncInfo
#
# Initializes the param hash to an empty state. The hash hold doc info about a particular function.
#
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
# IsTag
#-----------------------------------------------------------------------------------------------------------------
sub IsTag
{
	my $f2 = shift;
	if( ! ($f2 =~ /:$/ ))
		{ return 0; }
	my ($f2nc) = ($f2 =~ /(.+):$/);
	my @toks = split( /\s+/, $f2nc );
	if( @toks != 1 )
		{ return 0; }
	my $tok = $toks[0];
	return IsDocTag( $tok );
}# IsTag

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
# as the most recently defined tag in the hash, as ordered by the array of tag names in f_fiTags.
#
#-----------------------------------------------------------------------------------------------------------------
sub ScanCommentBlockLine
{
	my $hrFuncInfo = shift;
	my $sLine = shift;

	# get rid of CR
	$sLine =~ s/\r//;
	$sLine =~ s/\n//;

	# get line contents after comment comment char at start of line
	my ($f1, $f2 ) = split( /\s+/, $sLine, 2 );
	
	# if empty line, we're done
#	if( !defined( $f2 ))
#		{ return; }

	# if nothing after '--' token, set f2 to empty string
	if( !defined( $f2 ))
		{ $f2 = ""; }

	# check for single tag word 
#	if( $f2 =~ /:$/ )
	if( IsTag( $f2 ))
	{
		# get tag (skip preceding comment chars on line)
		my $sTag = substr( $f2, 0, length( $f2 ) - 1 );

		# check for valid tag (note: if some other word appears first on a line is followed by ':', this error will occur)
		if( !IsDocTag( $sTag ))
			{ die( "Error: invalid comment tag '$sTag' found on line $f_iCurLine in file $f_sCurSrcFile" ); }

		# get tag idx
		my $iTagIdx = GetTagIndex( $sTag );
		if( $iTagIdx < 0 )
			{ die( "Error: failed getting index for tag '$sTag'" ); }

		# make sure tag is in order
		my $iCurTagIdx = $$hrFuncInfo{'iCurTag'};
		if( $iTagIdx != $iCurTagIdx + 1 )
		{ 
			my $sMissingTag = $f_fiTags[$iCurTagIdx + 1];
			die( "Error: out-of-order tag found: curTagIdx=$iCurTagIdx, newTagIdx=$iTagIdx, curSrcFile=$f_sCurSrcFile. Did you forget the intermediate tag '$sMissingTag'?" ); 
		}

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
	}# end if tag line

	my $sContent = $f2;
=cut
	# do html substitutions for single '<' and '>'
	$sContent =~ s/</&lt;/g;
	$sContent =~ s/>/&gt;/g;

	# hack hack hack!
	$sContent =~ s/&lt;li&gt;/<li>/g;
	$sContent =~ s/&lt;ol&gt;/<ol>/g;
	$sContent =~ s/&lt;ul&gt;/<ul>/g;
	$sContent =~ s/&lt;\/ol&gt;/<\/ol>/g;
	$sContent =~ s/&lt;\/ul&gt;/<\/ul>/g;
=cut

	# do substitutions for non-escaped html characters
	$sContent = HtmlSub( $sContent );

	# add stripped line to tag contents
	my $iCurTagIdx = $$hrFuncInfo{'iCurTag'};
	if( $iCurTagIdx < 0 )
		{ return; }
	my $sCurTag = $f_fiTags[$iCurTagIdx];
	my $sEol = " ";

	# add hrefs for 'seealso' line
	if( $sCurTag eq "seealso" )
	{
#		$sContent =~ s/(\w+)(\(\))/<a href=\"#$1\">$&<\/a>/g;
		my $sHrefContent = "";
		my @refs = split( /,/, $sContent );
		while( @refs )
		{
			my $sFunc = shift( @refs );
			# trim capping whitespace
			$sFunc =~ s/^\s+//;
			$sFunc =~ s/\s+$//;
			my $sRef = $sFunc;
			# remove trailing parens if any
			$sRef =~ s/\(\)$//;

			my $sLink = "<a href=\"#$sRef\">$sFunc</a>";
			$sHrefContent = $sHrefContent . $sLink;
			if( @refs )
			{
				$sHrefContent = $sHrefContent . ", ";
			}
		}
		$sContent = $sHrefContent;
	}

	# add html line breaks for all but descrip and groups
	if( ($sCurTag ne "descrip") and ($sCurTag ne "groups"))
		{ $sEol = " <br>"; }

#if( $$hrFuncInfo{'name'} eq "setFfReportCondition" )
#{ print( "contentLine='$sContent'\n" ); }

	# add line to current tag content
	$$hrFuncInfo{$sCurTag} = $$hrFuncInfo{$sCurTag} . $sContent . $sEol;

}# ScanCommentBlockLine

#-----------------------------------------------------------------------------------------------------------------
# EndCommentBlock
#
# descrip:
# 	Checks that all required documentation tags for a function have been scanned.
# 	Then the function name is added to index lists and html documentation is generated for the function. 
#
# notes: 
#	'notes', 'seealso' and 'group' tags are optional.
#
#-----------------------------------------------------------------------------------------------------------------
sub EndCommentBlock
{
	my $hrFuncInfo = shift;

	my $sFuncName = $$hrFuncInfo{'name'};
	if( not $sFuncName )
		{ die( "Error: function name not defined" ); }

	print( $f_out "<hr><h2><a name=\"$sFuncName\">$sFuncName()</a></h2>\n" );
	# check for undefined tag info
	my $iTag;
	for( $iTag = 0; $iTag < @f_fiTags; ++$iTag )
	{
		my $sTag = $f_fiTags[$iTag];

		# if required and not defined, error
		if( !defined( $$hrFuncInfo{$sTag} ))
		{
			if( IsRequiredTag( $sTag ) )
				{ die( "Error: function info tag '$sTag' is not defined for function $sFuncName in file $f_sCurSrcFile" ); }
			next;
		}

		# get tag content, output html
		my $sContent = $$hrFuncInfo{$sTag};
		print( $f_out "<h3>$sTag</h3>\n" );
		# if 'notes', add <pre> brackets
#		if( $sTag eq "notes" )
#			{ print( $f_out "<pre>\n" ); } 
		
		print( $f_out "$sContent\n" );

#		if( $sTag eq "notes" )
#			{ print( $f_out "</pre>\n" ); } 
	}# end for all tags

	# add include info
	print( $f_out "<h3>include</h3>\n$f_sIncludeFile\n" );

	# add func name to 'all' index list
	my $raAllList = $f_group{"All"};
	push( @$raAllList, $sFuncName );

	# get group names
#	my $sGroup = $$hrFuncInfo{'group'};
#	$sGroup =~ s/\s+//g;

	# get default group name from the source file defining this function
	my $sGroup = GetGroupNameFromFile( $f_sIncludeFile );
	# add func name to group index list
	if( !defined( $sGroup ) || length( $sGroup ) < 1 )
	{ 
		die( "Error: group content not defined for function $sFuncName" );
	}
	my @groups = ( $sGroup );

	# get additional optional group names given in 'groups' tag
	my $sMoreGroups = $$hrFuncInfo{'groups'};
	if( $sMoreGroups )
	{
		my @moreGroups = split( /, /, $sMoreGroups );
		my $sGr = shift @moreGroups;
		while( $sGr )
		{
			$sGr =~ s/\s+//g;			# BUG ALERT: this will cause group names with internal spaces to be changed
			if( !defined( Find( \@groups, $sGr ))  )
				{ 
				push( @groups, $sGr ); 
				}
			$sGr = shift @moreGroups;
		}
	}

	# add func name to all groups
	my $iGr;
	for( $iGr = 0; $iGr < @groups; ++$iGr )
	{
		$sGroup = $groups[$iGr];
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
	my $sTitle = "Index of Lua Library Functions for the Rbq Application";
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
#
# Returns the first letter of the function, used to add alphabetical indicators in the index table.
#
#-----------------------------------------------------------------------------------------------------------------
sub GetAlphaLetter
	{
	my $sFunc = shift;
	return uc( substr( $sFunc, 0, 1 ));
	}# GetAlphaLetter

#-----------------------------------------------------------------------------------------------------------------
# PrintGroupIndex
#
# Prints an index table for a function category (group).
#
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
			my $sAlphaLetter = " ";
			my $sFunc = " ";
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

			# check for undefs
			if( not $sFunc )
				{ die( "Error: function name not defined" ); }
			if( not $sAlphaLetter )
				{ die( "Error: alpha letter not defined" ); }

			printf( $f_out "<td>$sAlphaLetter<td><a href=\"#$sFunc\">$sFunc</a> " );
			}
		}
	print( $f_out "</table>\n" );	

	}# PrintGroupIndex

#-----------------------------------------------------------------------------------------------------------------
# OutputIndexFile
#
# Outputs an html file containing a set of tables, one for each function category.  Each table is an
# index to the functions in the main html documentation section.
#
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
		# sort list
		my @sortedList = sort( @$raGroupList );
		PrintGroupIndex( $g, \@sortedList );
		}

	close( $f_out );

	}# OutputIndexFile

#-----------------------------------------------------------------------------------------------------------------
# OutputFile
#
# Outputs the contents of the param input file to the current module file handle, opened for output.
#
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
# ConcatHtmlFiles
#
# Concatenates the intermediate html files into a single final file.
#
#-----------------------------------------------------------------------------------------------------------------
sub ConcatHtmlFiles
	{

	# open outfile
	open( $f_out, ">$f_sOutFile" ) or die( "Error: failed opening file $f_sOutFile for output" );
	
	OutputFile( $f_sHdrFile );
	OutputFile( $f_sIndexFile );
	OutputFile( $f_sMainFile );
	OutputFile( $f_sFtrFile );

	close( $f_out );

	}# ConcatHtmlFiles

#-----------------------------------------------------------------------------------------------------------------
# ScanSrcFile
#
# Scans a lua src code file for function documentation blocks. When a function block is found, its tags and
# content are output in html format to the currenly open module file handle, which is opened for the intermediate
# file which holds the main html code.  Also, function names are added to lists which represent
# different categories of functions.  These will be later output to the intermediate output file which holds
# the index html code.
#
#-----------------------------------------------------------------------------------------------------------------
sub ScanSrcFile
	{
	my $sSrcFile = shift;

	# open infile
	open( FIN, "<$sSrcFile" ) or die( "Error: failed opening file $sSrcFile for input" );

	# reset file line counter
	$f_iCurLine = 0;

	my $bInCommentBlock = 0;
	my %funcInfo;
	my $iTotalFuncs = 0;

	my $sBannerPattern = "-------------------------";
	my $sPrevLine = "";
	# process each line in file
	my $sLine;
	while( $sLine = <FIN> )
		{
		++$f_iCurLine;

		# format: function documentation block begins with '-- funcName' (preceded by long '----------...' line)
		# followed by '-- descrip', '-- params', etc.
		my $bPrevLineIsBannerLine = ($sPrevLine =~ /$sBannerPattern/);
		my $bCommentLine = ( $sLine =~ /^\-\-/ );

		my $sErrLoc = "line $f_iCurLine in file $f_sCurSrcFile";

		# check for start of comment block
		if( $bCommentLine && $bPrevLineIsBannerLine )
			{
			# make sure not already in a comment block
			if( $bInCommentBlock) 
				{ die( "Error: found start of comment block while already in a comment block at $sErrLoc" ); }

			++$iTotalFuncs;
			$bInCommentBlock = 1;

			my ($f1, $f2) = split( ' ', $sLine );
			if( (not defined( $f2 )) or (not( $f2 )))
				{ die( "Error: failed parsing function name at $sErrLoc" ); }

			ClearFuncInfo( \%funcInfo );
			$funcInfo{'name'} = $f2;
			}
		# check for end of comment block
		elsif( $bInCommentBlock && !$bCommentLine )
			{
			# check for start of function def
			if( !( $sLine =~ /^function/ ))
				{ die( "Error: expected start of function definition after end of comment block at $sErrLoc" ); }
			# do end-comment-block processing
			EndCommentBlock( \%funcInfo );
			$bInCommentBlock = 0;
			}
		# scan comment block lines
		elsif( $bInCommentBlock )
			{
			ScanCommentBlockLine( \%funcInfo, $sLine );
			}
		
		# save prev line
		$sPrevLine = $sLine;
		}# end for all lines in file

	close( FIN );

	printf( "$f_iCurLine line(s) read, $iTotalFuncs function(s) processed from file $sSrcFile\n" );
	}# ScanSrcFile

#-----------------------------------------------------------------------------------------------------------------
# main
#
# Gets a list of src files
# Scans each sourc file for documented function blocks
# Each function block is output to a main html file
# Each function name is added to index lists
# After all src files scanned, index html files are output
# Main html file, index html file and header and footer are then concatenated into a single final output file.
#
#-----------------------------------------------------------------------------------------------------------------
	if( @ARGV < 1 )
		{
		printf( "usage: $f_sScriptName <luaFileSpec>\n" );
		printf( "\n" );
		printf( "scans lua library src files in the lua subdir and creates html docs\n" );
		exit( 0 );
		}
	my $sSrcFileSpec = shift;
	my @srcFiles = glob( $sSrcFileSpec );
	if( ! @srcFiles )
		{
		print( "Error: no files found from filespec '$sSrcFileSpec'\n" );
		exit( 1 );
		}

	# init 'all' list in group hash
	my @allFuncsList = ( );
	$f_group{"All"} = \@allFuncsList;

	# setup module output file handle
	$f_out = *FOUT;
	# reference FOUT again to get rid of stupid warning
	my $duh = *FOUT;

	# open main html outfile
	open( $f_out, ">$f_sMainFile" ) or die( "Error: failed opening file $f_sMainFile for output" );

	# process all src files
	my $sSrcFile;
	foreach $sSrcFile (@srcFiles)
		{
		# get base file name for documenting 'include' section
		my @flds = split( "\\\\", $sSrcFile );
		my $sBaseFile  = substr( $flds[@flds - 1 ], 1 );
		$f_sIncludeFile = $sBaseFile;
		$f_sCurSrcFile = $sSrcFile;
		# scan src file for function blocks
		ScanSrcFile( $sSrcFile );
		}

	# close main html output file
	close( $f_out );

	# output index file
	OutputIndexFile();

	# output html header/footer files
	my $iTotalFuncs = @allFuncsList;
	OutputHtmlHeader( $iTotalFuncs );
	OutputHtmlFooter();

	# combine hdr, index and main and ftr files
	ConcatHtmlFiles();

	# delete intermediate files

	# report
	printf( "Lua lib html documentation output to '$f_sOutFile'\n" );

	# copy to dst
#	my $rc = system( $f_sCopyCmd );
#	if( $rc != 0 )
#		{
#		print( "Error: system command '$f_sCopyCmd' failed\n" );
#		}


