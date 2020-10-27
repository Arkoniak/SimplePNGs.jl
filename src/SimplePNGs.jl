module SimplePNGs
using CodecZlib
using UnPack
using Colors
using Colors: N0f8, N0f16
using ColorVectorSpace

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

function a(data::AbstractArray{T}, i, j) where T
    @inbounds j == 1 ? pixel(T, 0x00) : data[i, j - 1]
end

function b(data::AbstractArray{T}, i, j) where T
    @inbounds i == 1 ? pixel(T, 0x00) : data[i - 1, j]
end

function c(data::AbstractArray{T}, i, j) where T
    @inbounds (i == 1) | (j == 1) ? pixel(T, 0x00) : data[i - 1, j - 1]
end

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
    a1 = a(data, i, j)
    b1 = b(data, i, j)
    c1 = c(data, i, j)
    if T <: Gray
        return pixel(T, paeth_internal(a1.val.i, b1.val.i, c1.val.i))
    end
end

function build(png, data)
    @unpack colourtype, bitdepth, width, height = png
    if colourtype == 0 && (bitdepth == 1 || bitdepth == 2 || bitdepth == 4 || bitdepth == 8 || bitdepth == 16)
        if bitdepth == 16
            T = Gray{N0f16}
        else
            T = Gray{N0f8}
        end
        res = Array{T}(undef, width, height)
        idx = 0
        @inbounds for i in 1:height
            idx += 1
            ft = data[idx] # filter type
            shift = 0
            p = 0x00
            if bitdepth == 16
                idx += 1
            end
            for j in 1:width
                p2 = if bitdepth != 16
                    # color bits are written from left to right
                    if shift == 0
                        idx += 1
                        p = data[idx]
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

                if ft == 0x00
                    res[i, j] = p2
                elseif ft == 0x01
                    res[i, j] = p2 + a(res, i, j)
                elseif ft == 0x02
                    res[i, j] = p2 + b(res, i, j)
                elseif ft == 0x04
                    res[i, j] = p2 + paeth(res, i, j)
                else
                    error("Unrecognized filter type: ", ft)
                end
                # if ft == 0x01
                #     if j != 1
                #         data[idx] += data[idx - 3]
                #         data[idx + 1] += data[idx - 2]
                #         data[idx + 2] += data[idx - 1]
                #     end
                # elseif ft == 0x02
                #     if i != 1
                #         data[idx] += data[idx - 1 - 3*w]
                #         data[idx + 1] += data[idx - 3*w]
                #         data[idx + 2] += data[idx + 1 - 3*w]
                #     end
                # elseif ft == 0x04
                #     data[idx] += paeth(data, w, 3, idx, i, j)
                #     data[idx + 1] += paeth(data, w, 3, idx + 1, i, j)
                #     data[idx + 2] += paeth(data, w, 3, idx + 2, i, j)
                # elseif ft == 0x03
                #     data[idx] += avg(data, w, 3, idx, i, j)
                #     data[idx + 1] += avg(data, w, 3, idx + 1, i, j)
                #     data[idx + 2] += avg(data, w, 3, idx + 1, i, j)
                # else
                # end
                # res[i, j] = rgb(data[idx], data[idx+1], data[idx+2])
                # idx += 3
            end
            if bitdepth == 16
                idx -= 1
            end
        end
    end

    return res
end

end
