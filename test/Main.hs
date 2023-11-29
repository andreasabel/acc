{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Acc
import qualified Data.List.NonEmpty as NonEmpty
import Test.QuickCheck.Instances ()
import Test.Tasty
import Test.Tasty.QuickCheck
import Prelude hiding (assert)

main :: IO ()
main =
  defaultMain
    $ testGroup
      "All tests"
      [ testProperty "Acc converted to list and reconstructed from it converts to the same list again"
          $ \(acc :: Acc Int) ->
            let list =
                  toList acc
                acc' :: Acc Int
                acc' =
                  fromList list
                list' =
                  toList acc'
             in list === list',
        testProperty "foldl"
          $ \(acc :: Acc Int) ->
            foldl (flip (:)) [] acc
              === foldl (flip (:)) [] (toList acc),
        testProperty "foldl'"
          $ \(acc :: Acc Int) ->
            foldl' (flip (:)) [] acc
              === foldl' (flip (:)) [] (toList acc),
        testProperty "foldr"
          $ \(acc :: Acc Int) ->
            foldr (:) [] acc
              === foldr (:) [] (toList acc),
        testProperty "foldr'"
          $ \(acc :: Acc Int) ->
            foldr' (:) [] acc
              === foldr' (:) [] (toList acc),
        testProperty "foldMap"
          $ \(acc :: Acc Int) ->
            foldMap (: []) acc
              === foldMap (: []) (toList acc),
        testProperty "foldMap'"
          $ \(acc :: Acc Int) ->
            foldMap' (: []) acc
              === foldMap' (: []) (toList acc),
        testProperty "toNonEmpty"
          $ \(acc :: Acc Int) ->
            Acc.toNonEmpty acc
              === NonEmpty.nonEmpty (toList acc)
      ]

instance (Arbitrary a) => Arbitrary (Acc a) where
  arbitrary =
    accGen arbitrary

accGen :: Gen a -> Gen (Acc a)
accGen aGen =
  oneof
    [ listAccGen aGen,
      appendAccGen aGen,
      pureAccGen aGen
    ]

listAccGen :: Gen a -> Gen (Acc a)
listAccGen aGen =
  fromList <$> listOf aGen

appendAccGen :: Gen a -> Gen (Acc a)
appendAccGen aGen =
  (<>) <$> accGen aGen <*> accGen aGen

pureAccGen :: Gen a -> Gen (Acc a)
pureAccGen aGen =
  pure <$> aGen
