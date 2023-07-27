function while_(token, i, variables, functions)
    while true
        cnt_int = 0
        new_token::Array = []
        while token[i + 1][1] != "Line"
            i += 1
            cnt_int += 1
            push!(new_token, token[i])
        end
        if getValue(new_token::Array, variables::Dict, functions::Dict) === true
            num_of_if = 1
            new_token = []::Array
            while num_of_if >= 1
                i += 1
                cnt_int += 1
                if token[i][2] == "while"
                    num_of_if += 1
                elseif token[i][2] === "endwhile"
                    num_of_if -= 1
                end
                push!(new_token, token[i])
            end
            pop!(new_token)
            is_break = run(new_token, variables, functions, ["while"])[3][1] === "break"
            i -= cnt_int
            if is_break
                num_of_if = 1
                while num_of_if >= 1
                    i += 1
                    cnt_int += 1
                    if token[i][2] == "while"
                        num_of_if += 1
                    elseif token[i][2] === "endwhile"
                        num_of_if -= 1
                    end
                end
                break
            end
        else
            num_of_if = 1
            while num_of_if >= 1
                i += 1
                if token[i][2] == "while"
                    num_of_if += 1
                elseif token[i][2] === "endwhile"
                    num_of_if -= 1
                end
            end
            break
        end
    end
    return i
end