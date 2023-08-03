MySQL = module("climb_mysql", "MySQL")

local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local Lang = module("lib/Lang")
Debug = module("lib/Debug")

local config = module("cfg/base")
local log_config = module("servercfg/cfg_webhooks")
local version = module("version")

print("^5^0[^3CLIMB^0]: ^7" .. 'Checking for CLIMB Updates..')

PerformHttpRequest("https://raw.githubusercontent.com/DunkoUK/dunko_climb/master/climb/version.lua",function(err,text,headers)
if err == 200 then
    text = string.gsub(text,"return ","")
    local r_version = tonumber(text)
    if version ~= r_version then
        print("^5^0[^3CLIMB^0]: ^7" .. 'A Dunko Update is available from: https://github.com/DunkoUK/dunko_climb')
    else 
        print("^5^0[^3CLIMB^0]: ^7" .. 'You are running the most up to date Dunko Version. Thanks for using Dunko_CLIMB and thanks to our contributors for updating the project. Support Found At: https://discord.gg/b8wQn2XqDt')
    end
else
    print("^0[^3CLIMB^0] unable to check the remote version")
end
end, "GET", "")


Debug.active = config.debug
CLIMB = {}
Proxy.addInterface("CLIMB",CLIMB)

tCLIMB = {}
Tunnel.bindInterface("CLIMB",tCLIMB) -- listening for client tunnel

-- load language 
local dict = module("cfg/lang/"..config.lang) or {}
CLIMB.lang = Lang.new(dict)

-- init
CLIMBclient = Tunnel.getInterface("CLIMB","CLIMB") -- server -> client tunnel

