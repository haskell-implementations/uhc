###########################################################################################
# this file
###########################################################################################

UHC_MK_SHARED_MKF								:= $(UHC_MK_PREFIX)shared.mk

###########################################################################################
# Shared makefile stuff
###########################################################################################

.SUFFIXES:
.SUFFIXES: .pdf .tex .bib .html .lhs .sty .lag .cag .chs

###########################################################################################
# EHC variants.
#
# Pivotal points:
# - 30 (TBD) switch to Core representation of types (Ty)
# - 50 module system is introduced, influencing global logistics
#
# 90-99 are reserved for very Haskell specific functionality (like deriving)
# 100 is Haskell
# 101 is UHC as to be installed
###########################################################################################

# 1 : explicitly typed lambda calculus
# 2 : + type inference (implicit typing)
# 3 : + polymorphism
# 4 : + quantifiers everywhere, existentials
# 5 : + datatypes
# 6 : + kinds (+inference)
# 7 : + fixed size records
# 8 : + code gen
# 9 : + CHR, class system, local instances
# 10: + (extensible) records (lack predicates)
# 11: + type synonyms
# 12: + explicit passing of implicit parameters (partially done)
# 13: + higher order predicates (dict trafo's) (partially done)
# 14: + (TBD) existentially quantified class predicates
# 15: + (TBD) functional dependencies
# 16: + 
# 17: + Polarity inference (co/contravariance)
# 18: + Unboxed types (partially done, to become obsolete, 20120427 AD: no longer included)
# 20: + 
# 30: + (TBD) Switch to use of Core to represent Ty, catering for dependent types
# 31: + (TBD) GADT
# 50: + module system
# 90: + (partially done at variant 8) full FFI (foreign function interface)
# 91: + deriving construct
# 92: + generics (for deriving)
# 93: + fusion
# 96: + exception handling
# 97: + numbers: Integer, Float, Double
# 98: + IO
# 99: + the rest to make uhc
# 100: - debugging/tracing stuff
# 101: same as 100, but built for installation
# 102: - removal of necessary stuff (i.e. error messages) to play with AG dependencies, mem usage
# 103: same as 100, but built for cabal based installation of platform independent subset of UHC

# 40: + GADT experiment
# 41: + GADT by Arie Middelkoop
# 4_2: + 2 pass type inference, quantifier propagation experiment
# 8_2: + A bit prettier output for intermediate languages, in order to include
#        in doc/llvm.pdf. This version is temporary until a framework to output
#        shuffle post-processed intermediate output is available.

###########################################################################################
# EHC variant partitioning into public/non-public (experimental, ...) + code/noncode variants
###########################################################################################

EHC_PREL_VARIANT				:= 99
EHC_UHC_VARIANT					:= 100
EHC_UHC_INSTALL_VARIANT			:= 101
EHC_UHCLIGHT_CABAL_VARIANT		:= 103
EHC_PREL_VARIANTS				:= $(EHC_PREL_VARIANT) $(EHC_UHC_VARIANT) $(EHC_UHC_INSTALL_VARIANT) $(EHC_UHCLIGHT_CABAL_VARIANT)
EHC_GMP_VARIANTS				:= $(EHC_PREL_VARIANTS) 97 98 $(EHC_OTHER_CODE_VARIANTS)
EHC_LTM_VARIANTS				:= $(EHC_GMP_VARIANTS)
EHC_PUB_NOCODE_VARIANTS			:= 1 2 3 4 5 6 7
EHC_PUB_RULER_VARIANTS			:= $(EHC_PUB_NOCODE_VARIANTS)
EHC_PUB_NOPREL_VARIANTS			:= 8 9 10 11 12 13 14 15 17 18 19 20 30 31 50 90 91 92 93 96 97 98
EHC_PUB_CODE_VARIANTS			:= $(EHC_PUB_NOPREL_VARIANTS) $(EHC_PREL_VARIANTS)
EHC_PUB_VARIANTS				:= $(EHC_PUB_NOCODE_VARIANTS) $(EHC_PUB_CODE_VARIANTS)
EHC_OTHER_NOCODE_VARIANTS		:= 
EHC_OTHER_NOPREL_VARIANTS		:= 
#EHC_OTHER_NOCODE_VARIANTS		:= 4_2 6_4 7_2
#EHC_OTHER_NOPREL_VARIANTS		:= 8_2
EHC_OTHER_PREL_VARIANTS			:= 102
EHC_OTHER_CODE_VARIANTS			:= $(EHC_OTHER_NOPREL_VARIANTS) $(EHC_OTHER_PREL_VARIANTS) 
EHC_OTHER_VARIANTS				:= $(EHC_OTHER_NOCODE_VARIANTS) $(EHC_OTHER_CODE_VARIANTS)
EHC_CODE_VARIANTS				:= $(EHC_PUB_CODE_VARIANTS) $(EHC_OTHER_CODE_VARIANTS)
EHC_VARIANTS					:= $(EHC_PUB_VARIANTS) $(EHC_OTHER_VARIANTS)

GRIN_PUB_VARIANTS				:= $(EHC_PUB_CODE_VARIANTS)
GRIN_VARIANTS					:= $(GRIN_PUB_VARIANTS)

TEST_VARIANTS					:= $(EHC_PUB_NOCODE_VARIANTS) 8 9 10 11 $(EHC_PREL_VARIANT)

