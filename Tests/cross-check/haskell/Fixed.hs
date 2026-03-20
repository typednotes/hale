module Main where

import Data.Fixed

main :: IO ()
main = do
  putStrLn "=== Fixed ==="
  let f1 = 3.00 :: Fixed E2
      f2 = 1.57 :: Fixed E2
  putStrLn $ "Fixed 2: " ++ show f1 ++ " + " ++ show f2 ++ " = " ++ show (f1 + f2)
