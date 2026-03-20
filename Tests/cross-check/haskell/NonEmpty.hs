module Main where

import Data.List.NonEmpty (NonEmpty(..))
import qualified Data.List.NonEmpty as NE

main :: IO ()
main = do
  putStrLn "=== NonEmpty ==="
  let ne = 1 :| [2, 3, 4, 5]
  putStrLn $ "NonEmpty: " ++ show (NE.toList ne)
  putStrLn $ "  head: " ++ show (NE.head ne)
  putStrLn $ "  last: " ++ show (NE.last ne)
  putStrLn $ "  length: " ++ show (NE.length ne)
  let ne2 = fmap (*10) ne
  putStrLn $ "  map (*10): " ++ show (NE.toList ne2)
