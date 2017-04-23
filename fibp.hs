import Control.Parallel
import Control.Monad
import Text.Printf    
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = l `pseq` r `pseq` l+r
    where
      l = fib (n-1)
      r = fib (n-2)
main = forM_ [0..35] $ \i ->
       printf "n=%d => %d\n" i (fib i)