#https://github.com/animesh/scripts/commit/8fd66822b7b85409b88983328ae97d608bc78b4b#diff-d592612aef70515362d5ab69e30a1b7ddff49ae376d5afbba0b286c04ac2452f
#https://api.platform.opentargets.org/api/v4/graphql/browser?operationName=assocs&query=query%20assocs%20%7B%0A%20%20search%28queryString%3A%20%22EIF3C%22%2C%20entityNames%3A%22target%22%29%20%7B%0A%09%09hits%20%7B%0A%20%20%20%20%20%20id%2C%0A%20%20%20%20%20%20name%2C%0A%20%20%20%20%09entity%2C%0A%20%20%20%20%20%20object%20%7B%0A%20%20%20%20%20%20%20%20...%20on%20Target%20%7B%0A%20%20%20%20%20%20%20%20%20%20associatedDiseases%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20count%0A%20%20%20%20%20%20%20%20%20%20%20%20rows%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20score%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20datatypeScores%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20id%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%09score%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20disease%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20id%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20name%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D%0A
#web interface https://platform.opentargets.org/target/ENSG00000184110/associations
#returns only top 50! Rows per page: 50 1-50 of 158, need to move to bigQuery@Google...
import requests
import json
import pandas as pd
colS=pd.DataFrame(columns=["ID","name","score","count", "rows"])
cntG=0;
for gene_id in genList.split():
    cntG=cntG+1
    print(cntG,gene_id)
    query_string = "query assocs {search(queryString:\""+gene_id+"\", entityNames:\"target\"){hits {id,name,entity,object { ... on Target {associatedDiseases {count rows {score datatypeScores{ id score}disease {id name}}}}}}}}"
    base_url = "https://api.platform.opentargets.org/api/v4/graphql"
    r = requests.post(base_url, json={"query": query_string})
    print(r.status_code)
    if r.status_code==200:
        api_response = json.loads(r.text)
        print(api_response)
        iD=api_response['data']['search']['hits'][0]['id']
        print(iD)
        iG=api_response['data']['search']['hits'][0]['name']
        print(iG)
        dC=api_response['data']['search']['hits'][0]['object']['associatedDiseases']['count']
        print(dC)
        if(dC>0): dS=api_response['data']['search']['hits'][0]['object']['associatedDiseases']['rows'][0]['score']
        aD=api_response['data']['search']['hits'][0]['object']['associatedDiseases']#['rows'][0]['datatypeScores']
        #print(aD)
        dataOIDP=pd.DataFrame(aD,columns=["count","rows"])
        if(dataOIDP.empty==False): print(dataOIDP.iloc[0])
        dataOIDP["ID"]=iD
        dataOIDP["name"]=iG
        dataOIDP["score"]=dS
        colS=pd.concat([colS,dataOIDP])
