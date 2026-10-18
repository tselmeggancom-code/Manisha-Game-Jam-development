--[[
Public domain:

Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES ARE
DISCLAIMED.
]]--

return function(moonshine)
  -- Barrel distortion adapted from Daniel Oaks (see commit cef01b67fd)
  -- Added feather to mask out outside of distorted texture

  local distortionFactor

  local shader = love.graphics.newShader([[
    extern vec2 distortionFactor;
    extern vec2 scaleFactor;
    extern float feather;

    vec4 effect(
      vec4 color,
      Image tex,
      vec2 uv,
      vec2 screen_coords
    )
    {
      // To barrel coordinates
      vec2 barrelUV = uv * 2.0 - vec2(1.0, 1.0);

      // Distort
      barrelUV *= scaleFactor;

      vec2 distortionAmount =
        (barrelUV.yx * barrelUV.yx)
        * barrelUV
        * (distortionFactor - vec2(1.0, 1.0));

      barrelUV += distortionAmount;

      // Feather the edges
      float maskX = 1.0 -
        smoothstep(
          1.0 - feather,
          1.0,
          abs(barrelUV.x)
        );

      float maskY = 1.0 -
        smoothstep(
          1.0 - feather,
          1.0,
          abs(barrelUV.y)
        );

      float mask = maskX * maskY;

      // Back to texture coordinates
      vec2 textureUV =
        (barrelUV + vec2(1.0, 1.0)) / 2.0;

      return color * Texel(tex, textureUV) * mask;
    }
  ]])

  local setters = {}

  setters.distortionFactor = function(v)
    assert(
      type(v) == "table" and #v == 2,
      "Invalid value for `distortionFactor'"
    )

    distortionFactor = {unpack(v)}
    shader:send("distortionFactor", v)
  end

  setters.x = function(v)
    setters.distortionFactor{
      v,
      distortionFactor[2]
    }
  end

  setters.y = function(v)
    setters.distortionFactor{
      distortionFactor[1],
      v
    }
  end

  setters.scaleFactor = function(v)
    if type(v) == "table" and #v == 2 then
      shader:send("scaleFactor", v)

    elseif type(v) == "number" then
      shader:send("scaleFactor", {v, v})

    else
      error("Invalid value for `scaleFactor'")

    end
  end

  setters.feather = function(v)
    shader:send("feather", tonumber(v) or 0)
  end

  local defaults = {
    distortionFactor = {1.06, 1.1},
    feather = 0.02,
    scaleFactor = 1
  }

  return moonshine.Effect{
    name = "crt",
    shader = shader,
    setters = setters,
    defaults = defaults
  }
end