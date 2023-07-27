include("CheckLexer.jl")

function endDearkelly(state, token, i, num_of_dearkelly)
    is_delete::Bool = false
    if i === state["Dearkelly"]["ending"]
        num_of_dearkelly += 1
    elseif i === (state["Dearkelly"]["ending"] === '(' ? ')' : state["Dearkelly"]["ending"] === '{' ? '}' : ']')
        if num_of_dearkelly <= 0
            push!(token, ("Dearkelly", state["Dearkelly"]["ending"], lexer(state["Dearkelly"]["text"], ["Dearkelly"])))
            delete!(state, "Dearkelly")
            is_delete = true
        else
            num_of_dearkelly -= 1
        end
    end
    if !is_delete
        state["Dearkelly"]["text"] *= i
    end
    return num_of_dearkelly
end