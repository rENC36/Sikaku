local BoardView = {}
BoardView.__index = BoardView

local PALETTE = {
	valid = vmath.vector4(91 / 255, 217 / 255, 139 / 255, 1),
	invalid = vmath.vector4(245 / 255, 95 / 255, 95 / 255, 1),

	badge_text = vmath.vector4(1, 1, 1, 1),
}

-- Насыщенность preview-заливки.
-- Если хочешь ещё ярче — поставь 0.8 или 0.9.
local PREVIEW_FILL_ALPHA = 0.7

-- Насыщенность уже поставленных областей.
local PLACED_FILL_ALPHA = 1

function BoardView.new(factory_url, settings, options)
	options = options or {}

	local self = setmetatable({}, BoardView)

	self.factory_url = factory_url

	self.badge_factory_url = options.badge_factory_url or factory_url
	self.preview_factory_url = options.preview_factory_url or factory_url
	self.overlay_factory_url = options.overlay_factory_url or self.preview_factory_url or factory_url
	self.board_bg_factory_url = options.board_bg_factory_url or nil

	self.settings = settings or {}
	self.settings.cell_size = self.settings.cell_size or 64
	self.settings.spacing = self.settings.spacing or 0
	self.settings.start_position = self.settings.start_position or vmath.vector3(0, 0, 0)

	self.badge_base_size = options.badge_base_size or self.settings.cell_size

	self.cells = {}
	self.board_width = 0
	self.board_height = 0
	self.bg_map = {}

	self.preview_bg_id = nil
	self.preview_badge_id = nil
	self.board_bg_id = nil

	return self
end

function BoardView:Create(board)
	self.board_width = board.width
	self.board_height = board.height

	local cell_size = self.settings.cell_size
	local spacing = self.settings.spacing
	local step = cell_size + spacing

	local total_w = board.width * step - spacing
	local total_h = board.height * step - spacing

	local ww, wh = window.get_size()
	local max_w = ww * 0.85
	local max_h = wh * 0.75

	if total_w > max_w or total_h > max_h then
		local scale = math.min(max_w / total_w, max_h / total_h)

		cell_size = cell_size * scale
		spacing = spacing * scale
		step = cell_size + spacing

		total_w = board.width * step - spacing
		total_h = board.height * step - spacing
	end

	self.effective_cell_size = cell_size
	self.effective_spacing = spacing
	self.effective_step = step

	self.board_start_x = self.settings.start_position.x - total_w / 2
	self.board_start_y = self.settings.start_position.y + total_h / 2

	self:CreateBoardBackground(board)

	local base_size = self.settings.cell_size
	local scale_factor = cell_size / base_size

	for y = 1, board.height do
		self.cells[y] = {}

		for x = 1, board.width do
			local cell_data = board:GetCell(x, y)

			local pos_x = self.board_start_x + (x - 1) * step + cell_size / 2
			local pos_y = self.board_start_y - (y - 1) * step - cell_size / 2

			local position = vmath.vector3(pos_x, pos_y, 0)

			local id = factory.create(self.factory_url, position)

			if not id then
				print("[BoardView] WARNING: failed to create cell at", x, y, "- sprite buffer full?")
			else
				go.set_scale(vmath.vector3(scale_factor, scale_factor, 1), id)

				self.cells[y][x] = {
					id = id,
					x = x,
					y = y,
					data = cell_data
				}

				msg.post(id, "set_data", {
					x = x,
					y = y,
					number = cell_data and cell_data.number or nil
				})
			end
		end
	end
end

function BoardView:GetCell(x, y)
	if self.cells[y] then
		return self.cells[y][x]
	end

	return nil
end

function BoardView:UpdatePreviewBg(rectangle, color, info)
	if not rectangle then
		self:ClearPreviewBg()
		return
	end

	info = info or {
		area = rectangle:GetArea(),
		valid = true
	}

	local cx, cy, outer_w, outer_h = self:GetPreviewBounds(rectangle)
	local valid = info.valid ~= false

	local fill_color = valid
	and vmath.vector4(PALETTE.valid.x, PALETTE.valid.y, PALETTE.valid.z, PREVIEW_FILL_ALPHA)
	or vmath.vector4(PALETTE.invalid.x, PALETTE.invalid.y, PALETTE.invalid.z, PREVIEW_FILL_ALPHA)

	local preview_pos = vmath.vector3(cx, cy, 0.08)

	if not self.preview_bg_id then
		self.preview_bg_id = factory.create(
		self.overlay_factory_url or self.preview_factory_url or self.factory_url,
		preview_pos
	)

	if self.preview_bg_id then
		go.set_scale(vmath.vector3(1, 1, 1), self.preview_bg_id)
	end
end

if self.preview_bg_id then
	go.set_position(preview_pos, self.preview_bg_id)
	go.set_scale(vmath.vector3(1, 1, 1), self.preview_bg_id)

	-- 9-slice размер
	go.set(msg.url(nil, self.preview_bg_id, "sprite"), "size", vmath.vector3(outer_w, outer_h, 1))

	-- Цвет preview-заливки
	go.set(msg.url(nil, self.preview_bg_id, "sprite"), "tint", fill_color)
end

-- Badge
local badge_size = math.max(24, math.min(38, self.effective_cell_size * 0.85))

local badge_base_size = self.badge_base_size or self.settings.cell_size or 64
local badge_scale = vmath.vector3(badge_size / badge_base_size, badge_size / badge_base_size, 1)

local badge_pos = vmath.vector3(
cx + outer_w / 2,
cy + outer_h / 2,
0.3
)

if not self.preview_badge_id then
self.preview_badge_id = factory.create(
self.badge_factory_url or self.factory_url,
badge_pos
)
end

