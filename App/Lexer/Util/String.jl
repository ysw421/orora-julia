include("CheckLexer.jl")

function startString(state, token, i)
    checkLexer(state, token)
    state["String"] = Dict("ending" => i, "text" => "")
end

function endString(state, token, i)
    state_string::Dict{String, Any} = state["String"]
    if i == state_string["ending"]
        push!(token, ("String", state_string["text"]))
        delete!(state, "String")
    else
        state["String"]["text"] *= i
    end
end