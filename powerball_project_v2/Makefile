R6 = raku

test:
	zef test -v .


# Batch parse locally saved PDFs with extract-from-pdfs.raku
# Usage:
#   make batch PDFS="~/LotteryPDFs/*.pdf" EMIT=both
# or
#   make batch PDFS="~/LotteryPDFs" EMIT=blocks
PDFS ?= ~/Downloads/pb.pdf
EMIT ?= blocks

batch:
	$(R6) extract-from-pdfs.raku $(PDFS) --emit=$(EMIT) > tests/tmp/batch.out
	@echo "Wrote tests/tmp/batch.out"
