local *
ffi = assert require "ffi"

ffi.cdef [[
    struct dcoords {
        int dx, dy;
    };
]]

ffi.typeof "struct dcoords"
