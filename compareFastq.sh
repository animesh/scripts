#https://chatgpt.com/share/69272b29-2bac-8003-91de-5925579b5391
#zcat /cluster/projects/nn9036k/TK/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L005__1.fq.gz | sed -n '2~4p' | cut -d' ' -f1  | less
#comm -23 <(zcat A.fastq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort) <(zcat B.fastq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort)
#comm -23 <(zcat /cluster/projects/nn9036k/TK/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__1.fq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_1.fastq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort)
#awk 'BEGIN{FS="\n"} FNR%4==2 {seq=$0; b[seq]=1; next} NR>FNR && FNR%4==2 { if(!(seq=$0 in b)) print seq }' <(zcat B.fq.gz) <(zcat A.fq.gz)
#awk 'BEGIN{FS="\n"} FNR%4==2 {seq=$0; b[seq]=1; next} NR>FNR && FNR%4==2 { if(!(seq=$0 in b)) print seq }' <(zcat /cluster/projects/nn9036k/TK/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L005__1.fq.gz) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_2.fastq.gz)
#comm -23 <(zcat /cluster/projects/nn9036k/TK/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__1.fq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_1.fastq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort)
#comm -23 <(zcat /cluster/projects/nn9036k/TK/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005__2.fq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_2.fastq.gz | sed -n '2~4p' | cut -d' ' -f1 | sort)
#for i in 1 2;do for f in /cluster/projects/nn9036k/TK/TK9*__${i}.fq.gz;do comm -23 <(zcat $f|sed -n '2~4p'|sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_${i}.fastq.gz|sed -n '2~4p'|sort) >$f.diff;done;done
#for i in 1 2;do parallel 'comm -23 <(zcat {}|sed -n "2~4p"|sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_'$i'.fastq.gz|sed -n "2~4p"|sort) >{}.diff' ::: /cluster/projects/nn9036k/TK/TK9*__${i}.fq.gz;done
#parallel 'i=$(echo {}|grep -o "__[12]"|tr -d _);comm -23 <(zcat {}|sed -n "2~4p"|sort) <(zcat /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076${i}.fastq.gz|sed -n "2~4p"|sort)>{}.diff' ::: /cluster/projects/nn9036k/TK/TK9*__*.fq.gz
parallel 'i=$(echo {}|grep -o "__[12]"|tr -d _); \
comm -23 <(pigz -dc {}|sed -n "2~4p"|sort) \
          <(pigz -dc /cluster/projects/nn9036k/TK/sra/fastq/SRR31089076${i}.fastq.gz|sed -n "2~4p"|sort) \
          >{}.diff' ::: /cluster/projects/nn9036k/TK/TK9*__*.fq.gz



