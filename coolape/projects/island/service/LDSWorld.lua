-- 世界地图网格
local skynet = require "skynet"
require "skynet.manager"    -- import skynet.register
---@type LDGrid
local grid = require("LDGrid")
local gridSize = 1000
local cellSize = 55

local CMD = {}
function CMD.getGrid()
    return grid
end

-- 取得空闲位置的index
function CMD.getIdleIdx()
    return 0
end

skynet.start(function()
    -- 初始化网格
    grid.init(Vector3.zero, gridSize, gridSize, cellSize)

    skynet.dispatch("lua", function(_, _, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    skynet.register "LDSWorld"
end)