-- Created & Tested in REAPER v6.77 (10/15/2024)
-- Description: Snap selected media items to nearest grid line
-- About: Requires "Snap" to be enabled before running the script, else the items will not snap to nearest grid line.

-- Begin undo block
reaper.Undo_BeginBlock()

-- Get the number of selected media items
local num_items = reaper.CountSelectedMediaItems(0)

-- Check if there are any selected items
if num_items > 0 then
  -- Loop through all selected media items
  for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i) -- Get the media item
    local position = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- Get item position
    local grid_pos = reaper.SnapToGrid(0, position) -- Get the nearest grid position

    -- Move the item to the snapped position
    reaper.SetMediaItemInfo_Value(item, "D_POSITION", grid_pos)
  end
  
  -- Update the arrange view to reflect changes
  reaper.UpdateArrange()

  -- End undo block
  reaper.Undo_EndBlock("Snap media item start to nearest grid line", -1)
else
  reaper.ShowMessageBox("No media items selected", "Error", 0)
end

