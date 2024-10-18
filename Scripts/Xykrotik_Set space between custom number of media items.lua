-- Created & Tested in REAPER v6.77 (10/15/2024)

-- User input for number of items and space
local retval, user_input = reaper.GetUserInputs("Insert Space Between Items", 2, "Insert space after every X items,Amount of space (seconds)", "4,1")
if not retval then return end -- Cancel script if input is not given

-- Parse user input
local num_items_per_group, space_between = user_input:match("(%d+),(%d+%.?%d*)")
num_items_per_group = tonumber(num_items_per_group)
space_between = tonumber(space_between)

if not num_items_per_group or not space_between then
  reaper.ShowMessageBox("Invalid input. Please enter valid numbers.", "Error", 0)
  return
end

-- Begin undo block
reaper.Undo_BeginBlock()

-- Get the number of selected media items
local num_items = reaper.CountSelectedMediaItems(0)

-- Loop through all selected media items and insert space
for i = num_items_per_group, num_items - 1, num_items_per_group do
  local item = reaper.GetSelectedMediaItem(0, i) -- Get the nth media item
  local position = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- Get the item's position
  local new_position = position + space_between -- Add space

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_position) -- Set new position
  
  -- Move subsequent items by the same amount of space
  for j = i + 1, num_items - 1 do
    local next_item = reaper.GetSelectedMediaItem(0, j)
    local next_position = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
    reaper.SetMediaItemInfo_Value(next_item, "D_POSITION", next_position + space_between)
  end
end

-- Update the arrange view to reflect changes
reaper.UpdateArrange()

-- End undo block
reaper.Undo_EndBlock("Insert space between media items", -1)
