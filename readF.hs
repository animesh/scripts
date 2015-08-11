module Main where
import Data.List (partition)

main :: IO ()
main = readFile "fasta.seq" >>= \xs -> print (count xs)

count str = let (cg,at) = partition (\x->x=='c'||x=='g') . concat . filter ((/='>').head) . lines $ str
            in fromIntegral (length cg) / fromIntegral (length cg+length at)
