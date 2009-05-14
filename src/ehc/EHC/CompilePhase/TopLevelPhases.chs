%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EHC Compile XXX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 haddock
Top level combinations, stratified into 6 levels,
where higher numbered levels use lower numbered levels.

Levels:
1: processing building blocks
2: ehc compilation phases, including progress messages, stopping when asked for
3: ehc grouping of compilation phases for a single module
4: single module compilation
5: full program phases
6: full program compilation

Naming convention for functions:
level 1    : with prefix 'cpProcess'
level 2..6 : with prefix 'cpEhc'
%%]

%%[8 module {%{EH}EHC.CompilePhase.TopLevelPhases}
%%]

-- general imports
%%[8 import(qualified Data.Map as Map)
%%]
%%[(20 codegen grin) import(Data.Maybe(catMaybes))
%%]

%%[8 import({%{EH}EHC.Common})
%%]
%%[8 import({%{EH}EHC.CompileUnit})
%%]
%%[8 import({%{EH}EHC.CompileRun})
%%]
%%[20 import({%{EH}EHC.CompileGroup})
%%]

%%[8 import({%{EH}EHC.CompilePhase.Parsers})
%%]
%%[8 import({%{EH}EHC.CompilePhase.Translations})
%%]
%%[8 import({%{EH}EHC.CompilePhase.Output})
%%]
%%[8 import({%{EH}EHC.CompilePhase.TransformCore},{%{EH}EHC.CompilePhase.TransformGrin})
%%]
%%[8 import({%{EH}EHC.CompilePhase.Semantics})
%%]
%%[8 import({%{EH}EHC.CompilePhase.FlowBetweenPhase})
%%]
%%[8 import({%{EH}EHC.CompilePhase.CompileC})
%%]
%%[(8 codegen grin) import({%{EH}EHC.CompilePhase.CompileLLVM})
%%]
%%[(8 codegen java) import({%{EH}EHC.CompilePhase.CompileJVM})
%%]
%%[(99 codegen) import({%{EH}Base.Target},{%{EH}EHC.CompilePhase.Link})
%%]
%%[20 import({%{EH}EHC.CompilePhase.Module})
%%]
%%[99 import({%{EH}EHC.CompilePhase.Cleanup})
%%]

-- Language syntax: Core
%%[(20 codegen) import(qualified {%{EH}Core} as Core(cModMerge))
%%]
-- Language syntax: Grin
%%[(20 codegen grin) import(qualified {%{EH}GrinCode} as Grin)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per full program compile actions: level 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(20 codegen grin) haddock
Top level entry point into compilation by the compiler driver, apart from import analysis, wich is assumed to be done.
%%]

