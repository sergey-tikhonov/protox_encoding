.PHONY: build dist install uninstall

build: clean
	USE_CYTHON=1 python3.8 setup.py build_ext --inplace

dist: build
	python3.8 setup.py sdist

clean:
	rm -f *.so
	rm -f *.c

install: uninstall dist
	python3.8 -m pip install .

uninstall:
	python3.8 -m pip uninstall -y protox_encoding
