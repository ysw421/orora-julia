include("Operator/Multiplication.jl")
include("Operator/Division.jl")
include("Operator/Addition.jl")
include("Operator/Subtraction.jl")
include("Operator/Mod.jl")
include("Operator/Square.jl")
include("Function.jl")

function precedence(op)
    return op === '^' ? 7 : 
    op in ["!", "\\neg"] ? 6 : 
    op in ['*', '/', "\\mod", "\\times", "\\div", "\\cdot", "\\over"] ? 5 : 
    op in ['+', '-'] ? 4 : 
    op in ["<", ">", "<=", ">=", "\\nless", "\\ngtr", "\\leq", "\\nleq", "\\geq", "\\ngeq"] ? 3 : 
    op in ["=", "!=", "==", "\\ne"] ? 2 :
    op in ["&&", "||", "\\or", "\\and"] ? 1 : 0
end

OPERATORS::Array = ['+', '-', '*', '/', "\\mod", '^', "\\times", "\\div", "\\cdot", 
"<", ">", "<=", ">=", "\\nless", "\\ngtr", "\\leq", "\\nleq", "\\geq", "\\ngeq", 
"=", "!=", "==", "\\ne", "&&", "||", "\\or", "\\and", "!", "\\neg", "\\over", '_']

function getValue(token::Array, variables::Dict, functions::Dict)
    if token[1][2] === "\\begin"
        if token[2][1] === "Dearkelly" && token[2][2] === '{' && length(token[2][3]) === 1
            ending = token[2][3][1][1][2]
            i = 2
            max_cnt = length(token)
            if ending === "bmatrix"
                result = []
                new_value = []
                new_token = []
                new_token2 = []
                while i < max_cnt
                    i += 1
                    if token[i][2] === "&"
                        push!(new_token, getValue(new_token2, variables, functions))
                        new_token2 = []
                        i += 1
                    elseif token[i][2] === "\\\\"
                        push!(new_token, getValue(new_token2, variables, functions))
                        new_token2 = []
                        push!(new_value, new_token)
                        new_token = []
                    end
                    push!(new_token2, token[i])
                end
                if new_token != [] # || new_token2 != []
                    push!(new_token, getValue(new_token2, variables, functions))
                    push!(new_value, new_token)
                end
                new_matrix = ones(length(new_value), length(new_value[1]))
                for j in 1:length(new_value)
                    for k in 1:length(new_value[1])
                        new_matrix[j, k] = new_value[j][k]
                    end
                end
                return new_matrix


            elseif ending === "cases"
                new_token = []
                while i < max_cnt
                    i += 1
                    if token[i][2] === "&"
                        new_token2 = []
                        while token[i + 1][2] !== "\\\\"
                            i += 1
                            push!(new_token2, token[i])
                        end
                        if new_token2[1][2] === "else"
                            return getValue(new_token, variables, functions)
                        elseif getValue(new_token2, variables, functions) === true
                            return getValue(new_token, variables, functions)
                        end
                        new_token2 = []
                        new_token = []
                        i += 1
                    end

                    push!(new_token, token[i])
                end
            end
        end
    else
        stack = []
        postfix_expression::Array = []

        is_last_value::Bool = false
        max_cnt::Int = length(token)
        i::Int = 0
        save_value = ""
        while i < max_cnt
            i += 1
            if token[i][2] in ["\n", "\\\\"]
                continue
            end
            if token[i][2] in OPERATORS
                if token[i][2] === '^' &&  i + 1 <= max_cnt && token[i + 1][1] === "Dearkelly" && token[i + 1][2] === '{' && token[i + 1][3][1][1][2] === "T"
                    v = pop!(postfix_expression)
                    save_value = transpose(v)
                    push!(postfix_expression, save_value)
                    i += 1
                    is_last_value = true
                elseif token[i][2] === '-' && i + 1 <= max_cnt && token[i + 1][1] in ["Bool", "String", "Int", "Float"]
                    if i > 1 && !(token[i - 1][2] in OPERATORS) #(token[i - 1][1] in ["Bool", "String", "Int", "Float"] || (token[i - 1][1] === "Text" && token[i - 1][2] in keys(variables)) )
                        while !isempty(stack) && precedence('+') >= precedence(token[i][2])
                            push!(postfix_expression, pop!(stack))
                        end
                        push!(stack, '+')
                    end
                    result = get_single_value((token[i + 1][1], string("-", token[i + 1][2])), functions)
                    push!(postfix_expression, result)
                    save_value = result
                    i += 1
                    is_last_value = true
                else
                    if token[i][2] === '_'
                        if i + 1 <= max_cnt && token[i + 1][1] === "Dearkelly" && token[i + 1][2] === '{' && i > 1
                            pop!(postfix_expression)
                            new_token = []
                            for j in 1:length(token[i + 1][3])
                                push!(new_token, getValue(token[i + 1][3][j], variables, functions))
                            end
                            result = save_value
                            for j in new_token
                                result = result[j]
                            end
                            push!(postfix_expression, result)
                            save_value = result
                            i += 1
                        end
                    else
                        while !isempty(stack) && precedence(stack[end]) >= precedence(token[i][2])
                            result = pop!(stack)
                            push!(postfix_expression, result)
                            save_value = result
                        end
                        push!(stack, token[i][2])
                        is_last_value = false
                    end
                end
            elseif token[i][1] in ["Bool", "String", "Int", "Float"] || token[i][2] in ["true", "false"] || (token[i][1] === "Dearkelly" && token[i][2] === '[')
                if is_last_value
                    while !isempty(stack) && precedence(stack[end]) >= precedence('*')
                        result = pop!(stack)
                        push!(postfix_expression, result)
                        save_value = result
                    end
                    push!(stack, '*')
                    # push!(postfix_expression, '*')
                end
                result = get_single_value(token[i])
                push!(postfix_expression, result)
                save_value = result
                is_last_value = true
            else
                if token[i][1] === "Dearkelly" && (token[i][2] === '(' || token[i][2] === '{') && length(token[i][3]) === 1
                    if is_last_value
                        while !isempty(stack) && precedence(stack[end]) >= precedence('*')
                            push!(postfix_expression, pop!(stack))
                        end
                        push!(stack, '*')
                    end
                    result = getValue(token[i][3][1], variables, functions)
                    push!(postfix_expression, result)
                    save_value = result
                elseif token[i][1] === "Text"
                    if token[i][2] in keys(variables)
                        if is_last_value
                            while !isempty(stack) && precedence(stack[end]) >= precedence('*')
                                push!(postfix_expression, pop!(stack))
                            end
                            push!(stack, '*')
                        end
                        result = variables[token[i][2]]
                        push!(postfix_expression, result)
                        save_value = result
                    else
                        get_function = getFunction(token[i], token, functions, variables, max_cnt, i, postfix_expression)
                        i = get_function[1]
                        if get_function[2] === Nothing
                            if i > 1 && token[i - 1][1] === "Int" && i + 1 <= max_cnt && token[i + 1][1] === "Int"
                                new_value = []
                                for i in get_single_value(token[i - 1]):get_single_value(token[i + 1])
                                    push!(new_value, i)
                                end
                                pop!(postfix_expression)
                                push!(postfix_expression, new_value)
                                save_value = new_value
                                i += 1
                            elseif token[i][2] in ["true", "false"]
                                result = get_single_value(("Bool", token[i][2]))
                                push!(postfix_expression, result)
                                save_value = result
                            end
                        end
                    end
                end
                is_last_value = true
            end
        end

        while !isempty(stack)
            push!(postfix_expression, pop!(stack))
        end
        # println(postfix_expression)

        # -------------------------
        stack = []

        i = 0
        max_cnt = length(postfix_expression)
        while i < max_cnt
            i += 1
            text = postfix_expression[i]
            if text in OPERATORS
                operand1 = ""
                operand2 = ""
                # try
                operand2 = pop!(stack)
                if !(text in ["!", "\\neg"])
                    operand1 = pop!(stack)
                end
                    
                result = 0
                if text === '+'
                    result = addition(operand1, operand2)
                elseif text === '-'
                    result = subtraction(operand1, operand2)
                elseif text in ['*', "\\times", "\\cdot"]
                    result = multiplication(operand1, operand2)
                elseif text in ['/', "\\div", "\\over"]
                    result = division(operand1, operand2)
                elseif text === "\\mod"
                    result = mod(operand1, operand2)
                elseif text === '^'
                    result = square(operand1, operand2)
                elseif text === "<"
                    result = operand1 < operand2
                elseif text === ">"
                    result = operand1 > operand2
                elseif text in ["\\leq", "<="]
                    result = operand1 <= operand2
                elseif text in ["\\geq", ">="]
                    result = operand1 >= operand2
                elseif text === "\\nleq"
                    result = !(operand1 <= operand2)
                elseif text === "\\geq"
                    result = !(operand1 >= operand2)
                elseif text === "\\nless"
                    result = !(operand1 < operand2)
                elseif text === "\\ngtr"
                    result = !(operand1 > operand2)
                elseif text in ["=", "=="]
                    result = operand1 === operand2
                elseif text in ["!=", "\\ne"]
                    result = operand1 != operand2
                elseif text in ["&&", "\\and"]
                    result = operand1 && operand2
                elseif text in ["||", "\\or"]
                    result = operand1 || operand2
                elseif text in ["!", "\\neg"]
                    result = !operand2
                end
                
                push!(stack, result)
            else
                push!(stack, text)
            end
        end
        
        if length(stack) != 1
            println("@@@ Error: 연산 불가.")
            exit()
        end
        return pop!(stack)
    end
end


function get_single_value(token::Tuple, variables=Dict(), functions = Dict())
    if token[1] === "Int"
        return parse(Int, token[2])
    elseif token[1] === "Float"
        return parse(Float64, token[2])
    elseif token[1] === "String"
        return token[2]
    elseif token[1] === "Bool"
        return parse(Bool, token[2])
    elseif token[1] === "Dearkelly" && token[2] === '['
        new_array::Array = []
        for i in 1:length(token[3])
            push!(new_array, getValue(token[3][i], variables, functions))
        end
        return new_array::Array
    end

    return false
end