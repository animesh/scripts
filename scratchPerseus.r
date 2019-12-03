#devtools::install_github('jdrudolph/PerseusR')
# All plugins can be split into 3 parts
# 1. Reading the command line arguments provided by Perseus and parsing the data.
# 2. Perform the desired functionality on the data.
# 3. Write the results to the expected locations in the Perseus formats.
# 1. Parse command line arguments passed in from Perseus,
# including input file and output file paths.
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
	stop("Do not provide additional arguments!", call.=FALSE)
}
inFile <- args[1]
outFile <- args[2]
# Use PerseusR to read and write the data in Perseus text format.
library(PerseusR)
#https://rdrr.io/cran/PerseusR/man/singleChoiceParamInd.html
#tmp <- tempfile(fileext = ".xml")
#write('<SingleChoiceParam Name="test_single">\n<Value>1</Value>\n
#<Values>\n<Item>A</Item>\n<Item>B</Item>\n</Values>\n</SingleChoiceParam>', file=tmp)
#parameters <- parseParameters(tmp)
#singleChoiceParamInd(parameters, "test_single")
#inFile <- tempfile(fileext = ".txt")
#write('Column_1\tColumn_2\tColumn_3\n#!{Description}\t\t\n#!{Type}E\tE\tE\n-1.860574\t-0.3910594\t0.2870352\nNaN\t-0.4742951\t0.849998', file=inFile)
mdata <- read.perseus(inFile)
# The mdata object can be easily deconstructed into a number of different
# data frames. Check reference manual or help() for full list.
mainMatrix <- main(mdata)
# 2. Run any kind of analysis on the extracted data.
df <- mainMatrix + 1
# 3. Create a matrixData object which can be conveniently written to file
# in the Perseus txt format.
outMdata <- matrixData(main=df)
write.perseus(outMdata, outFile)