CLIMB.users = {} -- will store logged users (id) by first identifier
CLIMB.rusers = {} -- store the opposite of users
CLIMB.user_tables = {} -- user data tables (logger storage, saved to database)
CLIMB.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
CLIMB.user_sources = {} -- user sources 
-- queries
Citizen.CreateThread(function()
    Wait(1000) -- Wait for GHMatti to Initialize
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_users(
    id INTEGER AUTO_INCREMENT,
    last_login VARCHAR(100),
    whitelisted BOOLEAN,
    banned BOOLEAN,
    bantime VARCHAR(100) NOT NULL DEFAULT "",
    banreason VARCHAR(1000) NOT NULL DEFAULT "",
    banadmin VARCHAR(100) NOT NULL DEFAULT "",
    CONSTRAINT pk_user PRIMARY KEY(id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_ids (
    identifier VARCHAR(100) NOT NULL,
    user_id INTEGER,
    banned BOOLEAN,
    CONSTRAINT pk_user_ids PRIMARY KEY(identifier)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_tokens (
    token VARCHAR(200),
    user_id INTEGER,
    banned BOOLEAN  NOT NULL DEFAULT 0,
    CONSTRAINT pk_user_tokens PRIMARY KEY(token)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_data(
    user_id INTEGER,
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
    CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_srv_data(
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_srv_data PRIMARY KEY(dkey)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_moneys(
    user_id INTEGER,
    wallet INTEGER,
    bank INTEGER,
    CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
    CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_business(
    user_id INTEGER,
    name VARCHAR(30),
    description TEXT,
    capital INTEGER,
    laundered INTEGER,
    reset_timestamp INTEGER,
    CONSTRAINT pk_user_business PRIMARY KEY(user_id),
    CONSTRAINT fk_user_business_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_vehicles(
    user_id INTEGER,
    vehicle VARCHAR(100),
    vehicle_plate varchar(255) NOT NULL,
    rented BOOLEAN NOT NULL DEFAULT 0,
    rentedid varchar(200) NOT NULL DEFAULT '',
    rentedtime varchar(2048) NOT NULL DEFAULT '',
    CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
    CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_homes(
    user_id INTEGER,
    home VARCHAR(100),
    number INTEGER,
    CONSTRAINT pk_user_homes PRIMARY KEY(user_id),
    CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE,
    UNIQUE(home,number)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_user_identities(
    user_id INTEGER,
    registration VARCHAR(100),
    phone VARCHAR(100),
    firstname VARCHAR(100),
    name VARCHAR(100),
    age INTEGER,
    CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
    CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES climb_users(id) ON DELETE CASCADE,
    INDEX(registration),
    INDEX(phone)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS climb_warnings (
    warning_id INT AUTO_INCREMENT,
    user_id INT,
    warning_type VARCHAR(25),
    duration INT,
    admin VARCHAR(100),
    warning_date DATE,
    reason VARCHAR(2000),
    PRIMARY KEY (warning_id)
    )
    ]])
    MySQL.SingleQuery("ALTER TABLE climb_users ADD IF NOT EXISTS bantime varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE climb_users ADD IF NOT EXISTS banreason varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE climb_users ADD IF NOT EXISTS banadmin varchar(100) NOT NULL DEFAULT ''; ")
    MySQL.SingleQuery("ALTER TABLE climb_user_vehicles ADD IF NOT EXISTS rented BOOLEAN NOT NULL DEFAULT 0;")
    MySQL.SingleQuery("ALTER TABLE climb_user_vehicles ADD IF NOT EXISTS rentedid varchar(200) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE climb_user_vehicles ADD IF NOT EXISTS rentedtime varchar(2048) NOT NULL DEFAULT '';")
    MySQL.createCommand("CLIMBls/create_modifications_column", "alter table climb_user_vehicles add if not exists modifications text not null")
	MySQL.createCommand("CLIMBls/update_vehicle_modifications", "update climb_user_vehicles set modifications = @modifications where user_id = @user_id and vehicle = @vehicle")
	MySQL.createCommand("CLIMBls/get_vehicle_modifications", "select modifications from climb_user_vehicles where user_id = @user_id and vehicle = @vehicle")
	MySQL.execute("CLIMBls/create_modifications_column")
    print("^0[^3CLIMB^0] init base tables")
end)






MySQL.createCommand("CLIMB/create_user","INSERT INTO climb_users(whitelisted,banned) VALUES(false,false)")
MySQL.createCommand("CLIMB/add_identifier","INSERT INTO climb_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
MySQL.createCommand("CLIMB/userid_byidentifier","SELECT user_id FROM climb_user_ids WHERE identifier = @identifier")
MySQL.createCommand("CLIMB/identifier_all","SELECT * FROM climb_user_ids WHERE identifier = @identifier")
MySQL.createCommand("CLIMB/select_identifier_byid_all","SELECT * FROM climb_user_ids WHERE user_id = @id")

MySQL.createCommand("CLIMB/set_userdata","REPLACE INTO climb_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
MySQL.createCommand("CLIMB/get_userdata","SELECT dvalue FROM climb_user_data WHERE user_id = @user_id AND dkey = @key")

MySQL.createCommand("CLIMB/set_srvdata","REPLACE INTO climb_srv_data(dkey,dvalue) VALUES(@key,@value)")
MySQL.createCommand("CLIMB/get_srvdata","SELECT dvalue FROM climb_srv_data WHERE dkey = @key")

MySQL.createCommand("CLIMB/get_banned","SELECT banned FROM climb_users WHERE id = @user_id")
MySQL.createCommand("CLIMB/set_banned","UPDATE climb_users SET banned = @banned, bantime = @bantime,  banreason = @banreason,  banadmin = @banadmin WHERE id = @user_id")
MySQL.createCommand("CLIMB/set_identifierbanned","UPDATE climb_user_ids SET banned = @banned WHERE identifier = @iden")
MySQL.createCommand("CLIMB/getbanreasontime", "SELECT * FROM climb_users WHERE id = @user_id")

MySQL.createCommand("CLIMB/get_whitelisted","SELECT whitelisted FROM climb_users WHERE id = @user_id")
MySQL.createCommand("CLIMB/set_whitelisted","UPDATE climb_users SET whitelisted = @whitelisted WHERE id = @user_id")
MySQL.createCommand("CLIMB/set_last_login","UPDATE climb_users SET last_login = @last_login WHERE id = @user_id")
MySQL.createCommand("CLIMB/get_last_login","SELECT last_login FROM climb_users WHERE id = @user_id")

--Token Banning 
MySQL.createCommand("CLIMB/add_token","INSERT INTO climb_user_tokens(token,user_id) VALUES(@token,@user_id)")
MySQL.createCommand("CLIMB/check_token","SELECT user_id, banned FROM climb_user_tokens WHERE token = @token")
MySQL.createCommand("CLIMB/check_token_userid","SELECT token FROM climb_user_tokens WHERE user_id = @id")
MySQL.createCommand("CLIMB/ban_token","UPDATE climb_user_tokens SET banned = @banned WHERE token = @token")
--Token Banning

-- init tables


-- identification system

--- sql.
-- cbreturn user id or nil in case of error (if not found, will create it)
function CLIMB.getUserIdByIdentifiers(ids, cbr)
    local task = Task(cbr)
    
    if ids ~= nil and #ids then
        local i = 0
        
        -- search identifiers
        local function search()
            i = i+1
            if i <= #ids then
                if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
                    MySQL.query("CLIMB/userid_byidentifier", {identifier = ids[i]}, function(rows, affected)
                        if #rows > 0 then  -- found
                            task({rows[1].user_id})
                        else -- not found
                            search()
                        end
                    end)
                else
                    search()
                end
            else -- no ids found, create user
                MySQL.query("CLIMB/create_user", {}, function(rows, affected)
                    if rows.affectedRows > 0 then
                        local user_id = rows.insertId
                        -- add identifiers
                        for l,w in pairs(ids) do
                            if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
                                MySQL.execute("CLIMB/add_identifier", {user_id = user_id, identifier = w})
                            end
                        end
                        
                        task({user_id})
                    else
                        task()
                    end
                end)
            end
        end
        
        search()
    else
        task()
    end
end

-- return identification string for the source (used for non CLIMB identifications, for rejected players)
function CLIMB.getSourceIdKey(source)
    local ids = GetPlayerIdentifiers(source)
    local idk = "idk_"
    for k,v in pairs(ids) do
        idk = idk..v
    end
    
    return idk
end

function CLIMB.getPlayerEndpoint(player)
    if CLIMBConfig.DoNotDisplayIps then 
        return "^1 IP Hidden^7 "
    end
    return GetPlayerEP(player) or "0.0.0.0"
end

function CLIMB.getPlayerName(player)
    return GetPlayerName(player) or "unknown"
end

--- sql

function CLIMB.ReLoadChar(source)
    local name = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source)
    CLIMB.getUserIdByIdentifiers(ids, function(user_id)
        if user_id ~= nil then  
            CLIMB.StoreTokens(source, user_id) 
            if CLIMB.rusers[user_id] == nil then -- not present on the server, init
                CLIMB.users[ids[1]] = user_id
                CLIMB.rusers[user_id] = ids[1]
                CLIMB.user_tables[user_id] = {}
                CLIMB.user_tmp_tables[user_id] = {}
                CLIMB.user_sources[user_id] = source
                CLIMB.getUData(user_id, "CLIMB:datatable", function(sdata)
                    local data = json.decode(sdata)
                    if type(data) == "table" then CLIMB.user_tables[user_id] = data end
                    local tmpdata = CLIMB.getUserTmpTable(user_id)
                    CLIMB.getLastLogin(user_id, function(last_login)
                        tmpdata.last_login = last_login or ""
                        tmpdata.spawns = 0
                        local ep = GetPlayerEndpoint(source)
                        local last_login_stamp = ep.." "..os.date("%H:%M:%S %d/%m/%Y")
                        MySQL.execute("CLIMB/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                        print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") joined (user_id = "..user_id..")")
                        TriggerEvent("CLIMB:playerJoin", user_id, source, name, tmpdata.last_login)
                        TriggerClientEvent("CLIMB:CheckIdRegister", source)
                    end)
                end)
            else -- already connected
                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") re-joined (user_id = "..user_id..")")
                TriggerEvent("CLIMB:playerRejoin", user_id, source, name)
                TriggerClientEvent("CLIMB:CheckIdRegister", source)
                local tmpdata = CLIMB.getUserTmpTable(user_id)
                tmpdata.spawns = 0
            end
        end
    end)
end
RegisterCommand("getmyid", function(source)
    TriggerClientEvent('chatMessage', source, "[Server]", {255, 255, 255}, " Perm ID: " .. CLIMB.getUserId(source) , "alert")
end)

-- This can only be used server side and is for the CLIMB bot. 
exports("climbbot", function(method_name, params, cb)
    if cb then 
        cb(CLIMB[method_name](table.unpack(params)))
    else 
        return CLIMB[method_name](table.unpack(params))
    end
end)

RegisterNetEvent("CLIMB:CheckID")
AddEventHandler("CLIMB:CheckID", function()
    local user_id = CLIMB.getUserId(source)
    if not user_id then
        CLIMB.ReLoadChar(source)
    end
end)

function CLIMB.isBanned(user_id, cbr)
    local task = Task(cbr, {false})
    
    MySQL.query("CLIMB/get_banned", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].banned})
        else
            task()
        end
    end)
end

--- sql

--- sql
function CLIMB.isWhitelisted(user_id, cbr)
    local task = Task(cbr, {false})
    
    MySQL.query("CLIMB/get_whitelisted", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].whitelisted})
        else
            task()
        end
    end)
end

--- sql
function CLIMB.setWhitelisted(user_id,whitelisted)
    MySQL.execute("CLIMB/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

--- sql
function CLIMB.getLastLogin(user_id, cbr)
    local task = Task(cbr,{""})
    MySQL.query("CLIMB/get_last_login", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].last_login})
        else
            task()
        end
    end)
