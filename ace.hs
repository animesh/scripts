-- ace2contigs
-- Extract the contigs with quality information from ace file

module Main where
import Prelude hiding (reads)
import Bio.Sequence
import Bio.Alignment.ACE
import System.Environment (getArgs)

main :: IO ()
main = do
 [ace] <- getArgs
 a <- readACE ace
 let cs = map (fst . contig) $ concat a
 writeFastaQual (ace++".fasta") (ace++".qual") cs
