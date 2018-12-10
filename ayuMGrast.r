

```{r data}
inpF<-"Z:\\USERS\\ayurveda\\mgm4804295.3.csv"
data<-read.table(inpF,comment="D",header=T,sep="\t")
plot(log(data$percentage.identity),log(data$e.value),col=factor(data$number.of.mismatches))
```

```{r install}
install.packages('matR')
library(matR)
```

```{r check}
??auth
auth.MGRAST('MgRastWebKeyGoesHereKEJ88')
biom_phylum <- biomRequest(metadata("mgp80869")$mgp80869, request="organism", hit_type="all", source="RDP", group_level="phylum", evalue=15,  wait=TRUE)
phylum_matrix <- as.matrix(biom_phylum)
#biomRequest(file="Z:\\USERS\\ayurveda\\mgm4804295.3.csv",group_level="level2",evalue=1,)
```
```{r matR}
#https://github.com/MG-RAST/matR/blob/master/demo/simple.R
zz0 <- transform (zz, t_Log)
columns (zz0, "host_common_name|samp_store_temp|material")
princomp (zz0, map=c(col="host_common_name", pch="samp_store_temp"), labels="$$pubmed_id", cex=2)
distx (zz0, groups="$$host_common_name")
pp <- (rowstats (zz0, groups="$$material") $ p.value < 0.05)
pp[is.na(pp)] <- FALSE
pp

####  that information can be used to make an informative heatmap.

image (zz0 [pp,], margins=c(5,10), cexRow=0.3)

####  for comparison, here is the same heatmap, but including all annotations.

image (zz0, margins=c(5,10), cexRow=0.3)
```

```{r data}
http://api.metagenomics.anl.gov/m5nr/taxonomy?filter=Bacteroidetes&filter_level=phylum&min_level=genus

#install.packages('jsonlite')
library(jsonlite)
S5 <- fromJSON("http://api.metagenomics.anl.gov/1/annotation/sequence/mgm4804308.3?evalue=10&type=organism&source=SwissProt&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk")
head(S5)

#S5-mgm4804308.3
#http://api.metagenomics.anl.gov/1/annotation/sequence/mgm4804308.3?evalue=10&type=organism&source=SwissProt&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk
#s13_R2- https://api-ui.mg-rast.org/metagenome/72d6f57b296d676d343638363631342e33?verbosity=stats&detail=ontology&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk

#http://api.mg-rast.org/api.html#metagenome
#http://api.metagenomics.anl.gov/1/annotation/sequence/mmgm4804308.3?evalue=10&type=organism&source=SwissProt&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk

library(rjson)
S5 <- rjson::fromJSON(file="http://api.metagenomics.anl.gov/1/annotation/sequence/mgm4804308.3?evalue=10&type=organism&source=SwissProt&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk")
head(S5)

dAyu<-read.table('http://api.metagenomics.anl.gov/1/annotation/sequence/mgm4804308.3?evalue=10&type=organism&source=SwissProt&auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk',sep='')

http://api.metagenomics.anl.gov/metadata/export/mgp17042?auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk
http://api.metagenomics.anl.gov/project/mgp17042?auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk
http://api.metagenomics.anl.gov/inbox?auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk
http://api.metagenomics.anl.gov/sample/mgm4804308.3?auth=kbm2R6jxx9LSnLVNmtawtFBVtVNbk

https://www.mg-rast.org/mgmain.html?mgpage=project&project=760ca003346d67703137303432
mgp17042

https://www.mg-rast.org/mgmain.html?mgpage=pipeline

Name    class   fwd     rev
s13     Vatta   TGGAACAA        TGGAACAA
S20-2   Pita    TGGCTTCA        TGGCTTCA
S23     Pita    TGGTGGTA        TGGTGGTA
S27     Kapha   TTCACGCA        TTCACGCA
S28     Vatta   AACTCACC        AACTCACC
S2      Kapha   TCCGTCTA        TCCGTCTA
S30     Kapha   AAGAGATC        AAGAGATC
S31     Kapha   AAGGACAC        AAGGACAC
S33     Kapha   AATCCGTC        AATCCGTC
S35     Vatta   AATGTTGC        AATGTTGC
S36     Vatta   ACACGACC        ACACGACC
S37     Pita    ACAGATTC        ACAGATTC
S3      Vatta   TCTTCACA        TCTTCACA
S40     Kapha   AGATGTAC        AGATGTAC
S44     Vatta   AGCACCTC        AGCACCTC
S46     Kapha   AGCCATGC        AGCCATGC
S47     Vatta   AGGCTAAC        AGGCTAAC
S48     Vatta   ATAGCGAC        ATAGCGAC
S5      Pita    TGAAGAGA        TGAAGAGA


system("mkdir ~/R/")
system("mkdir ~/R/libs/")


system("echo 'R_LIBS_USER=\"~/R/library\"' >  $HOME/.Renviron")

install.packages('devtools',lib.loc="/home/notebook/R/library")
install.packages('devtools')

```