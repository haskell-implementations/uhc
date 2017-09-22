%%[99
-- {-# LANGUAGE NoGenericDeriving #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE BangPatterns #-}

module UHC.BaseThree   -- adapted from the Hugs prelude
(
-- Classes
    Eq         (..),
    Ord        (..),
    Bounded    (..),
    Num        (..),
    Real       (..),
    Integral   (..),
    -- Fractional (..),
    -- Floating   (..),
    -- RealFrac   (..),
    -- RealFloat  (..),
    Enum       (..),
    Functor    (..),
    Monad      (..),
    Show       (..),
    Read       (..),

-- Types
    ''[]''     (..),
    Bool       (..),
    Maybe      (..),
    Either     (..),
    Ordering   (..),
    Ratio      (..), (%), 
    Char, 
    Int, 
    String,
    Integer, 
    Float, 
    Double, 
    IO,
    ShowS,
    ReadS,
    Rational, 

    IO            (..), 
    -- IOResult      (..),
    State         (..),
    IOWorld, ioWorld,
    RealWorld, realWorld,
    
        -- IO Exception
    SomeException'(..),
    ArithException(..),
    ArrayException(..),
    AsyncException(..),
    IOException       ,
    ExitCode      (..),
#if defined (__UHC_TARGET_C__) || defined (__UHC_TARGET_LLVM__)
    forceString,
#else
    throw,
#endif

--  dangerous functions
    asTypeOf, error, undefined, seq, ($!),
 
 
-- functions on specific types    
    -- Bool
    (&&), (||), not, otherwise,
    -- Char
    isSpace, isUpper, isLower, isAlpha, isDigit, 
    isOctDigit, isHexDigit, 
    isAlphaNum, showLitChar, 
    -- readLitChar, 
    lexLitChar,
    -- Ratio
    numerator, denominator,
    -- Maybe
    maybe, 
    -- Either
    either,
 
-- overloaded functions
    mapM, mapM_, sequence, sequence_, (=<<),
    subtract, even, odd, gcd, lcm, (^), 
    -- (^^), 
    absReal, signumReal,
    fromIntegral, 
    -- realToFrac,
    boundedSucc, boundedPred, boundedEnumFrom, boundedEnumFromTo, boundedEnumFromThen, boundedEnumFromThenTo,
    shows, showChar, showString, showParen,
    reads, read, lex, readParen, 
    -- readSigned, readInt, readDec, readOct, readHex, readSigned, readFloat, 
    lexDigits, 
    -- fromRat,

--  standard functions
    fst, snd, curry, uncurry, id, const, (.), flip, ($), until,
    map, (++), concat, filter,
    head, last, tail, init, null, length, (!!),
    foldl, foldl1, scanl, scanl1, foldr, foldr1, scanr, scanr1,
    iterate, repeat, replicate, cycle,
    take, drop, splitAt, takeWhile, dropWhile, span, break,
    lines, words, unlines, unwords, reverse, and, or,
    any, all, elem, notElem, lookup,
    sum, product, maximum, minimum, concatMap, 
    zip, zip3, zipWith, zipWith3, unzip, unzip3,

--  standard functions for Char
    ord, chr,

-- IO functions
    ioFromPrim,

-- Unsafe
    unsafeCoerce,

-- EHC specific functions
    PackedString,
    packedStringToString, packedStringToInteger, primIntToInteger,
    primGtInt, primEqChar,
    ByteArray,

-- EHC primitives, only exported to UHC. modules, hidden outside Prelude
    -- primEqInt,
    
-- System
    exitWithIntCode,

-- StackTrace
    ExplicitStackTrace,
    ImplicitStackTrace,
    pushExplicitStackTrace,

-- Generics
  -- * Generic representation types
    V1, U1(..), Par1(..), Rec1(..), K1(..), M1(..)
  , (:+:)(..), (:*:)(..), (:.:)(..)

  -- ** Synonyms for convenience
  , Rec0(..), Par0(..), R, P
  , D1(..), C1(..), S1(..), D, C, S

  -- * Meta-information
  , Datatype(..), Constructor(..), Selector(..)
  , Arity(..), Fixity(..), Associativity(..)
  , NoSelector

  -- * Representable type classes
  , Representable0(..), Representable1(..)

  -- * Dummy class
  , Generic

) where

import UHC.BaseTwo

#include "IntLikeInstance.h"

--------------------------------------------------------------
-- Operator precedences
--------------------------------------------------------------

infixr 9  .
infixl 9  !!
infixr 8  ^, ^^, **
infixl 7  *, /, `quot`, `rem`, `div`, `mod`, :%, %
infixl 6  +, -
infixr 5  :
infixr 5  ++
infix  4  ==, /=, <, <=, >=, >, `elem`, `notElem`
infixr 3  &&
infixr 2  ||
infixl 1  >>, >>=
infixr 1  =<<
infixr 0  $, $!, `seq`

-- numericEnumFrom        :: Num a => a -> [a]
-- numericEnumFromThen    :: Num a => a -> a -> [a]
-- numericEnumFromTo      :: (Ord a, Fractional a) => a -> a -> [a]
-- numericEnumFromThenTo  :: (Ord a, Fractional a) => a -> a -> a -> [a]
-- numericEnumFrom n            = iterate' (+1) n
-- numericEnumFromThen n m      = iterate' (+(m-n)) n
-- numericEnumFromTo n m        = takeWhile (<= m+1/2) (numericEnumFrom n)
-- numericEnumFromThenTo n n' m = takeWhile p (numericEnumFromThen n n')
--                                where p | n' >= n   = (<= m + (n'-n)/2)
--                                        | otherwise = (>= m + (n'-n)/2)

-- iterate' :: (a -> a) -> a -> [a]        -- strict version of iterate
-- #if defined (__UHC_TARGET_C__) || defined (__UHC_TARGET_LLVM__)
-- iterate' f x = x : (iterate' f $! f x)
-- #else
-- iterate' f x = x : (let !fx = f x in iterate' f fx)
-- #endif

