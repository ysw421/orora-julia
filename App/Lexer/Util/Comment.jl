include("CheckLexer.jl")

function startComment(state, token)
    checkLexer(state, token)
    state["Comment"] = ""
end

function endComment(state, token, i)
    if i === '\n'
        checkLexer(state, token)
        push!(token, ("Line", '\n'))
        delete!(state, "Comment")
    end
end