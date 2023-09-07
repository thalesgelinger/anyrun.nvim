print("hello anyrun")

local M = {}


local Cmds = {}

M.execute = function()
    local fullFilePath = vim.fn.expand("%")
    local fileName = vim.fn.fnamemodify(fullFilePath, ":t")
    local fileExtension = vim.fn.fnamemodify(fullFilePath, ":e")

    local current_win = vim.fn.win_getid()

    vim.cmd('rightbelow vnew')

    local new_win = vim.fn.win_getid()
    local bufnr = vim.fn.winbufnr(new_win)

    vim.fn.win_gotoid(current_win)

    local cmd = Cmds[fileExtension]
    table.insert(cmd, fullFilePath)

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("AnyRun", { clear = true }),
        pattern = "*." .. fileExtension,
        callback = function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "output of: " .. fileName })
            vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    if data then
                        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
                    end
                end,
                on_stderr = function(_, data)
                    if data then
                        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
                    end
                end
            })
        end
    })
end

M.setup = function(cmds)
    Cmds = cmds
end

return M