###########################################################################################
# Check whether tools are missing
###########################################################################################

EXIT_IF_ABSENT_LIB_OR_TOOL		:= 

###########################################################################################
# use of ruler depents on variant
###########################################################################################

EHC_CFG_USE_RULER						:= $(filter $(EHC_VARIANT),$(EHC_PUB_RULER_VARIANTS))

###########################################################################################
# rts building depends on target
###########################################################################################

# which specific target is built, used by rts
EHC_CFG_TARGET_IS_bc					:= $(filter bc,$(EHC_VARIANT_TARGET))
EHC_CFG_TARGET_IS_C						:= $(filter C,$(EHC_VARIANT_TARGET))
EHC_CFG_TARGET_IS_llvm					:= $(filter llvm,$(EHC_VARIANT_TARGET))

# which MP lib
EHC_CFG_MPLIB							:= ltm

# which GC lib
# NOTE: this is globally turned off, but for reasons of consistency/symmetry still here
EHC_CFG_GCLIB							:= mm

# whether LTM sources should be included in rts
ifeq (ltm,ltm)
EHC_CFG_USE_LTM							:= $(filter $(EHC_VARIANT),$(EHC_LTM_VARIANTS))
endif

# whether GMP library should be build and linked in when compiling
ifeq (ltm,gmp)
EHC_CFG_USE_GMP							:= $(filter $(EHC_VARIANT),$(EHC_GMP_VARIANTS))
EHC_CFG_GMP_LIB_ARCHIVE					:= /mnt/g/universiteit/thesis/uhcCA/EHC/extlibs/gmp/gmp-4.2.1.tar.gz
endif

###########################################################################################
# Names of compiler executables
###########################################################################################

EHC_EXEC_NAME			:= ehc
EHCRUN_EXEC_NAME		:= $(EHC_EXEC_NAME)r
UHC_EXEC_NAME			:= uhc
UHCLIGHT_EXEC_NAME		:= $(UHC_EXEC_NAME)l
UHCRUN_EXEC_NAME		:= $(UHC_EXEC_NAME)r

###########################################################################################
# GIT revision nr, and cmd to extract, if present
###########################################################################################

GIT_VERSION_EXISTS		:= yes
GIT_VERSION_CMD			:= cat GITHASH
GIT_REVISION			:= TiborCountingAnalysis@1ea414b8a1

###########################################################################################
# Locations in source, build, install, distribution
###########################################################################################

# suffix for build + (temporary) install locations + package names
EHC_BUILD_SUFFIX	:= 
ifneq ($(EHC_BUILD_SUFFIX),)
EHC_BUILD_SUFFIX_DASH					:= -$(EHC_BUILD_SUFFIX)
endif

# location for binaries
BIN_PREFIX			:= $(UHC_TOP_PREFIX)bin/
BINABS_PREFIX		:= $(TOPABS_PREFIX)bin/

# location for haddock
HDOC_PREFIX			:= $(UHC_TOP_PREFIX)hdoc/
HDOCABS_PREFIX		:= $(TOPABS_PREFIX)hdoc/

# location for libraries
LIB_PREFIX			:= $(UHC_TOP_PREFIX)lib/

# location for cabal installed stuff (mainly libraries), and other build time installs, used when building ehc
INSTALLFORBLD_PREFIX			:= $(UHC_TOP_PREFIX)install-for-build$(EHC_BUILD_SUFFIX_DASH)/
INSTALLFORBLDABS_PREFIX			:= $(TOPABS_PREFIX)install-for-build$(EHC_BUILD_SUFFIX_DASH)/
INSTALLFORBLDABS2_PREFIX		:= $(TOPABS2_PREFIX)install-for-build$(EHC_BUILD_SUFFIX_DASH)/
INSTALLFORBLDABS_FLAG_PREFIX	:= $(INSTALLFORBLDABS2_PREFIX)ins-flg-
INSTALLFORBLDABS_LIB_PREFIX		:= $(INSTALLFORBLDABS_PREFIX)lib/
INSTALLFORBLDABS_INC_PREFIX		:= $(INSTALLFORBLDABS_PREFIX)include/

# location installed stuff, used when running ehc
INSTALL_DIR						:= $(UHC_TOP_PREFIX)install$(EHC_BUILD_SUFFIX_DASH)
INSTALLABS_DIR					:= $(TOPABS_PREFIX)install$(EHC_BUILD_SUFFIX_DASH)
INSTALLABS2_DIR					:= $(TOPABS2_PREFIX)install$(EHC_BUILD_SUFFIX_DASH)

INSTALL_PREFIX					:= $(INSTALL_DIR)/
INSTALLABS_PREFIX				:= $(INSTALLABS_DIR)/
INSTALLABS_FLAG_PREFIX			:= $(INSTALLABS_PREFIX)ins-flg-
INSTALLABS_LIB_PREFIX			:= $(INSTALLABS_PREFIX)lib/
INSTALLABS_INC_PREFIX			:= $(INSTALLABS_PREFIX)include/

