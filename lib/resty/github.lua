-- Copyright (C) James Marlowe (jamesmarlowe), Lumate LLC.


local cjson = require "cjson"
local github_proxy_url = "/github/v3/"
local issue_url = "/repos/${owner}/${repo}/issues${issue}"


-- obtain a copy of enc() here: http://lua-users.org/wiki/BaseSixtyFour
function enc(data)
    -- character table string
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do
            r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0')
        end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do
            c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0)
        end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end


-- a string replacement function
function macro_replace(s,tab)
    return (s:gsub('($%b{})', function(w)
        return tab[w:sub(3, -2)] or w
    end))
end


local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end


local _M = new_tab(0, 155)
_M._VERSION = '0.01'


local valid_state_values = {
    open = "open", closed = "closed", all = "all"
}


local mt = { __index = _M }


function _M.new(self, access_token )
    local access_token  = access_token 
    if not access_token  then
        return nil, "must provide access_token "
    end
    return setmetatable({ access_token  = access_token  }, mt)
end


function _M.get_issues(self, owner, repo, state, issue)
    local access_token = self.access_token
    if not access_token then
        return nil, "not initialized"
    end
    
    if not owner then
        return nil, "no owner"
    end
    
    if not repo then
        return nil, "no repo"
    end
    
    local state = state and 
                  valid_state_values[state]
                  or "open"
    
    local parameter_specification = {
                                     state = state
                                    }
                                    
    local repo_specification = {
                                owner = owner,
                                repo = repo,
                                issue = issue and "/"..issue or ""
                               }
    
    resp = ngx.location.capture(
              github_proxy_url,
            { method = ngx.HTTP_GET,
              body = cjson.encode(parameter_specification),
              args = {api_method = macro_replace(issue_url,repo_specification),
                      authorization = "token "..access_token}}
    )
    
    if resp.status ~= 200 then
        return nil, resp.status.." : "..resp.body
    end
    
    return cjson.decode(resp.body)
end


function _M.new_issue(self, owner, repo, title, body)
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
                                     title = title,
                                     body  = body
                                    }
                                    
    local repo_specification = {
                                owner = owner,
                                repo = repo,
                                issue = ""
                               }
    
    resp = ngx.location.capture(
              github_proxy_url,
            { method = ngx.HTTP_POST,
              body = cjson.encode(parameter_specification),
              args = {api_method = macro_replace(issue_url,repo_specification),
                      authorization = "token "..access_token}}
    )
    
    if resp.status ~= 201 then
        return nil, resp.status.." : "..resp.body
    end
    
    return cjson.decode(resp.body)
end


function _M.safe_create_issue(self, owner, repo, title, body)
    local issues = self:get_issues(owner, repo)
    
    for k, v in ipairs(issues) do
        if title == v.title then 
            return v.html_url
        end
    end
    
    issue, err = self:new_issue(owner, repo, title, body)
    if err then return nil, err else return issue.html_url end
    
end


return _M
