if SERVER then
    do
        file.CreateDir("idrm") -- We need an idrm folder inside data/
        ICEMAN_DRM_FETCH = http.Fetch
        ICEMAN_DRM_URL = 'http://localhost/'
        ICEMAN_DRM_INIT_BOOL = false  
        ICEMAN_DRM = ICEMAN_DRM or {}
        ICEMAN_DRM_NEXTTHINK = CurTime()+3
        ICEMAN_DRM_CURTIME = 0
        ICEMAN_DRM_START_SYS = CurTime()
        ICEMAN_DRM_END_SYS = CurTime()
        ICEMAN_DRM_ADDONS={} -- where we store our addons registration data and keys.
        -- WE need to register each addon but DRM server will check if your addon is exist or available.
        function ICEMAN_DRM_ADDON_REGISTER(id)
            if ICEMAN_DRM_ADDONS then ICEMAN_DRM_ADDONS[id]=ICEMAN_DRM_ADDONS[id] or {key='',auth=0} end
        end
        -- Its time to initialize DRM
        ICEMAN_DRM_INIT = function()
            if ICEMAN_DRM_INIT_BOOL then return end
            iDRM_MSGC('SERVER: Loaded iDRM',Color(100,255,0))
            iDRM_MSGC('SERVER: iDRM made by ICEMAN',Color(100,255,0))
            iDRM_MSGC('SERVER: Dont try to hack my addon or your ip and steamid will be banned',Color(100,255,0))
            iDRM_MSGC("SERVER: Initialize DRM",Color(100,255,0))
            iDRM_MSGC("SERVER: Loading CFG",Color(100,255,0))
            iDRM_MSGC("SERVER: Loading Addons",Color(100,255,0))
            iDRM_MSGC("SERVER: Verifying Addons",Color(100,255,0))

            ICEMAN_DRM_INIT_BOOL=true
        end
        local bool = true
        -- We need BroadcastLua because it is a more easier way to pass codes.
        function ICEMAN_DRM_CALL_CLIENT(code)
            BroadcastLua( code )
        end
        -- We need a steamid to detect who bought each addon.
        function ICEMAN_DRM_STEAMID()
            steamid=''
            for k, v in pairs(player.GetAll()) do
                if v and v:IsValid() and !v:IsBot() then
                    steamid = v:SteamID()
                    steamid = string.Split( steamid, ":" )
                    steamid=steamid[3]
                    break
                end
            end
            return steamid
        end
        -- Currently not used but useful.
        function ICEMAN_DRM_STEAMID64()
            steamid=''
            for k, v in pairs(player.GetAll()) do
                if v and v:IsValid() and !v:IsBot() then
                    steamid = v:SteamID64()
                    break
                end
            end
            return steamid
        end
        -- Its time to load the Server Side or just pass it to the Clients.
        -- Not really used in DRM Server
        function ICEMAN_DRM_CODE(code,id) 
            RunString(code)
            ICEMAN_DRM_ADDONS[id]['auth']=3
        end
        -- Where we write the file.
        function ICEMAN_DRM_WRITE_FILE(name,data) 
            file.Write(name,data)
        end
        -- We need to check if we already have a key file and read it.
        function ICEMAN_DRM_CHECK_FILE(id)
            if file.Exists('idrm/'..id..'.txt', 'DATA') then
                
                f = file.Open( 'idrm/'..id.. ".txt", "r", "DATA" )
                key = f:ReadLine()
                f:Close()
                ICEMAN_DRM_ADDONS[id]['key']=key
                return true
            else return false
            end
            return false
        end
        --Registration required to create key file in data/idrm folder.
        function ICEMAN_REGISTER_ADDON(id, key)
            ICEMAN_DRM_WRITE_FILE(id,key)

        end
        -- Ping DRM Site with Addon ID
        function ICEMAN_DRM_PING_SITE(url,id)
            -- We need GET method only
            ICEMAN_DRM_FETCH(url,
            function(body,len,headers,code)
                
                if code == 200 then 
                    RunString(body) -- Its time to do what DRM server requests
                else
                    iDRM_ERR('Failed To Reach Site ADDON['.. id ..']')
                end 

            end,
            function(error)
                iDRM_ERR('ERROR ADDON['.. id ..']: '..error)
                return false
            end
            )
            if runthing!=nil then
                
            else
            end
        end
        -- Ping the DRM server and do the verification job
        function ICEMAN_DRM_PING()
            -- we verify each addon.
            for k, v in pairs(ICEMAN_DRM_ADDONS) do 
                if ICEMAN_DRM_ADDONS[k]['auth']==0 then
                    iDRM_MSGC('[ADDON]: '..k,Color(255,100,255))
                    iDRM_MSG('Pinging Site: ' .. ICEMAN_DRM_URL .. '?id='.. k ..'&auth=0')
                    ICEMAN_DRM_PING_SITE(ICEMAN_DRM_URL .. '?id='.. k ..'&auth=0',k)
                elseif ICEMAN_DRM_ADDONS[k]['auth']==1 then
                    iDRM_MSGC('[ADDON]: '..k,Color(255,100,255))
                    iDRM_MSG('Pinging Site: ' .. ICEMAN_DRM_URL .. '?id='.. k ..'&auth=1&key='..ICEMAN_DRM_ADDONS[k]['key'])
                    ICEMAN_DRM_PING_SITE(ICEMAN_DRM_URL .. '?id='.. k ..'&auth=1&key='..ICEMAN_DRM_ADDONS[k]['key'],k)
                elseif ICEMAN_DRM_ADDONS[k]['auth']==2 then
                    iDRM_MSGC('[ADDON]: '..k,Color(255,100,255))
                    iDRM_MSG('Pinging Site: ' .. ICEMAN_DRM_URL .. '?id='.. k ..'&auth=2&steamid='..ICEMAN_DRM_STEAMID())
                    ICEMAN_DRM_PING_SITE(ICEMAN_DRM_URL .. '?id='.. k ..'&auth=2&steamid='..ICEMAN_DRM_STEAMID()..'&steamid64='..ICEMAN_DRM_STEAMID64(),k)
                elseif ICEMAN_DRM_ADDONS[k]['auth']==3 then
                    ICEMAN_DRM_PING_SITE(ICEMAN_DRM_URL .. '?id='.. k ..'&auth=3&key='..ICEMAN_DRM_ADDONS[k]['key'],k)
                else
                end 
            end 
        end
        -- We need to call this every 5 seconds.
        hook.Add('Think', 'Think.ICEMAN_DRM', function()
            ICEMAN_DRM_INIT()
            ICEMAN_DRM_START_SYS = CurTime()
            if ICEMAN_DRM_NEXTTHINK < ICEMAN_DRM_CURTIME then
                ICEMAN_DRM_NEXTTHINK = ICEMAN_DRM_CURTIME + 3
                -- Its Time to ping the DRM server
                ICEMAN_DRM_PING()
            end
            ICEMAN_DRM_END_SYS = CurTime()
            ICEMAN_DRM_CURTIME =  ICEMAN_DRM_END_SYS
        end)
end