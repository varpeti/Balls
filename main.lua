local Balls = require "balls"

local palette = 
{
    {256/256, 128/256,   0/256},
    {  0/256, 255/256,   0/256},
    {256/256,   0/256,   0/256},
}

function love.load()
    math.randomseed(1)
    for i=0,49 do
        Balls:new(i,
            {x=math.random(0,love.graphics.getWidth()),y=math.random(0,love.graphics.getHeight())},
            palette[math.random(#palette)],
            math.random(10,52)
        )
        Balls:setVelocity(i,{x=math.random(-50,50),y=math.random(-50,50)})
    end
end

function warp(ball)
    if ball.pos.x+ball.r*5<0                         then ball.pos.x = love.graphics.getWidth()+ball.r*5  end
    if ball.pos.x-ball.r*5>love.graphics.getWidth()  then ball.pos.x = 0-ball.r*5                         end
    if ball.pos.y+ball.r*5<0                         then ball.pos.y = love.graphics.getHeight()+ball.r*5 end
    if ball.pos.y-ball.r*5>love.graphics.getHeight() then ball.pos.y = 0-ball.r*5                         end
end

function collide(ballA)
    Balls:useFuntion(
    function(ballB)
        if ballA == ballB then return end
        local dx = ballA.pos.x-ballB.pos.x
        local dy = ballA.pos.y-ballB.pos.y
        local r = ballA.r+ballB.r
        if dx*dx+dy*dy < r*r then 
            local angle = math.atan2(dy,dx) -- Angle of col

            local targetX = ballA.pos.x + math.cos(angle) * r
            local targetY = ballA.pos.x + math.sin(angle) * r

            local ax = (targetX - ballB.pos.x) * 0.05
            local ay = (targetY - ballB.pos.y) * 0.05

            ballA.velocity.x = ballA.velocity.x + ax
            ballA.velocity.y = ballA.velocity.y + ay

            ballB.velocity.x = ballB.velocity.x - ax
            ballB.velocity.y = ballB.velocity.y - ay
        end
        
    end)
end

function love.update(dt)
    Balls:update(0.03)

    Balls:useFuntion(warp)
    Balls:useFuntion(collide)
end

function love.draw()
    Balls:draw()
    love.graphics.print(love.timer.getFPS(),10,10)
end