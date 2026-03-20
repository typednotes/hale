module Main where

import Data.Complex

main :: IO ()
main = do
  putStrLn "=== Complex ==="
  let z1 = 3 :+ 4 :: Complex Int
      z2 = 1 :+ (-2) :: Complex Int
  putStrLn $ "z1 = " ++ show z1
  putStrLn $ "z2 = " ++ show z2
  putStrLn $ "|z1|^2 = " ++ show (realPart z1 * realPart z1 + imagPart z1 * imagPart z1)
