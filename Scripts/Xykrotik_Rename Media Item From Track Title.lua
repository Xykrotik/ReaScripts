-- Created & Tested in REAPER v6.77 (3/14/2023)

-- User inputs
local confirm = false -- Set to true to enable confirmation dialog before applying changes
local prefix = "" -- Set prefix to add to the beginning of the item name (optional)

-- Get the selected track
local track = reaper.GetSelectedTrack(0, 0)

-- Loop through all media items on the selected track
for i = 0, reaper.CountTrackMediaItems(track) - 1 do
  local item = reaper.GetTrackMediaItem(track, i) -- Get the media item
  local take = reaper.GetActiveTake(item) -- Get the active take
  local track_name = reaper.GetTrackName(track, "")
  
  -- If the track name is blank, nil or a boolean value, use the track number
  if not track_name or track_name == "" or type(track_name) ~= "string" then
    _, track_num = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    track_name = " " .. track_num
  end
  
  -- Set the new item name
  local new_name = prefix .. track_name
  
  -- Rename the item
  reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", new_name, true)
  
  -- Confirm the rename with the user
  if confirm then
    local confirm_dialog = reaper.ShowMessageBox("Rename item to '" .. new_name .. "'?", "Confirm Rename", 1)
    
    if confirm_dialog == 2 then
      break -- Stop the script if the user clicks Cancel
    end
  end
end

-- Update the arrange view to show the new item names
reaper.UpdateArrange()