%%[20
cpEhcFullProgLinkAllModules :: [HsName] -> EHCompilePhase ()
cpEhcFullProgLinkAllModules modNmL
 = do { cr <- get
      ; let (mainModNmL,impModNmL) = splitMain cr modNmL
            (_,opts) = crBaseInfo' cr
      ; cpMsg (head modNmL) VerboseDebug ("Main mod split: " ++ show mainModNmL ++ ": " ++ show impModNmL)
      ; case mainModNmL of
          [mainModNm]
            | ehcOptDoLinking opts
              -> cpSeq (   (if ehcOptFullProgAnalysis opts
                            then [ -- deed mergen:
                                   -- cpEhcFullProgPostModulePhases opts modNmL (impModNmL,mainModNm)
                                   -- Zorg dat er Grin klaarstaat:
                                   ensureGrin mainModNm modNmL
                                 , cpMsg mainModNm VerboseDebug "HACKING cpEhcMergeIntoOneBigGrin"
                                 , cpMergeIntoOneBigGrin opts modNmL (impModNmL, mainModNm)
                                 , panic "Ik vind het wel genoeg"
                                 , cpProcessGrin mainModNm
                                 -- , cpMsg mainModNm VerboseDebug "YY"
                                 ]
                            else []
                           )
                        ++ [cpEhcExecutablePerModule FinalCompile_Exec impModNmL mainModNm]
                       )
            | otherwise
              -> cpSetLimitErrs 1 "compilation run" [rngLift emptyRange Err_MayNotHaveMain mainModNm]
          _ | ehcOptDoLinking opts
              -> cpSetLimitErrs 1 "compilation run" [rngLift emptyRange Err_MustHaveMain]
            | otherwise
%%[[20
              -> return ()
%%][99
              -> case ehcOptPkg opts of
                   Just (PkgOption_Build pkg)
                     | targetAllowsOLinking (ehcOptTarget opts)
                       -> cpLinkO impModNmL pkg
%%[[(99 jazy)
                     | targetAllowsJarLinking (ehcOptTarget opts)
                       -> cpLinkJar Nothing impModNmL (JarMk_Pkg pkg)
%%]]
                   _ -> return ()
%%]]
      }
  where splitMain cr = partition (\n -> ecuHasMain $ crCU n cr)
        ensureGrin mainModNm modNmL
          = do { cpSeq [cpGetPrevGrin m | m <- modNmL]
               ; cr <- get
               ; let noGrinYet = [ m | m <- modNmL , isNothing (ecuMbGrin $ crCU m cr) ]
               ; let welGrin   = [ m | m <- modNmL , isJust (ecuMbGrin $ crCU m cr) ]
               ; cpMsg mainModNm VerboseDebug ("HACKING al wel   Grin: " ++ show welGrin)
               ; cpMsg mainModNm VerboseDebug ("HACKING nog geen Grin: " ++ show noGrinYet)
               ; cpSeq [cpGetPrevCore m | m <- noGrinYet]
               -- ; cpMsg mainModNm VerboseDebug ("HACKING cpProcessCoreRest on " ++ show noGrinYet)
               -- deed processCoreRest (ongeveer= vertalen
               -- naar GRIN) en processGrin:
               -- , cpEhcCorePerModulePart2 mainModNm
               -- , map (crCU nm AAP
               ; mapM_ cpProcessCoreRest noGrinYet
               }
%%]

%%[20 export(cpEhcCheckAbsenceOfMutRecModules,cpUpdCU)
cpEhcCheckAbsenceOfMutRecModules :: EHCompilePhase ()
cpEhcCheckAbsenceOfMutRecModules
 = do { cr <- get
      ; let mutRecL = filter (\ml -> length ml > 1) $ crCompileOrder cr
      ; when (not $ null mutRecL)
             (cpSetLimitErrs 1 "compilation run" [rngLift emptyRange Err_MutRecModules mutRecL]
             )
      }
%%]

%%[20 export(cpEhcFullProgCompileAllModules)
cpEhcFullProgCompileAllModules :: EHCompilePhase ()
cpEhcFullProgCompileAllModules
 = do { cr <- get
      ; let modNmLL = crCompileOrder cr
            modNmL = map head modNmLL
      ; cpSeq (   []
%%[[99
               ++ (let modNmL' = filter (\m -> let (ecu,_,_,_) = crBaseInfo m cr in not $ filelocIsPkg $ ecuFileLocation ecu) modNmL
                       nrMods = length modNmL'
                   in  zipWith (\m i -> cpUpdCU m (ecuStoreSeqNr (EHCCompileSeqNr i nrMods)) ) modNmL' [1..nrMods]
                  )
%%]]
               ++ [cpEhcFullProgModuleCompileN modNmL]
%%[[(20 codegen grin)
               ++ [cpEhcFullProgLinkAllModules modNmL]
%%]]
              )
      }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per full program compile actions: level 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(20 codegen grin) haddock
Post per module phases, as part of a full program compilation.
Post processing involves the following:
1. if doing full program analysis, merge the already compiled Core representations, and do the same work as for 1 module but now for the merged Core
2. compile+link everything together
%%]

%%[(20 codegen grin)
-- cpEhcFullProgPostModulePhases :: EHCOpts -> [HsName] -> ([HsName],HsName) -> EHCompilePhase ()
-- cpEhcFullProgPostModulePhases opts modNmL (impModNmL,mainModNm)
--   = cpSeq [ cpSeq [cpGetPrevCore m | m <- modNmL]
--           , mergeIntoOneBigCore
--           , cpOutputCore "fullcore" mainModNm
--           , cpMsg mainModNm VerboseDebug ("Full Core generated, from: " ++ show impModNmL)
--           ]
--   where mergeIntoOneBigCore
--           = do { cr <- get
--                ; cpUpdCU mainModNm (ecuStoreCore (Core.cModMerge [ panicJust "cpEhcFullProgPostModulePhases.mergeIntoOneBigCore" $ ecuMbCore $ crCU m cr
--                                                                  | m <- modNmL
--                                                                  ]
--                                    )             )
--                }

-- TODO: gaat kapot als je een core-bestand weggooit en de hi laat staan.
cpMergeIntoOneBigGrin :: EHCOpts -> [HsName] -> ([HsName],HsName) -> EHCompilePhase ()
cpMergeIntoOneBigGrin opts modNmL (impModNmL,mainModNm)
  = cpSeq [ -- cpSeq [cpGetPrevGrin m | m <- modNmL]
            mergeIntoOneBigGrin
          , cpOutputGrin' "fullgrin" mainModNm
          , cpMsg mainModNm VerboseDebug ("Full Grin generated, from: " ++ show impModNmL)
          ]
  where mergeIntoOneBigGrin
          = do { cr <- get
               ; let grins = [ panicJust "cpMergeIntoOneBigGrin.mergeIntoOneBigGrin" g | m <- modNmL , let g = ecuMbGrin $ crCU m cr ]
               ; cpUpdCU mainModNm (ecuStoreGrin (Grin.grModMerge grins))
               }
%%]

%%[20 haddock
Per module compilation of (import) ordered sequence of module, as part of a full program compilation
%%]

%%[20
cpEhcFullProgModuleCompileN :: [HsName] -> EHCompilePhase ()
cpEhcFullProgModuleCompileN modNmL
  = cpSeq (merge (map cpEhcFullProgModuleCompile1    modNmL)
                 (map cpEhcFullProgBetweenModuleFlow modNmL)
          )
  where merge (c1:cs1) (c2:cs2) = c1 : c2 : merge cs1 cs2
        merge []       cs       = cs
        merge cs       []       = cs
%%]

%%[20 haddock
Find out whether a compilation is needed, and if so, can be done.
%%]

%%[20
cpEhcFullProgModuleDetermineNeedsCompile :: HsName -> EHCompilePhase ()
cpEhcFullProgModuleDetermineNeedsCompile modNm
  = do { cr <- get
       ; let (ecu,_,opts,_) = crBaseInfo modNm cr
             needsCompile = crModNeedsCompile modNm cr
             canCompile   = crModCanCompile modNm cr
       ; when (ehcOptVerbosity opts >= VerboseDebug)
              (lift $ putStrLn
                (  show modNm
                ++ ", needs compile: " ++ show needsCompile
                ++ ", can compile: " ++ show canCompile
                ++ ", can use HI instead of HS: " ++ show (ecuCanUseHIInsteadOfHS ecu)
                ++ ", is main: " ++ show (ecuIsMainMod ecu)
                ++ ", is top: " ++ show (ecuIsTopMod ecu)
                ++ ", valid HI: " ++ show (ecuIsValidHI ecu)
                ++ ", HS newer: " ++ show (ecuIsHSNewerThanHI ecu)
                ))
       ; cpUpdCU modNm (ecuSetNeedsCompile (needsCompile && canCompile))
       }
%%]

%%[20 haddock
Compilation of 1 module, as part of a full program compilation
%%]

%%[20
cpEhcFullProgModuleCompile1 :: HsName -> EHCompilePhase ()
cpEhcFullProgModuleCompile1 modNm
  = do { cr <- get
       ; let (_,opts) = crBaseInfo' cr
       ; when (ehcOptVerbosity opts >= VerboseALot)
              (lift $ putStrLn ("====================== Compile1: " ++ show modNm ++ "======================"))
       ; cpEhcFullProgModuleDetermineNeedsCompile modNm
       ; cr <- get
       ; let (ecu,_,_,_) = crBaseInfo modNm cr
             targ = if ecuNeedsCompile ecu then HSAllSem else HIAllSem
       ; cpEhcModuleCompile1 (Just targ) modNm
       ; return ()
       }
%%]

%%[20 haddock
Flow of info between modules, as part of a full program compilation
%%]

%%[20
cpEhcFullProgBetweenModuleFlow :: HsName -> EHCompilePhase ()
cpEhcFullProgBetweenModuleFlow modNm
  = do { cr <- get
       ; case ecuState $ crCU modNm cr of
           ECUSHaskell HSAllSem -> return ()
           ECUSHaskell HIAllSem -> cpFlowHISem modNm
           _                    -> return ()
%%[[99
       ; cpCleanupFlow modNm
%%]]
       }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per module compile actions: level 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8.cpEhcModuleCompile1.sig export(cpEhcModuleCompile1)
cpEhcModuleCompile1 :: HsName -> EHCompilePhase ()
cpEhcModuleCompile1 modNm
%%]
%%[20 -8.cpEhcModuleCompile1.sig export(cpEhcModuleCompile1)
cpEhcModuleCompile1 :: Maybe HSState -> HsName -> EHCompilePhase HsName
cpEhcModuleCompile1 targHSState modNm
%%]
%%[8
  = do { cr <- get
       ; let (ecu,_,opts,fp) = crBaseInfo modNm cr
%%[[8
             defaultResult = ()
%%][20
             defaultResult = modNm
%%]]
%%[[20
       ; when (ehcOptVerbosity opts >= VerboseALot)
              (lift $ putStrLn ("====================== Module: " ++ show modNm ++ " ======================"))
       ; when (ehcOptVerbosity opts >= VerboseDebug)
              (lift $ putStrLn ("State: in: " ++ show (ecuState ecu) ++ ", to: " ++ show targHSState))
%%]]
%%[[8
       ; case (ecuState ecu,undefined) of
%%][20
       ; case (ecuState ecu,targHSState) of
%%]]
%%]
%%[20
           (ECUSHaskell st,Just HSOnlyImports)
             |    st == HSStart
%%[[99
               || st == LHSStart
%%]]
             -> do { cpEhcHaskellModulePrepareHS1 modNm
                   ; modNm' <- cpEhcHaskellImport stnext modNm
                   ; cpEhcHaskellModulePrepareHS2 modNm'
                   ; cpMsg modNm' VerboseNormal ("Imports of " ++ hsstateShowLit st ++ "Haskell")
                   ; when (ehcOptVerbosity opts >= VerboseDebug)
                          (do { cr <- get
                              ; let (ecu,_,opts,fp) = crBaseInfo modNm' cr
                              ; lift $ putStrLn ("After HS import: nm=" ++ show modNm ++ ", newnm=" ++ show modNm' ++ ", fp=" ++ show fp ++ ", imp=" ++ show (ecuImpNmL ecu))
                              })
                   ; cpUpdCU modNm' (ecuStoreState (ECUSHaskell stnext))
                   ; cpStopAt CompilePoint_Imports
                   ; return modNm'
                   }
             where stnext = hsstateNext st
           (ECUSHaskell HIStart,Just HSOnlyImports)
             -> do { cpMsg modNm VerboseNormal ("Imports of HI")
                   ; cpEhcHaskellModulePrepareHI modNm
                   ; cpUpdCU modNm (ecuStoreState (ECUSHaskell (hsstateNext HIStart)))
                   ; when (ehcOptVerbosity opts >= VerboseDebug)
                          (do { cr <- get
                              ; let (ecu,_,opts,fp) = crBaseInfo modNm cr
                              ; lift $ putStrLn ("After HI import: nm=" ++ show modNm ++ ", fp=" ++ show fp ++ ", imp=" ++ show (ecuImpNmL ecu))
                              })
                   ; return defaultResult
                   }
           (ECUSHaskell st,Just HSOnlyImports)
             |    st == HSOnlyImports
               || st == HIOnlyImports
%%[[99
               || st == LHSOnlyImports
%%]]
             -> return defaultResult
           (ECUSHaskell st,Just HSAllSem)
             |    st == HSOnlyImports
%%[[99
               || st == LHSOnlyImports
%%]]
             -> do { cpMsg modNm VerboseMinimal ("Compiling " ++ hsstateShowLit st ++ "Haskell")
                   ; cpEhcHaskellModuleAfterImport (ecuIsTopMod ecu) opts st modNm
                   ; cpUpdCU modNm (ecuStoreState (ECUSHaskell HSAllSem))
                   ; return defaultResult
                   }
           (ECUSHaskell st,Just HIAllSem)
             |    st == HSOnlyImports
               || st == HIOnlyImports
%%[[99
               || st == LHSOnlyImports
%%]]
             -> do { cpMsg modNm VerboseNormal "Reading HI"
%%[[(20 codegen grin)
                   ; cpUpdateModOffMp [modNm]
%%]]
                   ; cpUpdCU modNm (ecuStoreState (ECUSHaskell HIAllSem))
                   ; return defaultResult
                   }
%%]]
%%]
%%[8
           (ECUSHaskell HSStart,_)
             -> do { cpMsg modNm VerboseMinimal "Compiling Haskell"
                   ; cpEhcHaskellModulePrepare modNm
                   ; cpEhcHaskellParse True False modNm
                   ; cpEhcHaskellModuleCommonPhases True True opts modNm
                   ; when (ehcOptFullProgAnalysis opts)
                          (cpEhcCoreGrinPerModuleDoneFullProgAnalysis modNm)
                   ; cpUpdCU modNm (ecuStoreState (ECUSHaskell HSAllSem))
                   ; return defaultResult
                   }
%%[[20
           (_,Just HSOnlyImports)
             -> return defaultResult
%%]]
           (ECUSEh EHStart,_)
             -> do { cpMsg modNm VerboseMinimal "Compiling EH"
                   ; cpUpdOpts (\o -> o {ehcOptHsChecksInEH = True})
                   ; cpEhcEhParse modNm
%%[[20   
                   ; cpGetDummyCheckEhMod modNm
%%]]   
                   ; cpEhcEhModuleCommonPhases True True True opts modNm
                   
                   ; when (ehcOptFullProgAnalysis opts)
                          (cpEhcCoreGrinPerModuleDoneFullProgAnalysis modNm)
                   ; cpUpdCU modNm (ecuStoreState (ECUSEh EHAllSem))
                   ; return defaultResult
                   }
%%[[94
           (ECUSC CStart,_)
             -> do { cpSeq [ cpMsg modNm VerboseMinimal "Compiling C"
                           , cpCompileWithGCC FinalCompile_Module [] modNm
                           , cpUpdCU modNm (ecuStoreState (ECUSC CAllSem))
                           ]
                   ; return defaultResult
                   }
%%]]
%%[[(8 codegen grin)
           (ECUSGrin,_)
             -> do { cpMsg modNm VerboseMinimal "Compiling Grin"
                   ; cpParseGrin modNm
                   ; cpProcessGrin modNm
                   ; cpProcessBytecode modNm 
                   ; return defaultResult
                   }
                   
%%]]
           _ -> return defaultResult
       }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per module compile actions: level 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8 haddock
EH common phases: analysis + core + grin
%%]

