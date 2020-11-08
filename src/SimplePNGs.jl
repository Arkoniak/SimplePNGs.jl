module SimplePNGs
using CodecZlib
using UnPack
using FixedPointNumbers
using ColorTypes

function load(name)
    png = SimplePNG(chunkify(read(name)))
    data = extract(png)
    return build!(png, data)
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
    byteshift::Int
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
    byteshift = bytes(colourtype, bitdepth)

    return SimplePNG(bitdepth, colourtype, compression, filter, interlace, width, height, byteshift, chunks)
end

function name(chunk::Chunk)
    String(Char.(chunk.name))
end

function palette(chunk)
    res = Vector{RGB{N0f8}}(undef, length(chunk) ÷ 3)
    for i in 1:length(res)
        res[i] = pixel(RGB{N0f8}, chunk[3i - 2], chunk[3i - 1], chunk[3i])
    end
    return res
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

function pixel(::Type{Gray{T}}, c) where T
    return Gray{T}(reinterpret(T, c))
end

function pixel(::Type{GrayA{T}}, c, alpha) where T
    return GrayA{T}(reinterpret(T, c),
                    reinterpret(T, alpha))
end

function pixel(::Type{RGB{T}}, r, g, b) where T
    RGB{T}(reinterpret(T, r),
        reinterpret(T, g),
        reinterpret(T, b))
end

function pixel(::Type{RGBA{T}}, r, g, b, alpha) where T
    RGBA{T}(reinterpret(T, r),
        reinterpret(T, g),
        reinterpret(T, b),
        reinterpret(T, alpha))
end

function a(data, idx, i, j, width, byteshift)
    j == 1 ? 0x00 : data[idx - byteshift]
end

function b(data, idx, i, j, width, byteshift)
    i == 1 ? 0x00 : data[idx - byteshift * width - 1]
end

function c(data, idx, i, j, width, byteshift)
    (i == 1) | (j == 1) ? 0x00 : data[idx - byteshift * width - 1 - byteshift]
end

function avg(data, idx, i, j, width, byteshift)
    a1 = a(data, idx, i, j, width, byteshift)
    b1 = b(data, idx, i, j, width, byteshift)
    return UInt8((UInt16(a1) + UInt16(b1)) >> 1)
end

function paeth(data, idx, i, j, width, byteshift)
    a1 = a(data, idx, i, j, width, byteshift)
    b1 = b(data, idx, i, j, width, byteshift)
    c1 = c(data, idx, i, j, width, byteshift)
    p = Int(a1) + Int(b1) - Int(c1)
    pa = abs(p - a1)
    pb = abs(p - b1)
    pc = abs(p - c1)
    if (pa <= pb) & (pa <= pc)
        return a1
    elseif pb <= pc
        return b1
    else
        return c1
    end
end

function bytes(colourtype, bitdepth)
    if colourtype == 0
        bitdepth == 16 ? 2 : 1
    elseif colourtype == 2
        bitdepth == 16 ? 6 : 3
    elseif colourtype == 3
        1
    elseif colourtype == 4
        bitdepth == 16 ? 4 : 2
    else
        bitdepth == 16 ? 8 : 4
    end
end

function scale_width(width, bpb, bitdepth)
    return if bitdepth < 8
        x, y = divrem(width, bpb)
        x + (y > 0)
    else
        width
    end
end

function level2wh(width, height, level, bpb, bitdepth, width1, height1, scale = true)
    if level == 1
        x, y = divrem(width, 8)
        width1 = scale ? scale_width(x + (y > 0), bpb, bitdepth) : x + (y > 0)
        x, y = divrem(height, 8)
        height1 = x + (y > 0)
    elseif level == 2
        x, y = divrem(width, 8)
        width1 = scale ? scale_width(x + (y > 4), bpb, bitdepth) : x + (y > 4)
    elseif level == 3
        x, y = divrem(width, 4)
        width1 = scale ? scale_width(x + (y > 0), bpb, bitdepth) : x + (y > 0)
        x, y = divrem(height, 8)
        height1 = x + (y > 4)
    elseif level == 4
        x, y = divrem(width, 4)
        width1 = scale ? scale_width(x + (y > 2), bpb, bitdepth) : x + (y > 2)
        x, y = divrem(height, 4)
        height1 = x + (y > 0)
    elseif level == 5
        x, y = divrem(width, 2)
        width1 = scale ? scale_width(x + y, bpb, bitdepth) : x + y
        x, y = divrem(height, 4)
        height1 = x + (y > 2)
    elseif level == 6
        width1 = scale ? scale_width(width ÷ 2, bpb, bitdepth) : width ÷ 2
        x, y = divrem(height, 2)
        height1 = x + y
    elseif level == 7
        width1 = scale ? scale_width(width, bpb, bitdepth) : width
        height1 = height ÷ 2
    end

    return width1, height1
end

function process!(data, idx, width, height, byteshift)
    @inbounds for i in 1:height
        ft = data[idx]
        idx += 1
        for j in 1:width
            for k in 1:byteshift
                if ft == 0x01
                    data[idx] += a(data, idx, i, j, width, byteshift)
                elseif ft == 0x02
                    data[idx] += b(data, idx, i, j, width, byteshift)
                elseif ft == 0x03
                    data[idx] += avg(data, idx, i, j, width, byteshift)
                elseif ft == 0x04
                    data[idx] += paeth(data, idx, i, j, width, byteshift)
                end
                idx += 1
            end
        end
    end

    return idx
