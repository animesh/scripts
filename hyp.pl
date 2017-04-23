#!/usr/bin/perl
sub hypotenuse {return sqrt ( ($_[0] ** 2) + ($_[1] ** 2) );}
$tree=hypotenuse(3,4);
#print "the hyp of 3 4 is $tree";
@numb=qw/q r w q e f r y/;
@numbs=qw/r q d r g h/;
$tree="hi how r ya\n";
@wear=split(//,$tree);
$len1=@numbs;
$len2=@numb;
if($len1>$len2)
{$xx=$len1;}
else
{$xx=$len2;}
$great{a}=\@numb;$great{b}=\@numbs;
#foreach $test (keys %great)
#{
#$free=$great{$test};
#$temp=$#free;
#push(@$free,@wear[4]);
#print "@$free[$temp]\n";
#}
#print @numbs;
$length=%great;
#print $length;
#$treee=$great[1];
#print $treee;
#foreach $key (keys %great)
#{
#  $free=$great{$key};
#  for($cc=0;$cc<$len2;$cc++)
#{
        for($ccc=0;$ccc<$len1;$ccc++)
        {
        if(@numb[$ccc] eq @numbs[$ccc]){{
        print "numb[$ccc]\tnumbs[$ccc]\t@numb[$ccc]\t@numbs[$ccc]\tmatch\n";
        last if @numb[$ccc]=~/@numbs[$ccc]/;}}
        if(@numb[$ccc-1] eq $numbs[$ccc]){{
        print "numb[$ccc-1]\tnumbs[$ccc]\t@numb[$ccc-1]\t@numbs[$ccc]\tmatch\n";
        last if @numb[$ccc-1]=~/$numbs[$ccc]/;}}
        if(@numb[$ccc] eq @numbs[$ccc-1]){{
        print "numb[$ccc]\tnumbs[$ccc-1]\t@numb[$ccc]\t@numbs[$ccc-1]\tmatch\n";
        last if @numb[$ccc]=~/@numbs[$ccc-1]/;}}
        }
#}
