function if_(token, i, variables::Dict, functions::Dict, state_ = [])
    num_of_if::Int = 0
    new_token::Array = []
    while token[i + 1][1] != "Line"
        i += 1
        push!(new_token, token[i])
    end
    if getValue(new_token::Array, variables::Dict, functions::Dict) === true
        num_of_if = 1
        new_token = []::Array
        while num_of_if >= 1
            i += 1
            if token[i][2] == "if"
                num_of_if += 1
            elseif token[i][2] === "endif"
                num_of_if -= 1
            elseif token[i][2] in ["elseif", "else"] && num_of_if === 1
                break
            end
            push!(new_token, token[i])
        end
        pop!(new_token)
        result = run(new_token, deepcopy(variables), deepcopy(functions), state_)
        state_ = result[3]
        if token[i][2] != "endif"
            num_of_if = 1
            while num_of_if >= 1
                i += 1
                if token[i][2] == "if"
                    num_of_if += 1
                elseif token[i][2] === "endif"
                    num_of_if -= 1
                end
            end
        end
    else
        num_of_if = 1
        while num_of_if >= 1
            i += 1
            if token[i][2] == "if"
                num_of_if += 1
            elseif token[i][2] === "endif"
                num_of_if -= 1
            elseif token[i][2] in ["elseif", "else"] && num_of_if === 1
                break
            end
        end

        if token[i][2] === "elseif"
            while true
                new_token = []
                while token[i + 1][1] != "Line"
                    i += 1
                    push!(new_token, token[i])
                end
                if getValue(new_token::Array, variables::Dict, functions::Dict) === true
                    new_token = []::Array
                    while num_of_if >= 1
                        i += 1
                        if token[i][2] == "if"
                            num_of_if += 1
                        elseif token[i][2] === "endif"
                            num_of_if -= 1
                        elseif token[i][2] in ["elseif", "else"] && num_of_if === 1
                            break
                        end
                        push!(new_token, token[i])
                    end
                    pop!(new_token)
                    result = run(new_token, deepcopy(variables), deepcopy(functions), state_)
                    state_ = result[3]
                    if token[i][2] != "endif"
                        num_of_if = 1
                        while num_of_if >= 1
                            i += 1
                            if token[i][2] == "if"
                                num_of_if += 1
                            elseif token[i][2] === "endif"
                                num_of_if -= 1
                            end
                        end
                    end
                    break
                else
                    num_of_if = 1
                    while num_of_if >= 1
                        i += 1
                        if token[i][2] == "if"
                            num_of_if += 1
                        elseif token[i][2] === "endif"
                            num_of_if -= 1
                        elseif token[i][2] in ["elseif", "else"] && num_of_if === 1
                            break
                        end
                    end
                    if token[i][2] === "elseif"
                        continue
                    elseif token[i][2] === "else"
                        num_of_if = 1
                        new_token = []::Array
                        while num_of_if >= 1
                            i += 1
                            if token[i][2] == "if"
                                num_of_if += 1
                            elseif token[i][2] === "endif"
                                num_of_if -= 1
                            end
                            push!(new_token, token[i])
                        end
                        pop!(new_token)
                        result = run(new_token, deepcopy(variables), deepcopy(functions), state_)
                        state_ = result[3]
                        break
                    end
                end
            end
        elseif token[i][2] === "else"
            num_of_if = 1
            new_token = []::Array
            while num_of_if >= 1
                i += 1
                if token[i][2] == "if"
                    num_of_if += 1
                elseif token[i][2] === "endif"
                    num_of_if -= 1
                end
                push!(new_token, token[i])
            end
            pop!(new_token)
            result = run(new_token, deepcopy(variables), deepcopy(functions), state_)
            state_ = result[3]
        end
    end
    return i, state_
end