function fade(obj, dt)
  obj.alpha = obj.alpha - dt*FADE_RATE
  if obj.alpha <= 0 then
    obj.doingFade = false
    obj.open = false
    obj.timeOpen = 0
  end
end
