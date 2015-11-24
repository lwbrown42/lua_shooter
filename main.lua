--- apparently global variables are k?
player = {x = 200, y = 710, speed = 200, img = nil}

canShoot = true 
canShootTimerMax = .2
canShootTimer = canShootTimerMax

createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

bulletImg = nil
enemyImg = nil

bullets = {}
enemies = {}

isAlive = true
score = 0

function checkCollisions(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

function love.load(arg)
	-- load the image. uses the graphics api
	player.img = love.graphics.newImage('assets/plane.png')
	bulletImg = love.graphics.newImage('assets/bullet.png')
	enemyImg = love.graphics.newImage('assets/enemy.png')
end

function love.update(dt)

	canShootTimer = canShootTimer - (1*dt)
	createEnemyTimer = createEnemyTimer - (1*dt)

	-- checks if we can shoot
	if canShootTimer < 0 then
		canShoot = true
	end
	
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	-- handles movement
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	end

	--handles the shooting
	if love.keyboard.isDown(' ') and canShoot == true then
		newBullet = {x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end
	
	-- update the bullet's location
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (125 * dt)
		
		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end
	
	-- create enemies
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = {x = randomNumber, y = -10, img = enemyImg}
		table.insert(enemies, newEnemy)
	end

	-- update enemy positions
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200*dt)

		if enemy.y > love.graphics:getHeight() then
			table.remove(enemies, i)
		end
	end

	-- collisions and shit
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if checkCollisions(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) and isAlive then
				table.remove(enemies, i)
				table.remove(bullets, j)

				score = score + 1
			end
		end
	end

	-- if player hits enemy
	for i, enemy in ipairs(enemies) do
		if checkCollisions(player.x, player.y, player.img:getWidth(), player.img:getHeight(), enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) and isAlive then
			isAlive = false
			table.remove(enemies, i)
		end
	end

	-- handle restarting
	if not isAlive and love.keyboard.isDown('r') then
		bullets = {}
		enemies = {}
		
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		player.x = 50
		player.y = 710

		isAlive = true
		score = 0
	end


end

function love.draw(dt)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end
	
end
