local outline = require('outline')

local M = {}

local function get_rename_params(node, winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local fn = 'file://' .. vim.api.nvim_buf_get_name(bufnr)

  return {
    textDocument = { uri = fn },
    position = { line = node.line, character = node.character },
    bufnr = bufnr,
  }
end

function M.rename()
  local current_line = vim.api.nvim_win_get_cursor(outline.view.winnr)[1]
  local node = outline.state.flattened_outline_items[current_line]

  local params = get_rename_params(node, outline.state.code_win)

  local new_name = vim.fn.input({ prompt = 'New Name: ', default = node.name })
  if not new_name or new_name == '' or new_name == node.name then
    return
  end

  params.newName = new_name

  vim.lsp.buf_request(params.bufnr, 'textDocument/rename', params, function(_, result, ctx)
    if result ~= nil then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
    end
  end)
end

return M
