import time

import pyximport

old_get_distutils_extension = pyximport.pyximport.get_distutils_extension


def new_get_distutils_extension(modname, pyxfilename, language_level=None):
    extension_mod, setup_args = old_get_distutils_extension(modname, pyxfilename, language_level)
    extension_mod.language = 'c++'
    return extension_mod, setup_args


pyximport.pyximport.get_distutils_extension = new_get_distutils_extension

pyximport.install(language_level='3')

from cython_protox import Message

m = Message()
key = b'abc'
m.set_i64(key, 123)
t = time.monotonic()
for _ in range(1_000_000):
    m.get(key)
print(time.monotonic() - t)
