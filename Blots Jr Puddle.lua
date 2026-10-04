connect(RunService.Heartbeat, function()
 local h = getHum()
 if not h then return end
 if state.speedOn then h.WalkSpeed = state.speed end
 if state.jumpOn then
  h.UseJumpPower = true
  h.JumpPower = state.jump
 end
end)

connect(UIS.JumpRequest, function()
 if state.infJump then
  local h = getHum()
  if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)

---------------------------------------------------------------- 🤖 Auto
toggle(pages.Auto, "Auto Skill-Check", false, function(on) state.autoSkill = on end)

local function autoSkillTick()
 pcall(function()
  local pg = lp:FindFirstChild("PlayerGui")
  if not pg then return end

  for _, guiObj in ipairs(pg:GetDescendants()) do
   if guiObj:IsA("Frame") and guiObj.Name == "SkillCheckFrame" then
    local marker = guiObj:FindFirstChild("Marker")
    local targetArea = guiObj:FindFirstChild("GoldArea") 
     or guiObj:FindFirstChild("RequiredArea") 
     or guiObj:FindFirstChild("SuccessArea")

    if marker and targetArea then
     for _, child in ipairs(guiObj:GetDescendants()) do
      if child:IsA("GuiObject") then
       child.BackgroundTransparency = 1
      elseif child:IsA("TextLabel") or child:IsA("TextButton") then
       child.TextTransparency = 1
       child.TextStrokeTransparency = 1
      elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
       child.ImageTransparency = 1
      end
     end

     marker.Position = targetArea.Position

     VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
     task.wait(0.02)
     VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
   end
  end
 end)
end

connect(RunService.Heartbeat, function()
 if state.autoSkill then 
  autoSkillTick() 
 end
end)

toggle(pages.Auto, "Anti-AFK", false, function(on) state.antiAfk = on end)
connect(lp.Idled, function()
 if state.antiAfk then
  VirtualUser:CaptureController()
  VirtualUser:ClickButton2(Vector2.new())
 end
end)

---------------------------------------------------------------- 👁 Visual
toggle(pages.Visual, "ESP Switch", true, function(on)
 state.esp = on
 refreshESP()
end)

choice(pages.Visual, {
 { "full", "Fill + Outline + Text" },
 { "nolabel", "Fill + Outline, No Text" },
 { "outline", "Outline Only" },
 { "text", "Text Only" },
}, state.style, function(key)
 state.style = key
 refreshESP()
end)

toggle(pages.Visual, "Twisted", true, function(on) state.cats.twisted = on; refreshESP() end)
toggle(pages.Visual, "Players", false, function(on) state.cats.players = on; refreshESP() end)
toggle(pages.Visual, "Machines / Generators", false, function(on) state.cats.machines = on; refreshESP() end)

for _, r in ipairs(rarityOrder) do
 toggle(pages.Visual, r, true, function(on)
  state.rarity[r] = on
  refreshESP()
 end, rarityColors[r])
end

connect(closeBtn.MouseButton1Click, function()
 local h = getHum()
 if h then
  if state.speedOn then h.WalkSpeed = 16 end
  if state.jumpOn then h.JumpPower = 50 end
 end
 state.speedOn, state.jumpOn, state.infJump, state.antiAfk = false, false, false, false
 for _, c in ipairs(connections) do c:Disconnect() end
 for model in pairs(tracked) do removeESP(model) end
 gui:Destroy()
end)

selectTab("Main")
