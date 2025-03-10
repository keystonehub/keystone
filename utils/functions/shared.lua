--- Waits until a given condition is met or timeout occurs.
--- @param condition function The condition function that should return true when ready.
--- @param timeout number Maximum time to wait in seconds (default: 5 seconds).
--- @param interval number Interval between checks in milliseconds (default: 100ms).
function wait_for(condition, timeout, interval)
    timeout = timeout or 5
    interval = interval or 100
    local elapsed = 0
    while not condition() do
        if elapsed >= timeout * 1000 then return false end
        Wait(interval)
        elapsed = elapsed + interval
    end
    return true
end

--- Parse duration string into seconds.
--- @param str string: The duration string.
function parse_duration(str)
    if not str or str == 'perm' then return nil end
    local number, unit = str:match('^(%d+)([smhdMy])$')
    if not number or not unit then  debug_log('error', 'Invalid duration format:', str) return nil end
    local conversion = {s = 1, m = 60, h = 3600, d = 86400, M = 2592000, y = 31536000}
    local seconds = tonumber(number) * (conversion[unit] or 1)
    return seconds
end

--- Calculates the total weight of default items.
--- @param items table: List of default items for new characters.
--- @return number: Total weight of all items.
function calculate_total_item_weight(items)
    local total_weight = 0
    for _, item in pairs(items) do
        local item_data = keystone.data.items[item.id]
        if item_data then
            total_weight = total_weight + (item_data.weight * item.amount)
        end
    end
    return total_weight
end

--- Check if two rectangles intersect.
--- @param rect1 table: X and Y for rectangle 1.
--- @param rect2 table: X and Y for rectangle 2.
function rectangles_intersect(rect1, rect2)
    return not ( rect1.x2 < rect2.x1 or rect1.x1 > rect2.x2 or rect1.y2 < rect2.y1 or rect1.y1 > rect2.y2 )
end

--- Finds the next available grid position for an item without overlapping existing items.
--- @param inventory_grid table: The players inventory items (an array of item tables).
--- @param grid_columns number: Total columns in the grid.
--- @param grid_rows number: Total rows in the grid.
--- @param item_width number: The width of the new item.
--- @param item_height number: The height of the new item.
--- @return number, number: The x and y position if found, otherwise nil.
function find_available_grid_position(inventory_grid, grid_columns, grid_rows, item_width, item_height)
    for y = 1, grid_rows do
        for x = 1, grid_columns do
            if (x + item_width - 1) <= grid_columns and (y + item_height - 1) <= grid_rows then
                local candidate_rect = {
                    x1 = x,
                    y1 = y,
                    x2 = x + item_width - 1,
                    y2 = y + item_height - 1
                }
                local fits = true
                for _, item in ipairs(inventory_grid) do
                    local item_info = keystone.data.items[item.id]
                    local existing_width = (item_info and item_info.grid and item_info.grid.width) or 1
                    local existing_height = (item_info and item_info.grid and item_info.grid.height) or 1
                    local ex = item.grid.x
                    local ey = item.grid.y
                    local existing_rect = {
                        x1 = ex,
                        y1 = ey,
                        x2 = ex + existing_width - 1,
                        y2 = ey + existing_height - 1
                    }
                    if rectangles_intersect(candidate_rect, existing_rect) then
                        fits = false
                        break
                    end
                end
                if fits then
                    return x, y
                end
            end
        end
    end
    return nil, nil
end
