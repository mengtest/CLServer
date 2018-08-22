---@class cmd4city
local cmd4city = {}
local skynet = require("skynet")
require("public.include")
require("public.cfgUtl")
require("dbcity")
require("dbtile")
require("dbbuilding")
require("Errcode")
local math = math
local table = table

local constCfg -- 常量配置
local gridSize  -- 网格size
local cellSize = 1
local tileSize = 2

local NetProtoIsland = "NetProtoIsland"
---@type Grid
local grid

-- 网格状态
local gridState4Tile = {}
local gridState4Building = {}

---@type dbcity
local myself
local tiles = {}        -- 地块信息 key=idx, val=dbtile
local buildings = {}    -- 建筑信息 key=idx, val=dbbuilding
---@type dbbuilding
local headquarters -- 主基地

function cmd4city.new (uidx)
    tiles = {}        -- 地块信息 key=idx
    buildings = {}    -- 建筑信息 key=idx

    local idx = DBUtl.nextVal(DBUtl.Keys.city)

    myself = dbcity.new()
    local d = {}
    d.idx = idx
    d.name = "new city"
    d.pidx = uidx
    d.pos = skynet.call("LDSWorld", "lua", "getIdleIdx")
    d.status = 1
    d.lev = 1
    myself:init(d, true)

    --TODO: 初始化建筑
    -- add base buildings
    local building = cmd4city.newBuilding(1, grid:GetCellIndex(numEx.getIntPart(gridSize / 2 - 1), numEx.getIntPart(gridSize / 2 - 1)), idx)
    if building then
        buildings[building:get_idx()] = building
        headquarters = building
        cmd4city.placeBuilding(building)
    end

    --初始化地块
    cmd4city.initTiles(myself)

    -- 初始化树
    --cmd4city.initTree(myself, v4)

    return myself
end

---@param building dbbuilding
function cmd4city.placeBuilding(building)
    local center = building:get_pos()
    local attr = cfgUtl.getBuildingByID(building:get_attrid())
    local size = attr.Size
    local indexs = grid:getCells(center, size)
    for i, index in ipairs(indexs) do
        gridState4Building[index] = true
    end
end

---@param building dbbuilding
function cmd4city.unPlaceBuilding(building)
    local center = building:get_pos()
    local attr = cfgUtl.getBuildingByID(building:get_attrid())
    local size = attr.Size
    local indexs = grid:getCells(center, size)
    for i, index in ipairs(indexs) do
        gridState4Building[index] = nil
    end
end

---@param tile dbtile
function cmd4city.placeTile(tile)
    local center = tile:get_pos()

    local indexs = grid:getCells(center, tileSize)
    for i, index in ipairs(indexs) do
        gridState4Tile[index] = true
    end
end
---@param tile dbtile
function cmd4city.unPlaceTile(tile)
    local center = tile:get_pos()
    local indexs = grid:getCells(center, tileSize)
    for i, index in ipairs(indexs) do
        gridState4Tile[index] = nil
    end
end

function cmd4city.canPlaceBuilding(index, id)
    if id then
        local attr = cfgUtl.getBuildingByID(id)
        local size = attr.Size
        local indexs = grid:getCells(index, size)
        for i, v in ipairs(indexs) do
            if (not grid:IsInBounds(v)) or gridState4Building[v] then
                return false
            end
        end
        return true
    else
        return (not gridState4Building[index])
    end
end

function cmd4city.canPlaceTile(index)
    local indexs = grid:getCells(index, tileSize)
    for i, v in ipairs(indexs) do
        if (not grid:IsInBounds(v)) or gridState4Tile[v] then
            return false
        end
    end

    return true
end

function cmd4city.canPlace(index, is4Building, attrid)
    if is4Building then
        return cmd4city.canPlaceBuilding(index, attrid)
    else
        return cmd4city.canPlaceTile(index)
    end
end

