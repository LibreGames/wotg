class = require("middleclass.middleclass")
gamestate = require("hump.gamestate")
timer = require("hump.timer")
tween = require("tween.tween")

Screen = require("Screen")
Keyboard = require("input.Keyboard")
Scene = require("Scene")

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setLineStyle("rough")

	love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE)

	gamestate.registerEvents()
	gamestate.push(require("ingame.IngameScene")())
end

function love.gui()
	gamestate.current():gui()
end

function love.keypressed(k)
	Keyboard.keypressed(k)
end

function love.keyreleased(k)
	Keyboard.keyreleased(k)
end

function love.run()
	love.math.setRandomSeed(os.time())
	for i=1,3 do love.math.random() end

	love.event.pump()

	love.load(arg)

	-- We don't want the first frame's dt to include time taken by love.load.
	love.timer.step()

	local dt = 0

	-- Create root canvas
	local canvas = love.graphics.newCanvas(Screen.WIDTH, Screen.HEIGHT)

	-- Main loop time.
	while true do
		-- Process events.
		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				if not love.quit or not love.quit() then
					if love.audio then
						love.audio.stop()
					end
					return
				end
			end
			love.handlers[e](a,b,c,d)
		end

		-- Update dt, as we'll be passing it to update
		love.timer.step()
		dt = love.timer.getDelta()

		-- Call update and draw
		love.update(dt)

		if love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()

			canvas:clear(0, 0, 0, 255)
			love.graphics.setCanvas(canvas)

			love.draw()
			love.gui()

			love.graphics.scale(Screen.SCALE, Screen.SCALE)
			love.graphics.setCanvas()
			love.graphics.draw(canvas, 0, 0)

			love.graphics.present()
		end

		love.timer.sleep(0.001)
	end
end
