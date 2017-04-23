Reviewer's report 1:
Discovering biomarkers from gene expression data for predicting cancer subgroups using neuraTitle: l
networks and relational fuzzy clustering
Version: 1 Date: 18 September 2006
Reviewer number: 1
Reviewer's report:
General
The manuscript by Pal, et al., discusses a method for simultaneously
selecting genes or probes, and training a classifier, on microarray data.
The result is a very short list of genes which perform very well in
classifying the training and test samples, even when passed to a different
classifier algorithm such as SVM. I am quite pleased with this manuscript
in general, and believe the authors' approach is promising and of
interest. I have some concerns which I believe the authors can easily
address before publication.
-------------------------------------------------------------------------------
Major Compulsory Revisions (that the author must respond to before a decision on publication can be
reached)
1. In this particular case, the authors' methodology resulted in a much
shorter list of critical genes than other works have found for classifying
these samples. I think, though, that one example is insufficient to prove
that this shorter list is a guaranteed outcome. The authors should
provide some evidence or theoretical treatment to show that their method
will provide shorter lists in general, or de-emphasize the claim.
2. The authors stress that their neural net classifier can make use of
subtle nonlinearities in gene-gene interactions. However, the same genes
perform equally well as the basis for an SVM classifier, which would seem
to indicate that nonlinear interactions are not in fact important for the
classification problem. The authors should adduce some evidence that
nonlinearity is important, or de-emphasize the claim.
3. The intermediate step of fuzzy clustering, in order to reduce the
number of critical genes, would seem to involve a fair amount of
judgement. How much judgement is actually involved (consider the choice
of starting genes, number of clusters, etc.), and how much is this likely
to bias the classifier? The authors should comment on the practicality of
automating this process - I believe automation to be critical in winning
widespread acceptance for any method of microarray analysis. In this
context, it's not clear to me why two genes were preserved from the first
cluster - why not just one? Are both required for proper classification,
and if so, why does clustering not separate them? Should more genes be
included in the cluster, beyond the twenty selected?
-------------------------------------------------------------------------------
Minor Essential Revisions (such as missing labels on figures, or the wrong use of a term, which the author
can be trusted to correct)
4. The suggestion of a specialized microarray is well-taken, but
impractical for a number of reasons. It's very difficult to properly
analyze an array with so few genes, even if spotted in large numbers.
More importantly, there are more accurate and less expensive methods for
quantifying small numbers of transcripts, such as various PCR assays.
-------------------------------------------------------------------------------
Discretionary Revisions (which the author can choose to ignore)
Accept after discretionary revisionWhat next?: s
Level of interest: An article whose findings are important to those with closely related research interests
Quality of written English: Acceptable
Statistical review: No




Reviewer's report  2
Discovering biomarkers from gene expression data for predicting cancer subgroups using neuraTitle: l
networks and relational fuzzy clustering
Version: 1 Date: 26 September 2006
Reviewer number: 2
Reviewer's report:
General
The authors applied a novel methodology consisting of two procedures (a multi-layered neural net
conjoined to a fuzzy clustering procedure) applied to a set of expression data for a collection of four tumor
types. The goal was classification with the least number of classifiers, which their method did with seven
classifying genes and 100% accuracy in both the training and test tumor subsets. The method is logical and
clearly presented, and does as well or better than several other published analyses of the same data set,
and does so with less classifying genes. The specific manner that the neural network and clustering are
employed is clearly presented and appears to be reproducible.
-------------------------------------------------------------------------------
Major Compulsory Revisions (that the author must respond to before a decision on publication can be
reached)
There are no suggested cumpulsory revisions.
-------------------------------------------------------------------------------
Minor Essential Revisions (such as missing labels on figures, or the wrong use of a term, which the author
can be trusted to correct)
There are no essential revisions.
-------------------------------------------------------------------------------
Discretionary Revisions (which the author can choose to ignore)
1) The tumor data set employed in this paper shows strongly differential gene expression. Other studies
have also achieved 100% accurate classification with this same data set. This is somewhat unique in cases
where novel aids in clinical classification are needed, and most attempted applications of classification in
oncology must accept a higher error rate, suggesting less differential expression between the tumor classes
than found between the SRBC tumor types. The authors may want to temper their enthusiasm until this
method has been applied to other classification problems, such as other tumor types or SRBCT's from
another cohort. The growing interest in ensembles in classification problems is rooted in a repeatedly
observed need for greater diversity in classifiers than is strictly necessary in the training data set. While this
doesn't distract from the need to discern a minimal set of classifiers, its not clear from this one study that this
method gives a complete answer. It may be advisiable to acknowledge this uncertainty in this paper.
2) The authors discuss that a set of seven classifiers could be used in a specialized microarray with the
features repeated enough times to be visible to the naked eye. With this small number of classifers
antibody-based approaches also become feasible, and likely would be more cost effective.
What next?: Accept after discretionary revisions
Level of interest: An article whose findings are important to those with closely related research interests
Quality of written English: Acceptable
Statistical review: No


