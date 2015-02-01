local consul = require "ficus.consul"
local user, pres, path = ngx.var[1], ngx.var[2], ngx.var[3]

local upstream, err = consul.getPresentationUpstream(user, pres)

if not upstream then
  ngx.var.consul_err = err
  return ngx.exec "@presentation-not-found"
end

if path == nil then
  path = "/"
end

ngx.req.set_uri(path)
ngx.var.upstream = upstream