#print(colS)
colSs=colS['rows'].astype('str').str.split(',').str[0]
colSs=colSs.astype('str').str.split(':').str[1]
colSd=colS['rows'].astype('str').str.split(',').str[-1]
colSd=colSd.astype('str').str.split('\'').str[3]
colS["dDcore"]=colSs
colS["disease"]=colSd
colS.to_csv("openTargetResults.csv")
colScnt=colS['disease'].value_counts()
colScnt.to_csv("openTargetResultsCount.csv")
colScnt[colScnt>50].plot(kind="barh").figure.savefig("openTargetResult50D.svg",dpi=100,bbox_inches = "tight")
neoplasmL=set(colS[colS['disease']=='neoplasm'].ID)
cancerL=set(colS[colS['disease']=='cancer'].ID)
diffLnc=neoplasmL-cancerL
diffLcn=cancerL-neoplasmL
commonL=neoplasmL.intersection(cancerL)
print(len(commonL),len(diffLnc),len(diffLcn))
colGM=colS[colS.rows.astype('str').str.contains('glioblastoma multiforme')==True]
colGM.to_csv("openTargetResults_GM.csv")
genList="""
ASMTL

BCAS3

DHX37

DNAL1

FERMT3

IREB2

KIF1B

MMP15

MT-ND5

NO66

RGS10

SLC15A4

SMYD5

CCDC9

RAB33B

RB1

SMIM19

SP140L

ABCC2

KRT222

LOC101059915

ARSE

EHD3

DHCR7

PTBP2

PKM

LCP1

MAP4

PLD1

MRPL33

PTGES

MMP3

HLA-DQA1

ARL2

PPP1R14C

EMILIN2

PTGS2

UBAC2

LHFPL2

MRPL27

GHITM

NUBP1

SEC61G

ENDOG

UBL4A

NEO1

GGA2

CSMD2

NCL

EVI2B

PIP4P2

NAMPT

NCAM1

MT-CO3

PRIM1

KIDINS220

TRMT1L

C3AR1

NCBP2AS2

ECHDC1

SMIM20

HLA-DRB1

ST13P4

SLC7A1

C3

TMUB2

RPL29

CCDC127

LGALS3BP

LYPLA1

RPS27L

UFSP2

SERPINE1

TGFB1I1

HLA-DRA

TMEM132A

SLC43A3

FTH1

FAM129A

SELO

H2AC6

ANKRD17

COX6A1

MMP2

RPL23A

FUT8

RPLP1

CBX6

CERT1

MT-CO2

RFTN1

TRIM23

STX6

SCARB1

COX6C

LARP4

ACSL1

RPS20

SPTLC3

GNL3L

MET

SDCBP

FAM219B

NTPCR

TMEM159

EIF2AK2

MAN1A1

NDUFA4

TATDN1

ATXN2

RPS29

VAMP5

PAIP1

RAB1B

RPS17

RPSA

RPS25

MLLT4

CLCN3

GTF2H5

SERPINH1

RPS15

SMIM10

COX7A2L

RFC1

HECW2

RPS5

ATP2B1

PTBP3

RPLP2

ACBD3

TMEM65

C7orf50

LINC00301

EIF1AX

RAC2

SUMO1

SPTBN4

USP10

HSPA8

PLAA

THOC2

ACTN4

NUP107

TXNDC12

TLDC1

VPS35L

COIL

UGGT1

LIG3

SCAMP1

CTBP1

MKRN2

GRHPR

SUPT6H

CHTOP

EIF3G

EPHB2

PDS5B

SNX17

LYPLA2

CCAR1

HAUS3

EIF3M

LRWD1

FLOT1

RAI1

STXBP3

MESDC2

GIPC1

HMGCL

THOC3

PRPF3

TNPO1

HMOX1

AGTRAP

ARHGEF2

DARS2

LMNA

SYNPO

USP7

TOM1L2

WDR61

CDKAL1

HIBADH

CALCOCO2

VPS16

H2AC21

PCM1

ERGIC1

ABCC4

TPD52L2

PRDX4

NAGA

CTNNAL1

DCBLD2

NUP88

ZCCHC17

TGFBI

TUBB3

RAB13

SEL1L3

CCDC22

OGT

PAPD5

ATG9A

ACOX3

BAZ1A

RHOT2

DHX8

STAM2

SLC9A8

PPA2

CTNNB1

CINP

HM13

FH

MMAB

NPTXR

ING2

TRIP12

ASF1A

HM13

HOMER3

ACSF2

PRDX6

ARHGEF1

FRRS1

MBD1

PHC2

EMC9

SLC9A3R1

PLOD1

GGT7

HNRNPU

ERAL1

PREPL

MCCC1

FAIM

PCYOX1

COL7A1

AMPD2

TFB2M

PLOD2

CTSS

PRDX3

IDH1

ANKRD13A

GPATCH4

CNDP2

PLCB3

H1-0

CCDC97

R3HDM2

FLNB

TMX3

PDGFRB

VPS8

DNAJC3

COL6A3

LRRC1

PLOD3

MSI2

VPS45

SEC11C

ARHGEF11

ARFRP1

TNFRSF10D

TOR1AIP1

GTPBP3

PID1

PMVK

OSBPL1A

IAH1

IGSF8

GPATCH11

LMAN1

NDFIP2

DIP2C

HTRA1

PRRX1

RBPJ

PYCR1

MED11

SUMF2

NNT

P3H3

PDSS1

RNF170

CRLF3

DUSP12

SFR1

EXTL2

GATAD2B

C2CD2

INF2

RPRD2

KDSR

TRIOBP

NBR1

EPHA2

NDRG1

TMCO3

PUF60

P4HA2

CERS2

SCAMP3

S100A6

RNF219

TAGLN2

HAS1

DENND10

ABCB6

MYDGF

CTIF

CDC42EP1

TXNL1

MCAM

MRC2

VPS4B

RTN1

COMT

ADGRG1

ZNF687

SMAD4

HDHD2

HDGF

CEP170

PDZD8

GALE

GOLPH3L

CYB5A

SNX27

HSPB1

PDDC1

FRMD1

ABCC3

ALDH2

IFI16

THEM4

DDR2

ENDOD1

CA9

NEDD4L

ANP32E

SDF4

FECH

COL6A1

VTI1A

PIP5K1A

SHCBP1

TBC1D13

DPP4

TPM1

COL6A2

SHC1

KCTD5

FAM188B

TARS2

C3orf38

ERMP1

SV2A

PCBD1

RAB11FIP2

CDC42SE1

SYNE3

STRBP

KIF5A

SBSN

PAXX

VTA1

RTN1

HAX1

PEX19

ENTR1

SLC27A3

DPP7

TBC1D4

RELCH

PEA15

TDRKH

S100A13

EPB41

TXNL4A

SYBU

DSG2

BACE2

S100A16

RILPL1

PPP2R3A

SLC1A3

GSTM4

PLPP2

HSPB6

KCTD12

PPOX

P3H2

ENSA

TGM2

SERPINB7

ARMCX2

GLS

GYPC

RPRD1A

CD33

SLC1A1

SLC39A6

FABP5

SPRY2

CXADR

NES

GAP43

ACTL8

ANAPC16

ARG2

ARMCX4

ASS1

ATF6

C20orf144

CASKIN2

CPNE7

ECM1

ERBIN

ERRFI1

FKBP11

GAPDH

GYS1

HECTD1

HNRNPM

ICAM1

IFRD2

LAMA5

LIX1L

MAGEC1

MXRA8

NRAS

PBX2

PUSL1

RAB7B

RCN3

RGPD5

SGO1

SNCA

STX16

TAGLN3

TCP11L1

TLE1

VSNL1

XPA

ZDHHC2

ZMYND8

ACO2

PTK7

SKA1

SNRNP27

BCLAF1

CRTC2

DTX3L

EIF3C

"""