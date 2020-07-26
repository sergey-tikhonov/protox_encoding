from setuptools import setup

try:
    from Cython.Build import cythonize
except ModuleNotFoundError:
    raise RuntimeError(
        'Please install Cython to compile the library from source'
    )

setup(
    name='protox_encoding',
    version='0.0.1',
    description='Protox encoding library written in Cython',
    ext_modules=cythonize('protox_encoding.pyx'),
    author='Sergey Tikhonov',
    author_email='srg.tikhonov@gmail.com',
    license='MIT',
    zip_safe=False,
    python_requires=">=3.6",
)