# location for uhc installs, as specified by configure
INSTALL_UHC_ROOT		:= /usr/local/lib
INSTALL_UHC_DIR			:= /usr/local/@INSTALL_LIBC_SUFFIX@
INSTALL_UHC_PREFIX		:= $(INSTALL_UHC_DIR)/
INSTALL_UHC_BIN_PREFIX	:= /usr/local/bin/
INSTALL_UHC_LIB_PREFIX	:= $(INSTALL_UHC_PREFIX)lib/
INSTALL_UHC_INC_PREFIX	:= $(INSTALL_UHC_PREFIX)include/

# location for distribution construction
DIST_PREFIX				:= $(UHC_TOP_PREFIX)dist$(EHC_BUILD_SUFFIX_DASH)/
DISTABS_PREFIX			:= $(TOPABS_PREFIX)dist$(EHC_BUILD_SUFFIX_DASH)/

# location for building
BLD_PREFIX				:= $(UHC_TOP_PREFIX)build$(EHC_BUILD_SUFFIX_DASH)/
BLDABS_PREFIX			:= $(TOPABS_PREFIX)build$(EHC_BUILD_SUFFIX_DASH)/
BLD_BIN_PREFIX			:= $(BLD_PREFIX)bin/
BLD_LIBUTIL_PREFIX		:= $(BLD_PREFIX)libutil/

# location for barebones
BARE_PREFIX				:= $(UHC_TOP_PREFIX)bare$(EHC_BUILD_SUFFIX_DASH)/

# location for cabal buildable distributions (in particular uhc light)
CABALDIST_SRC_PREFIX				:= src/
CABALDIST_SRCMAIN_PREFIX			:= src-main/
CABALDIST_UHCLIGHT_PREFIX			:= $(UHC_TOP_PREFIX)cabaldist$(EHC_BUILD_SUFFIX_DASH)/uhc-light/
CABALDIST_UHCLIGHT_SRC_PREFIX		:= $(CABALDIST_UHCLIGHT_PREFIX)$(CABALDIST_SRC_PREFIX)
CABALDIST_UHCLIGHT_SRCMAIN_PREFIX	:= $(CABALDIST_UHCLIGHT_PREFIX)$(CABALDIST_SRCMAIN_PREFIX)

# location for doc (end products)
DOC_PREFIX			:= $(UHC_TOP_PREFIX)doc/

# location of test src
TEST_SRC_PREFIX						:= $(UHC_TOP_PREFIX)test/
TEST_REGRESS_SRC_PREFIX				:= $(TEST_SRC_PREFIX)regress/

# location for testing, is done after cd to test src dir, hence these relative paths, must correspond to above dirs w.r.t. nr of dir levels
TEST_TOP_PREFIX						:= ../../
TEST_BLD_PREFIX						:= $(TEST_TOP_PREFIX)build$(EHC_BUILD_SUFFIX_DASH)/

# name of subdirectory for shared ehc library artifacts
EHCLIB_SHARED						:= shared

###########################################################################################
# Commands
###########################################################################################

# compilers and tools used
AGC							:= /home/tibor/.cabal/bin/uuagc
SHUFFLE						:= /home/tibor/.cabal/bin/shuffle
RULER2						:= echo "**** ERROR **** A tool or library is missing. Check ./configure summary." ; exit 1
GHC							:= /usr/local/bin/ghc
GHC1						:= /usr/local/bin/ghc
GHC_VERSION         		:= 8.0.2
CABAL						:= /home/tibor/.cabal/bin/cabal
HSC2HS						:= /usr/local/bin/hsc2hs
HADDOCK						:= /home/tibor/.cabal/bin/haddock
HADDOCK_VERSION     		:= Haddock version 2.17.4, (c) Simon Marlow 2006
GCC							:= /usr/bin/gcc
AR							:= /usr/bin/ar
RANLIB						:= /usr/bin/ranlib
OPEN_FOR_EDIT				:= bbedit
STRIP						:= $(STRIP_CMD)
JAVAC						:= 
JAR							:= 
CAT							:= /bin/cat
SHELL_FILTER_NONEMP_FILES	:= $(BINABS_PREFIX)filterOutEmptyFiles
SHELL_AGDEPEND				:= $(BINABS_PREFIX)agdepend
TAR							:= tar

#tool existence
ifeq (no,yes)
RULER_EXISTS				:= yes
else
# just leave empty
RULER_EXISTS				:= 
endif

# lhs2TeX
LHS2TEX_ENV					:= $(LHS2TEX)
LHS2TEX_CMD					:= LHS2TEX=".$(PATHS_SEP)../../$(FMT_SRC_PREFIX)$(PATHS_SEP)$(LHS2TEX_ENV)" lhs2TeX

# latex
LATEX_ENV					:= $(TEXINPUTS)
PDFLATEX					:= TEXINPUTS=".$(PATHS_SEP_COL)../../$(LATEX_SRC_PREFIX)$(PATHS_SEP_COL)$(LATEX_EHC_SUBDIRS)$(LATEX_ENV)" pdflatex
BIBTEX						:= BSTINPUTS=".$(PATHS_SEP_COL)../../$(LATEX_SRC_PREFIX)$(PATHS_SEP_COL)$(LATEX_ENV)" BIBINPUTS=".$(PATHS_SEP_COL)../../$(LATEX_SRC_PREFIX)$(LATEX_ENV)" bibtex
MAKEINDEX					:= makeindex

