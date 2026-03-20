module Main where

import Data.Monoid

main :: IO ()
main = do
  putStrLn "=== Newtype wrappers ==="
  let s1 = Sum 3
      s2 = Sum 4
  putStrLn $ "Sum: " ++ show s1 ++ " ++ " ++ show s2 ++ " = " ++ show (s1 <> s2)
  let p1 = Product 3
      p2 = Product 4
  putStrLn $ "Product: " ++ show p1 ++ " ++ " ++ show p2 ++ " = " ++ show (p1 <> p2)
  let a1 = All True
      a2 = All False
  putStrLn $ "All: " ++ show a1 ++ " ++ " ++ show a2 ++ " = " ++ show (a1 <> a2)
  let o1 = Any False
      o2 = Any True
  putStrLn $ "Any: " ++ show o1 ++ " ++ " ++ show o2 ++ " = " ++ show (o1 <> o2)
  let f1 = First Nothing :: First Int
      f2 = First (Just 42)
  putStrLn $ "First: " ++ show f1 ++ " ++ " ++ show f2 ++ " = " ++ show (f1 <> f2)
