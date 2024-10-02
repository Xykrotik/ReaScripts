function find_zero_crossing(item, pos)
    local take = reaper.GetActiveTake(item)
    if not take or reaper.TakeIsMIDI(take) then return pos end
    
    local src = reaper.GetMediaItemTake_Source(take)
    local samplerate = reaper.GetMediaSourceSampleRate(src)
    
    -- Get start position of the media item
    local start_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    
    -- Set a window range around the cursor to search for zero crossings (e.g., 50 ms window)
    local search_range = 0.05 -- 50 milliseconds
    local search_start = math.max(start_pos, pos - search_range)
    local search_end = math.min(start_pos + length, pos + search_range)

    -- Number of peaks to retrieve, higher peakrate for more accuracy
    local peakrate = samplerate / 10  
    local num_samples = math.floor((search_end - search_start) * peakrate)
    
    -- Request peaks from the source
    local num_channels = 2 -- Adjust for mono or stereo
    local buffer = reaper.new_array(num_samples * num_channels) -- Create buffer with correct size
    reaper.PCM_Source_GetPeaks(src, peakrate, search_start, num_samples, num_channels, 1, buffer)
    
    local nearest_zero = pos
    local min_dist = math.huge

    -- Iterate over samples to find zero crossing within the window
    for i = 1, num_samples * num_channels, num_channels do
        local sample_value = buffer[i] -- Access left channel data
        
        -- Ensure the next sample is within the buffer
        if (i + num_channels) <= #buffer then
            local next_sample_value = buffer[i + num_channels]
            
            -- Detect zero crossing (from negative to positive)
            if sample_value <= 0 and next_sample_value > 0 then
                local crossing_pos = search_start + (i / peakrate)
                local dist = math.abs(pos - crossing_pos)
                if dist < min_dist then
                    min_dist = dist
                    nearest_zero = crossing_pos
                end
            end
        end
    end

    return nearest_zero
end

function main()
    local window, segment, details = reaper.BR_GetMouseCursorContext()
    if window ~= "arrange" then return end

    local item = reaper.BR_GetMouseCursorContext_Item()
    if not item then return end

    local mouse_pos = reaper.BR_GetMouseCursorContext_Position()
    local new_pos = find_zero_crossing(item, mouse_pos)

    reaper.SetEditCurPos(new_pos, true, false)
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Move edit cursor to nearest zero crossing at mouse cursor", -1)