# shuffle
SHUFFLE_HS_DFLT				:= $(SHUFFLE) --hs --preamble=no --lhs2tex=no --line=yes --compiler=$(GHC_VERSION)
SHUFFLE_HS_ASIS				:= $(SHUFFLE) --plain --preamble=no --lhs2tex=no --line=yes --compiler=$(GHC_VERSION)
SHUFFLE_HS					:= $(SHUFFLE_HS_DFLT)
SHUFFLE_HS_PRE				:= $(SHUFFLE) --hs --preamble=yes --lhs2tex=no --line=yes --compiler=$(GHC_VERSION)
SHUFFLE_AG					:= $(SHUFFLE) --ag --preamble=no --lhs2tex=no --line=no --compiler=$(GHC_VERSION)
SHUFFLE_AG_PRE				:= $(SHUFFLE) --ag --preamble=yes --lhs2tex=no --line=no --compiler=$(GHC_VERSION)
SHUFFLE_PLAIN				:= $(SHUFFLE) --plain --preamble=no --lhs2tex=no --line=no
SHUFFLE_C					:= $(SHUFFLE_PLAIN)
SHUFFLE_JAVA				:= $(SHUFFLE_PLAIN)
SHUFFLE_JS					:= $(SHUFFLE_PLAIN)

# misc
# $1: files to md5
ifneq (,)
FUN_MD5						= cat $(1) | 
else
FUN_MD5						= echo -n "no md5"
endif

###########################################################################################
# installation locations for ehc running time, as functions still depending on variant + target, see also functions.mk
###########################################################################################

FUN_VARIANT_XXX_PREFIX						= $(call FUN_VARIANT_PREFIX,$(1))$(2)/
FUN_VARIANT_LIB_PREFIX						= $(call FUN_VARIANT_XXX_PREFIX,$(1),lib)

FUN_DIR_VARIANT_XXX_PREFIX					= $(call FUN_DIR_VARIANT_PREFIX,$(1),$(2))$(3)/
FUN_DIR_VARIANT_SHARED_PREFIX				= $(call FUN_DIR_VARIANT_XXX_PREFIX,$(1),$(2),shared)
FUN_DIR_VARIANT_LIB_PREFIX					= $(call FUN_DIR_VARIANT_XXX_PREFIX,$(1),$(2),lib)
FUN_DIR_VARIANT_LIB_PKG_PREFIX              = $(call FUN_DIR_VARIANT_LIB_PREFIX,$(1),$(2))pkg/
FUN_DIR_VARIANT_BIN_PREFIX					= $(call FUN_DIR_VARIANT_XXX_PREFIX,$(1),$(2),bin)
FUN_DIR_VARIANT_LIB_TARGET_PREFIX			= $(call FUN_DIR_VARIANT_LIB_PREFIX,$(1),$(2))$(3)/
FUN_DIR_VARIANT_LIB_SHARED_PREFIX			= $(call FUN_DIR_VARIANT_SHARED_PREFIX,$(1),$(2))lib/
#FUN_DIR_VARIANT_PKGLIB_TARGET_PREFIX		= $(call FUN_DIR_VARIANT_LIB_TARGET_PREFIX,$(1),$(2),$(3))pkg/
#FUN_DIR_VARIANT_LIB_TARGET_PKG_PREFIX		= $(call FUN_DIR_VARIANT_PKGLIB_TARGET_PREFIX,$(1),$(2),$(3))$(4)/
FUN_DIR_VARIANT_INC_PREFIX					= $(call FUN_DIR_VARIANT_XXX_PREFIX,$(1),$(2),include)
FUN_DIR_VARIANT_INC_TARGET_PREFIX			= $(call FUN_DIR_VARIANT_INC_PREFIX,$(1),$(2))$(3)/
FUN_DIR_VARIANT_INC_SHARED_PREFIX			= $(call FUN_DIR_VARIANT_SHARED_PREFIX,$(1),$(2))include/

FUN_PKG_VARIANT_TARGET_TVARIANT             = $(1)/$(2)/$(3)/$(4)
FUN_DIR_PKG_VARIANT_TARGET_TVARIANT         = $(call FUN_DIR_VARIANT_LIB_PKG_PREFIX,$(1),$(3))$(call FUN_PKG_VARIANT_TARGET_TVARIANT,$(2),$(3),$(4),$(5))

FUN_INSTALL_VARIANT_SHARED_PREFIX			= $(call FUN_DIR_VARIANT_SHARED_PREFIX,$(INSTALL_DIR),$(1))
FUN_INSTALLABS_VARIANT_SHARED_PREFIX		= $(call FUN_DIR_VARIANT_SHARED_PREFIX,$(INSTALLABS_DIR),$(1))

FUN_INSTALL_VARIANT_PREFIX					= $(call FUN_DIR_VARIANT_PREFIX,$(INSTALL_DIR),$(1))
FUN_INSTALLABS_VARIANT_PREFIX				= $(call FUN_DIR_VARIANT_PREFIX,$(INSTALLABS_DIR),$(1))
FUN_INSTALLABS2_VARIANT_PREFIX				= $(call FUN_DIR_VARIANT_PREFIX,$(INSTALLABS2_DIR),$(1))
FUN_INSTALL_VARIANT_XXX_PREFIX				= $(call    FUN_INSTALL_VARIANT_PREFIX,$(1))$(2)/
FUN_INSTALLABS_VARIANT_XXX_PREFIX			= $(call FUN_INSTALLABS_VARIANT_PREFIX,$(1))$(2)/
FUN_INSTALLABS2_VARIANT_XXX_PREFIX			= $(call FUN_INSTALLABS2_VARIANT_PREFIX,$(1))$(2)/

