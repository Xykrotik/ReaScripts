-- Created & Tested in REAPER v7.22 (10/15/2024)
-- @description Rename multiple media items based on parent track title
-- @about
--   This script requires you to select all tracks that have media items occupying them that you wish to rename to parent track's name/title.

-- User inputs
local confirm = false -- Set to true to enable confirmation dialog before applying changes
local prefix = "" -- Set prefix to add to the beginning of the item name (optional)

-- Get the number of selected tracks
local num_tracks = reaper.CountSelectedTracks(0)

-- Loop through all selected tracks
for t = 0, num_tracks - 1 do
  local track = reaper.GetSelectedTrack(0, t) -- Get the selected track
  
  -- Get the track name or track number if the name is not set
  local _, track_name = reaper.GetTrackName(track, "")
  if track_name == "" then
    track_name = "Track " .. tostring(t + 1)
  end
  
  -- Loop through all media items on the current track
  for i = 0, reaper.CountTrackMediaItems(track) - 1 do
    local item = reaper.GetTrackMediaItem(track, i) -- Get the media item
    local take = reaper.GetActiveTake(item) -- Get the active take
    
    if take then
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
  end
end

-- Update the arrange view to show the new item names
reaper.UpdateArrange()

