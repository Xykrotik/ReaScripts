-- @description Replace multiple media item sources with files from a folder simultaneously
-- @version 1.2
-- @about
--   This script allows you to replace the source files of multiple selected media items with files from a specified folder.
--   First select all media items you wish to replace the source files of. Then run the script and select the folder containing the new audio files you wish to use as replacements. 
--   **NOTE: File replacement will occur IN THE ORDER of the listed files in the selected folder. It does not replace files based on name matching.

-- Function to get all files in a folder
function get_files_from_folder(folder)
  local files = {}
  local i = 0
  repeat
    local file = reaper.EnumerateFiles(folder, i)
    if file then
      files[#files + 1] = folder .. "\\" .. file
    end
    i = i + 1
  until not file
  return files
end

-- Main script execution
function main()
  -- Prompt user to select the folder containing new source files
  retval, folder = reaper.JS_Dialog_BrowseForFolder("Select folder with new source files", "")
  
  if retval then
    -- Get all files from the selected folder
    local files = get_files_from_folder(folder)
    
    if #files == 0 then
      reaper.ShowMessageBox("No files found in the selected folder.", "Error", 0)
      return
    end
    
    -- Count the number of selected media items
    local count_selected_items = reaper.CountSelectedMediaItems(0)
    
    if count_selected_items > 0 then
      -- Check if there are enough files for the selected items
      if #files < count_selected_items then
        reaper.ShowMessageBox("Not enough files in the selected folder for all selected media items.", "Error", 0)
        return
      end
      
      -- Loop through each selected media item and replace its source
      for i = 0, count_selected_items - 1 do
        -- Get the selected media item
        local media_item = reaper.GetSelectedMediaItem(0, i)
        -- Get the active take of the media item
        local take = reaper.GetActiveTake(media_item)
        
        if take then
          -- Set the new source file for the take
          reaper.BR_SetTakeSourceFromFile(take, files[i + 1], false)
        end
      end
      
      reaper.UpdateArrange()
    else
      reaper.ShowMessageBox("No media items selected.", "Error", 0)
    end
  else
    reaper.ShowMessageBox("No folder selected.", "Error", 0)
  end
end

-- Ensure SWS extension is available
if reaper.BR_SetTakeSourceFromFile then
  main()
else
  reaper.ShowMessageBox("This script requires the SWS extension. Please install it and try again.", "Error", 0)
end

