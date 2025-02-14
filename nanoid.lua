local math_random = math.random
local str_gmatch = string.gmatch
local tbl_concat = table.concat

local RandomMaxBit <const> = 63
local RandomMax <const> = (1 << RandomMaxBit) - 1

local DefaultAlphabet <const> = "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local DefaultSize <const> = 21

local function countl_zero(x)
    local n = 32
    local y = x >> 16
    if y ~= 0 then
        n = n - 16
        x = y
    end
    y = x >> 8
    if y ~= 0 then
        n = n - 8
        x = y
    end
    y = x >> 4
    if y ~= 0 then
        n = n - 4
        x = y
    end
    y = x >> 2
    if y ~= 0 then
        n = n - 2
        x = y
    end
    y = x >> 1
    if y ~= 0 then
        n = n - 1
        x = y
    end
    return n - x
end

local function random()
    return math_random(0, RandomMax)
end

return function(config)
    config = config or {
        alphabet = DefaultAlphabet,
        size = DefaultSize,
    }
    local alphabet = {}
    for c in str_gmatch(config.alphabet, ".") do
        alphabet[#alphabet + 1] = c
    end
    local size = config.size
    local mask_bit = 32 - countl_zero(#alphabet - 1)
    local mask = (1 << mask_bit) - 1
    local id = {}
    if #alphabet == mask + 1 then
        local step <const> = RandomMaxBit // mask_bit
        local suffix <const> = size // step * step
        if suffix == size then
            return function()
                for cnt = 1, size - step + 1, step do
                    local rnd = random()
                    for i = 0, step - 1 do
                        local index = 1 + ((rnd >> (i * mask_bit)) & mask)
                        id[cnt + i] = alphabet[index]
                    end
                end
                return tbl_concat(id)
            end
        else
            return function()
                for cnt = 1, size - step + 1, step do
                    local rnd = random()
                    for i = 0, step - 1 do
                        local index = 1 + ((rnd >> (i * mask_bit)) & mask)
                        id[cnt + i] = alphabet[index]
                    end
                end
                local rnd = random()
                for cnt = suffix, size do
                    local index = 1 + ((rnd >> ((cnt - suffix) * mask_bit)) & mask)
                    id[cnt] = alphabet[index]
                end
                return tbl_concat(id)
            end
        end
    else
        return function()
            local cnt = 1
            while true do
                local rnd = random()
                for i = 0, RandomMaxBit - mask_bit, mask_bit do
                    local index = 1 + ((rnd >> i) & mask)
                    if index <= #alphabet then
                        id[cnt] = alphabet[index]
                        cnt = cnt + 1
                        if cnt > size then
                            return tbl_concat(id)
                        end
                    end
                end
            end
        end
    end
end
