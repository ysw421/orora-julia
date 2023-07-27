# Any
function multiplication(a::Any, b::Any)
    return a * b
    # println("@@@Error: $(typeof(a)) * $(typeof(b))는 불가함")
    # exit()
end

function multiplication(a::Int, b::String)
    if a > 0
        return ["String", repeat(b, a)]
    else
        println("@@@Error: 곱하는 수는 0보다 커야함.")
        exit()
    end
end

function multiplication(a::String, b::Int)
    if b > 0
        return ["String", repeat(a, b)]
    else
        println("@@@Error: 곱하는 수는 0보다 커야함.")
        exit()
    end
end