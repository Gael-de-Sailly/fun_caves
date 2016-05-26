function table.shuffle(self)
	local j
	local t = self

	for i = #t, 2, -1 do
		j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end


function unionfind(max)
	local u = { _parent = {}, _rank = {} }

	for i = 1, max do
		u._parent[i] = i
		u._rank[i] = 1
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
