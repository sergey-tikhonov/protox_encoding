from setuptools import setup, Extension

try:
    from Cython.Build import cythonize
except ModuleNotFoundError:
    raise RuntimeError(
        'Please install Cython to compile the library from source'
    )

extensions = [
    Extension('protox_encoding', ['protox_encoding.pyx']),
]

setup(
    name='protox_encoding',
    version='0.0.3',
    url='http://github.com/sergey-tikhonov/protox_encoding',
    description='Protox encoding library written in Cython',
    long_description=open('README.md', 'r').read(),
    long_description_content_type='text/markdown',
    ext_modules=cythonize(extensions),
    author='Sergey Tikhonov',
    author_email='srg.tikhonov@gmail.com',
    license='MIT',
    zip_safe=False,
    python_requires=">=3.6",
)
