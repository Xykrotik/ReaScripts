-- Created & Tested in REAPER v6.77 (10/15/2024)
-- Add project marker at the start of each selected media item (no duplicates for overlapping items)

-- Function to check if the timestamp already has a marker
function MarkerExistsAtTimestamp(time)
    local num_markers, num_regions = reaper.CountProjectMarkers(0)
    for i = 0, num_markers + num_regions - 1 do
        local retval, isrgn, pos = reaper.EnumProjectMarkers(i)
        if not isrgn and pos == time then
            return true
        end
    end
    return false
end

-- Begin undo block
reaper.Undo_BeginBlock()

-- Get the selected media items
local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then
    local unique_times = {}

    -- Collect the start times of selected media items
    for i = 0, num_selected_items - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        
        -- Check if this start time is already in the unique_times table
        if not unique_times[item_start] then
            unique_times[item_start] = true
        end
    end

    -- Add project markers at each unique timestamp
    for time in pairs(unique_times) do
        -- Only add a marker if there isn't one at the same timestamp already
        if not MarkerExistsAtTimestamp(time) then
            reaper.AddProjectMarker(0, false, time, 0, "", -1)
        end
    end
else
    reaper.ShowMessageBox("No media items selected!", "Error", 0)
end

-- End undo block
reaper.Undo_EndBlock("Add Project Markers at Media Item Start Times", -1)

-- Update the project to reflect changes
reaper.UpdateArrange()
