local Enemy = require("ingame.Enemy")
local Seed = require("ingame.Seed")

local Pig = class("Pig", Enemy)

Pig.static.STATE_WALK    = 1
Pig.static.STATE_CHARGE  = 2
Pig.static.STATE_DASH    = 3
Pig.static.STATE_EAT     = 4
Pig.static.STATE_STUNNED = 5

Pig.static.WALK_SPEED = 25
Pig.static.CHARGE_TIME = 0.5
Pig.static.DASH_SPEED = 80
Pig.static.DASH_TIME = 2
Pig.static.STUNNED_TIME = 4

Pig.static.MAX_HP = 50
Pig.static.SEED = Seed.static.TYPE_HEAL

function Pig:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "pig")

	self.dir = dir
	self.xspeed = 0
	self.time = 0

	self.state = Pig.static.STATE_WALK
	self.blink = 0
	self.hp = Pig.static.MAX_HP
	self.slot = nil

	self.animator = Animator(Resources.getAnimator("pig.lua"))
	self.collider = BoxCollider(18, 14)
end

function Pig:enter()
	self.players = self.scene:findAll("player")
	self.slots = self.scene:findAll("slot")
end

function Pig:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt

	if self.state == Pig.static.STATE_WALK then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Pig.static.WALK_SPEED, dt*200)
		if self.x < 32 then self.dir = 1 end
		if self.x > Screen.WIDTH-32 then self.dir = -1 end

		local player_los, player = self:canSeePlayer()
		if player_los then
			self.dir = math.sign(player.x-self.x)
			self.state = Pig.static.STATE_CHARGE
			self.time = Pig.static.CHARGE_TIME
		else
			local slot_los, slot = self:canSeeSlot()
			if slot_los then
				local xdist = math.abs(self.x - slot.x)
				if xdist < 4 then
					self.dir = math.sign(self.x - slot.x)
				elseif xdist > 12 then
					self.dir = math.sign(slot.x - self.x)
				else
					self.state = Pig.static.STATE_EAT
					self.slot = slot
				end
			end
		end

	elseif self.state == Pig.static.STATE_CHARGE then
		self.xspeed = math.movetowards(self.xspeed, 0, 300*dt)
		if self.time <= 0 then
			self.state = Pig.static.STATE_DASH
			self.time = Pig.static.DASH_TIME
		end

	elseif self.state == Pig.static.STATE_DASH then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Pig.static.DASH_SPEED, dt*300)
		if self.time <= 0
		or (self.dir == -1 and self.x < 16)
		or (self.dir == 1 and self.x > Screen.WIDTH-16) then
			self.state = Pig.static.STATE_WALK
		end

	elseif self.state == Pig.static.STATE_EAT then
		self.xspeed = 0
		self.slot:eat(dt)
		if self.slot:isEmpty() then
			self.slot = nil
			self.state = Pig.static.STATE_WALK
		end

	elseif self.state == Pig.static.STATE_STUNNED then
		self.xspeed = math.movetowards(self.xspeed, 0, 300*dt)
		if self.time <= 0 then
			self:kill()
		end
	end

	self.x = self.x + self.xspeed * dt
end

function Pig:canSeePlayer()
	local min_dist = 50000
	local best_player
	for i,v in ipairs(self.players) do
		local xdist = math.abs(self.x - v.x)
		local ydist = math.abs(self.y - v.y)
		if ydist < 16 and xdist < 80 and xdist < min_dist then
			best_player = v
		end
	end

	return best_player ~= nil, best_player
end

function Pig:canSeeSlot()
	local min_dist = 50000
	local best_slot
	for i,v in ipairs(self.slots) do
		if not v:isEmpty() then
			local xdist = math.abs(self.x - v.x)
			if v.y > self.y and xdist < min_dist then
				best_slot = v
			end
		end
	end

	return best_slot ~= nil, best_slot
end

function Pig:draw()
	self.animator:setProperty("state", self.state)
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	if (self.blink > 0)
	or (self:isStunned() and love.timer.getTime() % 0.2 < 0.1) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Pig:onCollide(o)
	if o:getName() == "slash" and self.blink <= 0 then
		if self:isStunned() then
			if o:isCharged() then
				self.scene:add(Seed(self.x, self.y,
					o.dir*60,
					love.math.random(-80, -50),
					Pig.static.SEED
				))
				self:kill()
			end
		else
			self.blink = 0.15
			self.hp = self.hp - o:getDamage()
			self.xspeed = 100*o.dir
			if self.state == Pig.static.STATE_EAT then
				self.state = Pig.static.STATE_WALK
			end
			if self.hp <= 0 then
				self:setStunned()
				self.state = Pig.static.STATE_STUNNED
				self.time = Pig.static.STUNNED_TIME
			end
		end
	end
end

return Pig
