%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Additional Pred admin for Constraint Handling Rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Derived from work by Gerrit vd Geest.

%%[9 module {%{EH}Pred.CHR} import({%{EH}CHR},{%{EH}CHR.Constraint})
%%]

%%[9 import({%{EH}Pred.CommonCHR}) export(module {%{EH}Pred.CommonCHR})
%%]

%%[9 import(qualified Data.Map as Map,qualified Data.Set as Set,Data.Maybe)
%%]

%%[9 import(UU.Pretty,EH.Util.AGraph,EH.Util.PPUtils)
%%]

%%[9 import({%{EH}Base.Common})
%%]

%%[9 import({%{EH}Ty},{%{EH}Cnstr},{%{EH}Substitutable},{%{EH}Ty.FitsIn},{%{EH}Ty.TrieKey})
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHR instances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
instance CHRMatchable FIIn Pred Cnstr where
  chrMatchTo fi pr1 pr2
    = do { (_,subst) <- fitPredInPred fi pr1 pr2
         ; return subst
         }

instance CHRMatchable FIIn PredScope Cnstr where
  chrMatchTo _ (PredScope_Var v1) sc2@(PredScope_Var v2) | v1 /= v2 = Just $ v1 `cnstrScopeUnit` sc2
  chrMatchTo _ _                      (PredScope_Var v2)            = Nothing
  chrMatchTo _ (PredScope_Var v1) sc2                               = Just $ v1 `cnstrScopeUnit` sc2
  chrMatchTo _ (PredScope_Lev l1)     (PredScope_Lev l2) | l1 == l2 = Just emptyCnstr
  chrMatchTo _ _                  _                                 = Nothing

instance CHRMatchable FIIn PredOccId Cnstr where
  chrMatchTo _ (PredOccId_Var v1) sc2@(PredOccId_Var v2) | v1 /= v2 = Just $ v1 `cnstrPoiUnit` sc2
  chrMatchTo _ _                      (PredOccId_Var v2)            = Nothing
  chrMatchTo _ (PredOccId_Var v1) sc2                               = Just $ v1 `cnstrPoiUnit` sc2
  chrMatchTo _ (PredOccId   _ i1)     (PredOccId   _ i2)            = Just emptyCnstr
--  chrMatchTo _ (PredOccId   _ i1)     (PredOccId   _ i2) | i1 == i2 = Just emptyCnstr
--  chrMatchTo _ _                  _                                 = Nothing

instance CHRMatchable FIIn PredOcc Cnstr where
  chrMatchTo fi po1 po2
    = do { subst1 <- chrMatchTo fi (poPr po1) (poPr po2)
         ; subst2 <- chrMatchTo fi (poPoi po1) (poPoi po2)
         ; subst3 <- chrMatchTo fi (poScope po1) (poScope po2)
         ; return $ subst3 |=> subst2 |=> subst1
         }

instance CHRMatchable FIIn CHRPredOcc Cnstr where
  chrMatchTo fi po1 po2
    = do { subst1 <- chrMatchTo fi (cpoPr po1) (cpoPr po2)
         ; subst2 <- chrMatchTo fi (cpoScope po1) (cpoScope po2)
         ; return $ subst2 |=> subst1
         }

instance CHREmptySubstitution Cnstr where
  chrEmptySubst = emptyCnstr

instance CHRSubstitutable PredOcc TyVarId Cnstr where
  chrFtv        x = Set.fromList (ftv x)
  chrAppSubst s x = s |=> x

instance CHRSubstitutable CHRPredOcc TyVarId Cnstr where
  chrFtv        x = Set.fromList (ftv x)
  chrAppSubst s x = s |=> x

instance CHRSubstitutable CHRPredOccCnstrMp TyVarId Cnstr where
  chrFtv        x = Set.unions [ chrFtv k | k <- Map.keys x ]
  chrAppSubst s x = Map.mapKeys (chrAppSubst s) x

instance CHRSubstitutable Cnstr TyVarId Cnstr where
  chrFtv        x = Set.empty
  chrAppSubst s x = s |=> x

instance CHRSubstitutable Guard TyVarId Cnstr where
  chrFtv        (HasStrictCommonScope   p1 p2 p3) = Set.unions $ map (Set.fromList . ftv) [p1,p2,p3]
  chrFtv        (IsStrictParentScope    p1 p2 p3) = Set.unions $ map (Set.fromList . ftv) [p1,p2,p3]
  chrFtv        (IsVisibleInScope p1 p2   ) = Set.unions $ map (Set.fromList . ftv) [p1,p2]
  chrFtv        (NotEqualScope    p1 p2   ) = Set.unions $ map (Set.fromList . ftv) [p1,p2]

  chrAppSubst s (HasStrictCommonScope   p1 p2 p3) = HasStrictCommonScope   (s |=> p1) (s |=> p2) (s |=> p3)
  chrAppSubst s (IsStrictParentScope    p1 p2 p3) = IsStrictParentScope    (s |=> p1) (s |=> p2) (s |=> p3)
  chrAppSubst s (IsVisibleInScope p1 p2   ) = IsVisibleInScope (s |=> p1) (s |=> p2)
  chrAppSubst s (NotEqualScope    p1 p2   ) = NotEqualScope    (s |=> p1) (s |=> p2)
%%]
  -- chrFtv        (IsParentScope    p1 p2   ) = Set.unions $ map (Set.fromList . ftv) [p1,p2]
  -- chrAppSubst s (IsParentScope    p1 p2   ) = IsParentScope    (s |=> p1) (s |=> p2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lattice ordering, for annotations which have no ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This should be put in some library

%%[9 export(PartialOrdering(..),toOrdering,toPartialOrdering)
data PartialOrdering
  = P_LT | P_EQ | P_GT | P_NE
  deriving (Eq,Show)

toPartialOrdering :: Ordering -> PartialOrdering
toPartialOrdering o
  = case o of
      EQ -> P_EQ
      LT -> P_LT
      GT -> P_GT

toOrdering :: PartialOrdering -> Maybe Ordering
toOrdering o
  = case o of
      P_EQ -> Just EQ
      P_LT -> Just LT
      P_GT -> Just GT
      _    -> Nothing
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Guard, CHRCheckable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 export(Guard(..))
data Guard
  = HasStrictCommonScope 	PredScope PredScope PredScope                   -- have strict/proper common scope?
  | IsVisibleInScope    	PredScope PredScope                             -- is visible in 2nd scope?
  | NotEqualScope    		PredScope PredScope                             -- scopes are unequal
  | IsStrictParentScope  	PredScope PredScope PredScope                   -- parent scope of each other?
%%]
  | IsParentScope       PredScope PredScope                             -- is parent scope?

%%[9
instance Show Guard where
  show _ = "CHR Guard"

instance PP Guard where
  pp (HasStrictCommonScope   sc1 sc2 sc3) = ppParensCommas' [sc1 >#< "<" >#< sc2,sc1 >#< "<=" >#< sc3]
  pp (IsStrictParentScope sc1 sc2 sc3) = ppParens (sc1 >#< "==" >#< sc2 >#< "/\\" >#< sc2 >#< "/=" >#< sc3)
  -- pp (IsParentScope sc1 sc2) = sc1 >#< "+ 1 ==" >#< sc2
  pp (IsVisibleInScope sc1 sc2) = sc1 >#< "`visibleIn`" >#< sc2
  pp (NotEqualScope    sc1 sc2) = sc1 >#< "/=" >#< sc2
%%]

%%[9
instance CHRCheckable Guard Cnstr where
  chrCheck (HasStrictCommonScope (PredScope_Var vDst) sc1 sc2)
    = do { scDst <- pscpCommon sc1 sc2
         ; if scDst == sc1
           then Nothing
           else return $ vDst `cnstrScopeUnit` scDst
         }
  chrCheck (IsStrictParentScope (PredScope_Var vDst) sc1 sc2)
    = do { scDst <- pscpCommon sc1 sc2
         ; if scDst == sc1 && sc1 /= sc2
           then return $ vDst `cnstrScopeUnit` scDst
           else Nothing
         }
{-
  chrCheck (IsParentScope (PredScope_Var vDst) sc1)
    = do { scDst <- pscpParent sc1
         ; return $ vDst `cnstrScopeUnit` scDst
         }
-}
  chrCheck (NotEqualScope sc1 sc2) | isJust c
    = if fromJust c /= EQ then return emptyCnstr else Nothing
    where c = pscpCmp sc1 sc2
  chrCheck (IsVisibleInScope (PredScope_Var vDst) sc1)
    = return $ vDst `cnstrScopeUnit` sc1
  chrCheck (IsVisibleInScope scDst sc1) | pscpIsVisibleIn scDst sc1
    = return emptyCnstr
  chrCheck _
    = Nothing
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Criterium for proving in a let expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 export(isLetProveCandidate)
isLetProveCandidate :: (Ord v, CHRSubstitutable x v s) => Set.Set v -> x -> Bool
isLetProveCandidate glob x
  = Set.null fv || Set.null (fv `Set.intersection` glob)
  where fv = chrFtv x
%%]