end

function process!(png, data)
    @unpack colourtype, bitdepth, width, height, byteshift, interlace = png

    idx = 1
    bpb = 8 ÷ bitdepth
    if interlace == 0
        width = scale_width(width, bpb, bitdepth)
        process!(data, idx, width, height, byteshift)
    else
        height1, width1 = 0, 0
        for level in 1:7
            width1, height1 = level2wh(width, height, level, bpb, bitdepth, width1, height1)
            if (width1 > 0) & (height1 > 0)
                idx = process!(data, idx, width1, height1, byteshift)
            end
        end
    end

    return data
end

function prepare_array(colourtype, bitdepth, width, height)
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
    elseif colourtype == 3
        T = RGB{N0f8}
    elseif colourtype == 4
        if bitdepth == 8
            T = GrayA{N0f8}
        else
            T = GrayA{N0f16}
        end
    else
        if bitdepth == 8
            T = RGBA{N0f8}
        else
            T = RGBA{N0f16}
        end
    end

    return Array{T}(undef, width, height)
end

function build!(png, data)
    @unpack colourtype, bitdepth, width, height, byteshift, interlace = png
    process!(png, data)
    if colourtype == 3
        idx = findfirst(x -> name(x) == "PLTE", png.chunks)
        chunk = png.chunks[idx]
        plte = palette(chunk.data)
    else
        plte = nothing
    end
    res = prepare_array(colourtype, bitdepth, width, height)
    idx = 1
    
    if interlace == 0
        build!(res, data, idx, width, height, colourtype, bitdepth, plte, 0)
    else
        bpb = 8 ÷ bitdepth
        width1, height1 = 0, 0
        for level in 1:7
            width1, height1 = level2wh(width, height, level, bpb, bitdepth, width1, height1, false)
            if (width1 > 0) & (height1 > 0)
                idx = build!(res, data, idx, width1, height1, colourtype, bitdepth, plte, level)
            end
        end
    end
    return res
end

function nexti(i, level)
    (level == 0) && return i + 1
    (level == 1) | (level == 2) | (level == 3) && return i + 8
    (level == 4) | (level == 5) && return i + 4
    (level == 6) | (level == 7) && return i + 2
end

function nextj(j, level)
    (level == 0) | (level == 7) && return j + 1
    (level == 1) | (level == 2) && return j + 8
    (level == 3) | (level == 4) && return j + 4
    (level == 5) | (level == 6) && return j + 2
end

function startpoint(level)
    level == 0 && return (0, 0)   # .+ (1, 1) == (1, 1)
    level == 1 && return (-7, -7) # .+ (8, 8) == (1, 1)
    level == 2 && return (-7, -3) # .+ (8, 8) == (1, 5)
    level == 3 && return (-3, -3) # .+ (8, 4) == (5, 1)
    level == 4 && return (-3, -1) # .+ (4, 4) == (1, 3)
    level == 5 && return (-1, -1) # .+ (4, 2) == (3, 1)
    level == 6 && return (-1, 0)  # .+ (2, 2) == (1, 2)
    level == 7 && return (0, 0)   # .+ (2, 1) == (2, 1)
end

function build!(res::Array{T, 2}, data, idx, width, height, colourtype, bitdepth, plte, level) where T
    i1, j1 = startpoint(level)
    j2 = j1
    @inbounds for i in 1:height
        i1 = nexti(i1, level)
        j1 = j2  # reset counter
        shift = 0
        p = 0x00
        idx += 1
        for j in 1:width
            j1 = nextj(j1, level)
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
                    idx += 2
                    p2 = casttouint16(data, idx - 2)

                    pixel(T, p2)
                end
            elseif colourtype == 2
                # Warning, it is possible that PLTE can be used here
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
            elseif colourtype == 3
                if shift == 0
                    p = data[idx]
                    idx += 1
                    if bitdepth == 1
                        shift = 7
                    elseif bitdepth == 2
                        shift = 6
                    elseif bitdepth == 4
                        shift = 4
                    end
                else
                    if bitdepth == 1
                        shift -= 1
                    elseif bitdepth == 2
                        shift -= 2
                    elseif bitdepth == 4
                        shift -= 4
                    end
                end
                if bitdepth == 1
                    p2 = (p >> shift) & 0x01
                elseif bitdepth == 2
                    p2 = (p >> shift) & 0x03
                elseif bitdepth == 4
                    p2 = (p >> shift) & 0x0f
                else
                    p2 = p
                end
                
                plte[p2 + 1]
            elseif colourtype == 4
                if bitdepth == 8
                    idx += 2
                    pixel(T, data[idx - 2], data[idx - 1])
                else
                    idx += 4
                    c = casttouint16(data, idx - 4)
                    alpha = casttouint16(data, idx - 2)
                    pixel(T, c, alpha)
                end
            else
                if bitdepth == 8
                    idx += 4
                    r1 = data[idx - 4]
                    g1 = data[idx - 3]
                    b1 = data[idx - 2]
                    alpha1 = data[idx - 1]
                    pixel(T, r1, g1, b1, alpha1)
                else
                    idx += 8
                    r1 = casttouint16(data, idx - 8)
                    g1 = casttouint16(data, idx - 6)
                    b1 = casttouint16(data, idx - 4)
                    alpha1 = casttouint16(data, idx - 2)
                    pixel(T, r1, g1, b1, alpha1)
                end
            end
            
            res[i1, j1] = p2
        end
    end

    return idx
end

end # module
