gfx.init("Release Point Detection", 250, 100) -- initialize gfx module

local item = reaper.GetSelectedMediaItem(0, 0)
if not item then return end

local take = reaper.GetActiveTake(item)
if not take then return end

local accessor = reaper.CreateTakeAudioAccessor(take)

local take_start = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")

local min_val = -60
local max_val = -30


gfx.setfont(1, "Arial", 16)
gfx.x = 10
gfx.y = 10
gfx.drawstr("Threshold (dB)")

-- create slider using gfx.mouse_cap to check mouse button
local slider_pos = 30
local slider_w = 230
local slider_h = 20
local slider_val = (max_val - min_val) / 2 + min_val
local function update_slider()
  local x, y = gfx.mouse_x, gfx.mouse_y
  local inside_slider = x > gfx.x and x < gfx.x + slider_w and y > slider_pos and y < slider_pos + slider_h
  local left_click = gfx.mouse_cap & 1 == 1
  
  if inside_slider and left_click then
    slider_val = (x - gfx.x) / slider_w * (max_val - min_val) + min_val
  end
  
  gfx.set(0.3, 0.3, 0.3, 1)
  gfx.rect(gfx.x, slider_pos, slider_w, slider_h)
  gfx.set(1, 1, 1, 1)
  gfx.rect(gfx.x + (slider_val - min_val) / (max_val - min_val) * slider_w - 2, slider_pos - 2, 4, slider_h + 4)
end

-- main loop
local buffer_size = 4096
local buf = reaper.new_array(buffer_size)
local position = take_start
local marker_count = 0
while position < reaper.GetMediaItemInfo_Value(item, "D_LENGTH") do
  local samples = math.floor(buffer_size)
  local retval = reaper.GetAudioAccessorSamples(accessor, reaper.TimeMap2_timeToQN(position), samples, reaper.GetMediaItemTakeInfo_Value(take, "D_PITCH"), buf)
  if retval > 0 then
    local max_val = 0
    for i=0,samples-1 do
      local val = math.abs(buf[i])
      if val > max_val then max_val = val end
    end
    local db = 20*math.log(max_val, 10)
    if db < slider_val then
      reaper.AddTakeMarker(take, -1, reaper.TimeMap2_QNToTime(position), 0, "Release Point "..marker_count, 0)
      marker_count = marker_count + 1
    end
  end
  
  update_slider() -- update slider position
  
  gfx.update() -- update gfx window
  if gfx.getchar() >= 0 then break end -- exit loop when user presses any key
  position = position + buffer_size/reaper.GetMediaItemTakeInfo_Value(take, "D_SAMPLERATE")
end -- close the while loop
