---@public 常量定义
IDConstVals = {
    headquartersBuildingID = 1, -- 主基地
    dockyardBuildingID = 2, -- 造船厂
    AllianceID = 4, -- 联盟港口
    foodStorageBuildingID = 7,
    goldStorageBuildingID = 11,
    oildStorageBuildingID = 9,
    baseRes = 50000 -- 基础资源量
}

IDConstVals.PlayerState = {
    normal = 1, -- 正常
    protect = 2 -- 免战保护
}

IDConstVals.BuildingState = {
    normal = 0, --正常
    upgrade = 1, --升级中
    working = 2, --工作中
    renew = 9 -- 恢复中
}

---@public 游戏中各种类型
IDConstVals.UnitType = {
    building = 1,
    ship = 2,
    tech = 3,
    pet = 4,
    skill = 5
}
---@public 角色类别
IDConstVals.RoleGID = {
    worker = 0, -- 工人
    ship = 1, -- 舰船
    solider = 2, -- 陆战兵
    pet = 3 -- 宠物
}

---@public 资源各类
IDConstVals.ResType = {
    food = 1,
    gold = 2,
    oil = 3,
    diam = 9
}
---@public 大地图地块类型
IDConstVals.WorldmapCellType = {
    port = 1, -- 港口
    decorate = 2, -- 装饰
    user = 3, -- 玩家
    empty = 4, -- 空地
    occupy = 99 -- 占用
}

---@public 舰队任务
IDConstVals.FleetTask = {
    idel = 1, -- 待命状态
    voyage = 2, -- 出征
    back = 3, -- 返航
    attack = 4 -- 攻击
}
---@public 舰队状态
IDConstVals.FleetState = {
    none = 1, -- 无
    moving = 2, -- 航行中
    docked = 3, -- 停泊在港口
    stay = 4, -- 停留在海面
    fighting = 5 -- 正在战斗中
}
return IDConstVals
