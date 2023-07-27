include("GetValue.jl")
include("Function.jl")
include("If.jl")
include("While.jl")
include("For.jl")
include("New/NewValue.jl")
include("New/NewFunction.jl")

internal_functions::Dict{String, Any} = Dict(
    "print" => Dict("parameter" => [["Dearkelly", '(', []]]),
    "include" => Dict("parameter" => [["Dearkelly", '(', []]]),
    # "f" => Dict("parameter" => [1, ['('], ["x", "y"]], "value" => [("Int", "5"), ("Text", '*'), ("Text", "x"), ("Operator", '+'), ("Int", "6"), ("Text", '*'), ("Text", "y")])
    # "f" => Dict("parameter" => [["Dearkelly", '(', ["x", "y"]], ["Text", "^"], ["Dearkelly", '(', ["z"]]], "value" => [("Int", "5"), ("Text", '*'), ("Text", "x"), ("Operator", '+'), ("Int", "6"), ("Text", '*'), ("Text", "y")])
)

keywords::Array = ["print", '+', '-', '*', '/', "\\mod", '^', "\\times", "\\div", "\\cdot", 
"<", ">", "<=", ">=", "\\nless", "\\ngtr", "\\leq", "\\nleq", "\\geq", "\\ngeq", 
"=", "!=", "==", "\\ne", "&&", "||", "\\or", "\\and", "!", "\\neg", "\\over"]


function run(
    token::Array,
    variable_::Dict = Dict(),
    function_::Dict = Dict(),
    state_::Array = []
    )
    
    variables::Dict{String, Any} = variable_
    functions::Dict{String, Any} = function_
    
    if length(functions) === 0
        functions = internal_functions
    end
    
    state::Dict = Dict()
    num_of_if::Int = 0
    
    max_cnt::Int = length(token)
    cnt_break::Int = 0
    i::Int = 0
    while i < max_cnt
        i += 1
        card = token[i]

        if "while" in state_
            if card[2] == "while"
                cnt_break += 1
            elseif card[2] === "endwhile"
                cnt_break -= 1
            elseif card[2] === "break" && cnt_break === 0
                return [variables, functions, ["break"]]
            end
        end
        # define_variable(i, max_cnt, card, token, variables, functions)

        if "new function" in keys(state)
            i = newFunction(card, i, token, state, functions)
        elseif "new value" in keys(state)
            i = newValue(card, token, i, variables, functions, state, max_cnt)
        else
            get_function = getFunction(card, token, functions, variables, max_cnt, i)
            i = get_function[1]

            if get_function[2] === Nothing && card[1] != "Line"
                
                if card[2] === "if"
                    i, state_ = if_(token, i, variables::Dict, functions::Dict, state_)
                elseif card[2] === "while"
                    i = while_(token, i, variables, functions)
                elseif card[2] === "for"
                    i = for_(token, i, variables, functions)
                elseif card[1] === "Text" # && !(card[2] in keys(variables))
                    state["new value"] = [card[2]]
                    continue
                end
            end
        end


        if "new value" in keys(state)
        end
    end
    if length(state_) === 0
        println("------------------------------------------------------------")
        println("Run.jl")
        println(variables)
        # println(functions)
    end
    return [variables, functions, state_]
end