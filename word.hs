module Main where

import qualified Data.Set as S
import qualified Data.Map as M
import qualified Data.List as L
import Data.Maybe (fromMaybe)
import Control.Applicative

type SuperghostDict = M.Map String (S.Set String)

data Play = Cons Char | Snoc Char deriving (Show, Eq, Ord)

getWords :: IO [String]
getWords = filter (all (`elem` ['a'..'z'])) <$>
            lines <$>
            readFile "/usr/share/dict/words"

makeDict :: [String] -> SuperghostDict
makeDict words = M.unionWith S.union
                 (M.fromListWith S.union $
                    concatMap (\word -> let tails = L.tails word in
                                        zip (tail tails) $ map S.singleton tails)
                               words)
                 (M.fromAscList $ map (\x -> (x, S.empty)) $ words)

wordsEnding :: String -> SuperghostDict -> S.Set String
wordsEnding word dict = (fromMaybe S.empty $ M.lookup word dict)

wordsStarting :: String -> SuperghostDict -> S.Set String
wordsStarting word dict = S.fromAscList $
                            (takeWhile (word `L.isPrefixOf`) $ map fst $
                                                M.toAscList $ snd $ M.split word dict)

wordsMiddling :: String -> SuperghostDict -> S.Set String
wordsMiddling word dict = (foldr S.union S.empty
                        (map snd $ takeWhile ((word `L.isPrefixOf`) . fst) $
                                                M.toAscList $ snd $ M.split word dict))

wordsWith :: String -> SuperghostDict -> S.Set String
wordsWith word dict = (wordsEnding word dict) `S.union`
                        (wordsStarting word dict) `S.union`
                            (wordsMiddling word dict)

plays :: String -> SuperghostDict -> S.Set Play
plays word dict = (S.map (\ w -> (Snoc $ w !! (length word))) $
                        wordsStarting word dict)
                    `S.union` (S.map (\ w -> Cons $ head w)
                                $ wordsEnding word dict)
                        `S.union` (S.map (\ w -> Cons $ head w)
                                    $ wordsMiddling word dict)

apply :: String -> Play -> String
apply word (Snoc c) = word ++ [c]
apply word (Cons c) = c:word

winnable :: SuperghostDict -> String -> Bool
winnable dict word = let moves = S.toList $ plays word dict in
                        if null moves then
                            True
                        else
                            any (not . (winnable dict) . (apply word)) moves

winningPlays :: SuperghostDict -> String -> [Play]
winningPlays dict word = let moves = S.toList $ plays word dict in
                            filter (not . (winnable dict) . (apply word)) moves

forever :: (Monad m) => m a -> m ()
forever x = x >> forever x

main = do
        dict <- makeDict <$> filter ((> 3) . length) <$> getWords
        print $ winningPlays dict ""

