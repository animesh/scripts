use lib '/Home/siv11/ash022/home/cbu/2010/JSON-2.17/lib';
use JSON;
use Data::Dumper;
use LWP::Simple;

# gene queries

my @geneQ = qw (
http://www.ebi.ac.uk/gxa/api?geneGotermIs=p53+binding&geneDisease=cancer&rows=5
http://www.ebi.ac.uk/gxa/api?geneIs=ASPM&rows=5
http://www.ebi.ac.uk/gxa/api?geneIsNot=cell+cycle&rows=5
http://www.ebi.ac.uk/gxa/api?geneIs=ENSMUSG0000012344&rows=5
);

my @condQ = qw (
http://www.ebi.ac.uk/gxa/api?upIn=liver&rows=5
http://www.ebi.ac.uk/gxa/api?upIn=liver&species=Mus+musculus&rows=5
http://www.ebi.ac.uk/gxa/api?updownInOrganismpart=heart&rows=5
http://www.ebi.ac.uk/gxa/api?downInOrganismpart=kidney&upInSex=male&rows=5
http://www.ebi.ac.uk/gxa/api?geneIs=p53&downInOrganismpart=kidney&upInSex=male&rows=5
http://www.ebi.ac.uk/gxa/api?updownIn=EFO_0000302&rows=5
);

my @exptQ = qw (
http://www.ebi.ac.uk/gxa/api?experiment=E-AFMX-1&gene=top5&rows=5
http://www.ebi.ac.uk/gxa/api?experiment=cell&rows=5
http://www.ebi.ac.uk/gxa/api?experimentHasDiseasestate=normal&experiment=cancer&start=10&rows=10&rows=5
http://www.ebi.ac.uk/gxa/api?experimentHasFactor=celltype&gene=top10&rows=5
http://www.ebi.ac.uk/gxa/api?experiment=E-AFMX-5&gene=ENSG00000160766&gene=ENSG00000166337&rows=5
http://www.ebi.ac.uk/gxa/api?experiment=listAll&experimentInfoOnly&rows=5
);

#foreach(@geneQ, @condQ, @exptQ) {
foreach(@exptQ) {
	warn $_;
	my $jt = from_json(get($_));
	print Dumper($jt);
}

# TASK ONE: Mouse ASPM

my $jm = from_json(get('http://www.ebi.ac.uk/gxa/api?geneIs=ASPM&species=Mus+musculus&rows=5'));
my @expressions = @{$jm->{results}[0]->{expressions}};

foreach my $expr (@expressions) {
        if (exists $expr->{ef} ) {
                print $expr->{ef}, ": ", $expr->{efv} , "\t\t ", $expr->{upExperiments}, "/", $expr->{downExperiments}, "\n";
        } else {
                print $expr->{efoId}, ": ", $expr->{efoTerm} , "\t\t ", $expr->{upExperiments}, "/", $expr->{downExperiments}, "\n";
        }
}

# TASK TWO: ENSG00000160766 in E-AFMX-5

my $jt = from_json(get('http://www.ebi.ac.uk/gxa/api?experiment=E-AFMX-5&gene=ENSG00000160766'));
my @des = keys %{$jt->{results}[0]->{geneExpressions}->{'A-AFFY-33'}->{genes}->{'ENSG00000160766'}};

my @geneEx = @{$jt->{results}[0]->{geneExpressions}->{'A-AFFY-33'}->{genes}->{'ENSG00000160766'}->{$des[0]}};
my @assayIds = @{$jt->{results}[0]->{geneExpressions}->{'A-AFFY-33'}->{assays}};
my @assays = @{$jt->{results}[0]->{experimentDesign}->{assays}};

foreach my $aId (@assayIds) {
        my $assayFVs = $assays[$aId]->{factorValues};
        my $allAssayFVs = join ("\t\t\t\t\t", map { $_ . ": " . $assayFVs->{$_} } keys %$assayFVs);

        print $geneEx[$aId], "\t", $allAssayFVs, "\n";
}

