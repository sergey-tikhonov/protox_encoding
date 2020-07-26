import time
from contextlib import contextmanager
from io import BytesIO

from protox import encoding
from protox_encoding import encode_varint, decode_varint, encode_header, encode_bytes, encode_zig_zag32


@contextmanager
def bench(name: str):
    t = time.monotonic()
    yield
    print(name, time.monotonic() - t)


n = 200_000
value = 2 ** 64 - 1
encoded_value = encoding.encode_varint(value)

print('# Encode varint')
with bench('* cython'):
    for _ in range(n):
        encode_varint(value)

with bench('* python'):
    for _ in range(n):
        encoding.encode_varint(value)

print('\n# Decode varint')

with bench('* cython'):
    for _ in range(n):
        decode_varint(encoded_value, 0)

with bench('* python'):
    stream = BytesIO(encoded_value)
    for _ in range(n):
        stream.seek(0)
        encoding.decode_varint(stream)


def encode_header_py(number, wire_type):
    return encode_varint(number << 3 | wire_type)


bytes_value = b'a' * 1024

print('\n# Encode bytes')
with bench('* cython'):
    for _ in range(n):
        encode_bytes(bytes_value)

with bench('* python'):
    for _ in range(n):
        encoding.encode_bytes(bytes_value)

print('\n# Encode header')
with bench('* cython'):
    for _ in range(n):
        encode_header(200, 0)

with bench('* python'):
    for _ in range(n):
        encode_header_py(200, 0)

value = 2 ** 30

print('\n# Encode zig zag')
with bench('* cython'):
    for _ in range(n):
        encode_zig_zag32(value)

with bench('* python'):
    for _ in range(n):
        encoding.encode_zig_zag32(value)
