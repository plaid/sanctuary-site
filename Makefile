ESLINT = node_modules/.bin/eslint
NPM = npm

CUSTOM = $(shell find custom -name '*.md' | sort)
VENDOR = ramda sanctuary sanctuary-def snabbdom
VENDOR_CHECKS = $(patsubst %,check-%-version,$(VENDOR))
FILES = index.html sig-data.js $(patsubst %,vendor/%.js,$(VENDOR))


.PHONY: all
all: $(FILES)

index.html: scripts/generate node_modules/sanctuary/README.md $(CUSTOM)
	'$<' node_modules/sanctuary

sig-data.js: scripts/generate-sig-data.js node_modules/sanctuary/README.md
	'$<' node_modules/sanctuary

vendor/ramda.js: node_modules/ramda/dist/ramda.js
	cp '$<' '$@'

vendor/snabbdom.js: node_modules/snabbdom/dist/snabbdom.min.js
	cp '$<' '$@'

vendor/%.js: node_modules/%/index.js
	cp '$<' '$@'


.PHONY: $(VENDOR_CHECKS)
$(VENDOR_CHECKS): check-%-version:
	node -e 'require("assert").strictEqual(require("$*/package.json").version, require("./package.json").dependencies["$*"])'


.PHONY: clean
clean:
	rm -f -- $(FILES)


.PHONY: lint
lint:
	$(ESLINT) \
	  --config node_modules/sanctuary-style/eslint-es6.json \
	  --env es6 \
	  --env node \
	  --rule 'max-len: [off]' \
	  --rule 'prefer-template: [off]' \
	  -- scripts/*
	$(ESLINT) \
	  --config node_modules/sanctuary-style/eslint-es3.json \
	  --env es3 \
	  --env browser \
	  -- behaviour.js search.js
	make clean
	make
	git diff --exit-code


.PHONY: setup
setup:
	$(NPM) install


.PHONY: test
test: $(VENDOR_CHECKS)
