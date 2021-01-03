-- Original Copyright (C) @sunjon 2020

local M = {}
M.__index = M

local genopts = function(wininfo)
  return {
    relative = 'editor',
    -- relative = 'win',
    -- win = winid,
    col = wininfo.wincol + wininfo.width - 2,
    row = wininfo.winrow - 1,
    width = 1,
    height = wininfo.height,
    anchor = "NW",
    focusable = false,
    style = "minimal",
  }
end

function M:create(winid)
  local obj = {}
  obj.wininfo = vim.fn.getwininfo(winid)[1]
  obj.winid   = winid

  obj.scrollbar = {}
  obj.scrollbar.bufid = vim.api.nvim_create_buf(false, true)
  obj.scrollbar.nsid = vim.api.nvim_create_namespace("")
  obj.scrollbar.visible = false -- todo: DONT NEED THAT AT ALL LOL

  obj.scrollbar.winid = vim.api.nvim_open_win(obj.scrollbar.bufid, false, genopts(obj.wininfo))
  vim.api.nvim_win_set_option(obj.scrollbar.winid, "winhl", "Normal:ScrollbarBlank")

  local content = {}
  for i = 1, obj.wininfo.height do
    content[i] = "▄"
  end

  vim.api.nvim_win_set_option(obj.scrollbar.winid, "winblend", 0)
  vim.api.nvim_buf_set_lines(obj.scrollbar.bufid, 0, 1, 0, content)

  setmetatable(obj, self)
  return obj
end

function M:update()
  local win = vim.fn.getwininfo(self.winid)[1] -- todo: not use viml here
  local buf_line_count = vim.api.nvim_buf_line_count(win.bufnr)

  local container_height = win.height * 2 - 1 -- scaled for each cell comprising of two half-blocks
  local bar_height = win.height / buf_line_count

  local ratio = container_height / buf_line_count
  local gripper_start = win.topline * ratio
  local gripper_end = gripper_start + bar_height

  if win.botline == buf_line_count then
    gripper_end = win.botline * ratio
    gripper_start = gripper_end - bar_height
  end

  -- color a full block of 50/50
  local hl_head, hl_tail
  if math.floor(gripper_start) % 2 == 0 then
    hl_head = "ScrollbarFilled"
    hl_tail = "ScrollbarFilled"
  else
    hl_head = "ScrollbarFilledHead"
    hl_tail = "ScrollbarFilledTail"
    gripper_end = gripper_end + 1
  end

  -- scale down
  gripper_start = math.floor(gripper_start / 2)
  gripper_end = math.floor(gripper_end / 2)

  -- draw the scrollbar components
  local bar = self.scrollbar
  vim.api.nvim_buf_clear_namespace(bar.bufid, bar.nsid, 0, -1)

  -- fill the head/tail cells of the scrollbar gripper
  vim.api.nvim_buf_add_highlight(bar.bufid, bar.nsid, hl_head, gripper_start, 1, -1)
  vim.api.nvim_buf_add_highlight(bar.bufid, bar.nsid, hl_tail, gripper_end, 1, -1)

  -- fill the center of the scrollbar gripper
  for i = gripper_start + 1, gripper_end - 1 do
    vim.api.nvim_buf_add_highlight(bar.bufid, bar.nsid, "ScrollbarFilled", i, 1, -1)
  end
end

function M:close()
  if vim.api.nvim_win_is_valid(self.scrollbar.winid) then
    vim.api.nvim_win_close(self.scrollbar.winid, 1)
  end
end

return M
