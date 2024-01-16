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

local RANDOM_MAXBIT <const> = 63
local RANDOM_MAX <const> = (1<<RANDOM_MAXBIT)-1

local function random()
    return math.random(0, RANDOM_MAX)
end

local DefaultAlphabet <const> =  "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local DefaultSize <const> = 21

return function (config)
    config = config or {
        alphabet = DefaultAlphabet,
        size = DefaultSize,
    }
    local alphabet = {}
    for c in config.alphabet:gmatch "." do
        alphabet[#alphabet+1] = c
    end
    local size = config.size
    local mask_bit = 32 - countl_zero(#alphabet - 1)
    local mask = (1 << mask_bit) - 1
    local id = {}
    if #alphabet == mask + 1 then
        local step <const> = RANDOM_MAXBIT // mask_bit
        local suxfix <const> = size//step*step
        if suxfix == size then
            return function ()
                for cnt = 1, size - step + 1, step do
                    local rnd = random()
                    for i = 0, step-1 do
                        local index = 1 + ((rnd >> (i * mask_bit)) & mask)
                        id[cnt+i] = alphabet[index]
                    end
                end
                return table.concat(id)
            end
        else
            return function ()
                for cnt = 1, size - step + 1, step do
                    local rnd = random()
                    for i = 0, step-1 do
                        local index = 1 + ((rnd >> (i * mask_bit)) & mask)
                        id[cnt+i] = alphabet[index]
                    end
                end
                local rnd = random()
                for cnt = suxfix, size do
                    local index = 1 + ((rnd >> ((cnt-suxfix) * mask_bit)) & mask)
                    id[cnt] = alphabet[index]
                end
                return table.concat(id)
            end
        end
    else
        return function ()
            local cnt = 1
            while true do
                local rnd = random()
                for i = 0, RANDOM_MAXBIT-mask_bit, mask_bit do
                    local index = 1 + ((rnd >> i) & mask)
                    if index <= #alphabet then
                        id[cnt] = alphabet[index]
                        cnt = cnt + 1
                        if cnt > size then
                            return table.concat(id)
                        end
                    end
                end
            end
        end
    end
end
