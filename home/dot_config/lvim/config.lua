-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable the display of listchars
vim.opt.list = true

-- Set the listchars options
vim.opt.listchars = {
   tab = ">-",       -- Display tabs with ">" and "-"
   trail = ".",      -- Display trailing whitespace with a dot
   extends = ">",    -- Display the "extends" character with ">"
   precedes = "<",   -- Display the "precedes" character with "<"
   space = ".",       -- Display spaces with a dot
   conceal = "┆"     -- Display concealed text with a special character
}

vim.opt.relativenumber = true
