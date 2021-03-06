# This file is part of GNU OrgaDoc.
#
# GNU OrgaDoc is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# GNU OrgaDoc is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/. 

#
# Eiffel language support.
#
# Experiments by Berend de Boer to add Eiffel compiler support to autoconf.
# An important part of this macro set is checking for Gobo, as Gobo makes
# writing portable code lots and lots easier.
#


## ----------------------- ##
## 1. Language selection.  ##
## ----------------------- ##


# ----------------------------- #
# 1e. The Eiffel language.      #
# ----------------------------- #


# AC_LANG(Eiffel)
# -------------------
# This is not ok, perhaps remove?
# conftests doesn't work with Eiffel, and perhaps are/should not
# be necessary.
m4_define([AC_LANG(Eiffel)],
[ac_ext=e
ac_compile='geant conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_compiler_gnu=$ac_cv_eiffel_compiler_gnu
])


# AC_LANG_EIFFEL
# -----------------
AU_DEFUN([AC_LANG_EIFFEL], [AC_LANG(Eiffel)])



## ---------------------- ##
## 2.Producing programs.  ##
## ---------------------- ##


# ------------------------ #
# 2e. Eiffel sources.      #
# ------------------------ #

# AC_LANG_SOURCE(Eiffel)(BODY)
# --------------------------------
# FIXME: No idea if this is needed.
m4_define([AC_LANG_SOURCE(Eiffel)],
[class CONFTEST creation make feature make is do $1 end end])


## -------------------------------------------- ##
## 3. Looking for Compilers and Preprocessors.  ##
## -------------------------------------------- ##

# ----------------------------- #
# 3e. The Eiffel compiler.      #
# ----------------------------- #

# AC_LANG_COMPILER(Eiffel)
# ----------------------------
# Find the Eiffel compiler.  Must be AC_DEFUN'd to be
# AC_REQUIRE'able.


# AC_PROG_EC([COMPILERS...])
# ---------------------------
# COMPILERS is a space separated list of Eiffel compilers to search
# for.
AC_DEFUN([AC_PROG_EC],
[AC_LANG_PUSH(Eiffel)dnl
AC_ARG_VAR([EC],     [Eiffel compiler command])dnl
AC_ARG_VAR([GOBO_EIFFEL],     [Eiffel vendor (se, ise, ve), default is se])dnl
AC_CHECK_TOOLS(EC,
      [m4_default([$1],
                  [se-compile compile ec vec])])

# Provide some information about the compiler.
echo "$as_me:__oline__:" \
     "checking for _AC_LANG compiler version" >&AS_MESSAGE_LOG_FD
ac_compiler=`set X $ac_compile; echo $[2]`
_AC_EVAL([$ac_compiler --version </dev/null >&AS_MESSAGE_LOG_FD])
_AC_EVAL([$ac_compiler -v </dev/null >&AS_MESSAGE_LOG_FD])
_AC_EVAL([$ac_compiler -V </dev/null >&AS_MESSAGE_LOG_FD])

if test x$EC = x; then
  AC_MSG_ERROR(No recognized Eiffel compiler in your path or no Eiffel compiler installed)
fi

# We set GOBO_EIFFEL regardless of Gobo is installed or not.
# Gobo is more or less the base for every package out there, so why
# not use it as the default.
AC_SUBST(GOBO_EIFFEL)
if test x$EC = xcompile; then
  GOBO_EIFFEL=se
fi
if test x$EC = xse-compile; then
  GOBO_EIFFEL=se
fi
if test x$EC = xec; then
  GOBO_EIFFEL=ise
fi
if test x$EC = xvec; then
  GOBO_EIFFEL=ve
fi

# Depending on GOBO_EIFFEL, we set conditionals that can be used
# to create libraries for a specific compiler or to do other compiler
# specific stuff in a Makefile.am
AM_CONDITIONAL(SE, test "x$GOBO_EIFFEL" = "xse")
AM_CONDITIONAL(VE, test "x$GOBO_EIFFEL" = "xve")
AM_CONDITIONAL(ISE, test "x$GOBO_EIFFEL" = "xise")

# set EIFFEL_COMPILER_HEADER_DIR depending on EC
# useful for linking in C code that accesses Eiffel
AC_SUBST(EIFFEL_COMPILER_HEADER_DIR)
if test "x$GOBO_EIFFEL" = "xse"; then
  # Try SEDIR if set, more safe then hacking the SmaRTEiffel environment variable
  if test ! "x"$SEDIR = "x"; then
    EIFFEL_COMPILER_HEADER_DIR=$SEDIR
  else
    if test ! "x"$SmartEiffel = "x"; then
      EIFFEL_COMPILER_HEADER_DIR=`echo $SmartEiffel | sed -e 's/\(.*\)SmartEiffel\(.*\)/\1SmartEiffel/'`
    else
      if ! test "x"$SmallEiffel = "x"; then
        EIFFEL_COMPILER_HEADER_DIR=`echo $SmallEiffel | sed -e 's/\(.*\)SmallEiffel\(.*\)/\1SmallEiffel/'`
      else
        AC_MSG_ERROR(The SmartEiffel environment variable is not set)
      fi
    fi
  fi

  # With SE 1.1 the location of base.h has changed
  # To be able to support earlier and newer versions, we have to found
  # out where it is.
  if test -r $EIFFEL_COMPILER_HEADER_DIR/sys/runtime/c/base.h; then
    AC_DEFINE(HAVE_C_BASE_H, 1, [Define to 1 if SmartEiffel header file in sys/runtime/c/base.])
  else
    if test -r $EIFFEL_COMPILER_HEADER_DIR/sys/runtime/base.h; then
      AC_DEFINE(HAVE_BASE_H, 1, [Define to 1 if SmartEiffel header file in sys/runtime/base.])
    fi
  fi
fi
if test "x$GOBO_EIFFEL" = "xise"; then
  EIFFEL_COMPILER_HEADER_DIR=$ISE_EIFFEL/studio/spec/$ISE_PLATFORM/include
fi
if test "x$GOBO_EIFFEL" = "xve"; then
  EIFFEL_COMPILER_HEADER_DIR=$VE_Bin
fi

AC_LANG_POP(Eiffel)dnl
])# AC_PROG_EC


