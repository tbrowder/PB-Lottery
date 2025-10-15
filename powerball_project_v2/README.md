# Power Ball – v2 with LibCurl::Easy

Run `zef install LibCurl::Easy` and `sudo apt install poppler-utils`.


## Batch parse local PDFs
```bash
# Parse a single manual download
raku extract-from-pdfs.raku ~/Downloads/pb.pdf --emit=both

# Parse a folder of PDFs, dedup by date, output blocks
raku extract-from-pdfs.raku ~/LotteryPDFs --emit=blocks

# Parse a glob
raku extract-from-pdfs.raku "~/LotteryPDFs/*.pdf" --emit=json
```
