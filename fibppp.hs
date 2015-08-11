    import Control.Parallel
    import Control.Monad
    import Text.Printf

    cutoff = 35

    fib' :: Int -> Integer
    fib' 0 = 0
    fib' 1 = 1
    fib' n = fib' (n-1) + fib' (n-2)

    fib :: Int -> Integer
    fib n | n < cutoff = fib' n
          | otherwise  = r `par` (l `pseq` l + r)
     where
        l = fib (n-1)
        r = fib (n-2)

    main = forM_ [0..45] $ \i ->
                printf "n=%d => %d\n" i (fib i)
