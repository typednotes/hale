module Main where

import Data.Ratio

main :: IO ()
main = do
  putStrLn "=== Ratio ==="
  let r1 = 1 % 2
      r2 = 1 % 3
      rsum = r1 + r2
  putStrLn $ "1/2 + 1/3 = " ++ show (numerator rsum) ++ "/" ++ show (denominator rsum)
  let rprod = r1 * r2
  putStrLn $ "1/2 * 1/3 = " ++ show (numerator rprod) ++ "/" ++ show (denominator rprod)
  putStrLn $ "floor(5/3) = " ++ show (floor (5 % 3 :: Rational) :: Integer)
  putStrLn $ "ceil(5/3) = " ++ show (ceiling (5 % 3 :: Rational) :: Integer)
