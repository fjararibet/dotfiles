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

    rex.session.new_window{
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { shell = "none", command = { "/usr/bin/ssh", host } },
      },
    }
  end,
}

local projects_path = os.getenv("HOME") .. "/projects"

local function projects()
  local result, err = rex.exec{
    "/usr/bin/find", "-L", projects_path,
    "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-print0",
  }
  if not result or not result.ok then
    error(err or result.stderr)
  end

  local items = {}
  for path in result.stdout:gmatch("([^%z]+)%z") do
    local name = path:sub(#projects_path + 2)
    table.insert(items, { id = name, icon = "folder" })
  end
  return items
end

rex.action{
  name = "open_project",
  title = "Open Project",
  run = function()
    local project, reason = rex.ui.pick{
      title = "Open Project",
      placeholder = "Filter Projects",
      items = projects(),
    }
    if not project then
      if reason ~= "cancelled" then rex.log("warn", "Project picker: " .. reason) end
      return
    end

    local result, err = rex.call("session.list")
    for _, session in ipairs(result.sessions or {}) do
      if session.label == project then
        rex.client.queue("session.select", { session_id = session.session_id })
        return
      end
    end

    local session, create_err = rex.call("session.create", {
      label = project,
      initial_windows = {
        {
          layout = rex.layout.block{
            flavor = "com.superlogical.terminal.shell",
            options = { cwd = projects_path .. "/" .. project },
          },
        },
      },
    })
    rex.client.queue("session.select", { session_id = session.session_id })
  end,
}
