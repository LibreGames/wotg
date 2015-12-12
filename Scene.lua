local Scene = class("Scene")
local Camera = require("Camera")
local sort = require("sort")
local CollisionHandler = require("CollisionHandler")

function Scene:initialize()
	self.entities = {}
	self.camera = Camera(Screen.WIDTH/2, Screen.HEIGHT/2)
	self.collisionHandler = CollisionHandler(self)
	self.hasEntered = false

	timer.clear()
end

function Scene:update(dt)
	if self.hasEntered == false then
		self.hasEntered = true
		for i,v in ipairs(self.entities) do
			v:enter()
		end
	end

	for i,v in ipairs(self.entities) do
		if v:isAlive() and v.update then
			v:update(dt)
		end
	end

	if self.checkCollisions then
		self.collisionHandler:checkAll(dt)
	end

	timer.update(dt)

	sort.insertionsort(
		self.entities,
		function(a,b)
			return a.z > b.z
		end
	)

	for i=#self.entities, 1, -1 do
		if self.entities[i]:isAlive() == false then
			self.entities[i]:onRemove()
			table.remove(self.entities, i)
		end
	end
end

function Scene:draw()
	love.graphics.push()
	self.camera:apply()

	for i,v in ipairs(self.entities) do
		if v.draw then
			v:draw()
		end
	end

	love.graphics.pop()
end

function Scene:gui()
	love.graphics.push()

	for i,v in ipairs(self.entities) do
		if v.gui then
			v:gui()
		end
	end

	love.graphics.pop()
end

function Scene:add(e)
	table.insert(self.entities, e)
	e.scene = self
	e:enter()
	return e
end

function Scene:find(name)
	for i,v in ipairs(self.entities) do
		if v:getName() == name then
			return v
		end
	end
end

function Scene:findAll(name)
	local t = {}
	for i,v in ipairs(self.entities) do
		if v:getName() == name then
			table.insert(t, v)
		end
	end
	return t
end

function Scene:clearEntities()
	self.entities = {}
end

function Scene:getEntities()
	return self.entities
end

function Scene:getCamera()
	return self.camera
end

return Scene
