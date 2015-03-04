# myScripts
some handy scripts I use on my own computer and like to share.

## scan2file.sh
This script originally did nothing more than scanning multiple pages to a pdf file. 
I added some functionallities to the script to interpret the text of the scanned documents and
send the files to an printer specified in the script.

### tiff2pdf bugs
My script uses tiff2pdf to convert the scanned pages to pdf, firstly the pdf had a filesize of 25mb/page, 
after compression there was a problem with the background turning to red, this is a bug in tiff2pdf, 
but I fixed it inside the script.

## pdfInterleave
This script is not originally mine, but it was not working correctly. 
The script handles the interleaving of scanned dubblesided documents with multiple pages, it takes 2 input files of the pdf format and puts them together taking 1 page of both files in turn.
For scanning ease the file takes a even page file with descanding page numbering, in later versions of the script it will be a choice of the user to use this option or not.

### Todo
* integrate scan2file into pdfInterleave
* add a choice to have the even pages in increasing or decreasing order inside the input file.
