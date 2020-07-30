# cython: language_level=3
import struct

from libc.stdint cimport uint64_t, uint8_t
from protox.exceptions import MessageDecodeError

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
            raise RuntimeError(
                'Too many bytes when decoding varint'
            )

    raise RuntimeError(
        'Unexpected end of buffer when decoding varint'
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
        raise RuntimeError(
            'Unexpected end of buffer when decoding bytes'
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

def read_bytes(
    buffer: bytes,
    Py_ssize_t position,
    Py_ssize_t n
):
    if len(buffer) - position < n:
        raise RuntimeError(
            f'Expected to read {n} bytes, got {len(buffer) - position} bytes instead'
        )

    return buffer[position:position + n], position + n

def encode_int32(value: int):
    if value < 0:
        value += 2 ** 32

    return encode_varint(value)

def decode_int32(
    buffer: bytes,
    Py_ssize_t position,
):
    value, position = decode_varint(buffer, position)

    if value > 2 ** 31 - 1:
        value -= 2 ** 32

    return value, position

def encode_int64(value: int):
    if value < 0:
        value += 2 ** 64

    return encode_varint(value)

def decode_int64(
    buffer: bytes,
    Py_ssize_t position,
):
    value, position = decode_varint(buffer, position)

    if value > 2 ** 63 - 1:
        value -= 2 ** 64

    return value, position

def encode_sint32(value: int):
    zig_zag_value = encode_zig_zag32(value)
    return encode_varint(zig_zag_value)

def decode_sint32(
    buffer: bytes,
    Py_ssize_t position,
):
    zig_zag_value, position = decode_varint(buffer, position)
    return decode_zig_zag32(zig_zag_value), position

def encode_sint64(value: int):
    zig_zag_value = encode_zig_zag64(value)
    return encode_varint(zig_zag_value)

def decode_sint64(
    buffer: bytes,
    Py_ssize_t position,
):
    zig_zag_value, position = decode_varint(buffer, position)
    return decode_zig_zag64(zig_zag_value), position

encode_uint32 = encode_varint
encode_uint64 = encode_varint

decode_uint32 = decode_varint
decode_uint64 = decode_varint

def encode_fixed32(value: int):
    return struct.pack('<I', value)

def decode_fixed32(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 4)
    return struct.unpack('<I', data)[0], position

def encode_fixed64(value: int):
    return struct.pack('<Q', value)

def decode_fixed64(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 8)
    return struct.unpack('<Q', data)[0], position

def encode_sfixed32(value: int):
    return struct.pack('<i', value)

def decode_sfixed32(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 4)
    return struct.unpack('<i', data)[0], position

def encode_sfixed64(value: int):
    return struct.pack('<q', value)

def decode_sfixed64(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 8)
    return struct.unpack('<q', data)[0], position

def encode_float(value: float):
    return struct.pack('<f', value)

def decode_float(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 4)
    return struct.unpack('<f', data)[0], position

def encode_double(value: float):
    return struct.pack('<d', value)

def decode_double(
    buffer: bytes,
    Py_ssize_t position,
):
    data, position = read_bytes(buffer, position, 8)
    return struct.unpack('<d', data)[0], position

def encode_string(value: str):
    data = value.encode('utf-8')
    return encode_bytes(data)

def decode_string(buffer: bytes, position: int):
    data, position = decode_bytes(buffer, position)
    return data.decode('utf-8'), position

def encode_bool(value: bool):
    return chr(value).encode()

def decode_bool(
    buffer: bytes,
    Py_ssize_t position,
):
    value, position = decode_varint(buffer, position)
    return bool(value), position

def _decode_group_start(_buffer: bytes, _position: int):
    # TODO: implement to discard old messages group fields
    raise NotImplementedError(
        'Groups are not supported [deprecated by protobuf]'
    )

def _decode_group_end(_buffer: bytes, _position: int):
    # TODO: implement to discard old messages group fields
    raise NotImplementedError(
        'Groups are not supported [deprecated by protobuf]'
    )

wire_type_to_decoder = {
    0: decode_varint,
    1: decode_fixed64,
    2: decode_bytes,
    3: _decode_group_start,
    4: _decode_group_end,
    5: decode_fixed32
}

def message_fields_from_bytes(
    data: bytes,
    required_fields: set,
    field_by_number: dict,
):
    position = 0
    message_fields = {}
    required_fields_left = required_fields.copy()

    while position < len(data):
        number, wire_type, position = decode_header(data, position)

        if number in field_by_number:
            field = field_by_number[number]

            if field.wire_type != wire_type:
                raise MessageDecodeError(
                    f"Field {field.name} has wire_type={field.wire_type}, "
                    f"read wire_type={wire_type} instead"
                )

            position = field.read_to_dict(data, position, message_fields)
            required_fields_left.discard(field.name)
        else:
            # skip unknown fields
            _, position = wire_type_to_decoder[wire_type](data, position)

    if required_fields_left:
        raise MessageDecodeError(
            f"Missing required fields {required_fields_left}"
        )

    return message_fields
