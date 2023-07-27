# include("GetValue.jl")

function getFunction(card, token, functions, variables, max_cnt, i, postfix_expression = Nothing)
    new_value::Any = Nothing
    if card[1] === "Text" && card[2] in keys(functions) && i + length(functions[card[2]]["parameter"]) <= max_cnt
        is_function::Bool = true
        parameter::Array = functions[card[2]]["parameter"]
        if parameter != Nothing
            for j in 1:length(parameter)
                if token[i + j][1] === "Dearkelly" && parameter[j][1] === "Dearkelly" && token[i + j][2] === parameter[j][2]
                    continue
                elseif parameter[j][1] === "Text" && parameter[j][2] === string(token[i + j][2])
                    continue
                end
                is_function = false
                # if !(token[i + j][1] === "Dearkelly" && token[i + j][2] === parameter[2][j])
                #     is_function = false
                # end
            end
            if is_function  # 함수
                
                if card[2] === "print"
                    print_text::String = ""
                    for j in 1:length(token[i + 1][3])
                        print_text *= string(getValue(token[i + 1][3][j], variables, functions))
                    end
                    new_value = false
                    println(print_text)
                    if postfix_expression != Nothing
                        push!(postfix_expression, false)
                    end
                elseif card[2] === "include"
                    contents = read(string(getValue(token[2][3][1], variables, functions)), String)
                    new_token = lexer(contents, ["Include"])
                    functions = run(new_token, variables, functions)
                else
                    function_parameter = Dict()
                    for j in 1:length(parameter)
                        if token[i + j][1] === "Dearkelly"
                            if length(token[i + j][3]) === length(parameter[j][3])
                                for k in 1:length(parameter[j][3])
                                    function_parameter[string(parameter[j][3][k])] = getValue(token[i + j][3][k], variables, functions)
                                end
                            else
                                println("@@@ Error: 파라미터 개수가 옳지 않음.")
                                exit()
                            end
                        end
                    end
                    new_value = getValue(functions[card[2]]["value"], merge(variables, function_parameter), functions)
                    if postfix_expression != Nothing
                        push!(postfix_expression, new_value)
                    end
                end
                
                i += length(parameter)
            end
        end
    end
    return [i, new_value]
end