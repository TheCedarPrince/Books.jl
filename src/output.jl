export
    code

struct Code
    block::AbstractString
    mod::Module
    hide_module::Bool
end

code(block::AbstractString; mod=Main, hide_module=false) = 
    Code(rstrip(block), mod, hide_module)

struct ImageOptions
    caption::String
    label::String
end

function ImageOptions(; caption=nothing, label=nothing)
    ImageOptions(caption, label)
end

function convert_output(path, out::Code)
    block = out.block
    mod = out.mod
    ans = try 
        Core.eval(mod, Meta.parse("begin $block end"))
    catch e
        string(e)
    end
    @show path, typeof(ans)
    shown_output = convert_output(path, ans)
    if isa(ans, AbstractString) || isa(ans, Number)
        shown_output = code_block(shown_output)
    end

    mod_info = mod == Main || out.hide_module ? "" :
        """
        ```{=html}
        <span class="books-list-module">
            module: $mod
        </span>
        ```
        \\begin{flushright}
            \\tiny
            module: $mod
            \\normalsize
        \\end{flushright}
        """
    """
    $mod_info
    ```
    $block
    ```
    $shown_output
    """
end

"""
    convert_output(path, out)

Fallback method for `out::Any`.
Other methods are defined via Requires.
`path` is the path listed in the Pandoc Markdown file.
"""
convert_output(path, out) = string(out)