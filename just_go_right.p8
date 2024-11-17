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
		sfx(3)
	end
	if btnp(🅾️, 1) then
		two_player = false
		sfx(4)
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
	max_level = 7
	normal_speed = 2
	small_speed = 0.2

	p1_level_times = {}
	p2_level_times = {}
	for c=1,max_level do
		add(p1_level_times, 32767, c)
		add(p2_level_times, 32767, c)
	end
	level_effects = {}

	next_level()
end

function next_level()
	level += 1
	player1 = {
	 x = 16,
	 y = 38,
	 facing_left = false,
	 exited = false,
	 speed = normal_speed,
	}
	player2 = {
		x = 16,
		y = 72,
		facing_left = false,
		exited = false,
		speed = normal_speed,
	}
	goal = 128-32
	effect = get_effect(level)
	add(level_effects, effect.tip)
	if (effect.growing) then
		player1.growing_progress = 0
		player1.small = true
		player1.speed = small_speed
		player2.growing_progress = 0
		player2.small = true
		player2.speed = small_speed
	end
	level_start_time = time()
	level_end_time = 32767
end

function game_update()
	if (player1.exited or player2.exited) then
		if time() < level_end_time + 2 then
			return
		end
		if (level == max_level) then
			end_init()
			scene = "end"
		else
			next_level()
		end
		return
	end
	player1.growing = false
	player2.growing = false
	player1.ducking = false
	player2.ducking = false
	
	inputs()
	
	//game
	if (effect.cannon and flr((time() * 4 - level_start_time) % 4) == 3) then
		if not player1.ducking then
			player1.x = 0
		end
		if not player2.ducking then
			player2.x = 0
		end
		sfx(0)
	end
	if (player1.x > goal and player1.exited == false) then
		add(p1_level_times, time() - level_start_time, level)
		player1.exited = true
		level_end_time = time()
		sfx(1)
	end
	if (player2.x > goal and player2.exited == false) then
		add(p2_level_times, time() - level_start_time, level)
		player2.exited = true
		level_end_time = time()
		sfx(1)
	end
end

function inputs()
	//p1
	if btn(⬆️) then
		up(player1)
	end
	if btn(⬇️) then
		down(player1)
	end
	if btn(➡️) then
		right(player1)
	end
	if btn(⬅️) then
	 left(player1)
	end
	//p2
	if btn(⬆️, 1) then
		up(player2)
	end
	if btn(⬇️, 1) then
		down(player2)
	end
	if btn(➡️, 1) then
	 right(player2)
	end
	if btn(⬅️, 1) then
		left(player2)
	end
end

function right(player)
	if (player.growing or player.ducking) then
		return
	elseif (effect.reversed) then
		go_left(player)
	else
		go_right(player)
	end
end

function left(player)
	if (player.growing or player.ducking) then
		return
	elseif (effect.reversed) then
		go_right(player)
	else
		go_left(player)
	end
end

function down(player)
	if not effect.reversed then
		player.ducking = true
	else
		grow(player)
	end
end

function up(player)
	if effect.reversed then
		player.ducking = true
	else
		grow(player)
	end
end

function grow(player)
	if (effect.growing and player.small) then
		if (player.growing_progress < 15) then
			player.growing_progress += 1
			player.growing = true
		else
			player.small = false
			player.speed = normal_speed
			sfx(2)
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
	print("level "..level.."/"..max_level)
	if not two_player then
		print(flr(time() - level_start_time).." sec")
	end
	spr(64, goal, player1.y, 2, 2)
	if (two_player) then
		spr(64, goal, player2.y, 2, 2)
	end
	if (player1.exited == false) then
		draw_player(player1)
	end
	if (two_player and player2.exited == false) then
		pal(10, 12)
		draw_player(player2)
		pal()
	end
	if effect.cannon then
		spr(66 + 2*flr((time() * 4 - level_start_time) % 4), 128-16, player1.y, 2, 2)
		if two_player then
				spr(66 + 2*flr((time() * 4 - level_start_time) % 4), 128-16, player2.y, 2, 2)
		end
	end
	printc(effect.tip, 60)
end

