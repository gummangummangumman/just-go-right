pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- game states
function _init()
	two_player = false

	//game states
	scene="menu"
end

function _update()
	if (scene=="menu") then
		menu_update()
	elseif (scene=="game") then
		game_update()
	elseif (scene=="end") then
		end_update()
	end
end

function _draw()
	if (scene=="menu") then
		menu_draw()
	elseif (scene=="game") then
		game_draw()
	elseif (scene=="end") then
		end_draw()
	end
end
-->8
-- menu
function menu_update()
	if btnp(❎) then
		scene = "game"
		game_init()
	end
	if btnp(❎, 1) then
		two_player = true
	end
	if btnp(🅾️, 1) then
		two_player = false
	end
end

function menu_draw()
	cls()
	if (two_player) then
		printc("two player", 50)
	else
		printc("one player", 50)
		if (flr(time() % 3) < 2) then
			printc("p2 press ❎ to join", 114)
		end
	end
	printc("press ❎ to start", 60)

	if (two_player) then
		spr(1, 46, 32, 2, 2)
		pal(10, 12)
		spr(1, 66, 32, 2, 2, true)
		pal()
	else
		spr(1, 54, 32, 2, 2)
	end
end
-->8
-- game
function game_init()
	level = 0
	max_level = 5
	normal_speed = 5
	small_speed = 0.2

	p1_level_times = {}
	p2_level_times = {}
	level_effects = {}

	next_level()
end

function next_level()
	level += 1
	player1 = {
	 x = 32,
	 y = 32,
	 facing_left = false,
	 exited = false,
	 speed = normal_speed,
	}
	player2 = {
		x = 32,
		y = 64,
		facing_left = false,
		exited = false,
		speed = normal_speed,
	}
	goal = 128-16
	effect = get_effect(level)
	add(level_effects, effect.tip)
	if (effect.growing) then
		player1.growing_progress = 0
		player1.small = true
		player1.speed = small_speed
		player2.growing_progress = 0 / 10
		player2.small = true
		player2.speed = small_speed
	end
	level_start_time = time()
end

function game_update()
	player1.growing = false
	player2.growing = false
	//p1 inputs
	if btn(⬆️) then
		up(player1)
	end
	if btn(➡️) then
		right(player1)
	end
	if btn(⬅️) then
	 left(player1)
	end

	//p2 inputs
	if btn(⬆️, 1) then
		up(player2)
	end
	if btn(➡️, 1) then
	 right(player2)
	end
	if btn(⬅️, 1) then
		left(player2)
	end
	
	//game
	if (player1.x > goal and player1.exited == false) then
		add(p1_level_times, time() - level_start_time, level)
		player1.exited = true
	end
	if (player2.x > goal and player2.exited == false) then
		add(p2_level_times, time() - level_start_time, level)
		player2.exited = true
	end
	if (player1.exited and (player2.exited or not two_player)) then
		if (level == max_level) then
			scene = "end"
		else
			next_level()
		end
	end
end

function right(player)
	if (effect.reversed) then
		go_left(player)
	elseif (player.growing) then
		return
	else
		go_right(player)
	end
end

function left(player)
	if (effect.reversed) then
		go_right(player)
	elseif (player.growing) then
		return
	else
		go_left(player)
	end
end

function up(player)
	if (effect.growing and player.small) then
		if (player.growing_progress < 30) then
			player.growing_progress += 1
			player.growing = true
		else
			player.small = false
			player.speed = normal_speed
		end
	end
end

function go_left(player)
	if (player.x > 0) then
		player.x -= player.speed
	end
	player.facing_left = true
end

function go_right(player)
	player.x += player.speed
	player.facing_left = false
end

function game_draw()
	cls()
	print("level "..level)
	print(flr(time() - level_start_time).." sec")
	spr(32, goal, player1.y, 2, 2)
	if (two_player) then
		spr(32, goal, player2.y, 2, 2)
	end
	if (player1.exited == false) then
		draw_player(player1)
	end
	if (two_player and player2.exited == false) then
		pal(10, 12)
		draw_player(player2)
		pal()
	end
	draw_tips()
end

function draw_player(player)
if (effect.growing) then
	if (player.growing) then
		--todo consider showing player.growing_progress
		spr(35, player.x, player.y + 6, 1, 1, player.facing_left)
		return
	end
	if (player.small) then
		spr(34, player.x, player.y + 6, 1, 1, player.facing_left)
		return
	end
end
spr(1, player.x, player.y, 2, 2, player.facing_left)
end

function draw_tips()
	print(effect.tip, 64 - #effect.tip * 2, 54)
end
-->8
--levels/effects
effects = {
	{
		tip = "",
	},
	{
		tip = "reversed!",
		reversed = true,
	},
	{
		tip = "reach 4 the stars",
		growing = true,
	},
}

function get_effect(level)
	if (level==1) then
		return effects[1]
	end
	return rnd(effects)
end
-->8
--game over screen
function end_update()
	if btnp(❎) then
		scene = "menu"
	end
end

function end_draw()
	cls()
	p1_wins = 0
	p2_wins = 0
	for k, v in pairs(level_effects) do
		if v == "" then
			v = "normal"
		end
		text = k..". "..v
		if two_player then
			c = 6
			if (p1_level_times[k] > p2_level_times[k]) then
				text = text.." (p2)"
				c = 12
				p2_wins += 1
			elseif (p1_level_times[k] < p2_level_times[k]) then
				text = text.." (p1)"
				c = 10
				p1_wins += 1
			else
				text = text.." (tie)"
			end
		else
			text = text.." - "..(p1_level_times[k] or "?").." s"
		end
		printc(text, 10 + k*10, c)
	end

	if two_player then
		if p1_wins > p2_wins then
			printc("player 1 wins!!!", 20 + 10 * count(level_effects), 10)
		elseif p1_wins < p2_wins then
			printc("player 2 wins!!!", 20 + 10 * count(level_effects), 12)
		else
			printc("it's a draw!", 20 + 10 * count(level_effects))
		end
	else
		total_time = 0
		for k, t in pairs(p1_level_times) do
			total_time += t
		end
		printc("total time is...", 20 + 10 * count(level_effects))
		pal(6, 10)
		printc(total_time.." seconds", 30 + 10 * count(level_effects))
		pal()
	end
end
-->8
--util

--horizontally centered text
function printc(txt, y, c)
	y = y or 50
	c = c or 6
	print(txt, 64 - #txt*2, y, c)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000aaaa000000000000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000aa1aa00000000000aa1aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000aaaaaa0000000000aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000a1aaaa0000000000a1aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000a111100000000000a11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000aaaaa00000000000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000a000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000aaaaa00000000000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000a0a0000000000000a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666666666000aa1000a0aaaa0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633333333333336000a1aa00a01aa10a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633333363333336000a11100a0aaaa0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633333666333336000aaaa00a0a11a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6333366666333360000aa000a00aa00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633333666333336000aaaa00aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6333336663333360000aa000000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633333333333336000a00a0000a00a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000050500000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000505050500000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000005050505000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000050505000500000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c740227402874029740297402574020740187400a7400170000700007000070000700007000070001700017000170001700007000170000700007000070000700007000070000700007000070000700
__music__
00 01424344