-- -- --------------------------------------------------------------
-- -- -- Numeric classes: Num, Real, Integral, 
-- -- --                  Fractional, Floating, 
-- -- --                  RealFrac, RealFloat
-- -- --------------------------------------------------------------

-- class (Num a) => Fractional a where
--     (/)          :: a -> a -> a
--     recip        :: a -> a
--     fromRational :: Rational -> a
--     fromDouble   :: Double -> a

--     -- Minimal complete definition: fromRational and ((/) or recip)
--     recip x       = 1 / x
--     -- fromDouble x  = fromRational (fromDouble x)
--     x / y         = x * recip y


-- class (Fractional a) => Floating a where
--     pi                  :: a
--     exp, log, sqrt      :: a -> a
--     (**), logBase       :: a -> a -> a
--     sin, cos, tan       :: a -> a
--     asin, acos, atan    :: a -> a
--     sinh, cosh, tanh    :: a -> a
--     asinh, acosh, atanh :: a -> a

--     -- Minimal complete definition: pi, exp, log, sin, cos, sinh, cosh,
--     --                              asinh, acosh, atanh
--     pi                   = 4 * atan 1
--     x ** y               = exp (log x * y)
--     logBase x y          = log y / log x
--     sqrt x               = x ** 0.5
--     tan x                = sin x / cos x
--     sinh x               = (exp x - exp (-x)) / 2
--     cosh x               = (exp x + exp (-x)) / 2
--     tanh x               = sinh x / cosh x
--     asinh x              = log (x + sqrt (x*x + 1))
--     acosh x              = log (x + sqrt (x*x - 1))
--     atanh x              = (log (1 + x) - log (1 - x)) / 2

-- class (Real a, Fractional a) => RealFrac a where
--     properFraction   :: (Integral b) => a -> (b,a)
--     truncate, round  :: (Integral b) => a -> b
--     ceiling, floor   :: (Integral b) => a -> b

--     -- Minimal complete definition: properFraction
--     truncate x        = m where (m,_) = properFraction x

--     round x           = let (n,r) = properFraction x
--                             m     = if r < 0 then n - 1 else n + 1
--                         in case signum (abs r - 0.5) of
--                             -1 -> n
--                             0  -> if even n then n else m
--                             1  -> m

--     ceiling x         = if r > 0 then n + 1 else n
--                         where (n,r) = properFraction x

--     floor x           = if r < 0 then n - 1 else n
--                         where (n,r) = properFraction x
-- {-----------------------------
--     -- Minimal complete definition: properFraction
--     truncate x :: xt  = m where (m::xt,_) = properFraction x

--     round x :: xt     = let (n::xt,r) = properFraction x
--                             m     = if r < 0 then n - 1 else n + 1
--                         in case signum (abs r - 0.5) of
--                             -1 -> n
--                             0  -> if even n then n else m
--                             1  -> m

--     ceiling x :: xt   = if r > 0 then n + 1 else n
--                         where (n::xt,r) = properFraction x

--     floor x :: xt     = if r < 0 then n - 1 else n
--                         where (n::xt,r) = properFraction x
-- -----------------------------}


-- class (RealFrac a, Floating a) => RealFloat a where
--     floatRadix       :: a -> Integer
--     floatDigits      :: a -> Int
--     floatRange       :: a -> (Int,Int)
--     decodeFloat      :: a -> (Integer,Int)
--     encodeFloat      :: Integer -> Int -> a
--     exponent         :: a -> Int
--     significand      :: a -> a
--     scaleFloat       :: Int -> a -> a
--     isNaN, isInfinite, isDenormalized, isNegativeZero, isIEEE
--                      :: a -> Bool
--     atan2            :: a -> a -> a

