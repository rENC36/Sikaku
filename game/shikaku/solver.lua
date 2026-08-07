local Solver = {}

function Solver.Check(board, rectangles)
	if not board:IsFull() then
		return false
	end

	for _, rectangle in ipairs(rectangles) do
		local numbers = 0
		local number_value = nil

		for _, pos in ipairs(rectangle:GetCells()) do
			local cell = board:GetCell(pos.x, pos.y)
			if cell and cell:GetNumber() then
				numbers = numbers + 1
				number_value = cell:GetNumber()
			end
		end

		if numbers ~= 1 then
			return false
		end

		if rectangle:GetArea() ~= number_value then
			return false
		end
	end

	return true
end

return Solver
