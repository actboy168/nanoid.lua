# Nano ID

A tiny unique string ID generator for pure Lua, implementation of [ai's](https://github.com/ai) [nanoid](https://github.com/ai/nanoid)!

## Example

``` lua
local nanoid = require "nanoid" ()

for _ = 1, 5 do
    print(nanoid())
end
```
