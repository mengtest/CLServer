﻿-- 数字
---@class numEx
numEx = {}

--取一个数的整数部分
function numEx.getIntPart(x)
    local flag = 1;
    if (x < 0) then
        flag = -1;
    end
    x = math.abs(x);
    x = math.floor(x);
    return flag * x;
end

function numEx.nextBool()
    return (math.random(0, 100) > 50)
end

---@public 保留小数位位数
function numEx.getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

return numEx