%%[8
cpEhcEhModuleCommonPhases :: Bool -> Bool -> Bool -> EHCOpts -> HsName -> EHCompilePhase ()
cpEhcEhModuleCommonPhases isMainMod isTopMod doMkExec opts modNm
  = cpSeq ([ cpEhcEhAnalyseModuleDefs modNm
%%[[(8 codegen)
           , cpEhcCorePerModulePart1 modNm
%%]]
           ]
%%[[(8 codegen grin)
           ++ (if ehcOptFullProgAnalysis opts
               then []
               else [cpEhcCoreGrinPerModuleDoneNoFullProgAnalysis opts isMainMod isTopMod doMkExec modNm]
              )
%%]]
          )
%%]

%%[8 haddock
HS common phases: HS analysis + EH common
%%]

%%[8
cpEhcHaskellModuleCommonPhases :: Bool -> Bool -> EHCOpts -> HsName -> EHCompilePhase ()
cpEhcHaskellModuleCommonPhases isTopMod doMkExec opts modNm
  = cpSeq [ cpEhcHaskellAnalyseModuleDefs modNm
          , do { cr <- get
               ; let (ecu,_,_,_) = crBaseInfo modNm cr
               ; cpEhcEhModuleCommonPhases
%%[[8
                   isTopMod
%%][20
                   (ecuIsMainMod ecu)
%%]]
                   isTopMod doMkExec opts modNm
               }
          ]       
%%]

