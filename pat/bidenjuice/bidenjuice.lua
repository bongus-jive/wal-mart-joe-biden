function init()
  activeItem.setHoldingItem(false)

  self.soulResource = config.getParameter("soulResource", "pat_bidensoul")

  if entity.entityType() ~= "npc" or not status.isResource(self.soulResource) then
    script.setUpdateDelta(0)
    return
  end

  script.setUpdateDelta(25)

  self.emotes = config.getParameter("emotes", {})
  self.soulRestoreRange = config.getParameter("soulRestoreRange", {0.5, 1})
  self.soulSleepyPercentage = config.getParameter("soulSleepyPercentage", 0.1)
  self.drinkTime = config.getParameter("drinkTime", 0.3)
  self.drinkTimer = 0
  self.drinkArmAngles = config.getParameter("drinkArmAngles", {-90, 45})
  self.drinkArmAngles[1] = self.drinkArmAngles[1] / 180 * math.pi
  self.drinkArmAngles[2] = self.drinkArmAngles[2] / 180 * math.pi
end

function update(dt)
  if self.drinkTimer > 0 then
    drinking(dt)
    return
  end

  local soul = status.resourcePercentage("pat_bidensoul")
  if soul <= 0 then
    startDrink()
  elseif soul <= self.soulSleepyPercentage then
    sleepy()
  end
end

function emote(key)
  local e = self.emotes[key]
  if e then
    activeItem.emote(e)
  end
end

function sleepy()
  emote("sleepy")
end

function startDrink()
  self.drinkTimer = self.drinkTime
  activeItem.setHoldingItem(true)
  animator.playSound("drink")
  script.setUpdateDelta(1)
  emote("startDrink")
end

function drinking(dt)
  activeItem.setArmAngle(lerp(1 - self.drinkTimer / self.drinkTime, self.drinkArmAngles))

  self.drinkTimer = self.drinkTimer - dt
  if self.drinkTimer <= 0 then
    self.drinkTimer = 0
    endDrink()
    return
  end
end

function endDrink()
  activeItem.setHoldingItem(false)
  status.modifyResourcePercentage(self.soulResource, randomInRange(self.soulRestoreRange))
  script.setUpdateDelta(25)
  emote("endDrink")
end

function lerp(ratio, t)
  return t[1] + (t[2] - t[1]) * ratio
end

function randomInRange(t)
  return t[1] + (math.random() * (t[2]- t[1]))
end
