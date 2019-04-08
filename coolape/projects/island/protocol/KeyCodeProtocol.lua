do
    local KeyCodeProtocol = {}
    KeyCodeProtocol.map = {}
    local map = KeyCodeProtocol.map
    map[1] = "__session__"
    map[2] = "retInfor"
    map[3] = "callback"
    map[10] = "msg"
    map[11] = "code"
    map[12] = "cells"
    map[13] = "pageIdx"
    map[14] = "shipsMap"
    map[15] = "buildingIdx"
    map[16] = "idx"
    map[17] = "attrid"
    map[18] = "cidx"
    map[19] = "pos"
    map[20] = "val4"
    map[21] = "val3"
    map[22] = "val2"
    map[23] = "endtime"
    map[24] = "lev"
    map[25] = "val"
    map[26] = "val5"
    map[27] = "starttime"
    map[28] = "state"
    map[29] = "val1"
    map[30] = "type"
    map[31] = "oil"
    map[32] = "gold"
    map[33] = "food"
    map[34] = "tiles"
    map[35] = "name"
    map[36] = "buildings"
    map[37] = "status"
    map[38] = "pidx"
    map[39] = "diam"
    map[40] = "cityidx"
    map[41] = "unionidx"
    map[42] = "getShipsByBuildingIdx"
    map[43] = "dockyardShips"
    map[44] = "upLevBuilding"
    map[45] = "building"
    map[46] = "rmBuilding"
    map[47] = "newBuilding"
    map[48] = "login"
    map[49] = "uidx"
    map[50] = "channel"
    map[51] = "deviceID"
    map[52] = "isEditMode"
    map[53] = "player"
    map[54] = "city"
    map[55] = "systime"
    map[56] = "session"
    map[57] = "onFinishBuildOneShip"
    map[58] = "shipAttrID"
    map[59] = "shipNum"
    map[60] = "getBuilding"
    map[61] = "rmTile"
    map[62] = "onResChg"
    map[63] = "resInfor"
    map[64] = "moveBuilding"
    map[65] = "logout"
    map[66] = "buildShip"
    map[67] = "num"
    map[68] = "upLevBuildingImm"
    map[69] = "newTile"
    map[70] = "tile"
    map[71] = "onBuildingChg"
    map[72] = "onPlayerChg"
    map[73] = "heart"
    map[74] = "getMapDataByPageIdx"
    map[75] = "mapPage"
    map[76] = "moveTile"
    map[77] = "collectRes"
    map[78] = "resType"
    map[79] = "resVal"
    map[80] = "onFinishBuildingUpgrade"
    map["retInfor"] = 2
    map["msg"] = 10
    map["buildingIdx"] = 15
    map["uidx"] = 49
    map["city"] = 54
    map["cells"] = 12
    map["collectRes"] = 77
    map["pidx"] = 38
    map["moveBuilding"] = 64
    map["type"] = 30
    map["upLevBuildingImm"] = 68
    map["state"] = 28
    map["val1"] = 29
    map["moveTile"] = 76
    map["pos"] = 19
    map["shipAttrID"] = 58
    map["code"] = 11
    map["building"] = 45
    map["rmBuilding"] = 46
    map["callback"] = 3
    map["lev"] = 24
    map["login"] = 48
    map["gold"] = 32
    map["onFinishBuildOneShip"] = 57
    map["starttime"] = 27
    map["tiles"] = 34
    map["food"] = 33
    map["resType"] = 78
    map["newTile"] = 69
    map["getMapDataByPageIdx"] = 74
    map["cidx"] = 18
    map["val5"] = 26
    map["endtime"] = 23
    map["getShipsByBuildingIdx"] = 42
    map["cityidx"] = 40
    map["oil"] = 31
    map["resInfor"] = 63
    map["attrid"] = 17
    map["getBuilding"] = 60
    map["__currIndex__"] = 81
    map["status"] = 37
    map["tile"] = 70
    map["logout"] = 65
    map["shipsMap"] = 14
    map["onFinishBuildingUpgrade"] = 80
    map["heart"] = 73
    map["session"] = 56
    map["__session__"] = 1
    map["unionidx"] = 41
    map["systime"] = 55
    map["buildShip"] = 66
    map["onPlayerChg"] = 72
    map["upLevBuilding"] = 44
    map["buildings"] = 36
    map["player"] = 53
    map["shipNum"] = 59
    map["deviceID"] = 51
    map["onBuildingChg"] = 71
    map["newBuilding"] = 47
    map["rmTile"] = 61
    map[0] = "cmd"
    map["idx"] = 16
    map["mapPage"] = 75
    map["val4"] = 20
    map["isEditMode"] = 52
    map["onResChg"] = 62
    map["num"] = 67
    map["val2"] = 22
    map["val3"] = 21
    map["dockyardShips"] = 43
    map["diam"] = 39
    map["pageIdx"] = 13
    map["channel"] = 50
    map["name"] = 35
    map["resVal"] = 79
    map["cmd"] = 0
    map["val"] = 25
    

    KeyCodeProtocol.getKeyCode = function(key)
        local val = map[key]
        if val == nil then
            map[key] = map.__currIndex__
            map[map.__currIndex__] = key
            map.__currIndex__ = map.__currIndex__ + 1
        end
        val = map[key]
        return val
    end
    return KeyCodeProtocol
end