local configdir = vim.fn.stdpath("config")
local fennel = _G.fennel

do
  -- local rtp = vim.api.nvim_get_option("runtimepath")
  -- local custompaths = {(configdir .. "/fnl"), (configdir .. "/lua")}
  -- local customrtp = table.concat(custompaths, ",")
  -- vim.api.nvim_set_option("runtimepath", (customrtp .. "," .. rtp))
end

do
  local fnldir = (configdir .. "/fnl")
  for _, dir in ipairs({"/?.fnl", "/?/init.fnl"}) do
    fennel["path"] = (fnldir .. dir .. ";" .. fennel.path)
    fennel["macro-path"] = (fnldir .. dir .. ";" .. fennel["macro-path"])
  end
end

fennel.install()

local cfg = require("j.nvim.core")
return cfg
