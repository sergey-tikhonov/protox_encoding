# distutils: language = c++
from libcpp.map cimport map
from libcpp.string cimport string
from libc.stdint cimport uint64_t, int64_t

cdef enum field_kind:
    BYTES = 1
    I64 = 2
    U64 = 3

cdef union field_value:
    char *bytes
    int64_t i64
    uint64_t u64

cdef struct field:
    field_kind kind
    field_value value

cdef class Message:
    cdef map[string, field] _fields
    cdef field _field

    def __cinit__(self):
        pass

    def set_bytes(self, string name, char*value):
        pass

    def set_i64(self, string name, int64_t value):
        self._fields[name] = field(
            kind=field_kind.I64,
            value=field_value(i64=value)
        )

    def set_u64(self, string name, int64_t value):
        pass

    def get(self, string name):
        field = self._fields[name]

        if field.kind == field_kind.BYTES:
            return bytes(field.value.bytes)
        elif field.kind == field_kind.I64:
            return int(field.value.i64)
        elif field.kind == field_kind.U64:
            return int(field.value.u64)
