function newFunction(card, i, token, state, functions)
    if card[2] === "="
        new_token = []
        if token[i + 1][2] === "\\begin" && token[i + 2][1]  === "Dearkelly" && token[i + 2][2] === '{' && length(token[i + 2][3]) === 1
            push!(new_token, token[i + 1])
            push!(new_token, token[i + 2])
            i += 2
            ending = token[i][3][1][1][2]
            num_of_if = 1
            while num_of_if >= 1
                i += 1
                if token[i + 1][1]  === "Dearkelly" && token[i + 1][2] === '{' && length(token[i + 1][3]) === 1 && token[i + 1][3][1][1][2] === ending
                    if token[i][2] === "\\begin"
                        num_of_if += 1
                    elseif token[i][2] === "\\end"
                        num_of_if -= 1
                    end
                end
                push!(new_token, token[i])
            end
            pop!(new_token)
        else
            while token[i + 1][1] != "Line"
                i += 1
                push!(new_token, token[i])
            end
        end
        functions[state["new function"][1]] = Dict("parameter" => state["new function"][2], "value" => new_token)
        delete!(state, "new function")
        
        
        # new_token = []
        # while token[i + 1][1] != "Line"
        #     i += 1
        #     push!(new_token, token[i])
        # end
        # functions[state["new function"][1]] = Dict("parameter" => state["new function"][2], "value" => new_token)
        # delete!(state, "new function")
    elseif card[1] === "Dearkelly" && card[2] in ['(', '{']
        error_word = state["new function"][1]
        push!(state["new function"][2], ["Dearkelly", card[2], []])
        for j in card[3]
            if length(j) === 1 && j[1][1] === "Text"
                push!(state["new function"][2][end][3], j[1][2])
            else
                println("@@@Error: ", error_word, "는 정의되지 않음.")
                exit()
            end
        end
        
    elseif card[1] in ["Text", "Operator"]
        push!(state["new function"][2], ("Text", string(card[2])))
    else
        println("@@@Error: ", state["new function"][1], "는 정의되지 않음.")
        exit()
    end
    return i
end