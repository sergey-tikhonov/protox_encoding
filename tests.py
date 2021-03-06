import pytest

from protox_encoding import (
    encode_varint, decode_varint,
    encode_bytes, decode_bytes,
    encode_zig_zag32, decode_zig_zag32,
    encode_zig_zag64, decode_zig_zag64,
    encode_header, decode_header,
    read_bytes,
)


@pytest.mark.parametrize('value', [
    0,
    1,
    127,
    128,
    2 ** 32 - 1,
    2 ** 64 - 1,
])
def test_varint(value):
    encoded_value = encode_varint(value)
    decoded_value, position = decode_varint(encoded_value, 0)
    assert decoded_value == value
    assert position == len(encoded_value)


@pytest.mark.parametrize('value', [
    b'',
    b'0',
    b'1234',
    b'a' * 1024,
])
def test_bytes(value):
    encoded_value = encode_bytes(value)
    decoded_value, position = decode_bytes(encoded_value, 0)
    assert decoded_value == value
    assert position == len(encoded_value)


@pytest.mark.parametrize('value', [
    -2 ** 31,
    -1,
    0,
    1,
    2 ** 31 - 1,
])
def test_zig_zag32(value):
    encoded_value = encode_zig_zag32(value)
    assert decode_zig_zag32(encoded_value) == value


@pytest.mark.parametrize('value', [
    -2 ** 63,
    -1,
    0,
    1,
    2 ** 63 - 1,
])
def test_zig_zag64(value):
    encoded_value = encode_zig_zag64(value)
    assert decode_zig_zag64(encoded_value) == value


@pytest.mark.parametrize('number', [
    0,
    1,
    2 ** 32 - 1
])
@pytest.mark.parametrize('wire_type', range(6))
def test_header(number: int, wire_type: int):
    encoded_header = encode_header(number, wire_type)
    assert decode_header(encoded_header, 0) == (number, wire_type, len(encoded_header))


def test_read_bytes():
    buffer = b'12345'
    data, position = read_bytes(buffer, 0, 3)

    assert data == b'123'
    assert position == 3

    data, position = read_bytes(buffer, position, 2)

    assert data == b'45'
    assert position == 5

    with pytest.raises(RuntimeError):
        read_bytes(buffer, position, 1)
