local l2a = {}

local fileCheck = function( body, path )
    if not body then
        return error(
            "fileCheck - File not found (" .. path .. ")"
        )
    end
end

l2a.read = function( path )
    local file = io.open( path, "r" )
    fileCheck( file, path )
    local content = file:read( "*a" )
    file:close()
    return content
end

l2a.write = function( path, content )
    if type( content ) ~= "string" then
        return error(
            "write - Content not string (" .. type( content ) .. ")"
        )
    end
    local file = io.open( path, "w" )
    fileCheck( file, path )
    file:write( content )
    file:close()
end

l2a.auda2table = function( raw )
    if type( raw ) ~= "string" then
        return error(
            "auda2table - Content not string (" .. type( raw ) .. ")"
        )
    end
    local entries = {}
    local set, out, tag, min, max
    for line in raw:gmatch( "[^\n]+" ) do
        if set and out and tag and min and max then
            set, out, tag, min, max = line:match(
                "([%d%.]+)\t([%d%.]+)\t([^\t]*)\t([%d%.]+)\t([%d%.]+)"
            )
            table.insert(
                entries, {
                    set = tonumber( set ),
                    out = tonumber( out ),
                    tag = tostring( tag or "" ),
                    min = tonumber( min ),
                    max = tonumber( max ),
                }
            )
        elseif set and out and min and max then
            set, out, min, max = line:match(
                "([%d%.]+)\t([%d%.]+)\t([%d%.]+)\t([%d%.]+)"
            )
            table.insert(
                entries, {
                    set = tonumber( set ),
                    out = tonumber( out ),
                    min = tonumber( min ),
                    max = tonumber( max ),
                }
            )
        elseif set and out and tag then
            set, out, tag = line:match(
                "([%d%.]+)\t([%d%.]+)\t([^\t]*)"
            )
            table.insert(
                entries, {
                    set = tonumber( set ),
                    out = tonumber( out ),
                    tag = tostring( tag or "" ),
                }
            )
        elseif set and out then
            set, out = line:match(
                "([%d%.]+)\t([%d%.]+)"
            )
            table.insert(
                entries, {
                    set = tonumber( set ),
                    out = tonumber( out ),
                }
            )
        end
    end
    return entries
end

l2a.table2auda = function( entries )
    if type( entries ) ~= "table" then
        error(
            "table2auda - Expected table (" .. type( entries ) .. ")"
        )
    end
    if #entries == 0 then
        return error( "table2auda - table is empty" )
    end
    local lines = {}
    local row
    for i, e in ipairs( entries ) do
        if e.set and e.out and e.tag and e.min and e.max then
            row = string.format(
                "%.6f\t%.6f\t%s\t%.6f\t%.6f\n",
                tonumber( e.set ),
                tonumber( e.out ),
                tostring( e.tag or "" ),
                tonumber( e.min ),
                tonumber( e.max )
            )
        elseif e.set and e.out and e.min and e.max then
            row = string.format(
                "%.6f\t%.6f\t%.6f\t%.6f\n",
                tonumber( e.set ),
                tonumber( e.out ),
                tonumber( e.min ),
                tonumber( e.max )
            )
        elseif e.set and e.out and e.tag then
            row = string.format(
                "%.6f\t%.6f\t%s\n",
                tonumber( e.set ),
                tonumber( e.out ),
                tostring( e.tag or "" )
            )
        elseif e.set and e.out then
            row = string.format(
                "%.6f\t%.6f\n",
                tonumber( e.set ),
                tonumber( e.out )
            )
        end
        table.insert( lines, row )
    end
    return table.concat( lines, "" )
end

l2a.lua2table = function( raw )
    if type( raw ) ~= "string" then
        return error(
            "lua2table - Expected string (" .. type( raw ) .. ")"
        )
    end
    local chunk, err = loadstring( raw ) or load( raw )
    if not chunk then
        return error(
            "lua2table - Failed to parse lua (" .. err .. ")"
        )
    end
    local entries = chunk()
    if type( entries ) ~= "table" then
        return error(
            "lua2table - Lua code did not return a table"
        )
    end
    return entries
end

l2a.table2lua = function( entries )
    if type( entries ) ~= "table" then
        error(
            "table2lua - Expected table (" .. type( entries ) .. ")"
        )
    end
    if #entries == 0 then
        return error( "table2lua - table is empty" )
    end
    local lines = {}
    table.insert( lines, "return {\n" )
        for _, e in ipairs( entries ) do
            if e.set and e.out and e.min and e.max then
                table.insert(
                    lines,
                    string.format(
                        "\t{\n\t\tset = %s,\n\t\tout = %s,\n\t\ttag = %q,\n\t\tmin = %s,\n\t\tmax = %s,\n\t},\n",
                        tonumber( e.set ), tonumber( e.out ), tostring( e.tag or "" ), tonumber( e.min ), tonumber( e.max )
                    )
                )
            elseif e.set and e.out then
                table.insert(
                    lines,
                    string.format(
                        "\t{\n\t\tset = %s,\n\t\tout = %s,\n\t\ttag = %q,\n\t},\n",
                        tonumber( e.set ), tonumber( e.out ), tostring( e.tag or "" )
                    )
                )
            end
        end
    table.insert( lines, "}\n" )
    return table.concat( lines, "" )
end

return l2a