---@param grid Grid
function getFreeGridIdx(rangeV4, grid, is4Building)
    local x1 = rangeV4.x > rangeV4.z and rangeV4.z or rangeV4.x
    local x2 = rangeV4.x > rangeV4.z and rangeV4.x or rangeV4.z
    local y1 = rangeV4.y > rangeV4.w and rangeV4.w or rangeV4.y
    local y2 = rangeV4.y > rangeV4.w and rangeV4.y or rangeV4.w
    local cells = {}
    for i = x1, x2 do
        for j = y1, y2 do
            table.insert(cells, grid:GetCellIndex(i, j))
        end
    end
    local startIdx = math.random(1, #cells)
    if cmd4city.canPlace(cells[startIdx], is4Building) then
        return cells[startIdx]
    end

    local i = startIdx + 1
    while true do
        if i > #cells then
            i = 1
        end
        if i == startIdx then
            break
        end
        if cmd4city.canPlace(cells[i], is4Building) then
            return cells[i]
        end
        i = i + 1
    end
    return -1
end

-- 取得一定范围内可用的地块
---@param rangeV4 Vector4
function cmd4city.getFreeGridIdx4Tile(rangeV4)
    return getFreeGridIdx(rangeV4, grid)
end

-- 取得一定范围内可用的地块
---@param rangeV4 Vector4
function cmd4city.getFreeGridIdx4Building(rangeV4)
    return getFreeGridIdx(rangeV4, grid, true)
end

-- 初始化树
---@param dbcity
function cmd4city.initTree(city, rangeV4)
    local max = math.random(5, 12)
    for i = 1, max do
        local pos = cmd4city.getFreeGridIdx4Building(rangeV4)
        if pos >= 0 then
            -- attrid 32到36都是树的配制
            local treeAttrid = math.random(30, 34)
            local tree = cmd4city.newBuilding(treeAttrid, pos, city:get_idx())
            if tree then
                buildings[tree:get_idx()] = tree
                --gridState4Building[tree:getpos()] = true
            end
        end
    end
end

-- 取得主城的等级，其实就是主基地的等级
function cmd4city.getCityLev()
    if headquarters and (not headquarters:isEmpty()) then
        return headquarters:get_lev()
    else
        return 1
    end
end

-- 初始化地块
---@param city dbcity
function cmd4city.initTiles(city)
    local headquartersLevsAttr = cfgUtl.getHeadquartersLevsByID(cmd4city.getCityLev())
    if headquartersLevsAttr == nil then
        printe("get DBCFHeadquartersLevsData attr is nil. key=" .. cmd4city.getCityLev())
        return nil
    end

    local tileCount = headquartersLevsAttr.Tiles
    --local range = headquartersLevsAttr.Range
    local range = math.ceil(math.sqrt(tileCount * 4))
    local gridCells = grid:getCells(grid:GetCellIndex(numEx.getIntPart(gridSize / 2 - 1), numEx.getIntPart(gridSize / 2 - 1)), range)
    local counter = 0
    local treeCounter = 0
    local maxTree = math.random(10, 20)
    for i, index in ipairs(gridCells) do
        if counter < tileCount then
            local tile = cmd4city.newTile(index, 0, city:get_idx())
            if tile then
                counter = counter + 1
                tiles[tile:get_idx()] = tile

                -- 初始化树
                if treeCounter < maxTree then
                    local tileCells = grid:getCells(index, tileSize)
                    for i, index2 in ipairs(tileCells) do
                        if numEx.nextBool() then
                            -- attrid 32到36都是树的配制
                            local treeAttrid = math.random(30, 34)
                            local tree = cmd4city.newBuilding(treeAttrid, index2, city:get_idx())
                            if tree then
                                treeCounter = treeCounter + 1
                                buildings[tree:get_idx()] = tree
                            end
                        end
                    end
                end
            end
        else
            break
        end
    end

    cmd4city.setTilesAttr(tiles)
    return rangeV4
end

-- 设置tile属性
function cmd4city.setTilesAttr(tiles)
    ---@type dbtile
    local tile
    local attrid
    ---@type dbtile
    local left, right, up, down
    for idx, t in pairs(tiles) do
        tile = t
        left = grid:Left(tile:get_pos())
        left = tiles[left]
        right = grid:Right(tile:get_pos())
        right = tiles[right]
        up = grid:Up(tile:get_pos())
        up = tiles[up]
        down = grid:Down(tile:get_pos())
        down = tiles[down]
        attrid = cmd4city.getTileAttrWithAround(
                left and left:get_attrid() or 0,
                right and right:get_attrid() or 0,
                up and up:get_attrid() or 0,
                down and down:get_attrid() or 0
        )
        tile:set_attrid(attrid)
    end
end

function cmd4city.getTileAttrWithAround(leftAttrId, righAttrId, upAttrId, downAttrId)
    local all = { 1, 2, 3, 4, 5, 6, 7 }
    local ret1 = all
    local ret2 = all
    local ret3 = all
    local ret4 = all
    local attr
    if leftAttrId > 0 then
        attr = cfgUtl.getTileByID(leftAttrId)
        ret1 = attr.Right
    end
    if righAttrId > 0 then
        attr = cfgUtl.getTileByID(righAttrId)
        ret2 = attr.Left
    end
    if upAttrId > 0 then
        attr = cfgUtl.getTileByID(upAttrId)
        ret3 = attr.Down
    end
    if downAttrId > 0 then
        attr = cfgUtl.getTileByID(downAttrId)
        ret3 = attr.Up
    end

    local ret = {}
    for i, v in ipairs(all) do
        if ret1[v] and ret2[v] and ret3[v] and ret4[v] then
            table.insert(ret, v)
        end
    end
    if #ret > 0 then
        return ret[math.random(1, #ret)]
    else
        return 1
    end
end

---@param idx 城的idx
function cmd4city.getSelf(idx)
    -- 取得城数据
    if myself == nil then
        myself = dbcity.instanse(idx)
        if myself:isEmpty() then
            printe("[cmd4city.get].get city data is nil. idx==" .. idx)
            return nil
        end
        -- 设置一次
        cmd4city.setSelfTiles()
        cmd4city.setSelfBuildings()
    end
    return myself
end

-- 新建地块
---@param pos grid地块的idx
---@param cidx 城idx
function cmd4city.newTile(pos, attrid, cidx)
    if not cmd4city.canPlace(pos, false) then
        printe("【cmd4city.newTile】该位置不能放置地块, pos ==" .. pos)
        return nil
    end
    local tile = dbtile.new()
    local t = {}
    t.idx = DBUtl.nextVal(DBUtl.Keys.building) --"唯一标识"
    t.attrid = attrid --"属性id"
    t.cidx = cidx --"主城idx"
    t.pos = pos -- "城所在世界grid的index"
    if tile:init(t, true) then
        cmd4city.placeTile(tile)
        return tile
    else
        printe("[cmd4city.newTile]==" .. CLUtl.dump(t))
        return nil
    end
end

function cmd4city.queryTiles(cidx)
    return dbtile.getList(cidx)
end

function cmd4city.getSelfTile(idx)
    -- 取得建筑
    if myself == nil then
        printe("主城为空")
        return nil
    end
    if tiles == nil then
        printe("地块信息列表为空")
        return nil
    end
    ---@type dbbuilding
    local t = tiles[idx]
    if t == nil then
        printe("取得地块为空")
        return nil
    end
    return t
end

function cmd4city.setSelfTiles()
    local list = cmd4city.queryTiles(myself:get_idx())
    if list == nil then
        printe("[cmd4city.setSelfTiles]:get tiles is nil. cidx=" .. myself:get_idx())
        return
    end
    tiles = {}
    ---@type dbtile
    local t
    for i, v in ipairs(list) do
        t = dbtile.new(v)
        tiles[v.idx] = t
        cmd4city.placeTile(t)
    end
end

function cmd4city.getSelfTiles()
    if myself == nil then
        printe("[cmd4city.getSelfTiles]:the city data is nil")
        return nil
    end
    return tiles
end

-- 新建筑
---@param attrid 建筑的配置id
---@param pos grid地块idx
---@param cidx 城idx
function cmd4city.newBuilding(attrid, pos, cidx)
    if not cmd4city.canPlace(pos, true, attrid) then
        printe("该位置不能放置建筑, pos ==" .. pos)
        return nil
    end
    local building = dbbuilding.new()
    local b = {}
    b.idx = DBUtl.nextVal(DBUtl.Keys.building) -- 唯一标识
    b.cidx = cidx -- 主城idx
    b.pos = pos -- 位置，即在城的gird中的index
    b.attrid = attrid -- 属性配置id
    b.lev = 1 -- 等级
    b.val = 0 -- 值。如:产量，仓库的存储量等
    b.val2 = 0 -- 值。如:产量，仓库的存储量等
    b.val3 = 0 -- 值。如:产量，仓库的存储量等
    b.val4 = 0 -- 值。如:产量，仓库的存储量等

    if building:init(b, true) then
        cmd4city.placeBuilding(building)
        return building
    else
        printe("[cmd4city.newBuilding] new building error. attrid=" .. attrid .. "  pos==" .. pos .. "  cidx==" .. cidx)
        return nil
    end
end

function cmd4city.query(idx)
    -- 取得城数据
    local city = dbcity.instanse(idx)
    if city:isEmpty() then
        return nil
    end
    local ret = city:value2copy()
    city:release()
    return ret
end

function cmd4city.queryBuildings(cidx)
    return dbbuilding.getList(cidx)
end

function cmd4city.setSelfBuildings()
    if myself == nil then
        printe("[cmd4city.getSelfBuildings]:the city data is nil")
        return
    end
    local list = cmd4city.queryBuildings(myself:get_idx())
    if list == nil then
        printe("[cmd4city.getSelfBuildings]:get buildings is nil. cidx=" .. myself:get_idx())
        return
    end
    buildings = {}
    ---@type dbbuilding
    local b
    for i, v in ipairs(list) do
        b = dbbuilding.new(v)
        buildings[v.idx] = b
        if v.attrid == 1 then
            -- 说明是主基地
            headquarters = v
        end
        cmd4city.placeBuilding(b)
    end
end

function cmd4city.getSelfBuildings()
    if myself == nil then
        printe("[cmd4city.getSelfBuildings]:the city data is nil")
        return nil
    end
    return buildings
end

function cmd4city.getSelfBuilding(idx)
    -- 取得建筑
    if myself == nil then
        printe("主城为空")
        return nil
    end
    if buildings == nil then
        printe("建筑信息列表为空")
        return nil
    end
    ---@type dbbuilding
    local b = buildings[idx]
    if b == nil then
        printe("取得建筑为空")
        return nil
    end
    return b
end

-- 释放数据
function cmd4city.release()
    ---@type dbbuilding
    local b
    for k, v in pairs(buildings) do
        b = v
        b:release()
    end
    buildings = {}

    ---@type dbtile
    local t
    for k, v in pairs(tiles) do
        t = v
        t:release()
    end
    tiles = {}

    if myself and (not myself:isEmpty()) then
        myself:release()
        myself = nil
    end
    gridState4Tile = {}
    gridState4Building = {}
end

--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
cmd4city.CMD = {
    new = function(idx)
        ---@type dbcity
        local city = cmd4city.new(idx)
        if city then
            return city:value2copy()
        end
        return nil
    end,
    getSelf = function(idx)
        local city = cmd4city.getSelf(idx)
        if city then
            return city:value2copy()
        end
        return nil
    end,
    getSelfTiles = function()
        local tiles = cmd4city.getSelfTiles()
        if tiles then
            local tiles2 = {}
            for k, v in pairs(tiles) do
                tiles2[k] = v:value2copy()
            end
            return tiles2
        end
        return nil
    end,
    getSelfBuildings = function()
        local buildings = cmd4city.getSelfBuildings()
        if buildings then
            local buildings2 = {}
            for k, v in pairs(buildings) do
                buildings2[k] = v:value2copy()
            end
            return buildings2
        end
        return nil
    end,
    newBuilding = function(m, fd)
        -- 新建筑
        local ret = {}
        if myself == nil then
            printe("主城数据为空！")
            ret.code = Errcode.error
            ret.msg = "主城数据为空"
            return skynet.call(NetProtoIsland, "lua", "send", "newBuilding", ret, nil)
        end
        if not cmd4city.canPlace(m.pos, true) then
            printe("该位置不能放置建筑！pos==" .. m.pos)
            ret.code = Errcode.error
            ret.msg = "该位置不能放置建筑"
            return skynet.call(NetProtoIsland, "lua", "send", "newBuilding", ret, nil)
        end
        local building = cmd4city.newBuilding(m.attrid, m.pos, myself:get_idx())
        if building == nil then
            printe("新建建筑失败")
            ret.code = Errcode.error
            ret.msg = "新建建筑失败"
            return skynet.call(NetProtoIsland, "lua", "send", "newBuilding", ret, nil)
        end
        buildings[building:get_idx()] = building

        ret.code = Errcode.ok
        return skynet.call(NetProtoIsland, "lua", "send", "newBuilding", ret, building:value2copy())
    end,
    getBuilding = function(m, fd)
        -- 取得建筑
        local ret = {}
        local b = cmd4city.getSelfBuilding(m.idx)
        if b == nil then
            ret.code = Errcode.error
            ret.msg = "取得建筑为空"
            return skynet.call(NetProtoIsland, "lua", "send", "getBuilding", ret, nil)
        end
        ret.code = Errcode.ok
        return skynet.call(NetProtoIsland, "lua", "send", "getBuilding", ret, b:value2copy())
    end,
    moveTile = function(m, fd)
        -- 移动地块
        local ret = {}
        ---@type dbtile
        local t = cmd4city.getSelfTile(m.idx)
        if t == nil then
            ret.code = Errcode.error
            ret.msg = "取得地块为空"
            return skynet.call(NetProtoIsland, "lua", "send", "moveTile", ret, nil)
        end
        cmd4city.unPlaceTile(t)
        t:set_pos(m.pos)
        cmd4city.placeTile(t)
        ret.code = Errcode.ok
        return skynet.call(NetProtoIsland, "lua", "send", "moveTile", ret, t:value2copy())
    end,
    moveBuilding = function(m, fd)
        -- 移动建筑
        local ret = {}
        ---@type dbbuilding
        local b = cmd4city.getSelfBuilding(m.idx)
        if b == nil then
            ret.code = Errcode.error
            ret.msg = "取得建筑为空"
            return skynet.call(NetProtoIsland, "lua", "send", "moveBuilding", ret, nil)
        end
        -- 先释放之前的网格状态
        cmd4city.unPlaceBuilding(b)
        b:set_pos(m.pos)
        -- 设置新的网格的状态
        cmd4city.placeBuilding(b)
        ret.code = Errcode.ok
        return skynet.call(NetProtoIsland, "lua", "send", "moveBuilding", ret, b:value2copy())
    end,
    upLevBuilding = function(m, fd)
        -- 建筑升级
        local ret = {}
        local b = cmd4city.getSelfBuilding(m.idx)
        if b == nil then
            ret.code = Errcode.error
            ret.msg = "取得建筑为空"
            return skynet.call(NetProtoIsland, "lua", "send", "upLevBuilding", ret)
        end
        --TODO: check max lev
        b:set_lev(b:get_lev() + 1)
        ret.code = Errcode.ok
        return skynet.call(NetProtoIsland, "lua", "send", "upLevBuilding", ret)
    end,
    release = function(m, fd)
        cmd4city.release()
    end,
}

skynet.start(function()
    constCfg = cfgUtl.getConstCfg()
    gridSize = constCfg.GridCity
    grid = Grid.new()
    grid:init(Vector3.zero, gridSize, gridSize, cellSize)

    skynet.dispatch("lua", function(_, _, command, ...)
        local f = cmd4city.CMD[command]
        if f == nil then
            error("func is nill.cmd =" .. command)
        else
            skynet.ret(skynet.pack(f(...)))
        end
    end)
end)

