module SimplePNGs
using CodecZlib
using UnPack
using FixedPointNumbers
using ColorTypes

function load(name)
    png = SimplePNG(chunkify(read(name)))
    data = extract(png)
    return build(png, data)
end


function loadpng(name)
    png = SimplePNG(chunkify(read(name)))
end

struct Chunk
    length::UInt32
    name::Vector{UInt8}
    data::Vector{UInt8}
    crc::Vector{UInt8}
end

function chunkify(img::Vector{UInt8})
    res = Chunk[]
    @assert length(img) >= 8
    @assert all(Int.(img[1:8]) .== [137, 80, 78, 71, 13, 10, 26, 10]) # PNG signature
    idx = 9
    while idx < length(img)
        ll = casttoint(img, idx)
        idx += 4
        name = img[idx:idx+3]
        idx += 4
        data = img[idx:idx+ll-1]
        idx += ll
        crc = img[idx:idx+3]
        idx += 4
        chunk = Chunk(ll, name, data, crc)
        push!(res, chunk)
    end

    return res
end

# Cast to int
function casttoint(data, idx)
    @inbounds x = 0 | data[idx]
    x = x << 8
    @inbounds x = x | data[idx + 1]
    x = x << 8
    @inbounds x = x | data[idx + 2]
    x = x << 8
    @inbounds x = x | data[idx + 3]
    return x
end

function casttouint16(data, idx)
    @inbounds x = UInt16(data[idx])
    x = x << 8
    @inbounds x = x | data[idx + 1]
    
    return x
end

struct SimplePNG
    bitdepth::Int
    colourtype::Int
    compression::Int
    filter::Int
    interlace::Int
    width::Int
    height::Int
    chunks::Vector{Chunk}
end

function SimplePNG(chunks::Vector{Chunk})
    hdr = chunks[1] # Faster search
    data = hdr.data
    width = casttoint(data, 1)
    height = casttoint(data, 5)
    bitdepth = data[9]
    colourtype = data[10]
    compression = data[11]
    filter = data[12]
    interlace = data[13]

    return SimplePNG(bitdepth, colourtype, compression, filter, interlace, width, height, chunks)
end

function name(chunk::Chunk)
    String(Char.(chunk.name))
end

function firstdata(png)
    idx = 0
    while idx < length(png.chunks)
        idx += 1
        if name(png.chunks[idx]) == "IDAT"
            return idx
        end
    end

    return idx
end

function extract(png)
    idx = firstdata(png)
    @assert idx > 0
    res = png.chunks[idx].data
    for i in idx+1:length(png.chunks)
        if name(png.chunks[i]) == "IDAT"
            append!(res, png.chunks[i].data)
        end
    end

    data = transcode(ZlibDecompressor, res)
    return data
end

function pixel(::Type{Gray{N0f8}}, c)
    return Gray{N0f8}(reinterpret(N0f8, UInt8(c)))
end

function pixel(::Type{Gray{N0f16}}, c)
    return Gray{N0f16}(reinterpret(N0f16, UInt16(c)))
end

function pixel(::Type{RGB{N0f8}}, r, g, b)
    RGB{N0f8}(reinterpret(N0f8, r),
        reinterpret(N0f8, g),
        reinterpret(N0f8, b))
end

function pixel(::Type{RGB{N0f16}}, r, g, b)
    RGB{N0f16}(reinterpret(N0f16, r),
        reinterpret(N0f16, g),
        reinterpret(N0f16, b))
end

function byteadd(n1::N0f8, n2::N0f8)
    v1 = reinterpret(UInt8, n1)
    v2 = reinterpret(UInt8, n2)
    return reinterpret(N0f8, v1 + v2)
end

function byteadd(n1::N0f16, n2::N0f16)
    v1 = reinterpret(UInt16, n1)
    v2 = reinterpret(UInt16, n2)
    b1 = UInt8(v1 & 0x00ff)
    b2 = UInt8(v2 & 0x00ff)
    c1 = v1 & 0xff00
    c2 = v2 & 0xff00
    return reinterpret(N0f16, (c1 + c2) | (b1 + b2))
end

function compose(p1::T, p2::T) where {T <: AbstractRGB}
    RGB(byteadd(red(p1), red(p2)),
        byteadd(green(p1), green(p2)),
        byteadd(blue(p1), blue(p2)))
end

function compose(p1::T, p2::T) where {T <: AbstractGray}
    Gray(byteadd(gray(p1), gray(p2)))
end

