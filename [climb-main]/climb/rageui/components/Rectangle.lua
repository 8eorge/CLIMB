---RenderRectangle
---
--- Reference : https://github.com/iTexZoz/NativeUILua_Reloaded/blob/master/UIElements/UIResRectangle.lua#L84
---
---@param X number
---@param Y number
---@param Width number
---@param Height number
---@param R number|nil
---@param G number|nil
---@param B number|nil
---@param A number|nil
---@return nil
---@public
function RenderRectangle(X, Y, Width, Height, R, G, B, A)
    local X, Y, Width, Height = (tonumber(X) or 0) / 1920, (tonumber(Y) or 0) / 1080, (tonumber(Width) or 0) / 1920, (tonumber(Height) or 0) / 1080
    DrawRect(X + Width * 0.5, Y + Height * 0.5, Width, Height, tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255, tonumber(A) or 255)
end
