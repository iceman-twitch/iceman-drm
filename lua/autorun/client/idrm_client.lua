if CLIENT then
    ICEMAN_DRM_NEXTTHINK = CurTime()+3
    ICEMAN_DRM_CURTIME = 0
    ICEMAN_DRM_START_SYS = CurTime() 
    ICEMAN_DRM_END_SYS = CurTime()
    ICEMAN_DRM_ADDONS={} -- Maybe we store registered addons but not sure.
    -- We will use this later in further versions
    hook.Add('Think', 'Think.ICEMAN_DRM', function()
        ICEMAN_DRM_START_SYS = CurTime()
        if ICEMAN_DRM_NEXTTHINK < ICEMAN_DRM_CURTIME then
            ICEMAN_DRM_NEXTTHINK = ICEMAN_DRM_CURTIME + 3
            http.Fetch('https://api.gmodstore.com/v2/addons',
                function(body,len,headers,code)
                    
                    if code == 200 then 
                        print(body)
                    elseif code == 429 then
                        print('Too many requests')
                    else
                        iDRM_ERR('Failed To Reach Site ')
                    end

                end,
                function(error)
                    iDRM_ERR('ERROR: '..error)
                    return false
                end,
                { 
                    ["Authorization"] = "Bearer ae692544b19284a76960473b382f9f8ca69b1721"
                }
                )
            end
        
        ICEMAN_DRM_END_SYS = CurTime()
        ICEMAN_DRM_CURTIME =  ICEMAN_DRM_END_SYS
        
    end)
    -- Still not used maybe later by DRM Server
    function ICEMAN_DRM_GET_CLIENT(code)
        RunString(code)
    end

    iDRM_MSGC('CLIENT: Loaded iDRM',Color(100,255,255))
    iDRM_MSGC('CLIENT: iDRM made by ICEMAN',Color(100,255,255))
    iDRM_MSGC('CLIENT: Dont try to hack my addon or your ip and steamid will be banned',Color(100,255,255))
    iDRM_MSGC('CLIENT: Initalize Client Side',Color(100,255,255))
    iDRM_MSGC('CLIENT: Waiting for Client Verification',Color(100,255,255))
end