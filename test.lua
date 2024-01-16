package.path = package.path .. ";ltest/?.lua"
local lt = require "ltest"
local create_nanoid = require "nanoid"

local TESTS <const> = {
    default = {
        alphabet =  "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        size = 21,
    },
    letters = {
        alphabet =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        size = 24,
    },
    number = {
        alphabet =  "0123456789",
        size = 36,
    },
    hex = {
        alphabet =  "0123456789abcdef",
        size = 30,
    },
}

for name, cfg in pairs(TESTS) do
    local nanoid = create_nanoid(cfg)

    local suit = lt.test(name)

    function suit:base()
        local alphabet = cfg.alphabet
        for _ = 1, 1000 do
            local id = nanoid()
            lt.assertEquals(#id, cfg.size)
            for c in id:gmatch "." do
                lt.assertEquals(alphabet:match(c), c)
            end
        end
    end

    function suit:has_flat_distribution()
        local COUNT <const> = 100 * 1000
        local chars = {}
        for _ = 1, COUNT do
            local id = nanoid()
            for c in id:gmatch "." do
                chars[c] = (chars[c] or 0) + 1
            end
        end
        local max = 0
        local min = math.maxinteger
        local n = 0
        for _, count in pairs(chars) do
            local distribution = (count * #cfg.alphabet) / (COUNT * cfg.size)
            if distribution > max then max = distribution end
            if distribution < min then min = distribution end
            n = n + 1
        end
        lt.assertEquals(n, #cfg.alphabet)
        lt.assertEquals(max - min <= 0.05, true)
    end

    function suit:has_no_collisions()
        local used = {}
        for _ = 1, 50 * 1000 do
            local id = nanoid()
            lt.assertEquals(used[id], nil)
            used[id] = true
        end
    end
end

os.exit(lt.run(), true)
