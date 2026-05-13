local record TableFormat
    set: float
    out: float
    tag: string?
    min: float?
    max: float?
end

local fileCheck: function(
    body: any,
    path: string
): nil

local record l2a
    read: function(
        path: string
    ): string

    write: function(
        path: string,
        content: string,
    ): nil

    auda2table: function(
        raw: string,
    ): {
        TableFormat,
    }

    table2auda: function(
        entries: {
            TableFormat,
        }
    ): string

    lua2table: function(
        raw: string
    ): {
        TableFormat,
    } | table

    table2lua: function(
        entries: {
            TableFormat,
        }
    ): string
end