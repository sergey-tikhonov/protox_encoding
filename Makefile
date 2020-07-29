.PHONY: build dist install uninstall

build:
	USE_CYTHON=1 python setup.py build_ext --inplace

dist: build
	python setup.py sdist

install:
	pip install .

uninstall:
	pip uninstall protox_encoding