function draw_player(player)
	if player1.exited or player2.exited then
		spr(9, player.x, player.y, 2, 2)
	elseif (player.growing) then
		--todo consider showing player.growing_progress
		spr(35, player.x, player.y + 6, 1, 1, player.facing_left)
		return
	elseif (player.small and player.ducking) then
		spr(36, player.x, player.y + 6, 1, 1, player.facing_left)
	elseif (player.ducking) then
		spr(5, player.x, player.y, 2, 2, player.facing_left)
	elseif (player.small) then
		spr(34, player.x, player.y + 6, 1, 1, player.facing_left)
	else
		spr(1, player.x, player.y, 2, 2, player.facing_left)
	end
end
-->8
--levels/effects
effects = {
	{
		tip = "",
	},
	{
		tip = "reversed",
		reversed = true,
	},
	{
		tip = "reach 4 the stars",
		growing = true,
	},
	{
		tip = "duck!",
		cannon = true,
	},
	{
		tip = "reversed duck!",
		reversed = true,
		cannon = true,
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
function end_init()
	game_over_time = time()
	sfx(5)
end

function end_update()
	if btnp(❎) and elapsed() > 2 then
		scene = "menu"
		sfx(6)
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
		printc(text, 10 + k*8, c)
	end

	if two_player then
		if p1_wins > p2_wins then
			printc("player 1 wins!!!", 20 + 8 * count(level_effects), 10)
			spr(3, 52, 30 + 8 * count(level_effects), 2, 2)
		elseif p1_wins < p2_wins then
			printc("player 2 wins!!!", 20 + 8 * count(level_effects), 12)
			pal(10, 12)
			spr(3, 52, 30 + 8 * count(level_effects), 2, 2)
			pal()
		else
			printc("it's a tie!", 20 + 8 * count(level_effects))
			spr(7, 40, 30 + 8 * count(level_effects), 2, 2)
			pal(10, 12)
			spr(7, 62, 30 + 8 * count(level_effects), 2, 2)
			pal()
		end
	else
		total_time = 0
		for k, t in pairs(p1_level_times) do
			if k <= max_level do
				total_time += t
			end
		end
		printc("total time is...", 20 + 10 * count(level_effects))
		pal(6, 10)
		printc(total_time.." seconds", 30 + 10 * count(level_effects))
		pal()
	end
	if (elapsed() > 8 and flr(time() % 3) < 2) then
		printc("press ❎ to return", 114)
	end
end

function elapsed()
	return time() - game_over_time
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
00000000000000000000000000a000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000aaaa000000000a0aaaaaaa0a00000000000000000000000aaaaaaa000000000aaaaaaa000000000000000000000000000000000000000000000
0070070000000aa1aa00000000a0aa1a1aa0a00000000000000000000000aa1a1aa000000000aa1a1aa000000000000000000000000000000000000000000000
0007700000000aaaaaa0000000a0aaaaaaa0a00000000000000000000000aaaaaaa000000000aaaaaaa000000000000000000000000000000000000000000000
0007700000000a1aaaa0000000a0a1aaa1a0a00000000000000000000000aaaaaaa000000000aa111aa000000000000000000000000000000000000000000000
0070070000000a111100000000a0a11111a0a00000000000000000000000a11111a000000000a1aaa1a000000000000000000000000000000000000000000000
0000000000000aaaaa00000000a0aaaaaaa0a0000000000000000000a000aaaaaaa000a00000aaaaaaa000000000000000000000000000000000000000000000
000000000000000a0000000000a0000a0000a0000000000000000000aa00000a00000aa00000000a000000000000000000000000000000000000000000000000
00000000000000aaa000000000a000aaa000a00000000000000000000aa000aaa000aa00000000aaa00000000000000000000000000000000000000000000000
0000000000000aaaaa00000000aaaaaaaaaaa0000000000000aaaaaa00aaaaaaaaaaa00000000aaaaa0000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa0000000000000aaaaaa1a1a000000aaa0000000000000aaa00000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa0000000000000aaaaaa1aaa000000aaa0000000000000aaa00000000000000000000000000000000000000000000000
00000000000000aaa0000000000000aaa0000000000000aaa00a1aa0000000aaa0000000000000aaa00000000000000000000000000000000000000000000000
00000000000000a0a0000000000000a0a0000000000000a0a0001a00000000a0a0000000000000a0a00000000000000000000000000000000000000000000000
00000000000000a0a0000000000000a0a000000000000aaaa0000000000000a0a0000000000000a0a00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aa1000a0aaaa0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a1aa00a01aa10a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a11100a0aaaa0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaaa00a0a11a0a0000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aa000a00aa00aaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaaa00aaaaaaaaaaaaa1a10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aa000000aa000aaa0a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a00a0000a00a00a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333600000000000800000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000
6333333633333360006000000040000000600000008000000060000000000000aa60000000000000000000000000000000000000000000000000000000000000
6333336663333360006666666646600000666666664660000066666666866000aa66666666066000005555500000000000000000000000000000000000000000
6333366666333360006666666666600000666666666660000066666666666000aa66666666666000055555500000000000000000000000000000000000000000
6333336663333360006666666666600000666666666660000066666666666000aa66666666666000005555500000000000000000000000000000000000000000
6333336663333360006666666666600000666666666660000066666666666000aa66666666666000000000000000000000000000000000000000000000000000
6333333333333360006000555500000000600055550000000060005555000000aa60005555000000000000000000000000000000000000000000000000000000
63333333333333600000005555000000000000555500000000000055550000000a00005555000000000000000000000000000000000000000000000000000000
63333333333333600000005555000000000000555500000000000055550000000000005555000000000000000000000000000000000000000000000000000000
63333333333333600000005555000000000000555500000000000055550000000000005555000000000000000000000000000000000000000000000000000000
63333333333333600000005555000000000000555500000000000055550000000000005555000000000000000000000000000000000000000000000000000000
63333333333333600000005555000000000000555500000000000055550000000000005555000000000000000000000000000000000000000000000000000000
63333333333333600005555555000000000555555500000000055555550000000005555555000000000000000000000000000000000000000000000000000000
63333333333333600005555555550000000555555555000000055555555500000005555555550000000000000000000000000000000000000000000000000000
__label__
60006660606066606000000066000060666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006000606060006000000006000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006600606066006000000006000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006000666060006000000006000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660060066606660000066606000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666666666600000000000000000
00000000000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000063333333333333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000aa1aa0000000000000000000000000063333336333333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000aaaaaa000000000000000000000000063333366633333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000a1aaaa000000000000000000000000063333666663333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000a11110000000000000000000000000063333366633333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000aaaaa0000000000000000000000000063333366633333600000000000000000
0000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000063333333333333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000aaaaa0000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000aaa00000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000063333333333333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666666666600000000000000000
000000000000000000000000000000000000000cccc0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000cc1cc000000000000000000000000000000000000000000000000000063333336333333600000000000000000
000000000000000000000000000000000000000cccccc00000000000000000000000000000000000000000000000000063333366633333600000000000000000
000000000000000000000000000000000000000c1cccc00000000000000000000000000000000000000000000000000063333666663333600000000000000000
000000000000000000000000000000000000000c1111000000000000000000000000000000000000000000000000000063333366633333600000000000000000
000000000000000000000000000000000000000ccccc000000000000000000000000000000000000000000000000000063333366633333600000000000000000
00000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
000000000000000000000000000000000000000ccccc000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000c0c0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
0000000000000000000000000000000000000000c0c0000000000000000000000000000000000000000000000000000063333333333333600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

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
0002000037610376103761037610376103761037610356002e600296001c600006001360006600006000b6000e60007600006000f6002e6002b60028600026002f600006002f6002e60019600206000060000600
000c000006040090400e04011040160401c04022040260402b0400a00009000060000300001000000001000011000180000100001000000000100000000000000000000000000000000000000000000000000000
00030000121501a15022150291502b150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00050000130501b050220503105010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002d05029050230500f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000805008050090500a0500b0500c0500e0500f05010050110501205015050180501e0502705030050370503a0503f0003f0003f0003f0003f0003f0003f0003f0003f0000000000000000000000000000
000a00000a05001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

