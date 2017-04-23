#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
#read gbk file and the Markov Model level
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName GBK-SeqFile(file name)\n\n\n";}

$file = shift @ARGV;

#open GBK file
opengbk($file,$part);


sub opengbk{
    $file=shift;
    open(F,$file)||die "can\'t open \"$file\": $!";
    $part=shift;
    #print "Reading file $file";
    while($l=<F>)
    {
        $cnt1++;
    #    if(($cnt1%1000) eq 0){print ".";}
        if($l =~ /CDS/){
            if($l =~ /join/)
                {unless($l =~ /\)/)
                    {
                        do{
                        $linenew=<F>;
                        chomp ($linenew);
                        $l = $l.$linenew;
                            }until ($l =~ /\)/)
                    }
                }
        $l =~ s/\(/ /g;$l =~ s/\)/ /g;$l =~ s/join//;$l =~ s/CDS//;
        if($l=~/complement/){$l=~s/[A-Za-z]/ /g;$l=~s/\/\=\"\"//g;
            @temp=split(/,/,$l);foreach $tr (@temp){$tr=~s/\s+//g;
            chomp $tr;
            if($tr ne ""){push(@comcds,$tr);push(@t,$tr);}}}
        else
            {$l=~s/[A-Za-z]/ /g;$l=~s/\/\=\"\"//g;
            @temp=split(/,/,$l);
            foreach $tr (@temp){$tr=~s/\s+//g;
                chomp $tr;
                if(($tr ne "")){push(@cds,$tr);push(@t,$tr);}
                }
            }}
        if($l=~/^ORIGIN/)
        {        while($ll=<F>)
                {

                $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$line.=$ll;
                }
        }
    }
    $line=($line);$line=~s/\///g;1/1;$seql=length($line);
    foreach $cds1 (@cds){
        $cds1=~s/\s+//g;$cds1=~s/\>//g;$cds1=~s/\<//g;
        @no1=split(/\.\./,$cds1);$lll=@no1;
        if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
            $length=@no1[1]-@no1[0]+1;
            $st=@no1[0];$sp=@no1[1];$cds{$sp}=$st;
            $str = uc(substr($line,(@no1[0]-1),$length));
            $sname="CDS[@no1[0]-@no1[1]]";
            push(@cdsseq,$str);push(@cdsseqname,$sname);
        }
    }
    foreach $cds2 (@comcds){
        $cds2=~s/\s+//g;$cds2=~s/\>//g;$cds2=~s/\<//g;
        @no1=split(/\.\./,$cds2);$lll=@no1;
        if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
            $length=@no1[1]-@no1[0]+1;
            $str = substr($line,(@no1[0]-1),$length);
            $str=~tr/atgc/tacg/d;1/1;
            $str=~tr/ATGC/TACG/d;1/1;
            $str = uc(reverse($str));
            $st=@no1[0];$sp=@no1[1];$cds{$st}=$sp;
            $sname="cCDS[@no1[0]-@no1[1]]";
            push(@cdsseq,$str);push(@cdsseqname,$sname);
        }
    }
    $lcds=(@cdsseq);
    #print "\nExtracted $lcds coding sequence from $file";
    for($cc1=0;$cc1<=$#t;$cc1++){
        $cds1=@t[$cc1];
        $cds1=~s/\s+//g;$cds1=~s/\>//g;$cds1=~s/\<//g;
        @no1=split(/\.\./,$cds1);$lll=@no1;
        if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
            push(@to,@no1[0]);push(@to,@no1[1]);
        }
    }
    for($cc1=0;$cc1<($#to-1);$cc1=$cc1+2){
        $cds1=@to[$cc1];$sp=(@to[($cc1+2)]-1);$st=(@to[($cc1+1)]+1);
        $length=@to[($cc1+2)]-@to[($cc1+1)]-1;
        if($length le 0){
            $sp=$sp+1;$st=$st-1;
            $length=$st-$sp+1;
            $str = uc(substr($line,$sp-1,$length));
            $intgen{$sp}={$st};
        }
        #elsif($length >= 90){
        else{
            $str = uc(substr($line,(@to[($cc1+1)]),$length));
            $intgen{$sp}={$st};
            $ncdssname="Intergenic[$st-$sp]";
            push(@ncdsseq,$str);push(@ncdsseqname,$ncdssname);
            #$ncdssname="cIntergenic[$st-$sp]";
            #$str=~tr/atgc/tacg/d;1/1;
            #$str=~tr/ATGC/TACG/d;1/1;
            #$str = uc(reverse($str));
            #push(@ncdsseq,$str);push(@ncdsseqname,$ncdssname);
        }
    }
    $lcds=(@ncdsseq);
    #print "\nExtracted $lcds intergenic sequence from $file\n";
    close F;

}
for($c1=0;$c1<=$#ncdsseq;$c1++){print ">$file:@ncdsseqname[$c1]\n@ncdsseq[$c1]\n";}
#for($c1=0;$c1<=$#cdsseq;$c1++){print ">$file:@cdsseqname[$c1]\n@cdsseq[$c1]\n";}