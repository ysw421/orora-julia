include("Util/CheckLexer.jl")
include("Util/String.jl")
include("Util/Comment.jl")
include("Util/Dearkelly.jl")
include("Util/Operator.jl")
include("../Run/Run.jl")

function lexer(line::String, option::Array)
    state::Dict{String, Any} = Dict("Text" => "")
    token::Array = []

    num_of_dearkelly::Int = 0
    if "Dearkelly" in option
        parameter::Array{Array} = []
    end
    for i in line
        if "Comment" in keys(state)
            endComment(state, token, i)
            continue
        elseif "String" in keys(state)
            endString(state, token, i)
            continue
        elseif "Dearkelly" in keys(state)
            num_of_dearkelly = endDearkelly(state, token, i, num_of_dearkelly)
            continue
        elseif "Dearkelly" in option && i === ','
            checkLexer(state, token)
            append!(parameter, [token]::Array)
            token = []
            continue
        end

        # -------------------

        if i in ['(', '{', '[']
            checkLexer(state, token)
            state["Dearkelly"] = Dict("ending" => i, "text" => "")
            num_of_dearkelly = 0
            continue
        elseif getOperator(i, state, token)
            continue
        elseif i === '\n'
            checkLexer(state, token)
            push!(token, ("Line", "\n"))
            continue
        elseif i === ' '
            checkLexer(state, token)
            continue
        elseif i === '#'
            startComment(state, token)
            continue
        elseif i in ['"', ''']
            startString(state, token, i)
            continue
        end

        state["Text"] *= i
    end

    if "Main" in option
        checkLexer(state, token)
        push!(token, ("Line", "\n"))
        delete!(state, "Comment")
        if length(state) != 1
            if "String" in keys(state)
                println("@@@ Error: ", state["String"]["ending"], "가 끝나지 않음.")
                exit()
            elseif "Dearkelly" in keys(state)
                println("@@@ Error: ", state["Dearkelly"]["ending"], "가 끝나지 않음.")
                exit()
            else
                println("@@@ Error: 해석 에러 발생.")
                exit()
            end
        end
        # println("------------------------------------------------------------")
        # println("Laxer.jl")
        # println(token)
        # println("------------------------------------------------------------")
        run(token)
    elseif "Dearkelly" in option
        checkLexer(state, token)
        append!(parameter, [token])
        return parameter
    elseif "Include" in option
        return token
    end
end