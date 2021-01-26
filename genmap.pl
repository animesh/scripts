#https://github.com/HKU-BAL/Clair#quick-demo
Call whole-genome variants in parallel (using callVarBamParallel)
# variables
SAMPLE_NAME="NA12878"
OUTPUT_PREFIX="call/var"                        # please make sure the call/ directory exists

# create command.sh for run jobs in parallel
python $CLAIR callVarBamParallel \
--chkpnt_fn "$MODEL" \
--ref_fn "$REFERENCE_FASTA_FILE_PATH" \
--bam_fn "$BAM_FILE_PATH" \
--threshold 0.2 \
--sampleName "$SAMPLE_NAME" \
--output_prefix "$OUTPUT_PREFIX" > command.sh

# disable GPU if you have one installed
export CUDA_VISIBLE_DEVICES=""

# run Clair with 4 concurrencies
cat command.sh | parallel -j4

# Find incomplete VCF files and rerun them
for i in OUTPUT_PREFIX.*.vcf; do if ! [ -z "$(tail -c 1 "$i")" ]; then echo "$i"; fi ; done | grep -f - command.sh | sh

# concatenate vcf files and sort the variants called
vcfcat ${OUTPUT_PREFIX}.*.vcf | bcftools sort -m 2G | bgziptabix snp_and_indel.vcf.gz
#https://github.com/ding-lab/VirusScan/tree/simplified
#########Song Cao###########
#http://varscan.sourceforge.net/germline-calling.html
samtools mpileup -B -f reference.fasta myData.bam | java -jar VarScan.v2.2.jar mpileup2snp
#https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/quickStart.md
${STRELKA_INSTALL_PATH}/bin/configureStrelkaSomaticWorkflow.py \
    --normalBam normal.bam \
    --tumorBam tumor.bam \
    --referenceFasta hg38.fa \
    --runDir demo_somatic
# execution on a single local machine with 20 parallel jobs
demo_somatic/runWorkflow.py -m local -j 20
For references with many short contigs, it is strongly recommended to provide callable regions to avoid possible runtime issues:
--callRegions callable.bed.gz
For somatic calling, it is recommended to provide indel candidates from the Manta SV and indel caller to improve sensitivity to call indels of size 20 or larger:
--indelCandidates candidateSmallIndels.vcf.gz
For exome and amplicon inputs, add:
--exome
#https://github.com/ding-lab/somaticwrapper
perl somaticwrapper.pl --srg --step --sre --rdir --ref --log --q --mincovt --mincovn --minvaf --maxindsize --exonic --smg
#https://github.com/bli25broad/RSEM_tutorial
software/RSEM-1.2.25/rsem-calculate-expression -p 8 --paired-end \
					--bam \
					--estimate-rspd \
					--append-names \
					--output-genome-bam \
					exp/LPS_6h.bam \
					ref/mouse_ref exp/LPS_6h
## a simplified version of VirusScan pipeline ##
#
#!/usr/bin/perl
use strict;
use warnings;
#use POSIX;
use Getopt::Long;

#use POSIX;

my $version = "_simplified_v1.1";

#color code
my $red = "\e[31m";
my $gray = "\e[37m";
my $yellow = "\e[33m";
my $green = "\e[32m";
my $purple = "\e[35m";
my $cyan = "\e[36m";
my $normal = "\e[0m";

#usage information
(my $usage = <<OUT) =~ s/\t+//g;
This script will run the virus discovery pipeline by using nohup:

Pipeline version: $version

$yellow Usage: perl $0  --rdir --log --step $normal

<rdir> = full path of the folder holding files for this sequence run

<log> = directory for log files

<step> run this pipeline step by step. (running the whole pipeline if step number is 0)


$green		 [1]  Run bwa for unmapped reads againt virus reference
$purple [2]  Generate summary for virus discovery

$normal
OUT

my $run_dir="";
my $log_dir="";
my $help = 0;
my $step_number = -1;

my $status = &GetOptions (
      "step=i" => \$step_number,
      "rdir=s" => \$run_dir,
      "log=s"  => \$log_dir,
      "help" => \$help,
        );

if ($help || $run_dir eq "" || $log_dir eq "" || $step_number<0)
{
      print $usage;
      exit;
}

