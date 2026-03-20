module Main where

import Data.Either

main :: IO ()
main = do
  putStrLn "=== Either ==="
  let e1 = Right 42 :: Either String Int
      e2 = Left "error" :: Either String Int
  putStrLn $ "Right 42: " ++ show e1
  putStrLn $ "Left \"error\": " ++ show e2
  let e3 = fmap (+1) e1
  putStrLn $ "map (+1) on Right 42: " ++ show e3
  let mixed = [Left "a", Right 1, Right 2, Left "b", Right 3] :: [Either String Int]
      (ls, rs) = partitionEithers mixed
  putStrLn $ "partitionEithers: lefts=" ++ show ls ++ ", rights=" ++ show rs
