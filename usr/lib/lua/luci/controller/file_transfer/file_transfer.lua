module("luci.controller.file_transfer.file_transfer", package.seeall)

local http = luci.http
function index()
    local i18n = luci.i18n.translate
    local title  = i18n("File Transfer")

    page = entry({"admin", "system", "file_transfer"}, call("main"), title, 60)
    page = entry({"admin", "system", "file_transfer","cmd"}, call("cmd_post"), nil)
    page.leaf = true
end

function main()
    upload_set()
    luci.template.render("file_transfer/file_transfer", {error=error})
end

function cmd_post()
    local re =""
    local path = luci.dispatcher.context.requestpath
    local cmd = luci.http.formvalue("cmd")
    if(cmd=="dir_show")
    then
        dir_show()
    elseif(cmd=="download")
    then
        download()
    elseif(cmd=="remove")
    then
        remove()
    elseif(cmd=="copy")
    then
        copy()
    elseif(cmd=="rename")
    then
        rename()
    elseif(cmd=="create_dir")
    then
        create()
    end
end

function dir_show()
    local path = luci.http.formvalue("path")
    local lsCmd = io.popen("ls -F "..path.." 2>&1","r")
    local lsStr = lsCmd:read("*a")
    lsCmd:close()

    local rv = {["lsRt"]=lsStr}

    luci.http.prepare_content("application/json")
    luci.http.write_json(rv)

    --luci.http.status(404, "No such device")
end

function remove()
    local path=luci.http.formvalue("path")
    local r = luci.sys.exec(string.format('rm -r \"%s\"',path))
end

function create()
    local path=luci.http.formvalue("path")
    local r = luci.sys.exec(string.format('mkdir -r \"%s\"',path))
end

function copy()
    local src=luci.http.formvalue("src")
    local dest=luci.http.formvalue("dest")
    local r = luci.sys.exec(string.format('cp -r \"%s\" \"%s\"',src, dest))
    http.write("complete")
end

function rename()
    local src=luci.http.formvalue("src")
    local dest=luci.http.formvalue("dest")
    local r = luci.sys.exec(string.format('mv \"%s\" \"%s\"',src, dest))
    http.write("complete")
end

function download()
    local sPath, sFile, fd, block
    sPath = luci.http.formvalue("path")
    sFile = nixio.fs.basename(sPath)
    if nixio.fs.stat(sPath, "type") == "dir" then
        fd = io.popen('tar -C "%s" -cz .' % {sPath}, "r")
        sFile = sFile .. ".tar.gz"
    else
        fd = nixio.open(sPath, "r")
    end
    if not fd then
        local err = "Couldn't download this file: it's maybe a softlink.</br>You may see whether it's end with @"
        http.write(err)
        return
    end
    http.header('Content-Disposition', 'attachment; filename="%s"' % {sFile})
    http.prepare_content("application/octet-stream")
    while true do
        block = fd:read(nixio.const.buffersize)
        if (not block) or (#block ==0) then
            break
        else
            http.write(block)
        end
    end
    fd:close()
    http.close()
end

function upload_set()
    --local location=luci.http.formvalue("path")..'/'
    local location="/tmp/file_transfer/"
    nixio.fs.mkdir(location)
    local input_name="upload_file"
    setFileHandler(location,input_name)
    local upload = luci.http.formvalue(input_name)
    if upload and #upload > 0 then
        local path=luci.http.formvalue("path")
        local r = luci.sys.exec(string.format('mkdir -p %s && mv \"/tmp/file_transfer/%s\" %s',path,upload,path))
        local r = luci.sys.exec(string.format('sync'))
        http.write("complete")
    end
end

function setFileHandler(location, input_name, file_name)
    local sys = require "luci.sys"
    local fp
    luci.http.setfilehandler(
        function(meta, chunk, eof)
            if not fp then
                --make sure the field name is the one we want
                if meta and meta.name == input_name then
                    --use the file name if specified
                    if file_name ~= nil then
                        fp = io.open(location .. file_name, "w")
                    else
                        fp = io.open(location .. meta.file, "w")
                    end
                end
            end
            --actually do the uploading.
            if chunk then
                fp:write(chunk)
            end
            if eof then
                fp:close()
            end
        end)
end
