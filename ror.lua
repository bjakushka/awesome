-- bjakushka@07.08.14
-- Run Or Rise
-- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
local awful = require("awful")
local naughty = require("naughty")

function run_or_raise(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0

   -- iterate through spawned clients and try find same one
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end

   -- if matched clients could be found - rise first
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if #ctags == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end

   -- spawn new client if nothing was found
   awful.util.spawn(cmd, properties)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if type(v)=="table" then
	 local result = false
	 for _,vv in pairs(v) do
	    if table2[k] == vv or table2[k]:find(vv) then
	       result = true
	    end
	 end
	 return result
      else
	 if table2[k] ~= v and not table2[k]:find(v) then
	    return false
	 end
      end
   end

   return true
end