Reviewer's report  3
Discovering biomarkers from gene expression data for predicting cancer subgroups using neuraTitle: l
networks and relational fuzzy clustering
Version: 1 Date: 29 September 2006
Reviewer number: 3
Reviewer's report:
General
The authors propose a computational framework for selecting informative features from gene expression
data which can be used to identify biomarkers and predict subgroups of samples within pre-defined
populations.
The addressed questions are not entirely new, although still representing challenging issues in the field of
microarray data analysis. In particular, a valuable topic is the detection of genes whose expression patterns
are more complex than the simple difference in the average level. Similarly, the identification and
characterization of subgroups within a set of pathological samples is a notable issue.
No new data is presented; rather four publicly available datasets are used for this analysis. Title and the
abstract are appropriate, as well as most of the references to existing work. Finally, while for the most part
the writing is fluid, troubles can be encountered with the wording of some sections. Eventually, the authors
should re-review the manuscript grammatically but this does not detract from the technical understanding of
the paper.
-------------------------------------------------------------------------------
Major Compulsory Revisions (that the author must respond to before a decision on publication can be
reached)
1. The Results section, and in particular the discussion of 6 out of 7 biomarkers (pages 4 and 5 and Figure
1), represents the major problem of this manuscript. Indeed in this section, NAB2, EHD1, CDH2, FGFR4,
LSP1, and AF1Q are described as biomarkers of the wrong classes and are plotted accordingly (and
wrongly) in Figure 1. NAB2 is described as “highly upregulated in Non-Hodgkin lymphoma (NHL) and in a
few cases of RMS, while in majority of RMS and EWS cases it is moderately expressed” while is
upregulated in EWS. This can be easily verified in Khan’s original data and is also reported by the authors
on the diagnostic rule for EWS in page 6. Similarly, authors state that they “observed that EHD1 expression
is practically absent for RMS, NB and NHL groups of tumors, while for the EWS group it is highly
expressed”. This is wrong, since EHD1 marks the BL-NHL class. Even more disturbing are the descriptions
of CDH2, FGFR4, and AF1Q identified as markers of classes RMS, NB, and RMS respectively while a
simple, visual inspection of the original data (and of Figure 3b in Khan’s paper) clearly indicates that CDH2
marks NB samples, FGFR4 marks RMS and AF1Q is a biomarker of NB samples. All these descriptions
and the scatter plots of Figure 1 clearly contradict the 4 diagnostic rules reported in page 6.
2. As concerning the computational approach, the authors should clarify their choices in terms of network
topology (why 150 is an appropriate number of hidden nodes? Has been the network architecture optimized
in any way?) and gene selection approach (for which value a node is consider “reasonably open”? Based
on which threshold or ranking do they select 20 genes?). Most of their choices seems rather arbitrary and
need to be justified in quantitative terms.
-------------------------------------------------------------------------------
Minor Essential Revisions (such as missing labels on figures, or the wrong use of a term, which the author
can be trusted to correct)
1. Samples should be indicated as SRBCT and not as SRBT throughout the text.
2. On pages 4 and 5, the authors cite Liu et al., 2005. It is unclear the citation of “Liu L, Cara DC, Kaur J,
Raharjo E, Mullaly SC, Jongstra-Bilen J, Jongstra J, Kubes P (2005) LSP1 is an endothelial gatekeeper of
leukocyte transendothelial migration. J Exp Med 201: 409- 418” in this context.
-------------------------------------------------------------------------------
Discretionary Revisions (which the author can choose to ignore)
What next?: Reject because scientifically unsound
An article of limited interesLevel of interest: t
Quality of written English: Needs some language corrections before being published
Statistical review: No
