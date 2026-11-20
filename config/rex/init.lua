local function ssh_hosts()
  local items, seen = {}, {}
  for line in io.lines(os.getenv("HOME") .. "/.ssh/config") do
    local key, value = line:match("^%s*(%a+)[%s=]+([^#]*)")
    if key and key:lower() == "host" then
      local aliases, addresses = {}, {}
      for name in value:gmatch("%S+") do
        if name:match("^[%w:][%w._:%%-]*$") then
          local is_ip = name:find(":", 1, true) or name:match("^%d+%.%d+%.%d+%.%d+$")
          table.insert(is_ip and addresses or aliases, name)
        end
      end
      for _, name in ipairs(#aliases > 0 and aliases or addresses) do
        if not seen[name] then
          seen[name] = true
          local result, err = rex.exec{ "/usr/bin/ssh", "-G", name }
          if not result or not result.ok then
            error(err or result.stderr)
          end
          local address = ("\n" .. result.stdout):match("\nhostname ([^\r\n]+)")
          table.insert(items, { id = name, subtitle = address, icon = "server" })
        end
      end
    end
  end
  return items
end

rex.action{
  name = "ssh_connect",
  title = "SSH to host",
  run = function()
    local host, reason = rex.ui.pick{
      title = "SSH to host",
      placeholder = "Filter hosts",
      items = ssh_hosts(),
    }
    if not host then
      if reason ~= "cancelled" then rex.log("warn", "SSH picker: " .. reason) end
      return
    end

    assert(rex.session.new_window{
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { shell = "none", command = { "/usr/bin/ssh", host } },
      },
    })
  end,
}
