ffi = assert require "ffi"


ffi.cdef [[
    struct color {
        unsigned char r, g, b, a;
    };
]]


color_mt =
    __index:
        explode: =>
            @r, @g, @b, @a


ffi.metatype "struct color", color_mt