# AC_PROG_GOBO
# ------------
# Check if the Gobo package is available.
AC_DEFUN([AC_PROG_GOBO],
[

# check for Eiffel compiler
if test "x$GOBO_EIFFEL" = "x" ; then
  AC_PROG_EC
else
  if test "x$GOBO_EIFFEL" = "xise"; then
    AC_PROG_EC(ec)
  fi
  if test "x$GOBO_EIFFEL" = "xse"; then
    AC_PROG_EC([m4_default([$1],
                  [se-compile compile])])
  fi
  if test "x$GOBO_EIFFEL" = "xve"; then
    AC_PROG_EC(vec)
  fi
  AC_PROG_EC
fi

# check for Gobo tools
AC_CHECK_PROG(GOBO_GEANT,geant,yes,no)
AC_CHECK_PROG(GOBO_GEXACE,gexace,yes,no)
AC_CHECK_PROG(GOBO_TEST,getest,yes,no)
AC_CHECK_PROG(GOBO_YACC,geyacc,yes,no)
AC_CHECK_PROG(GOBO_LEX,gelex,yes,no)
AC_CHECK_PROG(GOBO_GEPP,gepp,yes,no)

if test x$GOBO_GEANT = xno; then
  AC_MSG_ERROR(Gobo "geant" not in your path or not installed)
fi

])# AC_PROG_GOBO


# AC_CHECK_RQRD_CLUSTER
# ---------------------
# Check if a certain cluster (or set of clusters) is available.
# This is equal to checking if the environment variable of this name is set
# and if that directory exists.
# The cluster is considered required, so an error message is given if
# cluster not found.
# Use AC_CHECK_XACE_CLUSTER to check for a .xace file in addition.
AC_DEFUN([AC_CHECK_RQRD_CLUSTER],
[AC_ARG_VAR([$1], [Location of $1 cluster])dnl

AC_MSG_CHECKING([for Eiffel cluster $1])

if test x$$1 = x; then
  AC_MSG_ERROR(The environment variable for cluster $1 is undefined)
fi

if test ! -d $$1; then
  AC_MSG_ERROR(The directory for cluster $1 given as $$1 does not exist)
fi

AC_MSG_RESULT([yes])
])# AC_CHECK_CLUSTER

# AC_CHECK_RQRD_CLUSTER
# ---------------------
# Check if a certain cluster (or set of clusters) is available.
# This is equal to checking if the environment variable of this name is set
# and if that directory or file exists.
# The cluster is considered required, so an error message is given if
# cluster not found.
# Use AC_CHECK_XACE_CLUSTER to check for a .xace file in addition.
AC_DEFUN([AC_CHECK_RQRD_CLUSTER2],
[AC_ARG_VAR([$1], [Location of $1 cluster])dnl

AC_MSG_CHECKING([for Eiffel cluster $1])

if test x$$1 = x; then
  AC_MSG_ERROR(The environment variable for cluster $1 is undefined)
fi

if test ! -f $$1; then
  if test ! -d $$1; then
    AC_MSG_ERROR(The file/directory for cluster $1 given as $$1 does not exist)
  fi
fi

AC_MSG_RESULT([yes])
])# AC_CHECK_CLUSTER2

# AC_CHECK_RQRD_XACE(CLUSTER, PATH-RELATIVE-TO-CLUSTER)
# -----------------------------------------------------
# Check if a certain .xace file is available.
AC_DEFUN([AC_CHECK_RQRD_XACE],
[AC_CHECK_RQRD_CLUSTER($1)

if test x$2 = x; then
  AC_MSG_CHECKING([for $3.xace])
else
  AC_MSG_CHECKING([for $3.xace in $2])
fi
if test ! -r $$1/$2/$3.xace; then
  AC_MSG_ERROR($$1/$2/$3.xace does not exist)
fi
AC_MSG_RESULT([yes])
])# AC_CHECK_XACE
