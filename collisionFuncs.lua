function bltOnPltCollision(data1, data2, normalImpulse)
  if (normalImpulse >= PL_MIN_IMP_TO_DAMAGE) then
    if data1.userType == "planet" then
      table.insert(changeHpAfterCollision, {bod=data1.parentClass, change=(-normalImpulse)})
    elseif data2.userType == "planet" then
      table.insert(changeHpAfterCollision, {bod=data2.parentClass, change=(-normalImpulse)})
    end
  end
end

function pltOnPltCollision(data1, data2, normalImpulse)
  table.insert(changeHpAfterCollision, {bod=data1.parentClass, change=(-normalImpulse)})
  table.insert(changeHpAfterCollision, {bod=data2.parentClass, change=(-normalImpulse)})
end

function changeHpAfterCollisionFunc()
  local i = 1
  while i <= #changeHpAfterCollision do
    if not changeHpAfterCollision[i].bod.body:isDestroyed() then
      changeHpAfterCollision[i].bod:changeHp(changeHpAfterCollision[i].change)
      table.remove(changeHpAfterCollision, i)
    else
      i = i + 1
    end
  end
end
