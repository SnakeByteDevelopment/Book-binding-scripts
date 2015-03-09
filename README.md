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
The basic script is not originally mine, I think I found it on stackoverflow but it was not working correctly. 
The script handles the interleaving of scanned dubblesided documents with multiple pages, it takes 2 input files of the pdf format and puts them together taking 1 page of both files in turn.
For scanning ease the file takes a even page file with descanding page numbering, in later versions of the script it will be a choice of the user to use this option or not.

### Todo
* integrate scan2file into pdfInterleave
* add a choice to have the even pages in increasing or decreasing order inside the input file.

## pdfBinder.sh
This script prepares a book in pdf for printing so you can bind it later. I was inspired to make this script by reading a article about book binding (see below) where there was explained how to prepare your book for printing using a Linux computer. Becous it is quite some work I desided to make a script that does it all for you. The script works perfectly but it needs some cleaning and minor debugging work done. 
More on binding your books you can find here: http://www.tuxgraphics.org/npa/book-binding/
