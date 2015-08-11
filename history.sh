    1  rsync.exe .profile ash022@norstore.uio.no:pr 
    2  ssh 
    3  ssh ash022@norstore.uio.no
    4  ssh animeshs@kongull.hpc.ntnu.no
    5  perl
    6  perl -e 'print 2+2'
    7  gcc
    8  lynx ntnu.no
    9  irc
   10  cp /cygdrive/c/cygwin/home/animeshs/.netrc .
   11  chmod 644 .netrc 
   12  ln -s /cygdrive/c/Users/animeshs/misccb .
   13  cd misccb
   14  git status
   15  git commit -am "protein cleavage and peptide counts"
   16  git config --global user.name "Anix64"
   17   git config --global user.email animesh@fuzzylife.org
   18  git push
   19  perl prot2pep.pl /cygdrive/l/Qexactive/Mirta/QExactive/Bcell_Project/combined.fasta  | grep "^IS"
   20  perl -v
   21  less /proc/meminfo 
   22  less /proc/cpuinfo 
   23  ls -ltr
   24  ls -ltr *.m
   25  wc 
   26  wget http://snps.biofold.org/phd-snp/pages/HumVar.txt
   27  curl http://snps.biofold.org/phd-snp/pages/HumVar.txt
   28  curl http://snps.biofold.org/phd-snp/pages/HumVar.txt | wc
   29  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 
   30  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 
   31  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 15
   32  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 15 | w
   33  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 15 | wc
   34  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 15 > /cygdrive/l/Elite/kamila/proteinGroupsOdenseUG.txt
   35  perl ungrouplist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdense.txt 15 50 > /cygdrive/l/Elite/kamila/proteinGroupsOdenseUG.txt
   36  perl matchlist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdenseUG.csv /cygdrive/l/Elite/kamila/combo.csv 
   37  perl matchlist.pl /cygdrive/l/Elite/kamila/proteinGroupsOdenseUG.csv /cygdrive/l/Elite/kamila/combo.csv > /cygdrive/l/Elite/kamila/proteinGroupsOdenseUGcombo.csv
   38  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/apo+redox.csv
   39  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/apo+redox.csv | wc
   40  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/
   41  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/sumofscores.csv
   42  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/sumofscores.csv | wc
   43  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo+redox.csv /cygdrive/l/Qexactive/Linda/sumofscores.csv > /cygdrive/l/Qexactive/Linda/ARsumofscores.csv
   44  perl matchlist.pl /cygdrive/l/Qexactive/Linda/redox.csv /cygdrive/l/Qexactive/Linda/sumofscores.csv > /cygdrive/l/Qexactive/Linda/Rsumofscores.csv
   45  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo.csv /cygdrive/l/Qexactive/Linda/sumofscores.csv > /cygdrive/l/Qexactive/Linda/Asumofscores.csv
   46  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo.csv /cygdrive/l/Qexactive/Linda/redox.csv
   47  perl matchlist.pl /cygdrive/l/Qexactive/Linda/apo.csv /cygdrive/l/Qexactive/Linda/redox.csv | wc
   48  ls -ltr
   49  ls
   50  ls
   51  git status
   52  cd misccb
   53  git status
   54  git commit -am "max quant combo update, amino acid composition in super silac exp"
   55  git push
   56  sort /cygdrive/l/Elite/Aida/SS_Result/up.txt 
   57  sort /cygdrive/l/Elite/Aida/SS_Result/up.txt | uniq | wc
   58  sort /cygdrive/l/Elite/Aida/SS_Result/up.txt | uniq
   59  sort /cygdrive/l/Elite/Aida/SS_Result/up.txt | uniq > /cygdrive/l/Elite/Aida/SS_Result/upc.txt
   60  sort /cygdrive/l/Elite/Aida/SS_Result/dn.txt | uniq > /cygdrive/l/Elite/Aida/SS_Result/dnc.txt
   61  sort /cygdrive/l/Elite/Aida/SS_Result/dn.txt | uniq | wc
   62  ls
   63  perl matchlist.pl /cygdrive/l/Elite/Camilla/140116_BisX1.csv /cygdrive/l/Elite/Camilla/kinase.csv 
   64  perl matchlist.pl /cygdrive/l/Elite/Camilla/140116_BisX1.csv /cygdrive/l/Elite/Camilla/kinase.csv  | wc
   65* for i in /cygdrive/l/Elite/Camilla/140116_BisX1.csv ; do echo $i ; perl matchlist.pl $i  |
   66  for i in /cygdrive/l/Elite/Camilla/140116_BisX1* ; do echo $i ; perl matchlist.pl $i  /cygdrive/l/Elite/Camilla/kinase.csv ; done
   67  for i in /cygdrive/l/Elite/Camilla/140116_*.csv ; do echo $i ; perl matchlist.pl $i  /cygdrive/l/Elite/Camilla/kinase.csv ; done
   68  for i in /cygdrive/l/Elite/Camilla/140116_*.csv ; do echo $i ; perl matchlist.pl $i  /cygdrive/l/Elite/Camilla/kinase.csv > $i.match.csv ; done
   69  perl matchlist.pl /cygdrive/l/Elite/Camilla/140116_BisX1.csv /cygdrive/l/Elite/Camilla/kinase.csv 
   70  ssh 129.241.176.112
   71  ls -ltr
   72  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   73  sed 's/,/\n' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   74  sed 's/,/\n/' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   75  sed 's/\,/\n/' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   76  sed 's/,/ /' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   77  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt 
   78  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt | sort | uniq
   79  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt | sort | uniq | wc
   80  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt | sort | wc
   81  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/ge.txt | sort | uniq 
   82  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/R3.txt | sort | uniq 
   83  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/R3.txt | sort | wc
   84  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/R3.txt | sort | uniq | wc
   85  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/R3.txt | sort | uniq |  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/R3.txt | sort | uniq 
   86  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CDS.txt | sort | wc
   87  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CDS.txt | sort | uniq | wc
   88  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CDS.txt | sort | uniq 
   89  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CC.txt | sort |  wc
   90  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CC.txt | sort | uniq | wc
   91  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CC.txt | sort | uniq 
   92  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | uniq 
   93  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt 
   94  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | wc
   95  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | wc
   96  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | less
   97  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt 
   98  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | uniq
   99  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | uniq | wc
  100  sort /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt |  wc
  101  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/CC.txt /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv 
  102  for i in /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/*.txt ; do echo $i; perl matchlist.pl $i /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv > $i.match.csv ; done
  103  for i in /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/*.txt ; do echo $i;  done
  104  cd /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/
  105  perl /home/animeshs/misccb/matchlist.pl CC.txt abundance_wgn.csv 
  106  for i in *.txt ; do echo $i; perl /home/animeshs/misccb/matchlist.pl $i abundance_wgn.csv ; done
  107  for i in *.txt ; do echo $i; perl /home/animeshs/misccb/matchlist.pl $i abundance_wgn.csv ; done
  108  for i in *.txt ; do echo $i; perl /home/animeshs/misccb/matchlist.pl $i abundance_wgn.csv > $i.abundancematch.csv ; done
  109  wc ge.txt
  110  git status
  111  cd
  112  cd /home/animeshs/misccb
  113  git status
  114  git status
  115  git diff
  116  git diff
  117  git stat
  118  git status
  119  git pull
  120  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance
  121  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv 
  122  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | awk '{print $1}' | wc
  123  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | awk '{print $1}' | sort | uniq | wc
  124  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatio.csv 
  125  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatio.csv > /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatio.TAIR.csv
  126  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv > /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.TAIR.csv
  127  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIRdown.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv > /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.TAIR.csv
  128  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIRdown.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv
  129  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv 
  130  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv 
  131  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIR.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv | wc
  132  perl matchlist.pl /cygdrive/l/Elite/LARS/2013/desember/ishita/UP2TAIRdown.csv /cygdrive/l/Elite/LARS/2013/desember/ishita/Min2PepRatioDown.csv| wc
  133  sed 's/\s+/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv 
  134  sed 's/\s+|,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv 
  135  sed 's/ |,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv 
  136  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv 
  137  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g
  138  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep GN
  139  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN="
  140  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g'
  141  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g' | wc
  142  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g' | sort | uniq
  143  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g' | sort | uniq | wc
  144  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g'
  145  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g'
  146  history > commands.txt
  147  history > history.sh
  148  rm commands.txt 
  149  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g'
  150  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | sed 's/ /\n'/g | grep "GN=" | sed 's/GN\=//g' | wc
  151  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | sed 's/ /\n'/g | grep "GN="
  152  sed 's/,/\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | sed 's/ /\n'/g | grep "GN=" | wc
  153  wc /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv 
  154  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "GN=" | wc
  155  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "GN\=" | wc
  156  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv 
  157  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "GN\=" | less
  158  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | less
  159  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | wc
  160  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort 
  161  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | less
  162  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | wc
  163  history | grep matchlist.pl
  164  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv
  165  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.AbundanceMatch.csv
  166  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv | wc
  167  git status
  168  git add .
  169  git status
  170  git commit -am "check threshold, arabidopsis gene set enrichment analysis, log command history"
  171  git push
  172  ssh promec1-vm.medisin.ntnu.no
  173  perl matchlist.pl /cygdrive/l/Elite/kamila/mRNA.csv /cygdrive/l/Elite/kamila/mRNAredone.csv > /cygdrive/l/Elite/kamila/mRNAmatchRedone.csv
  174  perl matchlist.pl /cygdrive/l/Elite/kamila/mRNAredone.csv /cygdrive/l/Elite/kamila/mRNA.csv > /cygdrive/l/Elite/kamila/mRNAwithRedone.csv
  175  wget www.nature.com/nature/journal/v464/n7291/pdf/nature08987.pdf
  176  wget
  177  vim t
  178  wc /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt 
  179  sort  /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt  | uniq
  180  sort  /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt  | uniq | wc
  181  wc /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt 
  182  less /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt 
  183  sed /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 
  184  sed 's/,/\t/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 
  185  sed 's/,/\t/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | awk '{print $2}'
  186  sed 's/,/ /g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | awk '{print $2}'
  187  cat /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | awk '{print $2}'
  188* grep "" /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | awk '{print $3}'
  189  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | awk '{print $2}'
  190  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "\[[A-Z]+_HUMAN\]" awk '{print $2}'
  191  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "_HUMAN" | awk '{print $2}'
  192  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "\[[A-Z]+_HUMAN\]" | awk '{print $2}'
  193  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "_HUMAN" | awk '{print $1}'
  194  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "_HUMAN"
  195  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "_HUMAN" | awk '{print -$1}'
  196  sed 's/,/\n/g' /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv | grep "_HUMAN" | sed 's/ /\n/g'  | awk '{print $1}'
  197  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | less
  198  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq | less
  199  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq | wc
  200  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq  > tw
  201  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv |  awk '{print $1}' | sort | uniq  | less
  202  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv |  awk '{print $1}' | sort | uniq  | less
  203  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv |  awk '{print $1}' | sort | uniq  > al
  204  diff al tw
  205  diff tw al
  206  diff tw al | less
  207  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance_wgn.csv |  awk '{print $1}' | less
  208  lesss tw
  209  less tw
  210* sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv |  awk '{print $1}' | sort | uniq  > tw
  211  less tw
  212  man tw
  213  man diff
  214  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | less
  215  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | less
  216  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' | less
  217  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' |less
  218  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' > al
  219  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq  | wc
  220  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq  | less
  221  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $2}' | sort | uniq  | less
  222  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $2}' | sort | uniq  | less
  223  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq  
  224  history | grep tw
  225  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1.csv |  awk '{print $1}' | sort | uniq  > tw
  226  less tw
  227  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv |  awk '{print $1}' | sort | uniq  
  228  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv |  awk '{print $1}' | sort | uniq  | wc 
  229  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv |  awk '{print $1}' | sort | uniq  | less
  230  sed 's/,/ /g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv |  awk '{print $1}' | sort | uniq  >  tw
  231  diff -v tw al
  232  diff  tw al
  233  diff  tw al | less
  234  bdiff
  235  man diff
  236  diff -s  tw al | less
  237  man diff
  238  man diff
  239  diff -l  tw al | less
  240  perl difflist.pl tw al
  241  perl difflist.pl tw al
  242  perl difflist.pl tw al
  243  perl difflist.pl tw al
  244  perl difflist.pl tw al 2>0  | less
  245  perl difflist.pl tw al 2>0  | wc
  246  perl difflist.pl tw al 2>0  > diff.txt
  247  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | less
  248  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abundance.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | wc
  249  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | less
  250  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN\=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | wc
  251  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | wc
  252  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c
  253  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | sort -r
  254  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      2 "
  255  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq | sed 's/\=/ /g' |  awk '{print $2}' | wc
  256  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      3 "
  257  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      4 "
  258  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      5 "
  259  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      6 "
  260  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | sort | uniq -c | grep "      3 "
  261  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" | less
  262  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | grep "^GN=" > al
  263  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | grep "^GN=" 
  264  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | grep "^GN="  | sed 's/GE=//g' 
  265  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | grep "^GN="  | sed 's/GN=//g' 
  266  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | grep "^GN="  | sed 's/GN=//g' 
  267  sed 's/ /\n/g' /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/chk.txt | grep "GN="  | sed 's/GN=//g' 
  268  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv 
  269  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | wc
  270  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv | wc
  271  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv 2>0 | less
  272  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv 2>0 > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd_wgn.csv
  273  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd_wgn.csv 2>0 | wc
  274  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd_wgn.csv 2>0 > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/tw2abd.csv
  275  perl matchlist.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/TrustWorthyScoreThr1GN.csv /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/notfoundinabundance.csv 2>0 > /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/notfound.csv
  276  perl getgn.pl /cygdrive/v/felles/PROTEOMICS\ and\ XRAY/Linda/abundance\ analysis/abd.csv 2>0 | less
  277  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 | less
  278  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 | less | wc
  279  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' 
  280  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}'
  281  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' > t
  282  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' > t.txt
  283  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' | sort | wc
  284  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' | sort | uniq | wc
  285  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' | sort | uniq | less
  286  perl getgn.pl /cygdrive/l/Elite/LARS/2014/januar/TObias/MCR25Reports.csv 2>0 |  sed 's/,/ /g' | awk '{print $1}' | sort | uniq | less
  287  ls
  288  git pull
  289  history > history.sh 