if self.preview_badge_id then
go.set_position(badge_pos, self.preview_badge_id)
go.set_scale(badge_scale, self.preview_badge_id)

local badge_label_url = msg.url(nil, self.preview_badge_id, "label")

local badge_text = tostring(info.area or 0)

-- Крестик показываем только если есть overlap
if not valid and (info.reason == "overlap" or info.overlapping) then
badge_text = "x"
end

label.set_text(badge_label_url, badge_text)

local badge_color = valid
and vmath.vector4(0.08, 0.95, 0.35, 1)
or vmath.vector4(1.0, 0.12, 0.12, 1)

go.set(msg.url(nil, self.preview_badge_id, "sprite"), "tint", badge_color)
end
end

function BoardView:Clear()
if self.board_bg_id then
go.delete(self.board_bg_id)
self.board_bg_id = nil
end

for y, row in pairs(self.cells) do
for x, cell in pairs(row) do
if cell and cell.id then
	go.delete(cell.id)
end
end
end

self.cells = {}

for rect, id in pairs(self.bg_map) do
go.delete(id)
end

self.bg_map = {}

self:ClearPreviewBg()

self.effective_cell_size = nil
self.effective_spacing = nil
self.effective_step = nil
self.board_start_x = nil
self.board_start_y = nil

self.board_width = 0
self.board_height = 0
end

function BoardView:SetCellColor(x, y, color)
local cell = self:GetCell(x, y)

if not cell then
return
end

msg.post(cell.id, "set_color", {
color = color
})
end

function BoardView:GetCellFromPosition(px, py)
if not self.effective_step or not self.effective_cell_size then
return nil
end

local start_x = self.board_start_x
local start_y = self.board_start_y

local step = self.effective_step
local spacing = self.effective_spacing
local cell_size = self.effective_cell_size

local total_w = self.board_width * step - spacing
local total_h = self.board_height * step - spacing

local rel_x = px - start_x
local rel_y = start_y - py

if rel_x < 0 or rel_y < 0 then
return nil
end

if rel_x >= total_w or rel_y >= total_h then
return nil
end

local x = math.floor(rel_x / step) + 1
local y = math.floor(rel_y / step) + 1

if x < 1 or y < 1 or x > self.board_width or y > self.board_height then
return nil
end

local cell_left = start_x + (x - 1) * step
local cell_right = cell_left + cell_size

local cell_top = start_y - (y - 1) * step
local cell_bottom = cell_top - cell_size

if px < cell_left or px > cell_right then
return nil
end

if py < cell_bottom or py > cell_top then
return nil
end

return self:GetCell(x, y)
end

function BoardView:GetPreviewBounds(rectangle)
	local step = self.effective_step
	local spacing = self.effective_spacing

	local outer_w = rectangle.width * step - spacing
	local outer_h = rectangle.height * step - spacing

	local cx = self.board_start_x + (rectangle.x - 1) * step + outer_w / 2
	local cy = self.board_start_y - (rectangle.y - 1) * step - outer_h / 2

	return cx, cy, outer_w, outer_h
end

function BoardView:ClearPreviewBg()
if self.preview_bg_id then
go.delete(self.preview_bg_id)
self.preview_bg_id = nil
end

if self.preview_badge_id then
go.delete(self.preview_badge_id)
self.preview_badge_id = nil
end
end

function BoardView:CreateBoardBackground(board)
if self.board_bg_id then
go.delete(self.board_bg_id)
self.board_bg_id = nil
end

if not self.board_bg_factory_url then
return
end

local step = self.effective_step
local spacing = self.effective_spacing
local cell_size = self.effective_cell_size

local total_w = board.width * step - spacing
local total_h = board.height * step - spacing

local padding = cell_size * 1.1

local panel_w = total_w + padding * 2
local panel_h = total_h + padding * 2

local base_size = 1024

local pos = vmath.vector3(
self.settings.start_position.x,
self.settings.start_position.y,
-0.5
)

self.board_bg_id = factory.create(self.board_bg_factory_url, pos)

if self.board_bg_id then
go.set_position(pos, self.board_bg_id)

go.set_scale(
vmath.vector3(panel_w / base_size, panel_h / base_size, 1),
self.board_bg_id
)
end
end

function BoardView:CreateRectangleBg(rectangle, color)
if not rectangle then
return
end

color = color or vmath.vector4(1, 1, 1, 1)

local cx, cy, outer_w, outer_h = self:GetPreviewBounds(rectangle)

-- Готовые области тоже поверх клеток, но чуть ниже preview.
local pos = vmath.vector3(cx, cy, 0.06)

local preview_factory_url = self.overlay_factory_url or self.preview_factory_url or self.factory_url
local id = factory.create(preview_factory_url, pos)

if not id then
return
end

go.set_scale(vmath.vector3(1, 1, 1), id)

local bg_color = vmath.vector4(color.x, color.y, color.z, PLACED_FILL_ALPHA)

go.set_position(pos, id)

-- 9-slice размер
go.set(msg.url(nil, id, "sprite"), "size", vmath.vector3(outer_w, outer_h, 1))

-- Цвет уже поставленной области
go.set(msg.url(nil, id, "sprite"), "tint", bg_color)

self.bg_map[rectangle] = id
end

function BoardView:RemoveRectangleBg(rectangle)
local id = self.bg_map[rectangle]

if not id then
return
end

self.bg_map[rectangle] = nil

go.animate(
id,
"scale",
go.PLAYBACK_ONCE_FORWARD,
vmath.vector3(0.01, 0.01, 1),
go.EASING_INBACK,
0.2,
0,
function()
go.delete(id)
end
)
end

return BoardView