FUN_INSTALL_VARIANT_LIB_PREFIX				= $(call    FUN_INSTALL_VARIANT_XXX_PREFIX,$(1),lib)
FUN_INSTALLABS_VARIANT_LIB_PREFIX			= $(call FUN_INSTALLABS_VARIANT_XXX_PREFIX,$(1),lib)
FUN_INSTALL_VARIANT_BIN_PREFIX				= $(call    FUN_INSTALL_VARIANT_XXX_PREFIX,$(1),bin)
FUN_INSTALLABS_VARIANT_BIN_PREFIX			= $(call FUN_INSTALLABS_VARIANT_XXX_PREFIX,$(1),bin)
FUN_INSTALL_VARIANT_INC_PREFIX				= $(call    FUN_INSTALL_VARIANT_XXX_PREFIX,$(1),include)
FUN_INSTALLABS_VARIANT_INC_PREFIX			= $(call FUN_INSTALLABS_VARIANT_XXX_PREFIX,$(1),include)

#FUN_INSTALL_VARIANT_LIB_TARGET_PREFIX		= $(call FUN_DIR_VARIANT_LIB_TARGET_PREFIX,$(INSTALL_DIR),$(1),$(2))
FUN_INSTALLABS_VARIANT_LIB_TARGET_PREFIX	= $(call FUN_DIR_VARIANT_LIB_TARGET_PREFIX,$(INSTALLABS2_DIR),$(1),$(2))
#FUN_INSTALL_VARIANT_LIB_SHARED_PREFIX		= $(call FUN_DIR_VARIANT_LIB_SHARED_PREFIX,$(INSTALL_DIR),$(1))
FUN_INSTALLABS_VARIANT_LIB_SHARED_PREFIX	= $(call FUN_DIR_VARIANT_LIB_SHARED_PREFIX,$(INSTALLABS_DIR),$(1))

FUN_INSTALL_PKG_VARIANT_TARGET_TVARIANT_PREFIX \
                                            = $(call FUN_DIR_PKG_VARIANT_TARGET_TVARIANT,$(INSTALL_DIR),$(1),$(2),$(3),$(4))/
FUN_INSTALL_PKG_VARIANT_TARGET_PREFIX       = $(call FUN_INSTALL_PKG_VARIANT_TARGET_TVARIANT_PREFIX,$(1),$(2),$(3),plain)
FUN_INSTALL_PKG_PREFIX                      = $(call FUN_INSTALL_PKG_VARIANT_TARGET_PREFIX,$(1),$(EHC_VARIANT),$(EHC_VARIANT_TARGET))

#FUN_INSTALL_VARIANT_PKGLIB_TARGET_PREFIX	= $(call FUN_DIR_VARIANT_PKGLIB_TARGET_PREFIX,$(INSTALL_DIR),$(1),$(2))
#FUN_INSTALLABS_VARIANT_PKGLIB_TARGET_PREFIX	= $(call FUN_DIR_VARIANT_PKGLIB_TARGET_PREFIX,$(INSTALLABS_DIR),$(1),$(2))

FUN_INSTALL_VARIANT_INC_TARGET_PREFIX		= $(call FUN_DIR_VARIANT_INC_TARGET_PREFIX,$(INSTALL_DIR),$(1),$(2))
FUN_INSTALLABS_VARIANT_INC_TARGET_PREFIX	= $(call FUN_DIR_VARIANT_INC_TARGET_PREFIX,$(INSTALLABS2_DIR),$(1),$(2))
FUN_INSTALL_VARIANT_INC_SHARED_PREFIX		= $(call FUN_DIR_VARIANT_INC_SHARED_PREFIX,$(INSTALL_DIR),$(1))
FUN_INSTALLABS_VARIANT_INC_SHARED_PREFIX	= $(call FUN_DIR_VARIANT_INC_SHARED_PREFIX,$(INSTALLABS_DIR),$(1))

FUN_INSTALL_FLAG_PREFIX						= $(call    FUN_INSTALL_VARIANT_XXX_PREFIX,$(1),ins-flg)
FUN_INSTALLABS_FLAG_PREFIX					= $(call FUN_INSTALLABS2_VARIANT_XXX_PREFIX,$(1),ins-flg)

###########################################################################################
# Construction of the name of a library, specific directories
###########################################################################################

# for an include directory inside a package
# $1: directory prefix of package
FUN_MK_PKG_INC_DIR						= $(1)include

# for a C library
# $1: directory/location prefix
# $2: package name
FUN_MK_CLIB_FILENAME					= $(1)lib$(2)$(LIBC_SUFFIX)

# for a java library
# $1: directory/location prefix
# $2: package name
FUN_MK_JAVALIB_FILENAME					= $(1)lib$(2).jar

# for a javascript library
# $1: directory/location prefix
# $2: package name
FUN_MK_JSLIB_FILENAME					= $(1)lib$(2)$(LIBJS_SUFFIX)

###########################################################################################
# Regular options to commands, as functions still depending on variant + target
###########################################################################################

