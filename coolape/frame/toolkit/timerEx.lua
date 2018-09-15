---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by chenbin.
--- DateTime: 18/9/15 12:04

---
local skynet = require "skynet"
timerEx = {}

---@public 新建定时器
---@param sec 秒为单位，可以是小数
---@param func 定时器执行的函数
timerEx.new = function(sec, func)
    local function cb()
        if func then
            func()
        end
    end
    local coroutine = {}
    coroutine.cancel = function()
        func = nil
    end
    --将当前 coroutine 挂起 ti 个单位时间。一个单位是 1/100 秒
    local ti = sec/100
    skynet.timeout(ti, cb)
    return coroutine
end

---@public 取消定时器
---@param coroutine
timerEx.cancel = function(coroutine)
    coroutine.cancel()
end

return timerEx