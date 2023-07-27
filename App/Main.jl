include("Lexer/Lexer.jl")

function orora(file_path::String)
    if !occursin(r"\.orora$", file_path)
        error("$file_path is not orora file")
    end
    try
        file = open(file_path, "r")
        content::String = read(file, String)
        close(file)
        println(content)

        lexer(content, ["Main"])
    catch e
        error("Error: $e")
    end
end