if SERVER then
    do
        iDRM_MSG = function(text)
            MsgC( Color(255,255,0), '[iDRM]: '..text .. '\n' )
        end
        iDRM_MSGC = function(text,color)
            MsgC( color, '[iDRM]: '..text .. '\n' )
        end
        iDRM_ERR = function(text)
            MsgC( Color(255,100,10), '[iDRM-ERROR]: '..text .. '\n' )
        end
        file.CreateDir("idrm") /* We need an idrm folder inside data/ */
        ICEMAN_DRM_FETCH = http.Fetch
        ICEMAN_DRM_URL = 'http://localhost/' 
        ICEMAN_DRM_INIT_BOOL = false  
        ICEMAN_DRM = ICEMAN_DRM or {}
        ICEMAN_DRM_NEXTTHINK = CurTime()+3
        ICEMAN_DRM_CURTIME = 0
        ICEMAN_DRM_START_SYS = CurTime()
        ICEMAN_DRM_END_SYS = CurTime() 
        ICEMAN_DRM_ADDONS={} /* where we store our addons registration data and keys. */
        /* WE need to register each addon but DRM server will check if your addon is exist or available. */
        function ICEMAN_DRM_ADDON_REGISTER(id)
            ICEMAN_DRM_ADDONS[id]=ICEMAN_DRM_ADDONS[id] or {key='',id=id,url='?id='.. id ..'&auth=0',auth=0}
        end
        /* Its time to initialize DRM */
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
        /* We need BroadcastLua because it is a more easier way to pass codes. */
        function ICEMAN_DRM_CALL_CLIENT(code)
            BroadcastLua( code )
        end
        /* We need a steamid to detect who bought each addon. */
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
        /* Currently not used but useful. */ 
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
        /* Its time to load the Server Side or just pass it to the Clients. */
        /* Not really used in DRM Server */
        function ICEMAN_DRM_CODE(code,id) 
            RunString(code)
            ICEMAN_DRM_ADDONS[id]['auth']=3
        end
        /*  Where we write the file. */
        function ICEMAN_DRM_WRITE_FILE(name,data) 
            file.Write(name,data)
        end
        /* We need to check if we already have a key file and read it. */
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
        /* Registration required to create key file in data/idrm folder. */
        function ICEMAN_REGISTER_ADDON(id, key)
            ICEMAN_DRM_WRITE_FILE(id,key)

        end
        /* Ping DRM Site with Addon ID */
        function ICEMAN_DRM_PING_SITE(url,id)
            /* We need GET method only */
            ICEMAN_DRM_FETCH(url,
            function(body,len,headers,code)
                
                if code == 200 then 
                    RunString(body) /* Its time to do what DRM server requests */
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
        /* Ping the DRM server and do the verification job */
        function ICEMAN_DRM_PING()
            /* we verify each addon. */
            for k, v in pairs(ICEMAN_DRM_ADDONS) do 
                if ICEMAN_DRM_ADDONS[k]['auth']!=nil then
                    local url = ICEMAN_DRM_ADDONS[k]['url'] or nil
                    ICEMAN_DRM_PING_SITE(ICEMAN_DRM_URL .. ICEMAN_DRM_ADDONS[k]['url'],k)
                else
                end 
            end 
        end
        /* We need to call this every 5 seconds. */
        hook.Add('Think', 'Think.ICEMAN_DRM', function()
            ICEMAN_DRM_INIT()
            ICEMAN_DRM_START_SYS = CurTime()
            if ICEMAN_DRM_NEXTTHINK < ICEMAN_DRM_CURTIME then
                ICEMAN_DRM_NEXTTHINK = ICEMAN_DRM_CURTIME + 3
                /* Its Time to ping the DRM server */
                ICEMAN_DRM_PING()
            end
            ICEMAN_DRM_END_SYS = CurTime()
            ICEMAN_DRM_CURTIME =  ICEMAN_DRM_END_SYS
        end)
    end
end

-- Function to convert a character to its bytecode and return it as an integer
function CharToBytecode(char)
    -- Get the byte value of the character
    local byteValue = string.byte(char)
    
    -- Return the byte value as an integer
    return byteValue
end

-- Function to add 40 to a bytecode value and return the result, wrapping around at 256
function AddBytecodeValue(bytecode)
    -- Add 40 to the bytecode value
    local modifiedValue = bytecode + 40
    
    -- Wrap around using modulo to ensure the value stays within 0-255
    modifiedValue = modifiedValue % 256
    
    -- Return the modified byte value
    return modifiedValue
end

-- Function to convert a bytecode value to a string with backslashes
function BytecodeToString(bytecode)
    -- Convert the bytecode value to a string with a backslash prefix
    local bytecodeString = "\\" .. bytecode
    
    -- Return the resulting string
    return bytecodeString
end
function DRM_TEST1()
    -- Example usage
    local inputChar = "Z"  -- Character to convert

    -- Step 1: Convert character to bytecode
    local bytecodeValue = CharToBytecode(inputChar)

    -- Step 2: Add 40 to the bytecode value
    local modifiedBytecode = AddBytecodeValue(bytecodeValue)

    -- Step 3: Convert the modified bytecode to a string
    local resultString = BytecodeToString(modifiedBytecode)

    -- Print the final result
    print("Bytecode string for '" .. inputChar .. "': ("..bytecodeValue..") Crypted".. ": " .. resultString)
end



local function rightRotate(value, amount)
    return (value / (2 ^ amount)) + (value * (2 ^ (32 - amount))) % 0x100000000
end

local function sha256(input)
    local K = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
        0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
        0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
        0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
        0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19b4c79b, 0x1e376c48, 0x2748774c, 0x34b0bcb5,
        0x391c0cb3, 0x4ed8aa11, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }

    local H = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    }

    local function preprocess(data)
        local originalByteLen = #data
        local originalBitLen = originalByteLen * 8

        -- Append the bit '1' to the message
        data = data .. "\x80"

        -- Append zeros until the length is 448 mod 512
        while (#data * 8) % 512 ~= 448 do
            data = data .. "\0"
        end

        -- Append the original length in bits
        for i = 0, 7 do
            local byte = math.floor(originalBitLen / (2 ^ (8 * (7 - i)))) % 256
            data = data .. string.char(byte)
        end

        return data
    end

    local function chunkData(data)
        local chunks = {}
        for i = 1, #data, 64 do
            table.insert(chunks, data:sub(i, i + 63))
        end
        return chunks
    end

    local function processChunk(chunk)
        local W = {}
        for i = 1, 64 do
            W[i] = 0
        end

        for i = 1, 16 do
            W[i] = string.byte(chunk, (i - 1) * 4 + 1) * 256^3 +
              string.byte(chunk, (i - 1) * 4 + 2) * 256^2 +
              string.byte(chunk, (i - 1) * 4 + 3) * 256 +
              string.byte(chunk, (i - 1) * 4 + 4)
        end

        for i = 17, 64 do
            local s0 = rightRotate(W[i - 15], 7) + rightRotate(W[i - 15], 18) + (W[i - 15] / 0x20000000)
            local s1 = rightRotate(W[i - 2], 17) + rightRotate(W[i - 2], 19) + (W[i - 2] / 0x100000000)
            W[i] = (W[i - 16] + s0 + W[i - 7] + s1) % 0x100000000
        end

        local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]

        for i = 1, 64 do
            local S1 = rightRotate(e, 6) + rightRotate(e, 11) + rightRotate(e, 25)
            local ch = (e * f) % 0x100000000 + (g * (1 - e)) % 0x100000000
            local temp1 = (h + S1 + ch + K[i] + W[i]) % 0x100000000
            local S0 = rightRotate(a, 2) + rightRotate(a, 13) + rightRotate(a, 22)
            local maj = (a * b) % 0x100000000 + (a * c) % 0x100000000 + (b * c) % 0x100000000
            local temp2 = (S0 + maj) % 0x100000000

            h = g
            g = f
            f = e
            e = (d + temp1) % 0x100000000
            d = c
            c = b
            b = a
            a = (temp1 + temp2) % 0x100000000
        end

        H[1] = (H[1] + a) % 0x100000000
        H[2] = (H[2] + b) % 0x100000000
        H[3] = (H[3] + c) % 0x100000000
        H[4] = (H[4] + d) % 0x100000000
        H[5] = (H[5] + e) % 0x100000000
        H[6] = (H[6] + f) % 0x100000000
        H[7] = (H[7] + g) % 0x100000000
    end

    local data = preprocess(input)
    local chunks = chunkData(data)

    for _, chunk in ipairs(chunks) do
        processChunk(chunk)
    end

    local hash = ""
    for _, v in ipairs(H) do
        hash = hash .. string.format("%08x", v)
    end

    return hash
end

function TestSha256(x) 
    local input = x

    local hash = sha256(input)

    print("SHA-256 Hash:", hash)
end