# C compiler options, some are also extended by sub makefiles
FUN_EHC_GCC_CC_OPTS							= -I$(call FUN_INSTALLABS_VARIANT_INC_SHARED_PREFIX,$(1)) $(GCC_OPTS_WHEN_EHC)
FUN_EHC_GCC_LD_OPTS							= -L$(call FUN_INSTALLABS_VARIANT_LIB_SHARED_PREFIX,$(1))

###########################################################################################
# Regular options to commands
###########################################################################################

# GHC options
GHC_OPTS_GENERAL						:=  -rtsopts
GHC_OPTS_WHEN_EHC						:= $(GHC_OPTS_GENERAL) 
GHC_OPTS								:= $(OPT_GHC_STANDARD_PACKAGES) -package uulib -package uhc-util $(GHC_OPTS_GENERAL)
GHC_OPTS_OPTIM							:= -O2

# HADDOCK options
HADDOCK_OPTS							:= 

# SHUFFLE options
SHUFFLE_OPTS_WHEN_EHC					:= 
SHUFFLE_OPTS_WHEN_UHC					:= --agmodheader=yes

# UUAGC options
UUAGC_OPTS_WHEN_EHC						:= --aoag 
UUAGC_OPTS_WHEN_EHC_AST_DATA			:=  --datarecords
UUAGC_OPTS_WHEN_EHC_AST_SEM				:= 

# UUAGC options for production version (i.e. uhc, ehc variant >= $(EHC_PREL_VARIANT))
UUAGC_OPTS_WHEN_UHC						:=
UUAGC_OPTS_WHEN_UHC_AST_DATA			:= --strictdata --datarecords
#UUAGC_OPTS_WHEN_UHC_AST_SEM				:= --Wignore --strictwrap -O
UUAGC_OPTS_WHEN_UHC_AST_SEM				:= --strictwrap -O

# GCC options
GCC_OPTS_WHEN_EHC						:= -std=gnu99   -fomit-frame-pointer

# CPP options
CPP_OPTS_WHEN_EHC						:=   -D__STDC__

# cabal options
CABAL_CONFIGURE_OPTS_WHEN_EHC			:= 
CABAL_SETUP_OPTS						:= --ghc --with-compiler=$(GHC1) $(CABAL_CONFIGURE_OPTS_WHEN_EHC)
CABAL_OPT_ALLOW_UNDECIDABLE_INSTANCES 	:= UndecidableInstances

# C compiler options, some are also extended by sub makefiles
EXTLIBS_GCC_CC_OPTS						:=   -m64
EXTLIBS_GMP_ABI							:=  64
EXTLIBS_BGC_OPTS						:=  @EXTLIBS_BGC_OPTS@
EHC_GCC_CC_OPTS							:= -I$(INSTALLFORBLDABS_INC_PREFIX) -I$(INSTALLFORBLDABS_INC_PREFIX)/gc $(GCC_OPTS_WHEN_EHC)
EHC_GCC_LD_OPTS							:= -L$(INSTALLFORBLDABS_LIB_PREFIX)
#RTS_GCC_CC_OPTS							:= -D__UHC_BUILDS_RTS__ -D__UHC_TARGET_$(if $(EHC_CFG_TARGET_IS_bc),BC,$(if $(EHC_CFG_TARGET_IS_C),C,$(if $(EHC_CFG_TARGET_IS_llvm),LLVM,)))__ -D__UHC_TARGET__=$(EHC_VARIANT_TARGET)
#RTS_GCC_CC_OPTS							:= -D__UHC_BUILDS_RTS__ -D__UHC_TARGET_$(shell echo $(EHC_VARIANT_TARGET) | tr "[a-z]" "[A-Z]")__ -D__UHC_TARGET__=$(EHC_VARIANT_TARGET)
RTS_GCC_CC_OPTS							:= -D__UHC_BUILDS_RTS__
RTS_GCC_CC_OPTS_OPTIM					:= $(RTS_GCC_CC_OPTS) -O3

# library building, using libtool
LIBTOOL_STATIC_CMD						:= no
LIBTOOL_STATIC							:= $(LIBTOOL_STATIC_CMD) -static -o
LIBTOOL_DYNAMIC							:=  

# lhs2tex options
LHS2TEX_OPTS_DFLT						:= 
LHS2TEX_OPTS_POLY						:= $(LHS2TEX_OPTS_DFLT) --poly
LHS2TEX_OPTS_NEWC						:= $(LHS2TEX_OPTS_DFLT) --newcode

# ruler2 options
RULER2_OPTS_DFLT						:= $(RULER2_OPTS_VERSION)
RULER2_OPTS								:= $(RULER2_OPTS_DFLT)

###########################################################################################
# Installation configuration: options to commands, naming of libraries
###########################################################################################

# cabal options
CABAL_OPT_INSTALL_LOC 					:= --user

# prefix for library name, to make them globally unique
GHC_PKG_NAME_PREFIX						:= 

###########################################################################################
# Shuffle order for EHC variants
###########################################################################################

