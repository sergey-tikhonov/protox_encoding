build:
	./setup.py build

dist:
	./setup.py sdist bdist_wheel

install:
	pip install .

uninstall:
	pip uninstall protox_encoding