print "run dir=",$run_dir,"\n";
print "log dir=",$log_dir,"\n";
print "step num=",$step_number,"\n";

## read tools ##

#samtools        /diskmnt/Software/samtools-1.2/samtools
#bwa     /diskmnt/Software/bwa-0.7.17/bwa
#bamtools        /home/scao/tools/anaconda2/bin/bamtools

my $tf="./source/path_tools.tsv";

open(IN_TF,"<$tf");
my $samtools;
my $bwa;
my $bamtools;

while(<IN_TF>)
{

my $ltr=$_;
chomp($ltr);

my @temp=split("\t",$ltr);
if($temp[0] eq "samtools") { $samtools=$temp[1]; }
if($temp[0] eq "bwa") { $bwa=$temp[1]; }
if($temp[0] eq "bamtools") { $bamtools=$temp[1]; }

}

close IN_TF;

# software path
#my $cd_hit = "/gscuser/mboolcha/software/cdhit/cd-hit-est";

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# path and name of databases
#my $db_BN = "/gscuser/scao/gc3027/nt/nt";
#my $db_BX = "/gscuser/scao/gc3027/nr/nr";
#my $bwa_ref = "/gscuser/scao/gc3027/fasta/virus/virusdb_082414.fa";

## virus reference ##
my $bwa_ref="./source/virusref.fa";

