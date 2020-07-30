import pyximport

pyximport.install(language_level='3')

from protox_encoding import read_bytes

buffer = bytes([1, 2, 3, 4, 5])
data, position = read_bytes(buffer, 0, 3)
print(read_bytes(buffer, position, 2))
