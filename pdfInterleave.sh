#!/usr/bin/env bash


#===============================================================================#
# pdfInterleave: interleave 2sided scanned documents to 1 file                  #
# Copyright (C) 2015 Gert Pellin gert@gepe-biljarts.be                          #
#                                                                               #
# This program is free software; you can redistribute it and/or modify          #
# it under the terms of the GNU General Public License as published by          #
# the Free Software Foundation; either version 2 of the License, or             #
# (at your option) any later version.                                           #
#                                                                               #
# This program is distributed in the hope that it will be useful,               #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                  #
# GNU General Public License for more details.                                  #
#                                                                               #
# You should have received a copy of the GNU General Public License             #
# along with this program; if not, see <http://www.gnu.org/licenses/>.          #
#===============================================================================#

outname="interleaved"


__ScriptVersion="1.0"


function add_leading_zero {
	prefix=$1
	baseprefix=$(basename $prefix | sed -e 's/[]\/()$*.^|[]/\\&/g')
	dirprefix=$(dirname $prefix)
	for filename in "$prefix"*".pdf"
	do
		base=$(basename "$filename")
		index=$(echo "$base" | sed -rn "s/$baseprefix([0-9]+).pdf$/\1/p")
		newbase=$(printf "$baseprefix%04d.pdf" $index)
		mv $filename "$dirprefix/$newbase"
	done
}

function pdfinterleave {
	oddfile=$1
	oddbase=$2
	evenfile=$3
	evenbase=$4
	key=$5
	
    # Odd pages
	pdfseparate $oddfile "$oddbase-$key-%d.pdf"
	add_leading_zero "$oddbase-$key-"
	oddpages=($(ls "$oddbase-$key-"* | sort))
	
    # Even pages
	pdfseparate $evenfile "$evenbase-$key-%d.pdf"
	add_leading_zero "$evenbase-$key-"
	evenpages=($(ls "$evenbase-$key-"* | sort -r))
	
    # Interleave pages
	pages=()
	for((i=0;i<${#oddpages[@]};i++))
	do
		pages+=(${oddpages[i]})
		pages+=(${evenpages[i]})
	done
	pdfunite ${pages[@]} "$outfile"
	rm ${oddpages[@]}
	rm ${evenpages[@]}
}

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    echo "Usage :  $<`0:0`> [options] [--] oddfile.pdf evenfile.pdf
    
    make shure the odd pages are ordered incremental and the 
    even pages decremental for this script to work.

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -o|Output <file> Outputfile name"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvo:" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$<`0:0`> -- Version $__ScriptVersion"; exit 0;;

    o|Output   )  outname=$OPTARG ;;
    
    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


if [ $# -lt 2 ]
then
	usage
    exit 1
fi
if [ $1 == $2 ]
then
	usage
	exit 1
fi
if ! hash pdfunite 2>/dev/null || ! hash pdfseparate 2>/dev/null
then
	echo "This script requires pdfunite and pdfseparate from poppler utils" \
	"to be in the PATH. On Debian based systems, they are found in the" \
	"poppler-utils package"
	exit 1
fi
oddbase=${1%.*}
evenbase=${2%.*}
odddir=$(dirname $oddbase)
oddfile=$(basename $oddbase)
evenfile=$(basename $evenbase)
outfile="$odddir/$outfile.pdf"
key=$(tr -dc "[:alpha:]" < /dev/urandom | head -c 8)
if [ -e $outfile ]
then
	echo "Output file $outfile already exists" >&2
	exit 1
fi
pdfinterleave $1 $oddbase $2 $evenbase $key 
