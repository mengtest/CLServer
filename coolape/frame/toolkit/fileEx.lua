﻿-- 文件处理
fileEx = {}

-- 取得目录下文件列表
function fileEx.getFiles(path, suffix)
    local cmd = ""
    if path then
        cmd = "ls " .. path
    else
        cmd = "ls"
    end
    local ret = {}
    --io.popen 返回的是一个FILE，跟c里面的popen一样
    local s = io.popen(cmd)
    local fileLists = s:read("*all")
    --print(fileLists)

    local start_pos = 1
    local end_pos, line
    local pattern = "([^\n\r]+." .. suffix .. ")"
    while true do
        --从文件列表里一行一行的获取文件名
        _, end_pos, line = string.find(fileLists, pattern, start_pos)
        if not end_pos then
            break
        end
        table.insert(ret, line)
        start_pos = end_pos + 1
    end
    return ret;
end

function fileEx.readAll(file_name)
    local f = io.open(file_name, 'r')
    if f == nil then
        return nil;
    end
    local string = f:read("*all")
    f:close()
    return string
end

function fileEx.writeAll(file_name, string)
    local f = assert(io.open(file_name, 'w'))
    if f == nil then
        return
    end
    f:write(string)
    f:close()
end

return fileEx