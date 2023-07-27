function for_(token, i, variables, functions)
    if token[i + 1][1] === "Text" token[i + 2][2] === "\\in"
        new_value = token[i + 1][2]
        i += 2

        cnt_int = 0
        new_token::Array = []
        while token[i + 1][1] != "Line"
            i += 1
            cnt_int += 1
            push!(new_token, token[i])
        end
        new_array = getValue(new_token::Array, variables::Dict, functions::Dict)
        if 1 === 1#eltype(new_array[1]) === Vector
            for j in new_array
                cnt_int = 0
                num_of_if = 1
                new_token = []::Array
                while num_of_if >= 1
                    i += 1
                    cnt_int += 1
                    if token[i][2] == "for"
                        num_of_if += 1
                    elseif token[i][2] === "endfor"
                        num_of_if -= 1
                    end
                    push!(new_token, token[i])
                    
                end
                pop!(new_token)
                is_break = run(new_token, merge(variables, Dict(new_value => j)), functions, ["while"])[3][1] === "break"
                i -= cnt_int
                if is_break
                    break
                end
            end
            num_of_if = 1
            while num_of_if >= 1
                i += 1
                if token[i][2] == "for"
                    num_of_if += 1
                elseif token[i][2] === "endfor"
                    num_of_if -= 1
                end
            end

        else
            println("@@@Error: for문은 1차원 배열을 사용해야함.")
            exit()
        end
    else
        println("@@@Error: for문 형식에 맞지 않음.")
        exit()
    end
    return i
end