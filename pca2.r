print.pdf <- function(figure,name,extra.width=0){
	
	# Create file name
	pdf <- paste("",name,".pdf",sep="")
	
	# Convert to pdf
	trellis.device("pdf", color=TRUE)
	pdf(pdf,onefile=FALSE, paper = "special")
	print(figure)
	dev.off()
	dev.off()
	
	}

# load the crab data
library(MASS)
data(crabs)

# Perform PCA on the data
# retx returns the scores for each crab
crab.pca <- prcomp(crabs[,4:8],retx=TRUE)

# Print the rounded scores for the first three components
write.table(signif(crab.pca$rotation[,1:3],5),"rotations.tab")

#
# The discrimating factors of the second component
#
library(lattice)
second.discriminators <- xyplot(CW ~ RW,data=crabs)
second.discriminators$xlab <- "Rear width (mm)"
second.discriminators$ylab <- "Carapace width (mm)"
print.pdf(second.discriminators,"second_discriminators")

second.discriminators.density <- densityplot(~ CW/RW,data=crabs,)
second.discriminators.density$xlab <- "Carapace width, Rear width ratio"
print.pdf(second.discriminators.density,"second_discriminators_density")
# The second principle component has meaning corresponding differences in the ratio of carapace to rear width

#
# Discriminating factors for the third component
#
third.discriminators <- xyplot(BD ~ CW,data=crabs)
third.discriminators$xlab <- "Carapace width (mm)"
third.discriminators$ylab <- "Body depth (mm)"
print.pdf(third.discriminators,"third_discriminators")

third.discriminators.density <- densityplot(~ BD/CW,data=crabs,)
third.discriminators.density$xlab <- "Body depth, Carapace width ratio"
print.pdf(third.discriminators.density,"third_discriminators_density")
# The third component has meaning discriminating between body depth and carapace width


# Colors to discriminate the crab type
crab.colors <- rep(c("blue1","blue4","orange1","orange4"),1,each=50)

# Plot morphology characteristics
morphology.plot <- xyplot(BD/CW ~ CW/RW,data=crabs,col=crab.colors,pch=crabs$sex)
morphology.plot$xlab <- "Carapace width, Rear width ratio"
morphology.plot$ylab <- "Body depth, Carapace width ratio"
print.pdf(morphology.plot,"morphology_plot")

# Plot pca components
first.pca.components <- xyplot(crab.pca$x[,2] ~ crab.pca$x[,1],col=crab.colors,pch=crabs$sex)
first.pca.components$xlab <- "First component"
first.pca.components$ylab <- "Second component"
print.pdf(first.pca.components,"first_pca_components")

# Plot pca components
second.pca.components <- xyplot(crab.pca$x[,3] ~ crab.pca$x[,2],col=crab.colors,pch=crabs$sex)
second.pca.components$xlab <- "Second component"
second.pca.components$ylab <- "Third component"
print.pdf(second.pca.components,"second_pca_components")
