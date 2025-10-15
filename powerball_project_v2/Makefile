R6 = raku
emit:
	$(R6) emit-blocks.raku --last=5 > tests/tmp/emit.blocks
emit-json:
	$(R6) emit-blocks.raku --last=5 --emit=json > tests/tmp/emit.json
parse:
	$(R6) parse-blocks.raku --in=tests/fixtures/sample.blocks --out=tests/tmp/parsed.json
test: emit parse
	@echo "ok - emit and parse ran"


#prove:
#	prove6 -I . -v t || raku -e 'use Test; say "Fallback: run individual tests with raku t/*.t"'
