require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
	self.Oh = config.getParameter("hipJointAngleOffset")
	self.A = config.getParameter("hipJointForwardAmplitude")
	self.B = config.getParameter("hipJointBackwardAmplitude")
	self.Ok = config.getParameter("kneeJointAngleOffset")
	self.C = config.getParameter("kneeJointForwardAmplitude")
	self.T = config.getParameter("cycleTime")
	self.t2 = config.getParameter("kneeLagTime")
	self.E = config.getParameter("feetJointForwardAmplitude")
	
	self.mechHorizontalMovement = config.getParameter("mechHorizontalMovement")
	self.time = 0
	self.walking = false
	message.setHandler("changeParameter", function(_, _, args)
		self[args.key] = args.value
	end)
end

function update()
	if vehicle.controlHeld("seat", "left") then
		mcontroller.setXVelocity(- self.mechHorizontalMovement)
		self.facingDirection = -1
	elseif vehicle.controlHeld("seat", "right") then
		mcontroller.setXVelocity(self.mechHorizontalMovement)
		self.facingDirection = 1
	end
	
	animate()
	sb.setLogMap("Time", sb.print(self.time % (self.T / 2)))
end

function animate()

	if math.abs(mcontroller.xVelocity()) >= 0.1 then
		self.walking = true
		self.time = self.time + script.updateDt()
	else
		if self.time % (self.T / 2) > 0.01 then
			if (self.time % self.T) < self.T / 4.0 then
				self.time = self.time - script.updateDt()
			else
				self.time = self.time + script.updateDt()
			end
		else
			self.walking = false
			self.time = 0		
		end
	end

	animator.setFlipped(self.facingDirection == -1)
	
	local layers = {
		"front", "back"
	}
	
	if self.walking then
		local offset = 0
		for _, layer in ipairs(layers) do
			animator.resetTransformationGroup(layer .. "LegUp")
			animator.resetTransformationGroup(layer .. "LegLow")
			animator.resetTransformationGroup(layer .. "Foot")
			
			local hipAngle, kneeAngle, footAngle
			if (currentInterval(self.time) == 1 and offset == 0) or (currentInterval(self.time) ~= 1 and offset ~= 0) then
				hipAngle = self.Oh + self.A * math.sin(2 * math.pi * self.time / self.T + offset)
				kneeAngle = self.Ok + math.min(self.C * math.sin(2 * math.pi * (self.time - self.t2) / self.T + offset), 0)
				footAngle = self.E * math.sin(2 * math.pi * self.time / (self.T) + offset)
			else
				hipAngle = self.Oh + self.B * math.sin(2 * math.pi * self.time / self.T + offset)
				kneeAngle = self.Ok
				footAngle = - hipAngle
			end
			
			animator.rotateTransformationGroup(layer .. "LegUp", hipAngle, animator.partProperty(layer .. "LegUp", "rotationCenter"))
			animator.rotateTransformationGroup(layer .. "LegLow", kneeAngle, {1.375, 0.125})
			animator.rotateTransformationGroup(layer .. "Foot", footAngle, {1.875, 0.625})
			offset = offset + math.pi
		end
	end
end

function currentInterval(time)
	return (time % self.T) < self.T / 2.0 and 1 or 2
end

function uninit()

end