%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constraint Handling Rules: Key to be used as part of TrieKey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 module {%{EH}CHR.Key} import({%{EH}Base.Common},{%{EH}Ty},{%{EH}Base.Trie})
%%]

%%[9 import(UU.Pretty,EH.Util.PPUtils)
%%]

%%[9 import({%{EH}Ty.Pretty})
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Key
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 export(Key(..))
data Key
  = Key_HNm     HsName			-- type constant, its name
  | Key_UID     UID				-- type variable, its id, used with TKK_Partial
  | Key_Str     String			-- arbitrary string
  | Key_TyQu    TyQu			-- quantified type, used with TKK_Partial
  | Key_Ty      Ty				-- catchall for the rest, used with TKK_Partial
  deriving (Eq,Ord)
%%]

%%[9
instance Show Key where
  show _ = "Key"

instance PP Key where
  pp (Key_HNm  n) = pp n
  pp (Key_UID  n) = pp n
  pp (Key_Str  n) = pp n
  pp (Key_TyQu n) = pp $ show n
  pp (Key_Ty   n) = pp n
%%]

%%[9 export(Keyable(..))
class Keyable k where
  toKey               :: k -> [TrieKey Key]
  toKeyParentChildren :: k -> ([TrieKey Key],[TrieKey Key])

  -- minimal def, mutually recursive
  toKey               x = let (p,c) = toKeyParentChildren x in p ++ c
  toKeyParentChildren x = case toKey x of
                            (h:t) -> ([h],t)
                            _     -> ([],[])
%%]

%%[9
instance Keyable x => TrieKeyable x Key where
  toTrieKey = toKey
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pretty printing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
%%]
instance PP Key where
  pp = pp . show
