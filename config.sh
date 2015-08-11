#!/bin/bash

declare -a BuildConfigs
declare -a ObjDirs

BuildConfigs=(
   Release
   Debug
   FastDebug
   Profile
   QualityScores
   ThreadedDebug
   ThreadedFastDebug
   ThreadedProfile
   ThreadedRelease
)



ObjDirs=(
   "bin"
)

BASE_DIR="`pwd`"

function makeDirectories()
{
   echo
   echo "Creating directories:"
   
   # Create the bin, obj, etc. directories.
   for objdir in "${ObjDirs[@]}"
   do
      cd "$BASE_DIR"
      
      echo "   ./${objdir}"
      mkdir -p "$objdir"
      cd "$objdir"
      
      # For each of the object directories, create the target directories.
      for bldConfig in "${BuildConfigs[@]}"
      do
         echo "      ${bldConfig}"
         mkdir -p "$bldConfig"
      done
   done
    
   # create ThirdParty lib 
   THIRDPARTY_DIR="$BASE_DIR/3rdParty"  
   echo
   echo "   ./3rdParty:"
   cd "$THIRDPARTY_DIR"
   echo "      lib"
   mkdir -p "lib"
   cd "$THIRDPARTY_DIR/lib"
   echo "   ./3rdParty/lib:"
   
   # For 3rdParty, create the build configuration directories.
   for bldConfig in "${BuildConfigs[@]}"
   do
      echo "      ${bldConfig}"
      mkdir -p "$bldConfig"
   done
      
   # create link for config files in ./bin so newbler can see it from 
   # build-config-specific dirs like ThreadedRelease
   cd "$BASE_DIR/bin"
   if [ ! -h config ]; then
   	ln -s "$BASE_DIR/config" config
   fi
}



makeDirectories
