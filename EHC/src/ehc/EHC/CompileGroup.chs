%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EHC Compile group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

An EHC compile group maintains info for a group of simultaneously compiled units.
This is not yet finished!!!!!!!!!!!!!!!!!!!!
Only a placeholder ...

%%[20 module {%{EH}EHC.CompileGroup}
%%]

-- general imports
%%[20 import({%{EH}EHC.Common})
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compilation group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[20 export(EHCompileGroup(..),emptyECG)
data EHCompileGroup
  = EHCompileGroup
      { ecgNm                :: HsName
      , ecgModL              :: [HsName]
      }

emptyECG :: EHCompileGroup
emptyECG
  = EHCompileGroup
      { ecgNm                = hsnUnknown
      , ecgModL              = []
      }
%%]

