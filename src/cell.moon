local *
ffi = assert require "ffi"

ffi.cdef [[
    struct cell {
        int value;
        bool open,
             flag;
    };
]]

ffi.typeof "struct cell"
