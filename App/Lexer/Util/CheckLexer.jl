FLOAT_KEY = r"^[-+]?(\d+\.\d*|\.\d+)([eE][-+]?\d+)?$"
INT_KEY = r"^[0-9]+$"
BOOL_KEY = r"^(true|false)$"

TOKEN_PATTERNS::Dict = Dict(
    FLOAT_KEY => "Float",
    INT_KEY => "Int",
    BOOL_KEY => "Bool"
)

function checkLexer(state::Dict, token)
    if state["Text"] === ""
        return false
    end
    match::Bool = false
    for (pattern, token_type) in TOKEN_PATTERNS
        if occursin(pattern, state["Text"])
            push!(token, (token_type, state["Text"]))
            match = true
            break
        end
    end
    result = ()
    if match === false
        new_string::String = ""
        is_delete::Bool = false
        for i in state["Text"]
            if occursin(BOOL_KEY, new_string)
                push!(token, ("Bool", new_string))
                push!(token, ("Text", '*'))
                result = state["Text"][length(new_string) + 1:end]
                is_delete = true
            elseif occursin(INT_KEY, new_string) && !occursin(FLOAT_KEY, new_string * i)
                push!(token, ("Int", new_string))
                push!(token, ("Text", '*'))
                result = state["Text"][length(new_string) + 1:end]
                is_delete = true
            elseif occursin(FLOAT_KEY, new_string) && !occursin(FLOAT_KEY, new_string * i)
                push!(token, ("Float", new_string))
                push!(token, ("Text", '*'))
                result = state["Text"][length(new_string) + 1:end]
                is_delete = true
            end
            new_string *= i
        end
        if !is_delete
            result = state["Text"]
        end
        new_string = ""
        is_match::Bool = false
        max_cnt::Int = length(result)
        for i in 1:max_cnt
            new_string = result[i:max_cnt]
            is_break::Bool = false
            for text in ["\\\\", "\\;", "!=", "==", "<=", ">=", '+', '-', '*', '/', "\\mod", '^', "\\times", "\\div", "\\cdots", "\\cdot", 
                "<", ">", "\\nless", "\\ngtr", "\\leq", "\\nleq", "\\geq", "\\ngeq", 
                "=", "\\neg", "\\ne", "&&", "||", "\\or", "\\and", "!", "&"]
                if startswith(string(new_string), text)
                    if is_delete
                        pop!(token)
                    end
                    if i != 1
                        push!(token, ("Text", result[1:i - 1]))
                    end
                    if text === "\\\\"
                        # push!(token, ("Line", '\n'))
                        push!(token, ("Line", "\\\\"))
                    elseif text === "\\;"
                        # push!(token, ("Text", "\\\\"))
                    else
                        push!(token, ("Text", text))
                    end
                    checkLexer(Dict("Text" => new_string[length(text) + 1:end]), token)
                    is_match = true
                    is_break = true
                    break
                end
            end
            if is_break
                break
            end
        end
        if !is_match
            push!(token, ("Text", result))
        end
    end

    state["Text"] = ""
end