end

function CLIMB.fetchBanReasonTime(user_id,cbr)
    MySQL.query("CLIMB/getbanreasontime", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then 
            cbr(rows[1].bantime, rows[1].banreason, rows[1].banadmin)
        end
    end)
end

function CLIMB.setUData(user_id,key,value)
    MySQL.execute("CLIMB/set_userdata", {user_id = user_id, key = key, value = value})
end

function CLIMB.getUData(user_id,key,cbr)
    local task = Task(cbr,{""})
    
    MySQL.query("CLIMB/get_userdata", {user_id = user_id, key = key}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

function CLIMB.setSData(key,value)
    MySQL.execute("CLIMB/set_srvdata", {key = key, value = value})
end

function CLIMB.getSData(key, cbr)
    local task = Task(cbr,{""})
    
    MySQL.query("CLIMB/get_srvdata", {key = key}, function(rows, affected)
        if rows and #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

-- return user data table for CLIMB internal persistant connected user storage
function CLIMB.getUserDataTable(user_id)
    return CLIMB.user_tables[user_id]
end

function CLIMB.getUserTmpTable(user_id)
    return CLIMB.user_tmp_tables[user_id]
end

function CLIMB.isConnected(user_id)
    return CLIMB.rusers[user_id] ~= nil
end

function CLIMB.isFirstSpawn(user_id)
    local tmp = CLIMB.getUserTmpTable(user_id)
    return tmp and tmp.spawns == 1
end

function CLIMB.getUserId(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return CLIMB.users[ids[1]]
        end
    end
    
    return nil
end

-- return map of user_id -> player source
function CLIMB.getUsers()
    local users = {}
    for k,v in pairs(CLIMB.user_sources) do
        users[k] = v
    end
    
    return users
end

-- return source or nil
function CLIMB.getUserSource(user_id)
    return CLIMB.user_sources[user_id]
end

function CLIMB.IdentifierBanCheck(source,user_id,cb)
    for i,v in pairs(GetPlayerIdentifiers(source)) do 
        MySQL.query('CLIMB/identifier_all', {identifier = v}, function(rows)
            for i = 1,#rows do 
                if rows[i].banned then 
                    if user_id ~= rows[i].user_id then 
                        cb(true, rows[i].user_id)
                    end 
                end
            end
        end)
    end
end

function CLIMB.BanIdentifiers(user_id, value)
    MySQL.query('CLIMB/select_identifier_byid_all', {id = user_id}, function(rows)
        for i = 1, #rows do 
            MySQL.execute("CLIMB/set_identifierbanned", {banned = value, iden = rows[i].identifier })
        end
    end)
end

function CLIMB.setBanned(user_id,banned,time,reason, admin)
    if banned then
        webhook = log_config.banlog
        if webhook ~= nil then
            if webhook ~= 'none' then
                PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({username = "Dunko CLIMB Logs", embeds = {{["color"] = "15158332", ["title"] = 'Someone Has Been Banned', ["description"] = 'Players Perm-ID: **' .. user_id .. '**\nReason Player Was Banned: **' .. reason .. '**\nBanning Admin: **' ..admin .. '**', ["footer"] = {["text"] = "Time - "..os.date("%x %X %p"),}}}}), { ["Content-Type"] = "application/json" })
            end
        end
        MySQL.execute("CLIMB/set_banned", {user_id = user_id, banned = banned, bantime = time, banreason = reason, banadmin = admin})
        CLIMB.BanIdentifiers(user_id, true)
        CLIMB.BanTokens(user_id, true) 
    else
        webhook = log_config.unbanlog
        if webhook ~= nil then
            if webhook ~= 'none' then
                PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({username = "Dunko CLIMB Logs", embeds = {{["color"] = "15158332", ["title"] = 'Someone Has Been Unbanned', ["description"] = 'Players Perm-ID: **' .. user_id .. '**', ["footer"] = {["text"] = "Time - "..os.date("%x %X %p"),}}}}), { ["Content-Type"] = "application/json" })
            end
        end
        MySQL.execute("CLIMB/set_banned", {user_id = user_id, banned = banned, bantime = "", banreason =  "", banadmin =  ""})
        CLIMB.BanIdentifiers(user_id, false)
        CLIMB.BanTokens(user_id, false) 
    end 
end

function CLIMB.ban(adminsource,permid,time,reason)
    local adminPermID = CLIMB.getUserId(adminsource)
    local getBannedPlayerSrc = CLIMB.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            CLIMB.setBanned(permid,true,banTime,reason, GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID)
            CLIMB.kick(getBannedPlayerSrc,"You have been banned from this server. Your ban expires in: " .. os.date("%c", banTime) .. " Reason: " .. reason .. " | Banning Admin: " ..  GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID ) 
            CLIMBclient.notify(adminsource,{"~g~Success banned! User PermID:" .. permid})
        else 
            CLIMBclient.notify(adminsource,{"~g~Success banned! User PermID:" .. permid})
            CLIMB.setBanned(permid,true,"perm",reason, GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID)
            CLIMB.kick(getBannedPlayerSrc,"You have been banned from this server. Your ban expires in: " .. "Never, you've been permanently banned." .. " Reason: " .. reason .. " | Banning Admin: " ..  GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID ) 
        end
    else 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            CLIMBclient.notify(adminsource,{"~g~Success banned! User PermID:" .. permid})
            CLIMB.setBanned(permid,true,banTime,reason, GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID)
        else 
            CLIMBclient.notify(adminsource,{"~g~Success banned! User PermID:" .. permid})
            CLIMB.setBanned(permid,true,"perm",reason, GetPlayerName(adminsource) .. " | ID Of Admin: " .. adminPermID)
        end
    end
end

function CLIMB.banConsole(permid,time,reason)
    local adminPermID = "Console Ban"
    local getBannedPlayerSrc = CLIMB.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            CLIMB.setBanned(permid,true,banTime,reason,  'Console' .. " | ID Of Admin: " .. adminPermID)
            CLIMB.kick(getBannedPlayerSrc,"You have been banned from this server. Your ban expires in: " .. os.date("%c", banTime) .. " Reason: " .. reason .. " | BanningAdmin: " ..  'Console' .. " | ID Of Admin: " .. adminPermID ) 
            print("~g~Success banned! User PermID:" .. permid)
        else 
            print("~g~Success banned! User PermID:" .. permid)
            CLIMB.setBanned(permid,true,"perm",reason,  'Console' .. " | ID Of Admin: " .. adminPermID)
            CLIMB.kick(getBannedPlayerSrc,"You have been banned from this server. Your ban expires in: " .. "Never, you've been permanently banned." .. " Reason: " .. reason .. " | BanningAdmin: " ..  'Console' .. " | ID Of Admin: " .. adminPermID ) 
        end
    else 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            print("~g~Success banned! User PermID:" .. permid)
            CLIMB.setBanned(permid,true,banTime,reason, 'Console' .. " | ID Of Admin: " .. adminPermID)
        else 
            print("~g~Success banned! User PermID:" .. permid)
            CLIMB.setBanned(permid,true,"perm",reason, 'Console' .. " | ID Of Admin: " .. adminPermID)
        end
    end
end

-- To use token banning you need the latest artifacts.
function CLIMB.StoreTokens(source, user_id) 
    if GetNumPlayerTokens then 
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            MySQL.query("CLIMB/check_token", {token = token}, function(rows)
                if token and rows and #rows <= 0 then 
                    MySQL.execute("CLIMB/add_token", {token = token, user_id = user_id})
                end        
            end)
        end
    end
end


function CLIMB.CheckTokens(source, user_id) 
    if GetNumPlayerTokens then 
        local banned = false;
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            local rows = MySQL.asyncQuery("CLIMB/check_token", {token = token, user_id = user_id})
                if #rows > 0 then 
                if rows[1].banned then 
                    return rows[1].banned, rows[1].user_id
                end
            end
        end
    else 
        return false; 
    end
end

function CLIMB.BanTokens(user_id, banned) 
    if GetNumPlayerTokens then 
        MySQL.query("CLIMB/check_token_userid", {id = user_id}, function(id)
            for i = 1, #id do 
                MySQL.execute("CLIMB/ban_token", {token = id[i].token, banned = banned})
            end
        end)
    end
end


function CLIMB.kick(source,reason)
    webhook = log_config.kicklog
    local user_id = CLIMB.getUserId(source)
    local playername = GetPlayerName(source)
    if webhook ~= nil then
        if webhook ~= 'none' then
            PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({username = "Dunko CLIMB Logs", embeds = {{["color"] = "15158332", ["title"] = playername .. ' Has Been Kicked', ["description"] = 'Players Perm-ID: **' .. user_id .. '**\nReason Player Was Kicked: **' .. reason .. '**', ["footer"] = {["text"] = "Time - "..os.date("%x %X %p"),}}}}), { ["Content-Type"] = "application/json" })
        end
    end
    DropPlayer(source,reason)
