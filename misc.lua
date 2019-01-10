function Vec2(x, y)
	return {x=x, y=y}
end

function inTable(table, item)
	for i=1, #table do
		if table[i] == item then
			return true
		end
	end
	return false
end
