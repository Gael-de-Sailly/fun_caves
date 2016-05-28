-- invisible maze
-- hungry maze
-- chests (w traps)
-- step traps (math based)
-- hidden doors/downs
-- hot/ice floors

fun_caves.fortress = function(node, data, area, minp, maxp, level)
	local n = 16
	local walls = {}
	local floor = node('fun_caves:dungeon_floor_1')
	local outer_wall = node('fun_caves:dungeon_wall_2')
	local inner_wall = node('fun_caves:dungeon_wall_1')

	for y2 = 0, n-1 do
	--for y2 = 0, 0 do
		-- walls is zero-based.
		for i = 0, 2 * n * n - 1 do
			walls[i] = i
		end
		table.shuffle(walls)

		local dox, doz = math.random(0, n-1), math.random(0, n-1)
		for z = minp.z, maxp.z do
			for y = minp.y + y2 * 5, minp.y + y2 * 5 + 4 do
				local ivm = area:index(minp.x, y, z)
				for x = minp.x, maxp.x do
					if (y - minp.y) % 5 == 0 then
						if math.floor((z - minp.z) / 5) == doz and math.floor((x - minp.x) / 5) == dox and (z - minp.z) % 5 ~= 0 and (x - minp.x) % 5 ~= 0 and y ~= minp.y then
							data[ivm] = node("air")
						else
							data[ivm] = floor
						end
					elseif x == minp.x or z == minp.z or x == maxp.x or z == maxp.z then
						data[ivm] = outer_wall
					elseif (z - minp.z) % 5 == 0 or (x - minp.x) % 5 == 0 then
						data[ivm] = inner_wall
					else
						data[ivm] = node("air")
					end
					ivm = ivm + 1
				end
			end
		end

		local set = unionfind(n * n)

		for m = 0, #walls do
			local c = walls[m]
			local a = math.floor(c / 2)
			local i = a % n
			local j = math.floor(a / n)
			local u = c % 2 == 0 and 1 or 0
			local v = c % 2 == 1 and 1 or 0
			local b = a + u + n * v
			if i < n - u and j < n - v and set:find(a) ~= set:find(b) then
				set:union(a, b)
				local x = (i + u) * 5 + minp.x
				local y = minp.y + y2 * 5
				local z = (j + v) * 5 + minp.z
				--if y > minp.y and math.random(20) == 1 then
				--	for z1 = z + 1, z + 4 do
				--		ivm = area:index(x+1, y, z1)
				--		for x1 = x + 1, x + 4 do
				--			data[ivm] = node("air")
				--			ivm = ivm + 1
				--		end
				--	end
				--end

				for z1 = z + (1-v), z + (1-v) * 4 do
					for y1 = y + 1, y + 4 do
						local ivm = area:index(x + (1-u), y1, z1)
						for x1 = x + (1-u), x + (1-u) * 4 do
							if x1 < maxp.x and z1 < maxp.z and x1 > minp.x and z1 > minp.z then
								data[ivm] = node("air")
							end
							ivm = ivm + 1
						end
					end
				end
			end
		end
	end
end
