ffi = assert require "ffi"


ffi.cdef [[
    typedef struct {
        unsigned char r, g, b, a;
    } color_t;
]]


color_mt =
    __index:
        explode: =>
            @r, @g, @b, @a


ffi.metatype "color_t", color_mt