end

-- tasks

function task_save_datatables()
    TriggerEvent("CLIMB:save")
    
    Debug.pbegin("CLIMB save datatables")
    for k,v in pairs(CLIMB.user_tables) do
        CLIMB.setUData(k,"CLIMB:datatable",json.encode(v))
    end
    
    Debug.pend()
    SetTimeout(config.save_interval*1000, task_save_datatables)
end
task_save_datatables()

-- handlers

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
    deferrals.defer()
    
    local source = source
    Debug.pbegin("playerConnecting")
    local ids = GetPlayerIdentifiers(source)
    
    if ids ~= nil and #ids > 0 then
        deferrals.update("^0[^3CLIMB^0] Checking identifiers...")
        CLIMB.getUserIdByIdentifiers(ids, function(user_id)
            CLIMB.IdentifierBanCheck(source, user_id, function(status, id)
                if status then
                    print("^0[^3CLIMB^0] User rejected for attempting to evade ID: " .. user_id .. " | (Ignore joined message, they were rejected)") 
                    deferrals.done("[CLIMB]: You are banned from this server, please do not try to evade your ban. If you believe this was an error quote your ID which is: " .. id)
                    return 
                end
            end)
            -- if user_id ~= nil and CLIMB.rusers[user_id] == nil then -- check user validity and if not already connected (old way, disabled until playerDropped is sure to be called)
            if user_id ~= nil then -- check user validity 
                deferrals.update("^0[^3CLIMB^0] Fetching Tokens...")
                CLIMB.StoreTokens(source, user_id) 
                deferrals.update("^0[^3CLIMB^0] Checking banned...")
                CLIMB.isBanned(user_id, function(banned)
                    if not banned then
                        deferrals.update("^0[^3CLIMB^0] Checking whitelisted...")
                        CLIMB.isWhitelisted(user_id, function(whitelisted)
                            if not config.whitelist or whitelisted then
                                Debug.pbegin("playerConnecting_delayed")
                                if CLIMB.rusers[user_id] == nil then -- not present on the server, init
                                    if CLIMB.CheckTokens(source, user_id) then 
                                        deferrals.done("[CLIMB]: You are banned from this server, please do not try to evade your ban.")
                                    end
                                    CLIMB.users[ids[1]] = user_id
                                    CLIMB.rusers[user_id] = ids[1]
                                    CLIMB.user_tables[user_id] = {}
                                    CLIMB.user_tmp_tables[user_id] = {}
                                    CLIMB.user_sources[user_id] = source
                                    
                                    -- load user data table
                                    deferrals.update("^0[^3CLIMB^0] Loading datatable...")
                                    CLIMB.getUData(user_id, "CLIMB:datatable", function(sdata)
                                        local data = json.decode(sdata)
                                        if type(data) == "table" then CLIMB.user_tables[user_id] = data end
                                        
                                        -- init user tmp table
                                        local tmpdata = CLIMB.getUserTmpTable(user_id)
                                        
                                        deferrals.update("^0[^3CLIMB^0] Getting last login...")
                                        CLIMB.getLastLogin(user_id, function(last_login)
                                            tmpdata.last_login = last_login or ""
                                            tmpdata.spawns = 0
                                            
                                            -- set last login
                                            local ep = GetPlayerEndpoint(source)
                                            local last_login_stamp = ep.." "..os.date("%H:%M:%S %d/%m/%Y")
                                            MySQL.execute("CLIMB/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                            
                                            -- trigger join
                                            print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") joined (user_id = "..user_id..")")
                                            TriggerEvent("CLIMB:playerJoin", user_id, source, name, tmpdata.last_login)
                                            deferrals.done()
                                        end)
                                    end)
                                else -- already connected
                                    if CLIMB.CheckTokens(source, user_id) then 
                                        deferrals.done("[CLIMB]: You are banned from this server, please do not try to evade your ban.")
                                    end
                                    print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") re-joined (user_id = "..user_id..")")
                                    TriggerEvent("CLIMB:playerRejoin", user_id, source, name)
                                    deferrals.done()
                                    
                                    -- reset first spawn
                                    local tmpdata = CLIMB.getUserTmpTable(user_id)
                                    tmpdata.spawns = 0
                                end
                                
                                Debug.pend()
                            else
                                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") rejected: not whitelisted (user_id = "..user_id..")")
                                deferrals.done("[CLIMB] Not whitelisted (user_id = "..user_id..").")
                            end
                        end)
                    else
                        deferrals.update("^0[^3CLIMB^0] Fetching Tokens...")
                        CLIMB.StoreTokens(source, user_id) 
                        CLIMB.fetchBanReasonTime(user_id,function(bantime, banreason, banadmin)
                            if tonumber(bantime) then 
                                local timern = os.time()
                                if timern > tonumber(bantime) then 
                                    deferrals.update('Your ban has expired. Please do not violate this server\'s rules again. You will now be automatically connected!')
                                    Wait(2000)
                                    CLIMB.setBanned(user_id,false)
                                    if CLIMB.rusers[user_id] == nil then -- not present on the server, init
                                        -- init entries
                                        CLIMB.users[ids[1]] = user_id
                                        CLIMB.rusers[user_id] = ids[1]
                                        CLIMB.user_tables[user_id] = {}
                                        CLIMB.user_tmp_tables[user_id] = {}
                                        CLIMB.user_sources[user_id] = source
                                        
                                        -- load user data table
                                        deferrals.update("^0[^3CLIMB^0] Loading datatable...")
                                        CLIMB.getUData(user_id, "CLIMB:datatable", function(sdata)
                                            local data = json.decode(sdata)
                                            if type(data) == "table" then CLIMB.user_tables[user_id] = data end
                                            
                                            -- init user tmp table
                                            local tmpdata = CLIMB.getUserTmpTable(user_id)
                                            
                                            deferrals.update("^0[^3CLIMB^0] Getting last login...")
                                            CLIMB.getLastLogin(user_id, function(last_login)
                                                tmpdata.last_login = last_login or ""
                                                tmpdata.spawns = 0
                                                
                                                -- set last login
                                                local ep = CLIMB.getPlayerEndpoint(source)
                                                local last_login_stamp = ep.." "..os.date("%H:%M:%S %d/%m/%Y")
                                                MySQL.execute("CLIMB/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                
                                                -- trigger join
                                                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") joined after his ban expired. (user_id = "..user_id..")")
                                                TriggerEvent("CLIMB:playerJoin", user_id, source, name, tmpdata.last_login)
                                                deferrals.done()
                                            end)
                                        end)
                                    else -- already connected
                                        print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") re-joined after his ban expired.  (user_id = "..user_id..")")
                                        TriggerEvent("CLIMB:playerRejoin", user_id, source, name)
                                        deferrals.done()
                                        
                                        -- reset first spawn
                                        local tmpdata = CLIMB.getUserTmpTable(user_id)
                                        tmpdata.spawns = 0
                                    end
                                    return 
                                end
                                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") rejected: banned (user_id = "..user_id..")")
                                deferrals.done("[CLIMB] You have been banned from this server.\nYour ban will expire on the: " .. os.date("%c", bantime) .. "\nReason: " .. banreason .. "\n\nBanning Admin: " .. banadmin)
                            else 
                                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") rejected: banned (user_id = "..user_id..")")
                                deferrals.done("[CLIMB] You have been banned from this server.\nYour ban will expire: Never, you have been permanently banned \nReason: " .. banreason .. "\n\nBanning Admin: " .. banadmin)
                            end
                        end)
                    end
                end)
            else
                print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") rejected: identification error")
                deferrals.done("[CLIMB] Identification error.")
            end
        end)
    else
        print("^0[^3CLIMB^0] "..name.." ("..CLIMB.getPlayerEndpoint(source)..") rejected: missing identifiers")
        deferrals.done("[CLIMB] Missing identifiers.")
    end
    Debug.pend()
