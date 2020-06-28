Balls = {}
Balls.__index = Balls

Balls._b = {}
Balls.numBalls = 0

-- id: 0..128

function Balls:new(id,pos,color,r)
    local ball =
    {
        pos = {x=pos.x,y=pos.y},
        color = {color[1],color[2],color[3]},
        r = r,
        velocity = {x=0,y=0}
    }
    setmetatable(ball,Balls)
    Balls._b[id] = ball
    Balls.numBalls = Balls.numBalls + 1
    Balls.shader:send("numLights", Balls.numBalls)
end

function Balls:update(dt)

    local i = 0
    for k,ball in pairs(self._b) do

        ball.pos = {x=ball.pos.x+ball.velocity.x*dt,y=ball.pos.y+ball.velocity.y*dt}

        local name = "lights["..i.."]"
        Balls.shader:send(name..".position", {ball.pos.x, ball.pos.y})
        Balls.shader:send(name..".diffuse", ball.color)
        Balls.shader:send(name..".power", 500-ball.r*9)
        i = i+1
    end
end

function Balls:draw()
    love.graphics.setShader(Balls.shader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

function Balls:setVelocity(id,velocity)
    Balls._b[id].velocity = velocity
end

function Balls:useFuntion(func)
    for k,ball in pairs(self._b) do
        func(ball)
    end
end

Balls.shaderCode = 
[[ 
    #define NUM_LIGHTS 128

    struct Light 
    {
        vec2 position;
        vec3 diffuse;
        float power;
    };

    extern Light lights[NUM_LIGHTS];
    extern int numLights;

    float constant = 1.0;
    float linear = 0.09;
    float quadratic = 0.032;

    vec2 screen = love_ScreenSize.xy;

    vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords)
    {
        //vec4 pixel = Texel(image, uvs);
        vec3 diffuse = vec3(0);
        vec2 norm_screen = screen_coords/screen;

        for (int i = 0; i < numLights; i++) 
        {
            Light light = lights[i];
            vec2 norm_pos = light.position/screen;
            
            float distance = length(norm_pos - norm_screen) * light.power;
            float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
            diffuse += light.diffuse * attenuation;
        }

        diffuse = clamp(diffuse, 0.0, 1.0);
        return vec4(diffuse, 1.0);
    }
]]

Balls.shader = love.graphics.newShader(Balls.shaderCode)

return Balls