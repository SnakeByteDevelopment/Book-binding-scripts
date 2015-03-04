# myScripts
some handy scripts I use on my own computer and like to share.

## scan2file.sh
This script originally did nothing more than scanning multiple pages to an pdf file. 
I added som functionallities to the script to interpret the text of the scanned documents and
send the files to an printer specified in the script.

### tiff2pdf bugs
My script uses tiff2pdf to convert the scanned pages to pdf, firstly the pdf had a filesize of 25mb/page, 
after compression there was a problem with the background turning to red, this is a bug in tiff2pdf, 
but I fixed it inside the script.
