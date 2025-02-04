projectile = entity:new({
    range=10
})

setmetatable(projectile, {__index=entity})

function projectile:draw()
    entity.draw(self)
end