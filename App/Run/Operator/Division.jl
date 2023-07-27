function division(a::Any, b::Any)
    return a / b
end

function multiplication(a::Int, b::String)
    println("@@@Error: String으로 나눌 수 없음.")
    exit()
end

function multiplication(a::String, b::Int)
    println("@@@Error: String을 나눌 수 없음.")
    exit()
end