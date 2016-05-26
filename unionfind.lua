-- All arrays are zero-based.


function table.shuffle(self)
	local j
	local t = self

	for i = #t, 1, -1 do
		j = math.random(0, i)
		t[i], t[j] = t[j], t[i]
	end
end


function unionfind(max)
	local u = { _parent = {}, _rank = {} }

	for i = 0, max-1 do
		u._parent[i] = i
		u._rank[i] = 0
	end

	u.find = function(self, i)
		local p = self._parent[i]
		if i == p then
			return i
		end
		self._parent[i] = self:find(p)
		return self._parent[i]
	end

	u.union = function(self, i, j)
		i = i or 0
		j = j or 0
		local root1 = self:find(i)
		local root2 = self:find(j)

		if root1 == root2 then
			return
		end

		if self._rank[root1] > self._rank[root2] then
			self._parent[root2] = root1
		elseif self._rank[root2] > self._rank[root1] then
			self._parent[root1] = root2
		else
			self._parent[root2] = root1
			self._rank[root1] = self._rank[root1] + 1
		end
	end

	return u
end

--local u = unionfind(5)
--print(dump(u))
--u:union(1,2)
--print(dump(u))
--u:union(1,2)
--print(dump(u))
--u:union(3,4)
--print(dump(u))
--u:union(1,0)
--print(dump(u))
--u:union(1,3)
--print(dump(u))
--u:union(4)
--print(dump(u))
