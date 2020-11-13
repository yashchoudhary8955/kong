--- Node-level utilities
--
-- @module kong.node

local utils = require "kong.tools.utils"


local kong = kong
local CLUSTER_ID_CACHE_KEY = require("kong.constants").CLUSTER_ID_CACHE_KEY


local function fetch_cluster_id()
  local res, err = kong.db.parameters:select({ key = CLUSTER_ID_CACHE_KEY, })
  if err then
    return nil, err
  end

  if res then
    return res.value
  end

  local cluster_id = utils.uuid()

  res, err = kong.db:cluster_mutex(CLUSTER_ID_CACHE_KEY, nil, function()
    -- another worker might have already generated the cluster ID, double check
    -- in here before overwriting it

    res, err = kong.db.parameters:select({ key = CLUSTER_ID_CACHE_KEY, })
    if err then
      error(err)
    end

    if not res then
      assert(kong.db.parameters:insert({ key = CLUSTER_ID_CACHE_KEY,
                                         value = cluster_id, }))

    else
      cluster_id = res.value
    end
  end)
  if err then
    error(err)
  end

  return cluster_id
end


local function new(self)
  local _CLUSTER = {}


  ---
  -- Returns the unique id for this Hybrid mode cluster. If Kong
  -- is not running in Hybrid mode, then this method returns nil.
  --
  -- All Control Planes and Data Planes belonging to the same
  -- cluster returns the same cluster ID.
  --
  -- @function kong.cluster.get_id
  -- @treturn string The v4 UUID used by this cluster as its id
  -- @usage
  -- local id = kong.cluster.get_id()
  function _CLUSTER.get_id()
    if kong.configuration.role == "data_plane" then
      -- in DB-less mode, parameters are exported and sent to DP
      local res, err = kong.db.parameters:select({ key = CLUSTER_ID_CACHE_KEY, })
      if res then
        return res.value
      end

      return nil, err
    end

    return kong.core_cache:get(CLUSTER_ID_CACHE_KEY, nil, fetch_cluster_id)
  end


  return _CLUSTER
end


return {
  new = new,
}
