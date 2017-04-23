import Text.Printf
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
main = flip mapM_ [0..35] $ \i ->
       printf "n=%d => %d\n" i (fib i)
