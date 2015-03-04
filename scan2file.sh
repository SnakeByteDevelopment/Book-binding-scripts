#!/bin/bash


#===============================================================================#
# scanToFile: multiple file scanning script to pdf and OCR                      #
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


outname="scannedfile"
startdir=$(pwd)
tmpdir=scan-$RANDOM
printer=HL-2030-series
ocr=0
printit=0
jpgCompression=50

__ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
  echo "Usage :  $0 [options] [--]

  Options:
  -h|Help           Display this message
  -v|Version        Display script version
  -o|Output <file>  Outputfile name
  -t|ToText         Try to make a text-file of scanned file
  -p|Print          Print pages using predefined printer in script"
   
}    # ----------  end of function usage  ----------

#===  FUNCTION  ================================================================
#         NAME:  scan
#  DESCRIPTION:  scan all pages in scanner tray
#===============================================================================
function scan ()
{
    cd ~/
    mkdir $tmpdir
    cd $tmpdir
    echo "################## Scanning ###################"
    scanimage -y 279.4 -x 215.9 --batch=out%03d.tif --format=tiff --resolution 300 
}   # ----------  end of function scan  ----------

#===  FUNCTION  ================================================================
#         NAME:  ocr
#  DESCRIPTION:  Text recognition using texeract
#===============================================================================
function ocr ()
{
    echo "#################### OCRing ####################"
    i=1
    for page in $(ls *.tif); do
    echo -n "Page: $i - "
        # run tesseract on each page and combine the outputs in a single file with a .txt extension.
        tesseract $page $page
        echo "---BEGIN PAGE: $i ---" >> $outname.txt
        cat $page.txt >> $outname.txt
        echo "---END PAGE: $1 ---" >> $outname.txt
        i=$(expr $i + 1)
    done
    mv $outname.txt $startdir
}   # ----------  end of function ocr  ----------


#===  FUNCTION ================================================================
#         NAME:  merge2pdf
#  DESCRIPTION:  Merge all pages into 1 pdf file
#==============================================================================
function merge2pdf()
{
    echo "############## Converting to PDF ##############"
    #Use tiffcp to combine output tiffs to a single mult-page tiff
    tiffcp -c lzw out*.tif output.tif 
    #Convert the tiff to PDF
    tiff2pdf -p A4 -j -q $jpgCompression -f output.tif > temp.pdf
    sed s/"ColorTransform 0"/"ColorTransform 1"/ < temp.pdf > $startdir/$outname 
}


#===  FUNCTION ================================================================
#         NAME:  print
#  DESCRIPTION:  print pages using printer defined at beginning of script
#==============================================================================

function print() {
    lpr -p $printer *.tif
}

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvo:tp*" opt

do
  case $opt in

    h|help     )  usage; exit 0   ;;
 
    v|version  )  echo "$<`0:0`> -- Version $__ScriptVersion"; exit 0   ;;

    o|Output   )  outname=$OPTARG  ;;

    t|ToText   )  ocr=1  ;;

    p|Print    )  printit=1  ;;

    * )  echo  "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

scan

if [[ ocr -eq 1 ]]; then
    ocr
fi

merge2pdf

if [[ printit -eq 1 ]]; then
    print
fi

cd ..
rm -rf ./$tmpdir
