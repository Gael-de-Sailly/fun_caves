
fun_caves.fortress = function(node, data, area, minp, maxp, level)
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			ivm = area:index(x, minp.y, z)
			for y = minp.y, maxp.y do
				if x == minp.x or x == maxp.x or z == minp.z or z == maxp.z then
					data[ivm] = node('default:steelblock')
				elseif (y - minp.y) % 5 == 0 then
					data[ivm] = node('default:steelblock')
				else
					data[ivm] = node('air')
				end
				ivm = ivm + area.ystride
			end
		end
	end

	local n = 16
	local walls = {}

	for y2 = 0, n-1 do
		for i = 1, 2 * n * n do
			walls[i] = i
		end
		table.shuffle(walls)

		local set = unionfind(n * n)
		local a, b, c, i, j, u, v

		for m = 1, #walls do
			c = walls[m] - 1
			a = math.floor(c / 2)
			i = a % n
			j = math.floor(a / n)
			u = c % 2 == 0 and 1 or 0
			v = c % 2 == 1 and 1 or 0
			b = a + u + n * v
			if i < n - u and j < n - v and set:find(a+1) ~= set:find(b+1) then
				set:union(a+1, b+1)
				x = (i + u) * 5 + minp.x
				y = minp.y + y2 * 5
				z = (j + v) * 5 + minp.z
				if y > minp.y and math.random(20) == 1 then
					for z1 = z + 1, z + 4 do
						ivm = area:index(x+1, y, z1)
						for x1 = x + 1, x + 4 do
							data[ivm] = node("air")
							ivm = ivm + 1
						end
					end
				end

				for z1 = z, z + (1-v) * 5 do
					for y1 = y + 1, y + 4 do
						ivm = area:index(x, y1, z1)
						for x1 = x, x + (1-u) * 5 do
							data[ivm] = node("default:sandstone")
							ivm = ivm + 1
						end
					end
				end
			end
		end
	end

	--local n = 16
	--local walls = {}
	--for i = 1, 3 * n * n * n do
	--	walls[i] = i
	--end
	--table.shuffle(walls)

	--local set = unionfind(n * n * n)
	--local a, b, c, i, j, k, u, v, w

	--for m = 1, #walls do
	--	c = walls[m] - 1
	--	a = math.floor(c / 3)
	--	i = a % n
	--	j = math.floor(a / n) % n
	--	k = math.floor(math.floor(a / n) / n)
	--	u = c % 3 == 0 and 1 or 0
	--	v = c % 3 == 1 and 1 or 0
	--	w = c % 3 == 2 and 1 or 0
	--	b = a + u + n * (v + n * w)
	--	if i < n - u and j < n - v and k < n - w and set:find(a+1) ~= set:find(b+1) then
	--		set:union(a+1, b+1)
	--		x = (i + u) * 5 + minp.x
	--		y = (j + v) * 5 + minp.y
	--		z = (k + w) * 5 + minp.z
	--		for z1 = z, z + (1-w) * 5 do
	--			for y1 = y, y + (1-v) * 5 do
	--				ivm = area:index(x, y1, z1)
	--				for x1 = x, x + (1-u) * 5 do
	--					data[ivm] = node("default:steelblock")
	--					ivm = ivm + 1
	--				end
	--			end
	--		end
	--	end
	--end

	--local index = 0
	--local index3d = 0
	--for z = minp.z, maxp.z do
	--	for x = minp.x, maxp.x do
	--		index = index + 1
	--		--index3d = noise_area:index(x - minp.x, 0, z - minp.z)
	--		ivm = area:index(x, minp.y, z)
	--		for y = minp.y, maxp.y do
	--			if x == minp.x or x == maxp.x or z == minp.z or z == maxp.z or y == minp.y or y == maxp.y then
	--				data[ivm] = node("default:steelblock")
	--			elseif (y - minp.y) % 5 == 0 then
	--				data[ivm] = node("default:stone")
	--			else
	--				data[ivm] = node("air")
	--			end

	--			ivm = ivm + area.ystride
	--			--index3d = index3d + csize.x
	--		end
	--	end
	--end
end
