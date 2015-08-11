#!/usr/bin/perl
while(<>){
	chomp;
	split(/\,/);
	print @_[0],"\t";
}
