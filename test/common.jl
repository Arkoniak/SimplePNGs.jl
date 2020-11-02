module TestCommon

using StructTypes
using SimplePNGs
using JSON3
using ColorTypes
using FixedPointNumbers
using CodecZlib

mutable struct JsonIMG
    T::String
    width::Int
    height::Int
    data::Vector{UInt16}

    JsonIMG() = new()
    JsonIMG(T, w, h, data) = new(T, w, h, data)
end
StructTypes.StructType(::Type{JsonIMG}) = StructTypes.Mutable()

function JsonIMG(x::AbstractArray{T0}) where {T0 <: AbstractGray}
    T = eltype(x) |> Symbol |> String
    T = replace(T, "ColorTypes." => "")
    T = replace(T, "FixedPointNumbers." => "")
    width, height = size(x)
    data = vec(reinterpret.(gray.(x)))

    return JsonIMG(T, width, height, data)
end

function JsonIMG(x::AbstractArray{T0}) where {T0 <: AbstractRGB}
    T = eltype(x) |> Symbol |> String
    T = replace(T, "ColorTypes." => "")
    T = replace(T, "FixedPointNumbers." => "")
    width, height = size(x)
    data = vcat(vec(reinterpret.(red.(x))),
                vec(reinterpret.(green.(x))),
                vec(reinterpret.(blue.(x))))

    return JsonIMG(T, width, height, data)
end

function reconstruct(x::JsonIMG)
    T0 = replace(x.T, "ColorTypes." => "")
    T0 = replace(T0, "FixedPointNumbers." => "")
    res = if T0 == "Gray{Normed{UInt8,8}}"
        T = Gray{N0f8}
        data = UInt8.(x.data)
        SimplePNGs.pixel.(T, data)
    elseif T0 == "RGB{Normed{UInt8,8}}"
        T = RGB{N0f8}
        lng = x.width * x.height
        data = UInt8.(x.data)
        SimplePNGs.pixel.(T, data[1:lng], data[lng+1:2*lng], data[2*lng+1:3*lng])
    elseif T0 == "Gray{Normed{UInt16,16}}"
        T = Gray{N0f16}
        data = UInt16.(x.data)
        SimplePNGs.pixel.(T, data)
    elseif T0 == "RGB{Normed{UInt16,16}}"
        T = RGB{N0f16}
        lng = x.width * x.height
        data = UInt16.(x.data)
        SimplePNGs.pixel.(T, data[1:lng], data[lng+1:2*lng], data[2*lng+1:3*lng])
    end

    reshape(res, x.width, x.height)
end

function save_json(name)
    namein = joinpath("test", "PngSuite", name*".png")
    nameout = joinpath("test", "jsons", name*"_json.gz")

    img = SimplePNGs.load(namein)
    out = JSON3.write(JsonIMG(img))
    compressed = transcode(GzipCompressor, out)
    write(nameout, compressed)
    nothing
end

function load_json(name, test = true)
    if test
        namein = joinpath("jsons", name*"_json.gz")
    else
        namein = joinpath("test", "jsons", name*"_json.gz")
    end
    json = transcode(GzipDecompressor, read(namein))
    json_img = JSON3.read(json, JsonIMG)
    return reconstruct(json_img)
end


end # module