# order to shuffle (see ehc/src/files1.mk for a complete list)
# 4_99: interim for stuff from 4, needed for 4_2, because of ruler generated material uptil 4_2
EHC_SHUFFLE_ORDER	:= 1 < 2 < 3 < 4 < 4_99 < 5 < 6 < 7 < 8 < 9 < 10 < 11 < 12 < 13 < 14 < 15 < 17 < 19 < 20 < 30 < 31 < 50 < 90 < 91 < 92 < 93 < 96 < 97 < 98 < $(EHC_PREL_VARIANT) < $(EHC_UHC_VARIANT) < $(EHC_UHC_INSTALL_VARIANT), \
						$(EHC_UHC_VARIANT) < 102, \
						$(EHC_UHC_VARIANT) < 103, \
						6 < 6_4, \
						15 < 41

#						4_99 < 4_2, \
#						7 < 7_2, \
#						8 < 8_2
#						10 < 40, \

###########################################################################################
# Cabal
###########################################################################################

# generate cabal file
# $1: pkg name
# $2: version
# $3: build-depends (additional)
# $4: extensions (additional)
# $5: synopsis
# $6: exposed modules
# $7: extra C sources
# $8: build type
# $9: license
FUN_GEN_CABAL		= \
					( \
					echo   "Name:				$(strip $(1))" ; \
					echo   "Version:			$(strip $(2))" ; \
					echo   "License:			BSD3" ; \
					echo   "Copyright:			Utrecht University, Department of Information and Computing Sciences, Software Technology group" ; \
					echo   "Build-Type:			$(8)" ; \
					echo   "license-file:		$(9)" ; \
					echo   "Author:				$(UHC_TEAM)" ; \
					echo   "Homepage:			http://www.cs.uu.nl/wiki/UHC" ; \
					echo   "Category:			Testing" ; \
					echo   "Build-Depends:		$(subst $(space),$(comma),$(strip  fgl uulib>=0.9.19 hashable>=1.2.4&&<1.3 uhc-util>=0.1.6.8&&<0.1.7 base>=4.7&&<5  vector network binary mtl dequeue lens transformers directory containers array process filepath utf8-string bytestring  $(CABAL_ENABLEDASPECT_LIB_DEPENDS) $(3)))" ; \
					echo   "Build-Tools:		" ; \
					echo   "Extensions:			$(subst $(space),$(comma),$(strip RankNTypes MultiParamTypeClasses FunctionalDependencies TupleSections DeriveFunctor NamedFieldPuns RecordWildCards DisambiguateRecordFields $(4)))" ; \
					echo   "Synopsis:			$(strip $(5))" ; \
					echo   "Exposed-Modules:	$(subst $(space),$(comma),$(strip $(6)))" ; \
					echo   "Exposed:			False" ; \
					echo   "C-Sources:			$(subst $(space),$(comma),$(strip $(7)))" ; \
					echo   "Ghc-Options:		$(GHC_OPTS_WHEN_EHC) -fno-warn-tabs" \
					)

# generate cabal file for library
# $1: pkg name
# $2: version
# $3: build-depends (additional)
# $4: extensions (additional)
# $5: synopsis
# $6: exposed modules
# $7: extra C sources
FUN_GEN_CABAL_LIB	= $(call FUN_GEN_CABAL,\
						$(1),$(2),$(3),$(4),$(5),$(6),$(7),\
						Simple,\
						$(TOPABS_PREFIX)LICENSE \
						)

# generate cabal file for executable
# $1: pkg name
# $2: version
# $3: build-depends (additional)
# $4: extensions (additional)
# $5: synopsis
# $6: exposed modules
# $7: extra C sources
FUN_GEN_CABAL_EXEC	= $(call FUN_GEN_CABAL,\
						$(1),$(2),$(3),$(4),$(5),$(6),$(7),\
						Custom,\
						LICENSE \
						)

# generate simplest cabal Setup.hs
GEN_CABAL_SETUP		= (echo "import Distribution.Simple" ; echo "main = defaultMain")

# compile cabal setup
# $1: src
# $2: exec
GHC_CABAL			= $(GHC) $(GHC_OPTS_GENERAL) -package Cabal -o $(2) $(1)  ; $(STRIP_CMD) $(2)

