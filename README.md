Name
====

lua-resty-github - Lua library for using the github api

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [new](#new)
    * [get_issues](#get_issues)
    * [new_issue](#new_issue)
    * [safe_create_issue](#safe_create_issue)
* [Limitations](#limitations)
* [Installation](#installation)
* [TODO](#todo)
* [Author](#author)
* [Copyright and License](#copyright-and-license)
* [See Also](#see-also)

Status
======

This library is still under early development and considered experimental.

Description
===========

This Lua library is a github utility for the ngx_lua nginx module.

One potential use case for this is automatically filing issues for you when errors occur in your code base.

Synopsis
========

```
    lua_package_path "/path/to/lua-resty-github/lib/?.lua;;";
    
    server {
        location /test {
            content_by_lua '
                local github = require "resty.github"
                
                local gh, err = github:new("github_token")
                
                local issue_url, err = gh:safe_create_issue("github_owner", "github_repo", "issue_title", "issue_body")
                
                ngx.say("Issue created at: "..issue_url)
            ';
        }
        
        include .../lua-resty-github/conf/*.urls;
    }
```

[Back to TOC](#table-of-contents)

Methods
=======

All of the commands return either something that evaluates to true on success, or `nil` and an error message on failure.

new
---
`syntax: gh, err = github:new("github_token")`

Creates an github auth object. In case of failures, returns `nil` and a string describing the error. You can create a token at https://github.com/settings/tokens/new

[Back to TOC](#table-of-contents)

get_issues
----------
`syntax: issues, err = gh:get_issues(owner, repo, state, issue)`

`syntax: issues, err = gh:get_issues("jamesmarlowe", "lua-resty-github", "open")`

Gets issues for the specified repository. In case of failures, returns `nil` and a string describing the error.

[Back to TOC](#table-of-contents)

new_issue
---------
`syntax: issue, err = gh:new_issue(owner, repo, title, body)`

`syntax: issue, err = gh:new_issue("jamesmarlowe", "lua-resty-github", "test-issue", "issue body")`

Creates and returns an issue in the specified repository. In case of failures, returns `nil` and a string describing the error.

[Back to TOC](#table-of-contents)

safe_create_issue
-----------------
`syntax: issue, err = gh:safe_create_issue(owner, repo, title, body)`

`syntax: issue, err = gh:safe_create_issue("jamesmarlowe", "lua-resty-github", "test-issue", "issue body")`

Finds or creates and returns an issue in the specified repository. In case of failures, returns `nil` and a string describing the error.

[Back to TOC](#table-of-contents)

Limitations
===========

* Only handles issues right now
* Can't handle 2 factor auth

[Back to TOC](#table-of-contents)

Installation
============

If you are using your own nginx + ngx_lua build, then you need to configure the lua_package_path directive to add the path of your lua-resty-github source tree to ngx_lua's LUA_PATH search path, and include the urls, as in

```nginx
    # nginx.conf
    http {
    
        lua_package_path "/path/to/lua-resty-github/lib/?.lua;;";
        
        ...
        
        server {
        
            include .../lua-resty-github/conf/*.urls;
            
        }
    }
```

Ensure that the system account running your Nginx ''worker'' proceses have
enough permission to read the `.lua` file.

Docker
------
I've also made a docker image to make setup of the nginx environment easier. View details here: https://registry.hub.docker.com/u/jamesmarlowe/lua-resty-github/
```
# install docker according to http://docs.docker.com/installation/

# pull image
sudo docker pull jamesmarlowe/lua-resty-github

# make sure it is there
sudo docker images

# run the image
sudo docker run -t -i jamesmarlowe/lua-resty-github
```

[Back to TOC](#table-of-contents)

TODO
====

* Add support for the rest of the api https://developer.github.com/v3/
* Handle 2 factor auth

[Back to TOC](#table-of-contents)

Author
======

James Marlowe "jamesmarlowe" <jameskmarlowe@gmail.com>, Lumate LLC.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2012-2014, by James Marlowe (jamesmarlowe) <jameskmarlowe@gmail.com>, Lumate LLC.

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

See Also
========
* the ngx_lua module: http://wiki.nginx.org/HttpLuaModule
* the [lua-resty-hipchat](https://github.com/jamesmarlowe/lua-resty-hipchat) library

[Back to TOC](#table-of-contents)
