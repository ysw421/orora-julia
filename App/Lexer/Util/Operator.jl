include("CheckLexer.jl")

OPERATOR::Array = ['+', '-', '*', '/', '^', '_']

function getOperator(text::Char, state::Dict, token::Array)
    if text in OPERATOR
        if !occursin(r"^[-+]?(\d+\.\d*|\.\d+)[eE]$", state["Text"])
            checkLexer(state, token)
            push!(token, ("Operator", text))
            return true
        end
    end
    return false
end
