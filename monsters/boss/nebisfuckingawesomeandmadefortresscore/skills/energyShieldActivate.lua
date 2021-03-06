--Blast shield slam transitional phase
energyShieldActivate = {}

function energyShieldActivate.enterWith(args)
  if not args or not args.enteringPhase then return nil end

  return {
    timer = config.getParameter("energyShieldActivate.skillTime", 1),
    rotateInterval = config.getParameter("energyShieldActivate.rotateInterval", 0.2),
    rotateAngle = config.getParameter("energyShieldActivate.rotateAngle", 0.05),
    prepareSlam = false,
    slam = false
  }
end

function energyShieldActivate.enteringState(stateData)
  if animator.animationState("blastShield") == "closed" then
    animator.setAnimationState("blastShield", "winddown")
  end
  
  animator.setAnimationState("stages", "stage"..currentPhase())
  animator.playSound("energyShieldActivate")
	
	local playerId = world.playerQuery(mcontroller.position(), 50, {order = "random"})[1]
	if not playerId then
		playerId = entity.id()
	end
	world.sendEntityMessage(playerId, "queueRadioMessage", "sgfortressenergyshielddeployment")
	self.radioMessage = true
end

function energyShieldActivate.update(dt, stateData)
  stateData.timer = stateData.timer - dt

  local duration = config.getParameter("energyShieldActivate.skillTime", 1) - stateData.timer
  local angle = energyShieldActivate.angleFactorFromTime(stateData.timer, stateData.rotateInterval) * stateData.rotateAngle - stateData.rotateAngle / 2
  animator.rotateGroup("core", angle, true)

  if stateData.timer <= 0 then
    return true
  end
end

--basic triangle wave
function energyShieldActivate.angleFactorFromTime(timer, interval)
  local modTime = timer % interval
  if modTime < interval / 2 then
    return modTime / (interval / 2)
  else
    return (interval - modTime) / (interval / 2) 
  end
end

function energyShieldActivate.leavingState(stateData)
  animator.rotateGroup("core", 0, true)
end