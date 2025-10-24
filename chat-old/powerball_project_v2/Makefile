
R6 = raku

test:
	zef test -v .

# Batch parse locally saved PDFs with extract-from-pdfs.raku
# Usage:
#   make batch PDFS="~/LotteryPDFs/*.pdf" EMIT=both
#   make batch PDFS="~/LotteryPDFs" EMIT=blocks
PDFS ?= ~/Downloads/pb.pdf
EMIT ?= blocks

batch:
	$(R6) extract-from-pdfs.raku $(PDFS) --emit=$(EMIT) > tests/tmp/batch.out || true
	@echo "Wrote tests/tmp/batch.out"

# Fetch latest Florida PDF to tests/tmp/pb.pdf
fetch:
	$(R6) download-pdf.raku --out=tests/tmp/pb.pdf

# Fetch and immediately parse to blocks+JSON
fetch-parse: fetch
	$(R6) emit-blocks.raku --pdf=tests/tmp/pb.pdf --emit=both > tests/tmp/fetch-parsed.out || true
	@echo "Wrote tests/tmp/fetch-parsed.out"