end)

AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = CLIMB.getUserId(source)
    local playername = GetPlayerName(source)
    webhook = log_config.leavelog
    if webhook ~= nil then
        if webhook ~= 'none' then
            PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({username = "Dunko CLIMB Logs", embeds = {{["color"] = "15158332", ["title"] = playername .. ' Has Left The Server', ["description"] = 'His Perm-ID: **' .. user_id .. '\n** His Source Id: **' .. source .. '**', ["footer"] = {["text"] = "Time - "..os.date("%x %X %p"),}}}}), { ["Content-Type"] = "application/json" })
        end
    end
    if user_id ~= nil then
        TriggerEvent("CLIMB:playerLeave", user_id, source)
        
        -- save user data table
        CLIMB.setUData(user_id,"CLIMB:datatable",json.encode(CLIMB.getUserDataTable(user_id)))
        
        print("^0[^3CLIMB^0] "..CLIMB.getPlayerEndpoint(source).." disconnected (user_id = "..user_id..")")
        CLIMB.users[CLIMB.rusers[user_id]] = nil
        CLIMB.rusers[user_id] = nil
        CLIMB.user_tables[user_id] = nil
        CLIMB.user_tmp_tables[user_id] = nil
        CLIMB.user_sources[user_id] = nil
        print('^0[^3CLIMB^0] Player Leaving Save:  Saved data for: ' .. GetPlayerName(source))
    else 
        print('^0[^3CLIMB^0] SEVERE ERROR: Failed to save data for: ' .. GetPlayerName(source) .. ' Rollback expected!')
    end
    CLIMBclient.removePlayer(-1,{source})
end)

RegisterServerEvent("CLIMBcli:playerSpawned")
AddEventHandler("CLIMBcli:playerSpawned", function()
    Debug.pbegin("playerSpawned")
    -- register user sources and then set first spawn to false
    local user_id = CLIMB.getUserId(source)
    local player = source
    if user_id ~= nil then
        CLIMB.user_sources[user_id] = source
        local tmp = CLIMB.getUserTmpTable(user_id)
        tmp.spawns = tmp.spawns+1
        local first_spawn = (tmp.spawns == 1)
        if first_spawn then
            for k,v in pairs(CLIMB.user_sources) do
                CLIMBclient.addPlayer(source,{v})
            end
            CLIMBclient.addPlayer(-1,{source})
        end
        TriggerEvent("CLIMB:playerSpawn",user_id,player,first_spawn)
    end
    Debug.pend()
end)

RegisterServerEvent("CLIMB:playerDied")

exports("getServerStatus", function(params, cb)
    if staffWhitelist then
        cb("Whitelisted")
    else
        cb("Online")
    end
end)