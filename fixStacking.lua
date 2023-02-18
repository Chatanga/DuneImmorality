local stacking = {
  ['2c5f0f'] = '204e00',
  ['2b61ee'] = '6e68b8',
  ['6e68b8'] = '204e00',
  ['204e00'] = '026149',
  ['026149'] = 'dd97a1'
}

function getTrueBounds(object)
  local bounds = object.getBounds()
  if object.type == 'Scripting' then
    local scale = object.getScale()
    bounds.size = {
      x = scale.x,
      y = scale.y,
      z = scale.z
    }
  end
  return bounds
end

function fixStacking(object)
  local GUID = object.getGUID()
  local baseGUID = stacking[GUID]
  if baseGUID then
    local base = getObjectFromGUID(baseGUID)
    if base then
      if not base.hasTag('stackingFixed') then
        fixStacking(base)
      end
      local baseBounds = getTrueBounds(base)
      local altitude = base.getPosition().y + baseBounds.size.y / 2
      local bounds = getTrueBounds(object)
      local y = altitude + bounds.offset.y + bounds.size.y / 2
      local position = object.getPosition()
      --log('Fixing ' .. GUID .. ' by ' .. (y - position.y) .. ' with a size.y of ' .. bounds.size.y)
      object.setPosition({position.x, y, position.z})
    else
      log('Unknown base GUID ' .. baseGUID)
    end
  end
  object.addTag('stackingFixed')
  object.setLock(true)
end

function onLoad()
  fixStacking(self)
end
