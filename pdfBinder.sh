#!/usr/bin/env bash

#===  LICENSE  ================================================================
# pdf2bind: make a pdf file ready to print for bookbinding.
# Copyright (C) 2017 <`2:Gert Pellin <gert@pellin.be>`>			
#									
# This script is free software; you can redistribute it and/or modify	
# it under the terms of the GNU General Public License as published by	
# the Free Software Foundation; either version 2 of the License, or	
# (at your option) any later version.					
#									
# This program is distributed in the hope that it will be useful,	
# but WITHOUT ANY WARRANTY; without even the implied warranty of	
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the		
# GNU General Public License for more details.				
#									
# You should have received a copy of the GNU General Public License	
# along with this program; if not, see <http://www.gnu.org/licenses/>.	
#==============================================================================

__ScriptVersion="0.1"
papertype="a4"

#=== FUNCTION ===============================================================
# NAME: add_leading_zero
# DESCRIPTION: <`0:`>
#==============================================================================
function add_leading_zero {
prefix=$1
suffix=$2
baseprefix=$(basename $prefix | sed -e 's/[]\/()$*.^|[]/\\&/g')
dirprefix=$(dirname $prefix)
for filename in "$prefix"*"$suffix"
do
    base=$(basename "$filename")
    index=$(echo "$base" | sed -rn "s/$baseprefix([0-9]+)$suffix$/\1/p")
    newbase=$(printf "$baseprefix%04d$suffix" $index)
    mv $filename "$dirprefix/$newbase"
done
}

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    echo "Usage :  $<`0:0`> [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hv" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$<`0:0`> -- Version $__ScriptVersion"; exit 0   ;;

    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

workingdir=$(pwd)
tmpdir=pdf2bind-$RANDOM

mkdir ~/$tmpdir
cd ~/$tmpdir
pdftops $workingdir/$1 ps.ps
declare -i bundlenr=1
for (( i=1; i < `pdfinfo $workingdir/$1 | grep Pages | sed 's/[^0-9]*//'`; i=$i+32 )); do
    psselect -q -p`declare -i j=$i
                while (($j < $i+31))
                do
                    echo -n "$j,"
                    j=$j+1
                done
                echo -n $j` ps.ps out${bundlenr}.ps
    if (( `gs -o /dev/null -sDEVICE=bbox out${bundlenr}.ps 2>&1 | grep HiResBoundingBox | wc -l` < 6 ))
    then
        psjoin out$(( $bundlenr-1 )).ps out${bundlenr}.ps > out$(( $bundlenr-1  ))
        mv out$(( $bundlenr-1 )) out$(( $bundlenr-1 )).ps 
        rm out$(( $bundlenr )).ps
    fi
    bundlenr=$bundlenr+1
done
rm ps.ps
add_leading_zero "out" ".ps"

bundlenr=1
for file in ./out*.ps
do
    psbook $file | psnup  -b1.4cm -s0.6 -p$papertype -2 > book_$bundlenr.ps
    ps2pdf book_$bundlenr.ps book_$bundlenr.pdf
    bundlenr=$bundlenr+1
done

add_leading_zero "book_" ".pdf"
pdfunite `echo ./book_*.pdf` book.pdf
mv book.pdf $workingdir/$outfile
cd $workingdir
rm -rf ~/$tmpdir

