-- Better Comments (VS Code style): color a comment by the tag right after its leader.
--   # * highlighted     -> green
--   # ? question        -> blue
--   # ! alert           -> red
--   # todo: something   -> orange
-- Override colors with the BetterComment* highlight groups.

local M = {}

local ns = vim.api.nvim_create_namespace("better_comments")

-- Order matters: first matching pattern wins. Patterns run against the text after the leader.
local tags = {
  { pattern = "^%s*!", hl = "BetterCommentAlert", fg = "#FF2D00" },
  { pattern = "^%s*%?", hl = "BetterCommentQuery", fg = "#3498DB" },
  { pattern = "^%s*%*", hl = "BetterCommentHighlight", fg = "#98C379" },
  { pattern = "^%s*[Tt][Oo][Dd][Oo]%f[^%w]", hl = "BetterCommentTodo", fg = "#FF8C00" },
}

local function set_hl()
  for _, tag in ipairs(tags) do
    vim.api.nvim_set_hl(0, tag.hl, { fg = tag.fg, default = true })
  end
end

-- Comment leaders for a buffer: the 'commentstring' leader, plus line-comment
-- leaders from 'comments' (e.g. "//" in C where commentstring is "/* %s */").
local cache = {}
local function leaders(buf)
  local cs, com = vim.bo[buf].commentstring, vim.bo[buf].comments
  local key = cs .. "\0" .. com
  if cache[buf] and cache[buf].key == key then
    return cache[buf].list
  end
  local list, seen = {}, {}
  local function add(leader, primary)
    leader = vim.trim(leader)
    if leader ~= "" and not seen[leader] then
      seen[leader] = true
      table.insert(list, { text = leader, primary = primary })
    end
  end
  add(cs:match("^(.-)%%s") or "", true)
  for part in com:gmatch("[^,]+") do
    local flags, leader = part:match("^([^:]*):(.+)$")
    if flags and not flags:find("[sme]") then
      add(leader, false)
    end
  end
  table.sort(list, function(a, b)
    return #a.text > #b.text
  end)
  cache[buf] = { key = key, list = list }
  return list
end

local function is_ts_comment(buf, row, col)
  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, buf, row, col)
  if not ok then
    return nil
  end
  for _, c in ipairs(captures) do
    if c.capture:find("comment") then
      return true
    end
  end
  return false
end

local function highlight_line(buf, row)
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  if not line or #line == 0 then
    return
  end
  local has_ts = vim.treesitter.highlighter.active[buf] ~= nil
  for _, leader in ipairs(leaders(buf)) do
    local init = 1
    while true do
      local s, e = line:find(leader.text, init, true)
      if not s then
        break
      end
      local rest = line:sub(e + 1)
      for _, tag in ipairs(tags) do
        if rest:find(tag.pattern) then
          -- Without treesitter only trust the primary leader at the start of the line.
          local ok
          if has_ts then
            ok = is_ts_comment(buf, row, s - 1)
          else
            ok = leader.primary and line:sub(1, s - 1):match("^%s*$") ~= nil
          end
          if ok then
            vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, {
              end_col = #line,
              hl_group = tag.hl,
              priority = 200, -- above treesitter (100) and semantic tokens (125)
              ephemeral = true,
            })
            return
          end
          break
        end
      end
      init = e + 1
    end
  end
end

function M.setup()
  set_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("better_comments", { clear = true }),
    callback = set_hl,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = "better_comments",
    callback = function(ev)
      cache[ev.buf] = nil
    end,
  })
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
      return vim.bo[buf].buftype == ""
    end,
    on_line = function(_, _, buf, row)
      highlight_line(buf, row)
    end,
  })
end

return M
