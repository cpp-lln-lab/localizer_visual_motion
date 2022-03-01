# TODO make more general to use the local matlab version
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

.PHONY: clean manual fix_submodule
clean: clean
	rm -rf version.txt

fix_submodule:
	git submodule update --init --recursive && git submodule update --recursive

lint:
	mh_style --fix && mh_metric --ci && mh_lint

test:
	$(MATLAB) $(ARG) -r "runTests; exit()"

version.txt: CITATION.cff
	grep -w "^version" CITATION.cff | sed "s/version: /v/g" > version.txt

validate_cff: CITATION.cff
	cffconvert --validate
