media_item = reaper.GetSelectedMediaItem(0, 0)
if media_item ~= nil then
    take = reaper.GetActiveTake(media_item)
    if take ~= nil then
        pcm_source = reaper.GetMediaItemTake_Source(take)
        if pcm_source ~= nil then
            samplerate = reaper.GetMediaSourceSampleRate(pcm_source)
            channels = reaper.GetMediaSourceNumChannels(pcm_source)
            item_start = reaper.GetMediaItemInfo_Value(media_item, "D_POSITION")
            item_end = item_start + reaper.GetMediaItemInfo_Value(media_item, "D_LENGTH")
            take_start = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
            take_end = take_start + reaper.GetMediaItemTakeInfo_Value(take, "D_LENGTH")
            for pos = take_start + 1/samplerate, take_end, 1/samplerate do
                value = reaper.GetMediaItemTake_Peaks(take, samplerate, pos, channels, 1.0)
                if value ~= nil then
                    peak_value = value[1]
                    if peak_value ~= nil then
                        if peak_value >= 0.99 then
                            reaper.AddTakeMarker(take, -1, reaper.TimeMap2_beatsToTime(0, pos - take_start + item_start, 1), -1, "")
                        end
                    end
                end
            end
        end
    end
end
