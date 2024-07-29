--[[
    @description Split the selected media items at transients, then normalize split items
    @Author: Jackson "Xykrotik" Harris
    @version 1.0
    
    @changelog
    - Initial release (01/04/2024)
]]

local numSelectedItems = reaper.CountSelectedMediaItems(0)
for i = 0, numSelectedItems - 1 do
    -- Get the current selected media item
    local selectedItem = reaper.GetSelectedMediaItem(0, i)

    -- Get the active take of the media item
    local activeTake = reaper.GetActiveTake(selectedItem)

    -- Set the take marker name
    local markerName = "Transient"

    -- Get the source filename of the media item
    local sourceFilename = reaper.GetMediaItemTake_Source(reaper.GetMediaItemTake_Source(activeTake), "")

    --Find transients in the media item
    local itemCount = reaper.CountTakes(selectedItem)
    for j = 0, itemCount - 1 do
        local take = reaper.GetTake(selectedItem, j)
        local retval, numTransients, _, _ = reaper.GetNumTakeMarkers(take)

        for k = 0, numTransients -1 do
            local retval, _, transientPosition, _ = reaper.GetTakeMarker(take, k)

            -- Place take marker at transient position
            reaper.SetTakeMarker(take, -1, markerName, transientPosition, -1, 0)
        end
    end
end
    --[[ Get the cursor position
    local cursorPosition = reaper.GetCursorPosition()

    -- Move the cursor to the start of the media item
    reaper.SetEditCurPos(reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION"), false, false)

    -- Detect transients in selected media item(s) and place take marker
    reaper.Main_OnCommand(40375, 0) -- Run "Move cursor to next transient in items" action
    reaper.SetTakeMarker(activeTake, -1, markerName, reaper.GetCursorPosition(), -1, 0)

    -- Restore the cursor position
    reaper.SetEditCurPos(cursorPosition, false, false)
]]

-- Get first selected media item
local selectedItem = reaper.GetSelectedMediaItem(0, 0)

-- Get the active take of the media item
local activeTake = reaper.GetActiveTake(selectedItem)

--Get the number of take markers
local numMarkers = reaper.GetNumTakeMarkers(activeTake)

-- Loop over the take markers in reverse order
for i = reaper.GetNumTakeMarkers(activeTake) -1, 0, -1 do
    local retval, _, _, _, _, markerName, markerPosition = reaper.GetTakeMarker(activeTake, i)

    -- Check if the marker position is valid
    if retval and markerPosition then
        -- Split the media item at the marker position
        reaper.SplitMediaItem(selectedItem, markerPosition)
    else   
        reaper.ShowConsoleMsg("Failed to retrieve marker position at index " .. i .. "\n")
        reaper.ShowConsoleMsg("Media Item: " .. tostring(selectedItem) .. "\n")
        reaper.ShowConsoleMsg("Active Take: " .. tostring(activeTake) .. "\n")
    end
end

-- Normalize split items
reaper.Main_OnCommand(40108, 0) -- Normalize selected items