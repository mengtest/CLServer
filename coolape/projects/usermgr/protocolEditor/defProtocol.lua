--[[
-- 定义接口协议
--]]
defProtocol = {}
defProtocol.name = "UsermgrHttpProto";      -- 协议名字
defProtocol.isSendClientInt2bio = true;     -- 发送给客户端时是否把int转成bio
--===================================================
--===================================================
--===================================================
--[[ 数据结构定义,格式如下

defProtocol.structs.数据结构名 = {
    "数据结构的说明",
    {
        字段1 = { 可以确定类型的初始值, "字段说明" },
        字段2 = { 可以确定类型的初始值, "字段说明" },
    }
}
例如：
defProtocol.structs.retInfor = {
    "返回信息",
    {
        code = { 1, "返回值" },
        msg = { "", "返回消息" },
    }
}

.注意每个字段对应一个list，list[1]=设置一个值，以确定该字段的类型,可以嵌套其它数据结构, list[2]=该字段的备注说明（可以没有）
例如：
defProtocol.structs.AA = {
    "例1",
    {
        a = { 1, "说明" },
    }
}

defProtocol.structs.BB = {
    "例2",
    {
        b = { {d = defProtocol.structs.AA}, "该字段是一个table形，值是一个defProtocol.structs.AA数据结构" },
        c = { {defProtocol.structs.AA, defProtocol.structs.AA}, "该字段是个list，里面的值是defProtocol.structs.AA数据结构"},
    }
}

--]]
---@class defProtocol.structs
defProtocol.structs = {}
defProtocol.structs.retInfor = {
    "返回信息",
    {
        code = { 1, "返回值" },
        msg = { "", "返回消息" },
    }
}

defProtocol.structs.userInfor = {
    "用户信息",
    {
        idx = { 0, "唯一标识" },
        name = { "", "名字" },
    }
}
defProtocol.structs.server = {
    "服务器",
    {
        idx = { 0, "id" },
        name = { "", "名称" },
        status = { 0, "状态 0:正常; 1:爆满; 2:维护" }
    }
}
defProtocol.structs.servers = {
    "服务器列表",
    {
        list = { { defProtocol.structs.server, defProtocol.structs.server }, "服务器列表" },
    }
}
--===================================================
--===================================================
--===================================================
local structs = defProtocol.structs;
--===================================================
--===================================================
--===================================================
-- 接口定义
defProtocol.cmds = {
    --[[
    login = {       -- 接口名
        desc="";       -- 接口说明
        input = {"userId", "password" };  -- 入参
        inputDesc = {"用户名","密码"};     -- 入参说明
        output = { structs.retInfor, structs.userInfor, "sysTime" };        -- 出参
        outputDesc = {"返回信息","用户信息","系统时间"};  -- 出参说明
        logic = "cmd4user";     -- 处理的接口的lua
    };
    --]]
    regist = {
        desc = "注册"; -- 接口说明
        input = { "userId", "password", "appid", "channel", "deviceID", "deviceInfor" }; -- 入参
        inputDesc = { "用户名", "密码", "应用id", "渠道", "机器码", "机器信息" }; -- 入参说明
        output = { structs.retInfor, structs.userInfor }; -- 出参
        outputDesc = { "返回信息", "用户信息", }; -- 出参说明
        logic = "cmd4user";
    };
    login = {
        desc = "登陆"; -- 接口说明
        input = { "userId", "password" }; -- 入参
        inputDesc = { "用户名", "密码" }; -- 入参说明
        output = { structs.retInfor, structs.userInfor }; -- 出参
        outputDesc = { "返回信息", "用户信息", }; -- 出参说明
        logic = "cmd4user";
    };
    getServers = {
        desc = "取得服务器列表"; -- 接口说明
        input = { "appid", "channceid" }; -- 入参
        inputDesc = { "应用id", "渠道号" }; -- 入参说明
        output = { structs.retInfor, structs.servers }; -- 出参
        outputDesc = { "返回信息", "服务器列表", }; -- 出参说明
        logic = "cmd4user";
    };
}

return defProtocol