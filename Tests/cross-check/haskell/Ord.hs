module Main where

import Data.Ord (Down(..))

main :: IO ()
main = do
  putStrLn "=== Down (reversed ordering) ==="
  let d1 = Down 3
      d2 = Down 7
  putStrLn $ "compare Down(3) Down(7) = " ++ show (compare d1 d2)
  putStrLn $ "compare 3 7 = " ++ show (compare (3 :: Int) (7 :: Int))
