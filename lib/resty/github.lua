-- Copyright (C) James Marlowe (jamesmarlowe), Lumate LLC.


local cjson = require "cjson"
local github_proxy_url = "/github/v3/"
local issue_url = "/repos/${owner}/${repo}/issues/${issue}"


-- a string replacement function
function macro_replace(s,tab)
    return (s:gsub('($%b{})', function(w)
        return r_args[w:sub(3, -2)] and tab[w:sub(3, -2)] or w
    end))
end


local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end


local _M = new_tab(0, 155)
_M._VERSION = '0.01'


local mt = { __index = _M }


function _M.new(self, access_token )
    local access_token  = access_token 
    if not access_token  then
        return nil, "must provide access_token "
    end
    return setmetatable({ access_token  = access_token  }, mt)
end


function _M.get_issues(self, state, issue)
    local access_token = self.access_token
    if not access_token then
        return nil, "not initialized"
    end
    
    local parameter_specification = {
                                     state = state,
                                     issue = issue
                                    }
    
    resp = ngx.location.capture(
              github_proxy_url,
            { method = ngx.HTTP_GET,
              body = cjson.encode(parameter_specification),
              args = {api_method=issue_url}}
    )
    
    if resp.status ~= 200 then
        return nil, "message failed"
    end
    
    return resp.body
end


function _M.new_issue(self, title, body)
    local access_token = self.access_token
    if not access_token then
        return nil, "not initialized"
    end
    
    if not title then
        return nil, "no title specified"
    end
    
    if not body then
        return nil, "no body specified"
    end
    
    local parameter_specification = {
                                     title = title
                                     body  = body
                                    }
    
    resp = ngx.location.capture(
              github_proxy_url,
            { method = ngx.HTTP_POST,
              body = cjson.encode(parameter_specification),
              args = {api_method=issue_url}}
    )
    
    if resp.status ~= 200 then
        return nil, "message failed"
    end
    
    return resp.body
end


return _M