# generate cabal file for uhc-light cabal distr
# $1: pkg name
# $2: version
# $3: build-depends (additional)
# $4: extensions (additional)
# $5: synopsis 
# $6: description 
# $7: exposed library modules
# $8: other library modules
# $9: executable Main: compiler
# $10: executable name: compiler
# $11: extra source files
# $12: build type
# $13: license
# $14: change log
# $15: executable Main: runner
# $16: executable name: runner
# $17: src dir lib
# $18: src dir main
FUN_GEN_CABAL_UHC_LIGHT		= \
					( \
					echo   "Name:				$(strip $(1))" ; \
					echo   "Version:			$(strip $(2))" ; \
					echo   "License:			BSD3" ; \
					echo   "Copyright:			Utrecht University, Department of Information and Computing Sciences, Software Technology group" ; \
					echo   "Build-Type:			$(12)" ; \
					echo   "license-file:		$(13)" ; \
					echo   "Author:				$(UHC_TEAM)" ; \
					echo   "Maintainer:         uhc-developers@lists.science.uu.nl" ; \
					echo   "Homepage:			https://github.com/UU-ComputerScience/uhc" ; \
					echo   "Bug-Reports:        https://github.com/UU-ComputerScience/uhc/issues" ; \
					echo   "Category:			Development" ; \
					echo   "Synopsis:			$(strip $(5))" ; \
					echo   "Description:		$(strip $(6))" ; \
					echo   "Cabal-Version:      >= 1.8" ; \
					echo   "data-files:         $(11)" ; \
					echo   "extra-source-files: $(14)" ; \
					echo   "" ; \
					echo   "Library" ; \
					echo   "  Hs-Source-Dirs:       $(17)" ; \
					echo   "  Build-Depends:		$(subst $(space),$(comma),$(strip  fgl uulib>=0.9.19 hashable>=1.2.4&&<1.3 uhc-util>=0.1.6.8&&<0.1.7 base>=4.7&&<5  vector network binary mtl dequeue lens transformers directory containers array process filepath utf8-string bytestring  $(CABAL_ENABLEDASPECT_LIB_DEPENDS) $(3)))" ; \
					echo   "  Extensions:			$(subst $(space),$(comma),$(strip RankNTypes MultiParamTypeClasses FunctionalDependencies $(4)))" ; \
					echo   "  Exposed-Modules:		$(7)" ; \
					echo   "  Other-Modules:		$(8)" ; \
					echo   "  Ghc-Options:			-fno-warn-tabs" ; \
					echo   "" ; \
					echo   "Executable $(strip $(10))" ; \
					echo   "  Hs-Source-Dirs:       $(18)" ; \
					echo   "  Build-Depends:		$(strip $(1))==$(strip $(2)), $(subst $(space),$(comma),$(strip  fgl uulib>=0.9.19 hashable>=1.2.4&&<1.3 uhc-util>=0.1.6.8&&<0.1.7 base>=4.7&&<5  vector network binary mtl dequeue lens transformers directory containers array process filepath utf8-string bytestring  $(CABAL_ENABLEDASPECT_LIB_DEPENDS) $(3)))" ; \
					echo   "  Extensions:			$(subst $(space),$(comma),$(strip RankNTypes MultiParamTypeClasses FunctionalDependencies $(4)))" ; \
					echo   "  Main-Is:           	$(strip $(9)).hs" ; \
					echo   "" ; \
					echo   "Executable $(strip $(16))" ; \
					echo   "  Hs-Source-Dirs:       $(18)" ; \
					echo   "  Build-Depends:		$(strip $(1))==$(strip $(2)), $(subst $(space),$(comma),$(strip  fgl uulib>=0.9.19 hashable>=1.2.4&&<1.3 uhc-util>=0.1.6.8&&<0.1.7 base>=4.7&&<5  vector network binary mtl dequeue lens transformers directory containers array process filepath utf8-string bytestring  $(CABAL_ENABLEDASPECT_LIB_DEPENDS) $(3)))" ; \
					echo   "  Extensions:			$(subst $(space),$(comma),$(strip RankNTypes MultiParamTypeClasses FunctionalDependencies $(4)))" ; \
					echo   "  Main-Is:           	$(strip $(15)).hs" ; \
					)

###########################################################################################
# Filter out empty files
###########################################################################################

# remove files with empty content from list of files
# $1: file list
FILTER_OUT_EMPTY_FILES		= $(if $(strip $(1)),$(shell echo $(1) | sed -e 's/\([^ ]*\)\s*/ls \1\* ;/g' | sh | sed -e 's/\s+/ /g' | sort | uniq | xargs $(SHELL_FILTER_NONEMP_FILES)),)

# FILTER_OUT_EMPTY_FILES		= $(shell echo $(1) | sed -e 's/\([^ ]*\)\.hs\s*/ls \1\*\.hs ;/g' | sh | sed -e 's/\s+/ /g' | sort | uniq | xargs $(SHELL_FILTER_NONEMP_FILES) )

###########################################################################################
# Misc
###########################################################################################

# strip dashes
# $1: dashed text
FUN_STRIP_DASH		= $(subst -,,$(1))

# date
TODAY				:= $(shell date '+%G%m%d')

# strip a '/' at the end, turning a prefix into a directory
FUN_PREFIX2DIR			= $(patsubst %/,%,$(1))

# target suffix for core
CORE_TARG_SUFFIX	:= grin2

# subst's
SUBST_BAR_IN_TT		:= sed -e '/begin{TT[^}]*}/,/end{TT[^}]*}/s/|/||/g'
SUBST_EHC			:= perl $(BIN_PREFIX)substehc.pl
SUBST_LINE_CMT		:= sed -e 's/{-\# LINE[^\#]*\#-}//' -e '/{-\#  \#-}/d'
SUBST_SH			:= perl $(BIN_PREFIX)substsh.pl

# indentation of (test) output
INDENT2				:= sed -e 's/^/  /'
INDENT4				:= sed -e 's/^/    /'

# make programming utils
head				= $(word 1,$(1))
tail				= $(wordlist 2,$(words $(1)),$(1))
comma				:= ,
empty				:=
space				:= $(empty) $(empty)
dollar				:= $$
ddollar				:= $(dollar)$(dollar)
cparen				:= )

# subst _ by x
# $1: text
SUBS_US_X			= $(subst _,x,$(1))

# make a static library, see also src/ehc/Config.chs.in
# $1: library
# $2: files
ifeq ($(LIBTOOL_STATIC_CMD),no)
FUN_LIB_MK_STATIC		= $(AR) r $(1) $(2) ; $(RANLIB) $(1)
else
FUN_LIB_MK_STATIC		= $(LIBTOOL_STATIC) $(1) $(2)
endif