--     -- Minimal complete definition: All, except exponent, signficand,
--     --                              scaleFloat, atan2
--     exponent x        = if m==0 then 0 else n + floatDigits x
--                         where (m,n) = decodeFloat x
--     significand x     = encodeFloat m (- floatDigits x)
--                         where (m,_) = decodeFloat x
--     scaleFloat k x    = encodeFloat m (n+k)
--                         where (m,n) = decodeFloat x
--     atan2 y x
--       | x>0           = atan (y/x)
--       | x==0 && y>0   = pi/2
--       | x<0 && y>0    = pi + atan (y/x)
--       | (x<=0 && y<0) ||
--         (x<0 && isNegativeZero y) ||
--         (isNegativeZero x && isNegativeZero y)
--                       = - atan2 (-y) x
--       | y==0 && (x<0 || isNegativeZero x)
--                       = pi    -- must be after the previous test on zero y
--       | x==0 && y==0  = y     -- must be after the other double zero tests
--       | otherwise     = x + y -- x or y is a NaN, return a NaN (via +)

--------------------------------------------------------------
-- Overloaded numeric functions
--------------------------------------------------------------

-- (^^)           :: (Fractional a, Integral b) => a -> b -> a
-- x ^^ n          = if n >= 0 then x ^ n else recip (x^(-n))

-- realToFrac     :: (Real a, Fractional b) => a -> b
-- realToFrac      = fromRational . toRational

-- --------------------------------------------------------------
-- -- class Read, Show
-- --------------------------------------------------------------


