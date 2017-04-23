        while(<>){
                chomp;
                @t1=split(/\s+/);
                for($cc=0;$cc<=$#t1;$cc++) {
                        if(@t1[$cc]=~/^V/){
                                push(@tall,@t1[$cc]);
                        }
                }
        }
        close F;
        @utall = grep !$seen{$_}++, @tall;
        print join(",",@utall),"\n";

