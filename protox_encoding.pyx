# cython: language_level=3
from libc.stdint cimport uint64_t, uint8_t

def encode_varint(value: uint64_t):
    cdef uint8_t[10] vec
    cdef uint8_t i = 0
    cdef uint8_t x = value & 127

    value >>= 7

    while value != 0:
        vec[i] = x | 128
        i += 1
        x = value & 127
        value >>= 7

    vec[i] = x

    return vec[:i + 1]

def decode_varint(
    buffer: bytes,
    Py_ssize_t position,
) -> int:
    cdef uint64_t rv = 0
    cdef uint8_t shift = 0
    cdef uint64_t x

    while position < len(buffer):
        x = buffer[position]
        rv |= (x & 127) << shift
        position += 1
        shift += 7

        # eighth bit is a flag
        if not x & 128:
            return rv, position

        if shift > 63:
            raise ValueError(
                'Too many bytes when decoding varint'
            )

    raise ValueError(
        'Unexpected end of bytes when decoding varint'
    )

def encode_bytes(data: bytes) -> bytes:
    length = encode_varint(len(data))
    return length + data

def decode_bytes(
    buffer: bytes,
    Py_ssize_t position,
):
    length, position = decode_varint(buffer, position)
    data = buffer[position:position + length]

    if len(data) < length:
        raise ValueError(
            'Unexpected end of bytes when decoding bytes'
        )

    return data, position + length

def encode_zig_zag32(x):
    return (x << 1) ^ (x >> 31)

def decode_zig_zag32(x):
    return (x >> 1) ^ -(x & 1)

def encode_zig_zag64(x):
    return (x << 1) ^ (x >> 63)

def decode_zig_zag64(x):
    return (x >> 1) ^ -(x & 1)

def encode_header(
    uint64_t number,
    uint64_t wire_type,
):
    return encode_varint(number << 3 | wire_type)

def decode_header(
    buffer: bytes,
    Py_ssize_t position,
):
    header, position = decode_varint(buffer, position)
    return header >> 3, header & 0b111, position

def skip_fixed32(
    buffer: bytes,
    Py_ssize_t position,
):
    skip_bytes = 4

    if len(buffer) - position < skip_bytes:
        raise ValueError(
            'Unexpected end of bytes when decoding fixed32'
        )

    return None, position + skip_bytes

def skip_fixed64(
    buffer: bytes,
    Py_ssize_t position,
):
    skip_bytes = 8

    if len(buffer) - position < skip_bytes:
        raise ValueError(
            'Unexpected end of bytes when decoding fixed64'
        )

    return None, position + skip_bytes
