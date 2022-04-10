atreplinit() do repl
    try
        @eval using OhMyREPL
    catch e
        @warn "error while importing OhMyREPL" e
    end
end

ENV["JULIA_PKG_SERVER"] = "https://mirrors.tuna.tsinghua.edu.cn/julia"
ENV["JUPYTER"] = "/opt/homebrew/Caskroom/mambaforge/base/bin/jupyter"
