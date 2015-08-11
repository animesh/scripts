main = flip mapM_ [1..5] $ \i -> do
  putStrLn $ show i