zero1(::Type{C}) where {C<:TransparentRGB} = C(0,0,0,0)
zero1(::Type{C}) where {C<:AbstractRGB}    = C(0,0,0)
zero1(::Type{C}) where {C<:TransparentGray} = C(0,0)
zero1(::Type{C}) where {C<:AbstractGray} = C(0)

function a(data::AbstractArray{T}, i, j) where T
    @inbounds j == 1 ? zero1(T) : data[i, j - 1]
end

function b(data::AbstractArray{T}, i, j) where T
    @inbounds i == 1 ? zero1(T) : data[i - 1, j]
end

function c(data::AbstractArray{T}, i, j) where T
    @inbounds (i == 1) | (j == 1) ? zero1(T) : data[i - 1, j - 1]
end

tuplify(c::AbstractGray) = reinterpret.((gray(c), ))
tuplify(c::AbstractRGB) = reinterpret.((red(c), green(c), blue(c)))

function paeth_internal(a, b, c)
    p = Int(a) + Int(b) - Int(c)
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if (pa <= pb) & (pa <= pc)
        return a
    elseif pb <= pc
        return b
    else
        return c
    end
end

function paeth(data::AbstractArray{T}, i, j) where T
    a1 = a(data, i, j) |> tuplify
    b1 = b(data, i, j) |> tuplify
    c1 = c(data, i, j) |> tuplify
    p = paeth_internal.(a1, b1, c1)
    return pixel(T, p...)
end

function avg(a::UInt8, b::UInt8)
    return UInt8((UInt16(a) + UInt16(b)) >> 1)
end

function avg(a::UInt16, b::UInt16)
    return UInt16((UInt32(a) + UInt32(b)) >> 1)
end

function avg(data::AbstractArray{T}, i, j) where T
    a1 = a(data, i, j) |> tuplify
    b1 = b(data, i, j) |> tuplify

    return pixel(T, avg.(a1, b1))
end

function build(png, data)
    @unpack colourtype, bitdepth, width, height = png
    if colourtype == 0
        if bitdepth == 16
            T = Gray{N0f16}
        else
            T = Gray{N0f8}
        end
    elseif colourtype == 2
        if bitdepth == 16
            T = RGB{N0f16}
        else
            T = RGB{N0f8}
        end
    end
    res = Array{T}(undef, width, height)
    idx = 1
    @inbounds for i in 1:height
        ft = data[idx] # filter type
        shift = 0
        p = 0x00
        idx += 1
        for j in 1:width
            p2 = if colourtype == 0 
                if bitdepth != 16
                    # color bits are written from left to right
                    if shift == 0
                        p = data[idx]
                        idx += 1
                        if bitdepth == 1
                            shift = 7
                        elseif bitdepth == 2
                            shift = 6
                        elseif bitdepth == 4
                            shift = 4
                        elseif bitdepth == 8
                            shift = 0
                        end
                    else
                        if bitdepth == 1
                            shift -= 1
                        elseif bitdepth == 2
                            shift -= 2
                        elseif bitdepth == 4
                            shift -= 4
                        elseif bitdepth == 8
                            shift -= 8
                        end
                    end
                    if bitdepth == 1
                        p2 = (p >> shift) & 0x01 == 0x01 ? 0xff : 0x00
                    elseif bitdepth == 2
                        p2 = ((p >> shift) & 0x03) * 0x55
                    elseif bitdepth == 4
                        p2 = ((p >> shift) & 0x0f) * 0x11
                    elseif bitdepth == 8
                        p2 = p
                    end

                    pixel(T, p2)
                else
                    p2 = UInt16(data[idx])
                    p2 = p2 << 8
                    p2 = p2 | data[idx + 1]
                    idx += 2

                    pixel(T, p2)
                end
            elseif colourtype == 2
                if bitdepth == 8
                    idx += 3
                    pixel(T, data[idx - 3], data[idx - 2], data[idx - 1])
                elseif bitdepth == 16
                    idx += 6
                    r1 = casttouint16(data, idx - 6)
                    g1 = casttouint16(data, idx - 4)
                    b1 = casttouint16(data, idx - 2)
                    pixel(T, r1, g1, b1)
                end
            end

            if ft == 0x00
                res[i, j] = p2
            elseif ft == 0x01
                res[i, j] = compose(p2, a(res, i, j))
            elseif ft == 0x02
                res[i, j] = compose(p2, b(res, i, j))
            elseif ft == 0x03
                res[i, j] = compose(p2, avg(res, i, j))
            elseif ft == 0x04
                res[i, j] = compose(p2, paeth(res, i, j))
            else
                error("Unrecognized filter type: ", ft)
            end
        end
    end

    return res
end

end
