
module SineWaves

using sinewave_jll

import Base: fill!
export SineWave, spectrum

mutable struct SineWave
    previous::Float64
    current::Float64
    cosine::Float64
    function SineWave(frequency::Float64, samplerate::Float64)
        sinewave = new()
        status = ccall((:init, libsinewave), Cint, (Ref{SineWave}, Cdouble, Cdouble), sinewave, frequency, samplerate)
        if (status != 0)
            error("Generator is unstable for f=$frequency and fs=$samplerate")
        end
        return sinewave
    end
end

function fill!(buffer::Vector{Float64}, sinewave::SineWave)
    ccall((:fill, libsinewave), Cvoid, (Ref{SineWave}, Ptr{Float64}, Cint), sinewave, buffer, length(buffer))
    return buffer
end

function spectrum(buffer::Vector{Float64})
    spectr = ccall((:spectrum, libsinewave), Ptr{Cdouble}, (Ptr{Float64}, Cint), buffer, length(buffer))
    len = div(length(buffer), 2) + 1
    return unsafe_wrap(Array{Float64,1}, spectr, len; own = true)
end

end #module