my $HOME = $ENV{HOME};
my $working_name= (split(/\//,$run_dir))[-2];

# To run jobs faster, split large fasta files to small ones. Split to specific number of
# files instead of specific sequences in each small file, because the number of job array
# cannot be determined if spliting to specific number of sequences in each file. Job
# number is required by qsub ${SGE_TASK_ID}. The minimum size of each file is 4kb.
# The number of files should be determined accourding to CPUs available in the computer
# cluster.


my $HOME1=$log_dir;

if(! -d $HOME1) { `mkdir $HOME1`; }

#store job files here
if (! -d $HOME1."/tmpvirus") {
    `mkdir $HOME1"/tmpvirus"`;
}
my $job_files_dir = $HOME1."/tmpvirus";

#store SGE output and error files here
if (! -d $HOME1."/LSF_DIR_VIRUS") {
    `mkdir $HOME1"/LSF_DIR_VIRUS"`;
}

my $lsf_file_dir = $HOME1."/LSF_DIR_VIRUS";

# obtain script path
my $run_script_path = `dirname $0`;
chomp $run_script_path;
$run_script_path = "/usr/bin/perl ".$run_script_path."/";

my $hold_RM_job = "norm";
my $current_job_file = "";#cannot be empty
my $hold_job_file = "";
my $nohup_com = "";
my $sample_full_path = "";
my $sample_name = "";


# get sample list in the run, name should not contain "."
opendir(DH, $run_dir) or die "Cannot open dir $run_dir: $!\n";
my @sample_dir_list = readdir DH;
close DH;

# check to make sure the input directory has correct structure
&check_input_dir($run_dir);

# start data processsing
if ($step_number<3) {
	#begin to process each sample
	for (my $i=0;$i<@sample_dir_list;$i++) {#use the for loop instead. the foreach loop has some problem to pass the global variable $sample_name to the sub functions
		$sample_name = $sample_dir_list[$i];
		if (!($sample_name =~ /\./)) {
			$sample_full_path = $run_dir."/".$sample_name;
			if (-d $sample_full_path) { # is a full path directory containing a sample
				print $yellow, "\nSubmitting jobs for the sample ",$sample_name, "...",$normal, "\n";
				$current_job_file="";
				######################################################################
				#run the pipeline step by step
				if($step_number == 1) {
					&nohup_bwa();
				}elsif($step_number == 2)
				{
				 	&nohup_sum();
				}
			}
		}
	}
}


exit;


########################################################################
# subroutines

sub check_input_dir {
	my ($input_dir) = @_;
	my $have_input_sample = 0;

	# get sample list in the run, name should not contain "."
	opendir(DH, $input_dir) or die "Cannot open dir $input_dir: $!\n";
	my @sample_list = readdir DH;
	close DH;

	for (my $i=0;$i<@sample_list;$i++) {#use the for loop instead. the foreach loop has some problem to pass the global variable $sample_name to the sub functions
		$sample_name = $sample_list[$i];
		if (!($sample_name =~ /\./)&&!($sample_name =~/Analysis_/)) {
			$have_input_sample = 1;
			$sample_full_path = $input_dir."/".$sample_name;
			if (-d $sample_full_path) { # is a full path directory containing a sample
				my $input_file = $input_dir."/".$sample_name."/".$sample_name.".bam";
				if (!(-e $input_file)) { # input file does not exist
					print $red, "Do not have appropriate input directory structure. Please check your command line argument!", $normal, "\n\n";
					die;
				}
			}
			else { # input sample directory does not exist
				print $red, "Do not have appropriate input directory structure. Please check your command line argument!", $normal, "\n\n";
				die;
			}
		}
	}

	if (!($have_input_sample)) { # does not have any input sample directory
		print $red, "Do not have appropriate input directory structure. Please check your command line argument!", $normal, "\n\n";
		die;
	}

}


sub nohup_sum{

    $current_job_file = "j2_sum_".$sample_name.".sh";

    my $lsf_out=$lsf_file_dir."/".$current_job_file.".out";
    my $lsf_err=$lsf_file_dir."/".$current_job_file.".err";

    `rm $lsf_out`;
    `rm $lsf_err`;

    open(SUM, ">$job_files_dir/$current_job_file") or die $!;
    print SUM "#!/bin/bash\n";
    print SUM "          ".$run_script_path."generate_final_report.pl ".$run_dir." ".$version,"\n";
    close SUM;
    my $sh_file=$job_files_dir."/".$current_job_file;

    $nohup_com = "nohup sh $sh_file > $lsf_out 2> $lsf_err &";
    print $nohup_com;
    system ($nohup_com);
}
########################################################################
########################################################################
sub nohup_bwa{

    #my $cdhitReport = $sample_full_path."/".$sample_name.".fa.cdhitReport";

    $current_job_file = "j1_bwa_".$sample_name.".sh";

    my $IN_bam = $sample_full_path."/".$sample_name.".bam";

    if (! -e $IN_bam) {#make sure there is a input fasta file
        print $red,  "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&\n";
        print "Warning: Died because there is no input bam file for bwa:\n";
        print "File $IN_bam does not exist!\n";
        die "Please check command line argument!", $normal, "\n\n";

    }
    if (! -s $IN_bam) {#make sure input fasta file is not empty
        print $red, "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&\n";
        die "Warning: Died because $IN_bam is empty!", $normal, "\n\n";
    }

    my $lsf_out=$lsf_file_dir."/".$current_job_file.".out";
    my $lsf_err=$lsf_file_dir."/".$current_job_file.".err";

    `rm $lsf_out`;
    `rm $lsf_err`;

    open(BWA, ">$job_files_dir/$current_job_file") or die $!;
    print BWA "#!/bin/bash\n";
   # print BWA "#BSUB -n 1\n";
   # print BWA "#BSUB -R \"rusage[mem=20000]\"","\n";
   # print BWA "#BSUB -M 20000000\n";
   # print BWA "#BSUB -o $lsf_file_dir","/","$current_job_file.out\n";
   # print BWA "#BSUB -e $lsf_file_dir","/","$current_job_file.err\n";
   # print BWA "#BSUB -J $current_job_file\n";
    print BWA "BWA_IN=".$sample_full_path."/".$sample_name.".bam\n";
    print BWA "BWA_fq=".$sample_full_path."/".$sample_name.".fq\n";
    print BWA "BWA_sai=".$sample_full_path."/".$sample_name.".sai\n";
    print BWA "BWA_sam=".$sample_full_path."/".$sample_name.".sam\n";
    print BWA "BWA_bam=".$sample_full_path."/".$sample_name.".remapped.bam\n";
    #print BWA "BWA_bam=".$sample_full_path."/".$sample_name.".realign.bam\n";
    #print BWA "BWA_mapped_bam=".$sample_full_path."/".$sample_name.".mapped.bam\n";

    print BWA "BWA_mapped=".$sample_full_path."/".$sample_name.".mapped.reads\n";
    print BWA "BWA_fa=".$sample_full_path."/".$sample_name.".fa\n";
	#print BWA
	print BWA 'if [ ! -s $BWA_mapped ]',"\n";
    print BWA "    then\n";
	print BWA "rm \${BWA_sai}","\n";
	print BWA "rm \${BWA_fq}","\n";
	#print BWA "mkfifo \${BWA_sai}","\n";
	print BWA "mkfifo \${BWA_fq}","\n";
	#0x100: secondary alignment
	#0x800: supplementary alignment
    #H: Hard clipping
	#S: Soft clipping
     print BWA "$samtools view -h \${BWA_IN} | perl -ne \'\$line=\$_; \@ss=split(\"\\t\",\$line); \$flag=\$ss[1]; \$cigar=\$ss[5]; if(\$ss[0]=~/^\@/ || (!((\$flag & 0x100) || (\$flag & 0x800) || (\$cigar=~/H/)) && ((\$flag & 0x4) || (\$cigar=~/S/))) || (!((\$flag & 0x100) || (\$flag & 0x800) || (\$cigar=~/H/)) && (\$ss[2]=~/^NC/))) { print \$line;}\' | $samtools view -Sb - | $bamtools convert -format fastq > \${BWA_fq} \&","\n";

     #print BWA "$samtools view -f 4 \${BWA_IN} | $samtools view -Sb - | $bamtools convert -format fastq > \${BWA_fq} \&","\n";
    #print BWA "bwa aln $bwa_ref -b0 \${BWA_IN} > \${BWA_sai} \&","\n";
     print BWA "$bwa aln $bwa_ref \${BWA_fq} > \${BWA_sai}","\n";
     print BWA 'rm ${BWA_fq}',"\n";
     print BWA "mkfifo \${BWA_fq}","\n";
     print BWA "$samtools view -h \${BWA_IN} | perl -ne \'\$line=\$_; \@ss=split(\"\\t\",\$line); \$flag=\$ss[1]; \$cigar=\$ss[5]; if(\$ss[0]=~/^\@/ || (!((\$flag & 0x100) || (\$flag & 0x800) || (\$cigar=~/H/)) && ((\$flag & 0x4) || (\$cigar=~/S/))) || (!((\$flag & 0x100) || (\$flag & 0x800) || (\$cigar=~/H/)) && (\$ss[2]=~/^NC/))) { print \$line;}\' | $samtools view -Sb - | $bamtools convert -format fastq > \${BWA_fq} \&","\n";
	#print BWA "samtools view -h \${BWA_IN} | gawk \'{if (substr(\$1,1,1)==\"\@\" || (and(\$2,0x4) || and(\$2,0x8) )) print}\' | samtools view -Sb - | bamtools convert -format fastq > \${BWA_fq} \&","\n";
    # print BWA "$samtools view -f 4 \${BWA_IN} | $samtools view -Sb - | $bamtools convert -format fastq > \${BWA_fq} \&","\n";
     print BWA "$bwa samse $bwa_ref \${BWA_sai} \${BWA_fq} > \${BWA_sam}","\n";
     print BWA "grep -v \@SQ \${BWA_sam} | perl -ne \'\$line=\$_; \@ss=split(\"\\t\",\$line); if(\$ss[2]=~/^gi/) { print \$line; }\' > \${BWA_mapped}","\n";
     print BWA "$samtools view -bT $bwa_ref \${BWA_sam} > \${BWA_bam}","\n";
	#print BWA "     ".$run_script_path."get_fasta_from_bam_filter.pl \${BWA_mapped} \${BWA_fa}\n";
    #print BWA " 	".$run_script_path."trim_readid.pl \${BWA_fa} \${BWA_fa}.cdhit_out\n";
     print BWA 'rm ${BWA_sam}',"\n";
     print BWA 'rm ${BWA_sai}',"\n";
	#print BWA 'rm ${BWA_fq}',"\n";
	#print BWA "else\n";
    #print BWA "     ".$run_script_path."get_fasta_from_bam_filter.pl \${BWA_mapped} \${BWA_fa}\n";
    #print BWA "     ".$run_script_path."trim_readid.pl \${BWA_fa} \${BWA_fa}.cdhit_out\n";
    print BWA "   fi\n";
    close BWA;

    #my $sh_file=$job_files_dir."/".$current_job_file;
    #$nohup_com = "bsub -q research-hpc -n 1 -R \"select[mem>30000] rusage[mem=30000]\" -M 30000000 -a \'docker(registry.gsc.wustl.edu/genome/genome_perl_environment)\' -J $current_job_file -o $lsf_out -e $lsf_err sh $sh_file\n";
    #system ( $nohup_com );

        my $sh_file=$job_files_dir."/".$current_job_file;

        $nohup_com = "nohup sh $sh_file > $lsf_out 2> $lsf_err &";
        print $nohup_com;
        system ($nohup_com);


   #$nohup_com = "bsub < $job_files_dir/$current_job_file\n";
    #system ( $nohup_com );
}

#!/usr/bin/perl
use strict;

my $usage = "
This script will read corresponding files in the given director and
generate a report which contains SampleDescription, SequenceReport,
AssignmentSummary, InterestingReads.

perl $0 <run folder> <program version>
<run folder> = full path of the folder holding files for this sequence run

";

die $usage unless scalar @ARGV == 2;

my ( $dir, $version ) = @ARGV;

my @temp = split("/", $dir);
my $run_name = pop @temp;
my $outFile = $dir."/Analysis_Report_".$run_name;

my $virus_ref="./source/virusref.fa";

open(IN,"<$virus_ref");

my %gi2name=();

while(<IN>)
{
my $l=$_;
chomp($l);
if($l=~/^>gi/)
{
@temp=split(" ",$l);
my $gi=$temp[0];
$gi=~s/\>//g;
my $name=$temp[1];
#print $gi,"\n";
for(my $i=2;$i<@temp;$i++)
{
$name.=" ".$temp[$i];
}
$gi2name{$gi}=$name;
}
}

open (OUT, ">$outFile") or die "can not open file $outFile!\n";

my ($wkday,$month,$day,$time,$year) = split(/\s+/, localtime);
print OUT "VirusScan V${version}; Processing date: $day-$month-$year\n";

my $c = "**************************************************************************\n";
my $c2 = "#########################################################################\n";
print OUT $c;

print OUT "Summary:\n\n";

print OUT "Sample","\t","Virus","\t","Number of supporting reads","\n";

&generate_AssignmentSummary( $dir );

print OUT "\nEnd of Summary\n";
#print OUT $c ;

#print OUT "\n\nSequence Report\n\n";
#&generate_SequenceReport( $dir );
#print OUT "End of Sequence Report\n\n";
#print OUT $c ;

#print OUT "\n\nTaxonomy Assignment:\n\n";
#&generate_AssignmentSummary( $dir );
#print OUT "End of Assignment\n\n";
#print OUT $c ;

#print OUT "\n\nInteresting Reads\n\n";
#&generate_InterestingReads( $dir );
#print OUT "End of Interesting Reads\n\n";
#print "\n";

#print OUT "# Finished\n";

exit;
#####################################################################
# Assignment Summary
sub generate_AssignmentSummary {
	my ( $dir ) = @_;
	my $n;
	opendir(DH, $dir) or die "Can not open dir $dir!\n";
	my @files = readdir DH;
	foreach my $name (sort {$a cmp $b} @files) {
		# name is either file name or sample name (directory)
		my $full_path = $dir."/".$name;
#		print $full_path,"\n";
		if (!($name =~ /\./)) {
			if (-d $full_path) { # is a directory
				my $Summary_file = $full_path."/".$name.".mapped.reads";
				if (-e $Summary_file) {
					my %vreads=();
					open (IN, $Summary_file) or die "can not open file $Summary_file!\n";
					while (<IN>) {
					my $l=$_;
					chomp($l);
					@temp=split("\t",$l);
#					print $temp[2],"\n";
					#<STDIN>;
					$n=$gi2name{$temp[2]};
#					print $n,"\n";
#					<STDIN>;
					$vreads{$n}{$temp[0]}++;
					}
				if(keys %vreads)
				{
				foreach $n (sort keys %vreads)
				{
				my $count=0;
				foreach $c (sort keys %{$vreads{$n}})
				{
					$count++;
				}
				print OUT $name, "\t", $n, "\t", $count,"\n"; }
				}
				else { print OUT $name,"\t","Virus","\t","0","\n"; }

				print OUT $c2 ;
			}
			}
		}
	}
}