class Read a where
    readsPrec :: Int -> ReadS a
    readList  :: ReadS [a]

    -- Minimal complete definition: readsPrec
    readList  :: ReadS [a]
               = readParen False (\r -> [pr | ("[",s) <- lex r,
                                              pr      <- readl s ])
                 where readl :: ReadS [a]
                       readl  s = [([],t)   | ("]",t) <- lex s] ++
                                  [(x:xs,u) | (x,t)   <- reads s,
                                              (xs,u)  <- readl' t]
                       readl' :: ReadS [a]
                       readl' s = [([],t)   | ("]",t) <- lex s] ++
                                  [(x:xs,v) | (",",t) <- lex s,
                                              (x,u)   <- reads t,
                                              (xs,v)  <- readl' u]


sequence       :: Monad m => [m a] -> m [a]
sequence []     = return []
sequence (c:cs) = do x  <- c
                     xs <- sequence cs
                     return (x:xs)

--mapM             :: Monad m => (a -> m b) -> [a] -> m [b]
mapM             :: forall a b . Monad m => (a -> m b) -> [a] -> m [b]
mapM f            = sequence . map f

-- instance Read Char where
--     readsPrec p      = readParen False
--                             (\r -> [(c,t) | ('\'':s,t) <- lex r,
--                                             (c,"\'")   <- readLitChar s ])
--     readList = readParen False (\r -> [(l,t) | ('"':s, t) <- lex r,
--                                                (l,_)      <- readl s ])
--                where readl ('"':s)      = [("",s)]
--                      readl ('\\':'&':s) = readl s
--                      readl s            = [(c:cs,u) | (c ,t) <- readLitChar s,
--                                                       (cs,u) <- readl t ]


-- --------------------------------------------------------------
-- -- Maybe type
-- --------------------------------------------------------------

-- --------------------------------------------------------------
-- -- Lists
-- --------------------------------------------------------------

-- instance Read a => Read [a]  where
--     readsPrec p = readList


-- --------------------------------------------------------------
-- -- Int type
-- --------------------------------------------------------------
-- -- type Int builtin

-- instance Read Int where
--     readsPrec p = readSigned readDec


-- instance Read Integer where
--     readsPrec p = readSigned readDec


-- --------------------------------------------------------------
-- -- Float and Double type
-- --------------------------------------------------------------

-- instance Real Float where
--     toRational = floatToRational

-- instance Real Double where
--     toRational = doubleToRational

-- -- TODO: Calls to these functions should be optimised when passed as arguments to fromRational
-- floatToRational  :: Float  -> Rational
-- doubleToRational :: Double -> Rational
-- floatToRational  x = fromRat x 
-- doubleToRational x = fromRat x

-- fromRat :: RealFloat a => a -> Rational
-- fromRat x = (m%1)*(b%1)^^n
--           where (m,n) = decodeFloat x
--                 b     = floatRadix x


-- instance Fractional Float where
--     (/)          = primDivideFloat
--     recip        = primRecipFloat
--     fromRational = primRationalToFloat
--     fromDouble   = primDoubleToFloat

-- foreign import prim primDivideDouble :: Double -> Double -> Double
-- foreign import prim primRecipDouble :: Double -> Double

-- instance Fractional Double where
--     (/)          = primDivideDouble
--     recip        = primRecipDouble
--     fromRational = primRationalToDouble
--     fromDouble x = x

{-----------------------------
-- These primitives are equivalent to (and are defined using) 
-- rationalTo{Float,Double}.  The difference is that they test to see
-- if their argument is of the form (fromDouble x) - which allows a much
-- more efficient implementation.
primitive primRationalToFloat  :: Rational -> Float
primitive primRationalToDouble :: Rational -> Double
-----------------------------}

{-----------------------------
-- These functions are used by Hugs - don't change their types.
rationalToFloat  :: Rational -> Float
rationalToDouble :: Rational -> Double
rationalToFloat  = rationalToRealFloat
rationalToDouble = rationalToRealFloat

rationalToRealFloat x = x'
 where x'    = f e
       f e   = if e' == e then y else f e'
               where y      = encodeFloat (round (x * (1%b)^^e)) e
                     (_,e') = decodeFloat y
       (_,e) = decodeFloat (fromInteger (numerator x) `asTypeOf` x'
                             / fromInteger (denominator x))
       b     = floatRadix x'
-----------------------------}

-- primitive Float functions

-- #if defined( __UHC_TARGET_JAZY__ )
-- foreign import prim  primSinFloat   :: Float -> Float
-- foreign import prim  primCosFloat   :: Float -> Float
-- foreign import prim  primTanFloat   :: Float -> Float
-- foreign import prim  primAsinFloat  :: Float -> Float
-- foreign import prim  primAcosFloat  :: Float -> Float
-- foreign import prim  primAtanFloat  :: Float -> Float
-- foreign import prim  primExpFloat   :: Float -> Float
-- foreign import prim  primLogFloat   :: Float -> Float
-- foreign import prim  primSqrtFloat  :: Float -> Float
-- foreign import prim  primAtan2Float :: Float -> Float -> Float
-- #elif defined(__UHC_TARGET_JS__) || defined(__UHC_TARGET_CR__)
-- foreign import prim "primSinDouble"  primSinFloat   :: Float -> Float
-- foreign import prim "primCosDouble"  primCosFloat   :: Float -> Float
-- foreign import prim "primTanDouble"  primTanFloat   :: Float -> Float
-- foreign import prim "primAsinDouble" primAsinFloat  :: Float -> Float
-- foreign import prim "primAcosDouble" primAcosFloat  :: Float -> Float
-- foreign import prim "primAtanDouble" primAtanFloat  :: Float -> Float
-- foreign import prim "primExpDouble"  primExpFloat   :: Float -> Float
-- foreign import prim "primLogDouble"  primLogFloat   :: Float -> Float
-- foreign import prim "primSqrtDouble" primSqrtFloat  :: Float -> Float
-- foreign import prim "primSinhDouble" primSinhFloat  :: Float -> Float
-- foreign import prim "primCoshDouble" primCoshFloat  :: Float -> Float
-- foreign import prim "primTanhDouble" primTanhFloat  :: Float -> Float
-- foreign import prim "primAtan2Double"  primAtan2Float   :: Float -> Float -> Float
-- #else 
-- foreign import ccall "sinf"  primSinFloat   :: Float -> Float
-- foreign import ccall "cosf"  primCosFloat   :: Float -> Float
-- foreign import ccall "tanf"  primTanFloat   :: Float -> Float
-- foreign import ccall "asinf" primAsinFloat  :: Float -> Float
-- foreign import ccall "acosf" primAcosFloat  :: Float -> Float
-- foreign import ccall "atanf" primAtanFloat  :: Float -> Float
-- foreign import ccall "expf"  primExpFloat   :: Float -> Float
-- foreign import ccall "logf"  primLogFloat   :: Float -> Float
-- foreign import ccall "sqrtf" primSqrtFloat  :: Float -> Float
-- -- extra
-- foreign import ccall "sinhf" primSinhFloat  :: Float -> Float
-- foreign import ccall "coshf" primCoshFloat  :: Float -> Float
-- foreign import ccall "tanhf" primTanhFloat  :: Float -> Float
-- foreign import ccall "atan2f"  primAtan2Float   :: Float -> Float -> Float
-- #endif

-- #if defined(__UHC_TARGET_JS__) || defined(__UHC_TARGET_CR__)
-- foreign import prim "primIsNaNDouble         " primIsNaNFloat              :: Float -> Bool
-- foreign import prim "primIsNegativeZeroDouble" primIsNegativeZeroFloat     :: Float -> Bool
-- foreign import prim "primIsDenormalizedDouble" primIsDenormalizedFloat     :: Float -> Bool
-- foreign import prim "primIsInfiniteDouble    " primIsInfiniteFloat         :: Float -> Bool
-- foreign import prim "primDigitsDouble        " primDigitsFloat             :: Int
-- foreign import prim "primMaxExpDouble        " primMaxExpFloat             :: Int
-- foreign import prim "primMinExpDouble        " primMinExpFloat             :: Int
-- foreign import prim "primDecodeDouble        " primDecodeFloat             :: Float -> (Integer, Int)
-- foreign import prim "primEncodeDouble        " primEncodeFloat             :: Integer -> Int -> Float
-- #else
-- foreign import prim primIsNaNFloat              :: Float -> Bool
-- foreign import prim primIsNegativeZeroFloat     :: Float -> Bool
-- foreign import prim primIsDenormalizedFloat     :: Float -> Bool
-- foreign import prim primIsInfiniteFloat         :: Float -> Bool
-- foreign import prim primDigitsFloat             :: Int
-- foreign import prim primMaxExpFloat             :: Int
-- foreign import prim primMinExpFloat             :: Int
-- foreign import prim primDecodeFloat             :: Float -> (Integer, Int)
-- foreign import prim primEncodeFloat             :: Integer -> Int -> Float
-- #endif

-- -- primitive Double functions

-- #if defined( __UHC_TARGET_JAZY__ ) || defined(__UHC_TARGET_JS__) || defined(__UHC_TARGET_CR__)
-- foreign import prim  primSinDouble   :: Double -> Double
-- foreign import prim  primCosDouble   :: Double -> Double
-- foreign import prim  primTanDouble   :: Double -> Double
-- foreign import prim  primAsinDouble  :: Double -> Double
-- foreign import prim  primAcosDouble  :: Double -> Double
-- foreign import prim  primAtanDouble  :: Double -> Double
-- foreign import prim  primExpDouble   :: Double -> Double
-- foreign import prim  primLogDouble   :: Double -> Double
-- foreign import prim  primSqrtDouble  :: Double -> Double
-- foreign import prim  primAtan2Double :: Double -> Double -> Double
-- #if !defined(__UHC_TARGET_JAZY__)
-- foreign import prim primSinhDouble  :: Double -> Double
-- foreign import prim primCoshDouble  :: Double -> Double
-- foreign import prim primTanhDouble  :: Double -> Double
-- #endif
-- #else
-- foreign import ccall "sin"  primSinDouble   :: Double -> Double
-- foreign import ccall "cos"  primCosDouble   :: Double -> Double
-- foreign import ccall "tan"  primTanDouble   :: Double -> Double
-- foreign import ccall "asin" primAsinDouble  :: Double -> Double
-- foreign import ccall "acos" primAcosDouble  :: Double -> Double
-- foreign import ccall "atan" primAtanDouble  :: Double -> Double
-- foreign import ccall "exp"  primExpDouble   :: Double -> Double
-- foreign import ccall "log"  primLogDouble   :: Double -> Double
-- foreign import ccall "sqrt" primSqrtDouble  :: Double -> Double
-- foreign import ccall "sinh" primSinhDouble  :: Double -> Double
-- foreign import ccall "cosh" primCoshDouble  :: Double -> Double
-- foreign import ccall "tanh" primTanhDouble  :: Double -> Double
-- foreign import ccall "atan2"  primAtan2Double   :: Double -> Double -> Double
-- #endif

-- foreign import prim primIsNaNDouble             :: Double -> Bool
-- foreign import prim primIsNegativeZeroDouble    :: Double -> Bool
-- foreign import prim primIsDenormalizedDouble    :: Double -> Bool
-- foreign import prim primIsInfiniteDouble        :: Double -> Bool
-- foreign import prim primDigitsDouble            :: Int
-- foreign import prim primMaxExpDouble            :: Int
-- foreign import prim primMinExpDouble            :: Int
-- foreign import prim primDecodeDouble            :: Double -> (Integer, Int)
-- foreign import prim primEncodeDouble            :: Integer -> Int -> Double

-- foreign import prim primIsIEEE  :: Bool
-- foreign import prim primRadixDoubleFloat  :: Int

-- instance Floating Float where
--     exp   = primExpFloat
--     log   = primLogFloat
--     sqrt  = primSqrtFloat
--     sin   = primSinFloat
--     cos   = primCosFloat
--     tan   = primTanFloat
--     asin  = primAsinFloat
--     acos  = primAcosFloat
--     atan  = primAtanFloat
-- #ifndef __UHC_TARGET_JAZY__
--     sinh  = primSinhFloat
-- #endif

-- instance Floating Double where
--     exp   = primExpDouble
--     log   = primLogDouble
--     sqrt  = primSqrtDouble
--     sin   = primSinDouble
--     cos   = primCosDouble
--     tan   = primTanDouble
--     asin  = primAsinDouble
--     acos  = primAcosDouble
--     atan  = primAtanDouble
-- #if !defined(__UHC_TARGET_JAZY__)
--     sinh  = primSinhDouble
--     cosh  = primCoshDouble
--     tanh  = primTanhDouble
-- #endif


-- instance RealFrac Float where
--     properFraction = floatProperFraction

-- instance RealFrac Double where
--     properFraction = floatProperFraction

-- floatProperFraction :: (RealFloat a, Integral b) => a -> (b,a)
-- floatProperFraction x
--    | n >= 0      = (fromInteger m * fromInteger b ^ n, 0)
--    | otherwise   = (fromInteger w, encodeFloat r n)
--                    where (m,n) = decodeFloat x
--                          b     = floatRadix x
--                          (w,r) = quotRem m (b^(-n))

-- instance RealFloat Float where
--     floatRadix  _ = toInteger primRadixDoubleFloat
--     floatDigits _ = primDigitsFloat
--     floatRange  _ = (primMinExpFloat, primMaxExpFloat)
--     encodeFloat   = primEncodeFloat
--     decodeFloat   = primDecodeFloat
--     isNaN         = primIsNaNFloat
--     isInfinite    = primIsInfiniteFloat
--     isDenormalized= primIsDenormalizedFloat
--     isNegativeZero= primIsNegativeZeroFloat
--     isIEEE      _ = primIsIEEE
--     atan2         = primAtan2Float

-- instance RealFloat Double where
--     floatRadix  _ = toInteger primRadixDoubleFloat
--     floatDigits _ = primDigitsDouble
--     floatRange  _ = (primMinExpDouble, primMaxExpDouble)
--     encodeFloat   = primEncodeDouble
--     decodeFloat   = primDecodeDouble
--     isNaN         = primIsNaNDouble
--     isInfinite    = primIsInfiniteDouble
--     isDenormalized= primIsDenormalizedDouble
--     isNegativeZero= primIsNegativeZeroDouble
--     isIEEE      _ = primIsIEEE
--     atan2         = primAtan2Double

-- instance Enum Float where
--     succ x                = x+1
--     pred x                = x-1
--     toEnum                = primIntToFloat
--     fromEnum              = fromInteger . truncate   -- may overflow
--     enumFrom              = numericEnumFrom
--     enumFromThen          = numericEnumFromThen
--     enumFromTo            = numericEnumFromTo
--     enumFromThenTo        = numericEnumFromThenTo

-- instance Enum Double where
--     succ x                = x+1
--     pred x                = x-1
--     toEnum                = primIntToDouble
--     fromEnum              = fromInteger . truncate   -- may overflow
--     enumFrom              = numericEnumFrom
--     enumFromThen          = numericEnumFromThen
--     enumFromTo            = numericEnumFromTo
--     enumFromThenTo        = numericEnumFromThenTo

-- instance Read Float where
--     readsPrec p = readSigned readFloat


-- instance Read Double where
--     readsPrec p = readSigned readFloat

--------------------------------------------------------------
-- Ratio and Rational type
--------------------------------------------------------------

-- intToRatio :: Integral a => Int -> Ratio a  -- TODO: optimise fromRational (intToRatio x)
-- intToRatio x = fromInt x :% 1

-- instance Integral a => Fractional (Ratio a) where
--     (x:%y) / (x':%y')   = (x*y') % (y*x')
--     recip (x:%y)        = y % x
--     fromRational (x:%y) = fromInteger x :% fromInteger y
--     fromDouble          = doubleToRatio

-- doubleToRatio :: Integral a => Double -> Ratio a   -- TODO: optimies fromRational (doubleToRatio x)
-- doubleToRatio x
--             | n>=0      = (round (x / fromInteger pow) * fromInteger pow) % 1
--             | otherwise = fromRational (round (x * fromInteger denom) % denom)
--                           where (m,n) = decodeFloat x
--                                 denom, pow, radix :: Integer
--                                 radix = floatRadix x
--                                 denom = radix ^ (-n)
--                                 pow   = radix ^ n

{-
doubleToRatio :: Integral a => Double -> Ratio a   -- TODO: optimies fromRational (doubleToRatio x)
doubleToRatio x
            | n>=0      = (round (x / fromInteger pow) * fromInteger pow) % 1
            | otherwise = fromRational (round (x * fromInteger denom) % denom)
                          where (m,n) = decodeFloat x
                                n_dec, denom, pow :: Integer
                                n_dec = floor (logBase 10 (encodeFloat 1 n :: Double))
                                denom = 10 ^ (-n_dec)
                                pow   = 10 ^ n_dec
-}

-- instance Integral a => RealFrac (Ratio a) where
--     properFraction (x:%y) = (fromIntegral q, r:%y)
--                             where (q,r) = quotRem x y

-- instance Integral a => Enum (Ratio a) where
--     succ x         = x+1
--     pred x         = x-1
--     toEnum         = fromInt
--     fromEnum       = fromInteger . truncate   -- may overflow
--     enumFrom       = numericEnumFrom
--     enumFromTo     = numericEnumFromTo
--     enumFromThen   = numericEnumFromThen
--     enumFromThenTo = numericEnumFromThenTo

-- instance (Read a, Integral a) => Read (Ratio a) where
--     readsPrec p = readParen (p > 7)
--                             (\r -> [(x%y,u) | (x,s)   <- readsPrec 8 r,
--                                               ("%",t) <- lex s,
--                                               (y,u)   <- readsPrec 8 t ])

-- instance (Show a,Integral a) => Show (Ratio a) where
--     showsPrec p (x:%y) = showParen (p > 7)
--                              (showsPrec 8 x . showString " % " . showsPrec 8 y)




--------------------------------------------------------------
-- PreludeText
--------------------------------------------------------------

reads        :: Read a => ReadS a
reads         = readsPrec 0

read         :: Read a => String -> a
read s        =  case [x | (x,t) <- reads s, ("","") <- lex t] of
                      [x] -> x
                      []  -> error "Prelude.read: no parse"
                      _   -> error "Prelude.read: ambiguous parse"

-- readParen    :: Bool -> ReadS a -> ReadS a
-- readParen b g = if b then mandatory else optional
--                 where optional r  = g r ++ mandatory r
--                       mandatory r = [(x,u) | ("(",s) <- lex r,
--                                              (x,t)   <- optional s,
--                                              (")",u) <- lex t    ]

readParen    :: Bool -> ReadS a -> ReadS a
readParen b g = if b then mandatory else optional
                where optional r  = g r ++ mandatory r
                      mandatory r = [(x,u) | ("(",s) <- lex r,
                                             (x,t)   <- g s,
                                             (")",u) <- lex t    ]

-- readField    :: Read a => String -> ReadS a
-- readField m s0 = [ r | (t,  s1) <- readFieldName m s0,
--                        ("=",s2) <- lex s1,
--                        r        <- reads s2 ]

-- readFieldName :: String -> ReadS String
-- readFieldName m@(c:_) s0
--   | isAlpha c || c == '_' = [ (f,s1) | (f,s1) <- lex s0, f == m ]
--   | otherwise = [ (f,s3) | ("(",s1) <- lex s0,
--                            (f,s2)   <- lex s1, f == m,
--                            (")",s3) <- lex s2 ]

lex                    :: ReadS String
lex ""                  = [("","")]
lex (c:s) | isSpace c   = lex (dropWhile isSpace s)
lex ('\'':s)            = [('\'':ch++"'", t) | (ch,'\'':t)  <- lexLitChar s,
                                               -- head ch /= '\'' || not (null (tail ch))
                                               ch /= "'"                
                          ]
lex ('"':s)             = [('"':str, t)      | (str,t) <- lexString s]
                          where
                          lexString ('"':s) = [("\"",s)]
                          lexString s = [(ch++str, u)
                                                | (ch,t)  <- lexStrItem s,
                                                  (str,u) <- lexString t  ]

                          lexStrItem ('\\':'&':s) = [("\\&",s)]
                          lexStrItem ('\\':c:s) | isSpace c
                              = [("",t) | '\\':t <- [dropWhile isSpace s]]
                          lexStrItem s            = lexLitChar s

lex (c:s) | isSym c     = [(c:sym,t)         | (sym,t) <- [span isSym s]]
          | isAlpha c   = [(c:nam,t)         | (nam,t) <- [span isIdChar s]]
             -- '_' can be the start of a single char or a name/id.
          | c == '_'    = case span isIdChar s of 
                            ([],_) -> [([c],s)]
                            (nm,t) -> [((c:nm),t)]
          | isSingle c  = [([c],s)]
          | isDigit c   = [(c:ds++fe,t)      | (ds,s)  <- [span isDigit s],
                                               (fe,t)  <- lexFracExp s     ]
          | otherwise   = []    -- bad character
                where
                isSingle c  =  c `elem` ",;()[]{}_`"
                isSym c     =  c `elem` "!@#$%&*+./<=>?\\^|:-~"
                isIdChar c  =  isAlphaNum c || c `elem` "_'"

                lexFracExp ('.':c:cs) | isDigit c 
                            = [('.':ds++e,u) | (ds,t) <- lexDigits (c:cs),
                                               (e,u)  <- lexExp t    ]
                lexFracExp s       = lexExp s

                lexExp (e:s) | e `elem` "eE"
                         = [(e:c:ds,u) | (c:t)  <- [s], c `elem` "+-",
                                                   (ds,u) <- lexDigits t] ++
                           [(e:ds,t)   | (ds,t) <- lexDigits s]
                lexExp s = [("",s)]

lexDigits               :: ReadS String
lexDigits               =  nonnull isDigit

nonnull                 :: (Char -> Bool) -> ReadS String
nonnull p s             =  [(cs,t) | (cs@(_:_),t) <- [span p s]]

lexLitChar          :: ReadS String
lexLitChar ""       =  []
lexLitChar (c:s)
 | c /= '\\'        =  [([c],s)]
 | otherwise        =  map (prefix '\\') (lexEsc s)
 where
   lexEsc (c:s)     | c `elem` "abfnrtv\\\"'" = [([c],s)]
   lexEsc ('^':c:s) | c >= '@' && c <= '_'    = [(['^',c],s)]
    -- Numeric escapes
   lexEsc ('o':s)  = [prefix 'o' (span isOctDigit s)]
   lexEsc ('x':s)  = [prefix 'x' (span isHexDigit s)]
   lexEsc s@(c:_) 
     | isDigit c   = [span isDigit s]  
     | isUpper c   = case [(mne,s') | (c, mne) <- table,
                        ([],s') <- [lexmatch mne s]] of
                       (pr:_) -> [pr]
                       []     -> []
   lexEsc _        = []

   table = ('\DEL',"DEL") : asciiTab
   prefix c (t,s) = (c:t, s)

asciiTab = zip ['\NUL'..' ']
           (["NUL", "SOH", "STX", "ETX"]++[ "EOT", "ENQ", "ACK", "BEL"]++
           [ "BS",  "HT",  "LF",  "VT" ]++[  "FF",  "CR",  "SO",  "SI"]++
           [ "DLE", "DC1", "DC2", "DC3"]++[ "DC4", "NAK", "SYN", "ETB"]++
           [ "CAN", "EM",  "SUB", "ESC"]++[ "FS",  "GS",  "RS",  "US"]++
           [ "SP"])

isOctDigit c  =  c >= '0' && c <= '7'
isHexDigit c  =  isDigit c || c >= 'A' && c <= 'F'
                           || c >= 'a' && c <= 'f'

lexmatch                   :: (Eq a) => [a] -> [a] -> ([a],[a])
lexmatch (x:xs) (y:ys) | x == y  =  lexmatch xs ys
lexmatch xs     ys               =  (xs,ys)

-- readLitChar            :: ReadS Char
-- readLitChar ('\\':s)    = readEsc s
--  where
--        readEsc ('a':s)  = [('\a',s)]
--        readEsc ('b':s)  = [('\b',s)]
--        readEsc ('f':s)  = [('\f',s)]
--        readEsc ('n':s)  = [('\n',s)]
--        readEsc ('r':s)  = [('\r',s)]
--        readEsc ('t':s)  = [('\t',s)]
--        readEsc ('v':s)  = [('\v',s)]
--        readEsc ('\\':s) = [('\\',s)]
--        readEsc ('"':s)  = [('"',s)]
--        readEsc ('\'':s) = [('\'',s)]
--        readEsc ('^':c:s) | c >= '@' && c <= '_'
--                         = [(toEnum (fromEnum c - fromEnum '@'), s)]
--        readEsc s@(d:_) | isDigit d
--                         = [(toEnum n, t) | (n,t) <- readDec s]
--        readEsc ('o':s)  = [(toEnum n, t) | (n,t) <- readOct s]
--        readEsc ('x':s)  = [(toEnum n, t) | (n,t) <- readHex s]
--        readEsc s@(c:_) | isUpper c
--                         = let table = ('\DEL',"DEL") : asciiTab
--                           in case [(c,s') | (c, mne) <- table,
--                                             ([],s') <- [lexmatch mne s]]
--                              of (pr:_) -> [pr]
--                                 []     -> []
--        readEsc _        = []
-- readLitChar (c:s)       = [(c,s)]

-- Unsigned readers for various bases
-- readDec, readOct, readHex :: Integral a => ReadS a
-- readDec = readInt 10 isDigit    (\ d -> fromEnum d - fromEnum_0)
-- readOct = readInt  8 isOctDigit (\ d -> fromEnum d - fromEnum_0)
-- readHex = readInt 16 isHexDigit hex
--             where hex d = fromEnum d - (if isDigit d then fromEnum_0
--                                        else fromEnum (if isUpper d then 'A' else 'a') - 10)



-- readInt reads a string of digits using an arbitrary base.  
-- Leading minus signs must be handled elsewhere.

-- readInt :: Integral a => a -> (Char -> Bool) -> (Char -> Int) -> ReadS a
-- readInt radix isDig digToInt s =
--     [(foldl1 (\n d -> n * radix + d) (map (fromIntegral . digToInt) ds), r)
--         | (ds,r) <- nonnull isDig s ]

-- readSigned:: Real a => ReadS a -> ReadS a
-- readSigned readPos = readParen False read'
--                      where read' r  = read'' r ++
--                                       [(-x,t) | ("-",s) <- lex r,
--                                                 (x,t)   <- read'' s]
--                            read'' r = [(n,s)  | (str,s) <- lex r,
--                                                 (n,"")  <- readPos str]

-- -- This floating point reader uses a less restrictive syntax for floating
-- -- point than the Haskell lexer.  The `.' is optional.
-- readFloat     :: RealFrac a => ReadS a
-- readFloat r    = [(fromRational ((n%1)*10^^(k-d)),t) | (n,d,s) <- readFix r,
--                                                        (k,t)   <- readExp s] ++
--                  [ (0/0, t) | ("NaN",t)      <- lex r] ++
--                  [ (1/0, t) | ("Infinity",t) <- lex r]
--                  where readFix r = [(read (ds++ds'), length ds', t)
--                                         | (ds, d) <- lexDigits r
--                                         , (ds',t) <- lexFrac d   ]

--                        lexFrac ('.':s) = lexDigits s
--                        lexFrac s       = [("",s)]

--                        readExp (e:s) | e `elem` "eE" = readExp' s
--                        readExp s                     = [(0::Int,s)]

--                        readExp' ('-':s) = [(-k,t) | (k,t) <- readDec s]
--                        readExp' ('+':s) = readDec s
--                        readExp' s       = readDec s

%%]

%%[99

----------------------------------------------------------------
-- Defaulting
----------------------------------------------------------------

-- default Fractional Double
-- default RealFrac Double
-- default Floating Double
-- default RealFloat Double

%%]