%%[20 haddock
Post module import common phases: Parse + Module analysis + HS common
%%]

%%[20
cpEhcHaskellModuleAfterImport :: Bool -> EHCOpts -> HSState -> HsName -> EHCompilePhase ()
cpEhcHaskellModuleAfterImport isTopMod opts hsst modNm
  = cpSeq [ cpEhcHaskellParse False (hsstateIsLiteral hsst) modNm
          , cpEhcHaskellAnalyseModuleItf modNm
          , cpEhcHaskellModuleCommonPhases isTopMod False opts modNm
          , cpEhcHaskellModulePostlude modNm
          ]       
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per module compile actions: level 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[20 haddock
Prepare module for compilation.
This should be the first step before compilation of a module and is meant to obtain cached info from a previous compilation.
%%]

%%[8.cpEhcHaskellModulePrepare
cpEhcHaskellModulePrepare :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePrepare _ = return ()
%%]

We need to know meta info in a more staged manner.
To be able to cpp preprocess first we need to know whether a Haskell file exists.
(1) we get the timestamp, so we know the file exists, so we can preprocess.
(..) then happens other stuff, getting the real module name, getting the import list.
(2) only then we can get info about derived files because the location is based on the real module name.
    Previous info also has to be obtained again.

%%[20 -8.cpEhcHaskellModulePrepare
cpEhcHaskellModulePrepareHS1 :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePrepareHS1 modNm
  = cpGetMetaInfo [GetMeta_HS,GetMeta_Dir] modNm

cpEhcHaskellModulePrepareHS2 :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePrepareHS2 modNm
  = cpSeq [ cpGetMetaInfo [GetMeta_HS, GetMeta_HI, GetMeta_Core, GetMeta_Dir] modNm
          , cpGetPrevHI modNm
          , cpFoldHI modNm
          ]

cpEhcHaskellModulePrepareHI :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePrepareHI modNm
  = cpSeq [ cpGetMetaInfo [GetMeta_HI, GetMeta_Core] modNm
          , cpGetPrevHI modNm
          , cpFoldHI modNm
          ]

cpEhcHaskellModulePrepare :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePrepare modNm
  = cpSeq [ cpEhcHaskellModulePrepareHS1 modNm
          , cpEhcHaskellModulePrepareHS2 modNm
          ]
%%]

%%[20
cpEhcHaskellModulePostlude :: HsName -> EHCompilePhase ()
cpEhcHaskellModulePostlude modNm
  = cpSeq [ cpOutputHI "hi" modNm
%%[[99
          , cpCleanupCU modNm
%%]]
          ]
%%]

%%[20 haddock
Get import information from module source text.
%%]

%%[20
cpEhcHaskellImport :: HSState -> HsName -> EHCompilePhase HsName
cpEhcHaskellImport hsst modNm
  = do {
%%[[20
         cpParseHsImport modNm
%%][99
         cpPreprocessWithCPP modNm
       ; cpParseHsImport (hsstateIsLiteral hsst) modNm
%%]]
       ; cpStepUID
       ; cpFoldHsMod modNm
       ; cpGetHsImports modNm
       }
%%]

%%[20 haddock
Parse a Haskell module
%%]

%%[8
cpEhcHaskellParse :: Bool -> Bool -> HsName -> EHCompilePhase ()
cpEhcHaskellParse doCPP litmode modNm
  = cpSeq (
%%[[8
             [ cpParseHs modNm ]
%%][99
             (if doCPP then [cpPreprocessWithCPP modNm] else [])
          ++ [ cpParseHs litmode modNm ]
%%]]
          ++ [ cpMsg modNm VerboseALot "Parsing done"
             , cpStopAt CompilePoint_Parse
             ]
          )
%%]

%%[8
cpEhcEhParse :: HsName -> EHCompilePhase ()
cpEhcEhParse modNm
  = cpSeq [ cpParseEH modNm
          , cpStopAt CompilePoint_Parse
          ]
%%]

%%[20 haddock
Analyse a module for
  (1) module information (import, export, etc),
%%]

%%[20
cpEhcHaskellAnalyseModuleItf :: HsName -> EHCompilePhase ()
cpEhcHaskellAnalyseModuleItf modNm
  = cpSeq [ cpStepUID, cpFoldHsMod modNm, cpGetHsMod modNm
%%[[99
          , cpCleanupHSMod modNm
%%]]
          , cpCheckMods [modNm]
%%[[(20 codegen grin)
          , cpUpdateModOffMp [modNm]
%%]]
          ]
%%]

%%[8 haddock
Analyse a module for
  (2) names + dependencies
%%]

%%[8
cpEhcHaskellAnalyseModuleDefs :: HsName -> EHCompilePhase ()
cpEhcHaskellAnalyseModuleDefs modNm
  = cpSeq [ cpStepUID
          , cpProcessHs modNm
          , cpMsg modNm VerboseALot "Name+dependency analysis done"
          , cpStopAt CompilePoint_AnalHS
          ]
%%]

%%[8 haddock
Analyse a module for
  (3) types
%%]

%%[8
cpEhcEhAnalyseModuleDefs :: HsName -> EHCompilePhase ()
cpEhcEhAnalyseModuleDefs modNm
  = cpSeq [ cpStepUID, cpProcessEH modNm
          , cpMsg modNm VerboseALot "Type analysis done"
          , cpStopAt CompilePoint_AnalEH
          ]
%%]

%%[(8 codegen) haddock
Part 1 Core processing, on a per module basis, part1 is done always
%%]

%%[(8 codegen)
cpEhcCorePerModulePart1 :: HsName -> EHCompilePhase ()
cpEhcCorePerModulePart1 modNm
  = cpSeq [ cpStepUID
          , cpProcessCoreBasic modNm
          , cpMsg modNm VerboseALot "Core (basic) done"
          , cpStopAt CompilePoint_Core
          ]
%%]

%%[(8 codegen) haddock
Part 2 Core processing, part2 is done either for individual modules or after full program analysis
%%]

%%[(8 codegen)
cpEhcCorePerModulePart2 :: HsName -> EHCompilePhase ()
cpEhcCorePerModulePart2 modNm
  = cpSeq [ cpProcessCoreRest modNm
          , cpProcessGrin modNm
          ]
%%]

%%[(8 codegen grin) haddock
Core+grin processing, on a per module basis, may only be done when no full program analysis is done
%%]

%%[(8 codegen grin)
cpEhcCoreGrinPerModuleDoneNoFullProgAnalysis :: EHCOpts -> Bool -> Bool -> Bool -> HsName -> EHCompilePhase ()
cpEhcCoreGrinPerModuleDoneNoFullProgAnalysis opts isMainMod isTopMod doMkExec modNm
  = cpSeq (  [ cpEhcCorePerModulePart2 modNm
%%[[20
             , cpFlowOptim modNm
%%]]
%%[[99
             , cpCleanupGrin modNm
%%]]
             , cpProcessBytecode modNm
             ]
          ++ (if not isMainMod || doMkExec
              then let how = if doMkExec then FinalCompile_Exec else FinalCompile_Module
                   in  [cpEhcExecutablePerModule how [] modNm]
              else []
             )
          ++ [ cpMsg modNm VerboseALot "Core+Grin done"
             , cpMsg modNm VerboseDebug ("isMainMod: " ++ show isMainMod)
             ]
          )
%%]

%%[(8 codegen grin) haddock
Core+grin processing, on a per module basis, may only be done when full program analysis is done
%%]

%%[(8 codegen grin)
cpEhcCoreGrinPerModuleDoneFullProgAnalysis :: HsName -> EHCompilePhase ()
cpEhcCoreGrinPerModuleDoneFullProgAnalysis modNm
  = cpSeq (  [ cpEhcCorePerModulePart2 modNm
             , cpEhcExecutablePerModule FinalCompile_Exec [] modNm
             , cpMsg modNm VerboseALot "Full Program Analysis Core+Grin done"
             ]
          )
%%]

%%[(8 codegen grin) haddock
Make final executable code, either still partly or fully (i.e. also linking)
%%]

%%[(8 codegen grin)
cpEhcExecutablePerModule :: FinalCompileHow -> [HsName] -> HsName -> EHCompilePhase ()
cpEhcExecutablePerModule how impModNmL modNm
  = cpSeq [ cpCompileWithGCC how impModNmL modNm
          , cpCompileWithLLVM modNm
%%[[(8 jazy)
          , cpCompileJazyJVM how impModNmL modNm
%%]]
          ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Per module compile actions: level 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
cpProcessHs :: HsName -> EHCompilePhase ()
cpProcessHs modNm 
  = cpSeq [ cpFoldHs modNm
%%[[20
          , cpFlowHsSem1 modNm
%%]]
          , cpTranslateHs2EH modNm
%%[[99
          , cpCleanupHS modNm
%%]]
          ]
%%]

%%[8
cpProcessEH :: HsName -> EHCompilePhase ()
cpProcessEH modNm
  = cpSeq [ cpFoldEH modNm
%%[[99
          , cpCleanupFoldEH modNm
%%]]
          , cpFlowEHSem1 modNm
          , cpTranslateEH2Output modNm
%%[[(8 codegen)
          , cpTranslateEH2Core modNm
%%]]
%%[[99
          , cpCleanupEH modNm
%%]]
          ]
%%]

%%[(8 codegen)
cpProcessCoreBasic :: HsName -> EHCompilePhase ()
cpProcessCoreBasic modNm 
  = do { cr <- get
       ; let (_,opts) = crBaseInfo' cr
       ; cpSeq [ cpTransformCore
                   modNm
                     (
%%[[102
                       -- [ "CS" ] ++
%%]]
                       [ "CER", "CRU", "CLU", "CILA", "CETA", "CCP", "CILA", "CETA"
                       , "CFL", "CLGA", "CCGA", "CLU", "CFL", {- "CLGA", -} "CLFG"    
%%[[9               
                       ,  "CLDF"
%%]
%%[[8_2        
                       , "CPRNM"
%%]]
                       , "CFN"
                       ]
                     )
               , when (ehcOptEmitCore opts) (cpOutputCore "core" modNm)
%%[[(8 codegen java)
               , when (ehcOptEmitJava opts) (cpOutputJava "java" modNm)
%%]]
               ]
        }
%%]

%%[(8 codegen)
cpProcessCoreRest :: HsName -> EHCompilePhase ()
cpProcessCoreRest modNm 
  = cpSeq [ cpFoldCore modNm
%%[[20
          , cpFlowCoreSem modNm
%%]]
          , cpMsg modNm VerboseDebug ("HACKING: cpTranslateCore2Grin on " ++ show modNm)
          , cpTranslateCore2Grin modNm
%%[[(8 jazy)
          , cpTranslateCore2Jazy modNm
%%]]
%%[[99
          , cpCleanupCore modNm
%%]]
          ]
          
%%]

%%[(8 codegen grin)
cpProcessGrin :: HsName -> EHCompilePhase ()
cpProcessGrin modNm 
  = do { cr <- get
       ; let (_,opts) = crBaseInfo' cr
       ; cpSeq ([ cpOutputGrin "-000-initial" modNm
                , cpTransformGrin modNm
                , cpOutputGrin "-099-final" modNm
                ]
                ++ (if ehcOptEmitBytecode opts then [cpTranslateGrin2Bytecode modNm] else [])
                ++ (if ehcOptFullProgAnalysis opts then [cpTranslateGrin modNm] else [])
               )
       }
%%]

%%[(8 codegen grin)
cpProcessBytecode :: HsName -> EHCompilePhase ()
cpProcessBytecode modNm 
  = do { cr <- get
       ; let (_,opts) = crBaseInfo' cr
       ; cpSeq [ cpTranslateByteCode modNm
%%[[99
               , cpCleanupFoldBytecode modNm
%%]]
               , when (ehcOptEmitBytecode opts) (cpOutputByteCodeC "c" modNm)
%%[[99
               , cpCleanupBytecode modNm
%%]]
               ]
       }

%%]

