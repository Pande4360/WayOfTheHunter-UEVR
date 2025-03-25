require("UEHelper")
require("CONFIG")
local api = uevr.api
local vr = uevr.params.vr


 local camera_component_c = api:find_uobject("Class /Script/Engine.CameraComponent")

local ActiveHandState= 0 --0: non, 1:right, 2:left
local isLHandPressed=false
local isRHandPressed=false
local isDriving = false

--degrees
local CurrentHandRoll_Right = 0
local CurrentHandRoll_Left  = 0
local StartRoll_Left=0
local StartRoll_Right=0

local ThumbLX   = 0
local ThumbLY   = 0
local ThumbRX   = 0
local ThumbRY   = 0
local LTrigger  = 0
local RTrigger  = 0
local rShoulder = false
local lShoulder = false
local lThumb    = false
local rThumb    = false
local Abutton = false
local Bbutton = false
local Xbutton = false
local Ybutton = false
local CurrentSteerVal=0
local LastSteerVal=0


local function UpdateHandState()
	if lShoulder and isLHandPressed==false then
		ActiveHandState= 2
		isLHandPressed = true
		StartRoll_Left=CurrentHandRoll_Left
	elseif lShoulder and ActiveHandState==1 and not rShoulder then
		ActiveHandState= 2
		isLHandPressed = true
		StartRoll_Left=CurrentHandRoll_Left
	end
	if rShoulder  and isRHandPressed==false then
			ActiveHandState= 1
			isRHandPressed = true
			StartRoll_Right= CurrentHandRoll_Right
	elseif rShoulder and ActiveHandState==2 and not lShoulder then
			ActiveHandState= 1
			isRHandPressed = true
			StartRoll_Right= CurrentHandRoll_Right
	end
	if not lShoulder and isLHandPressed then
			isLHandPressed=false
	end
	if not rShoulder and isRHandPressed then
			isRHandPressed=false
	end
	if not lShoulder and not rShoulder then
			ActiveHandState=0
	end
end

--XINPUT functions

local function UpdateInput(state)

--Read Gamepad stick input 
	ThumbLX = state.Gamepad.sThumbLX
	ThumbLY = state.Gamepad.sThumbLY
	ThumbRX = state.Gamepad.sThumbRX
	ThumbRY = state.Gamepad.sThumbRY
	LTrigger= state.Gamepad.bLeftTrigger
	RTrigger= state.Gamepad.bRightTrigger
	rShoulder= isButtonPressed(state, XINPUT_GAMEPAD_RIGHT_SHOULDER)
	lShoulder= isButtonPressed(state, XINPUT_GAMEPAD_LEFT_SHOULDER)
	lThumb   = isButtonPressed(state, XINPUT_GAMEPAD_LEFT_THUMB)
	rThumb   = isButtonPressed(state, XINPUT_GAMEPAD_RIGHT_THUMB)
	Abutton  = isButtonPressed(state, XINPUT_GAMEPAD_A)
	Bbutton  = isButtonPressed(state, XINPUT_GAMEPAD_B)
	Xbutton  = isButtonPressed(state, XINPUT_GAMEPAD_X)
	Ybutton  = isButtonPressed(state, XINPUT_GAMEPAD_Y)
end

local function Drive(state)
	if isDriving then
		--state.Gamepad.sThumbLX = 0
		--state.Gamepad.sThumbRX = 0
	
		if ActiveHandState == 1 then
			local DiffAngleRight= CurrentHandRoll_Right-StartRoll_Right
			CurrentSteerVal= LastSteerVal+DiffAngleRight
			
		elseif ActiveHandState ==2 then
			local DiffAngleLeft= CurrentHandRoll_Left-StartRoll_Left
			CurrentSteerVal= LastSteerVal+DiffAngleLeft
		elseif ActiveHandState==0 then
			CurrentSteerVal = 0
		end
		if CurrentSteerVal>90 then
			CurrentSteerVal=90 
		end
		if CurrentSteerVal<-90 then
			CurrentSteerVal=-90 
		end
		state.Gamepad.sThumbLX = 32767/90*CurrentSteerVal
	end	
end

uevr.sdk.callbacks.on_xinput_get_state(
function(retval, user_index, state)


--Read Gamepad stick input 
if isDriving and PhysicalDriving then
--INPUT OVerrides:	

	Drive(state)
end

end)







uevr.sdk.callbacks.on_pre_engine_tick(
	function(engine, delta)
	
	if ActiveHandState~=ActiveHandState then
		LastSteerVal=CurrentSteerVal
	end
	
	pawn=api:get_local_pawn(0)

	--print(isDriving)
UpdateHandState()

--degrees:	
CurrentHandRoll_Right= right_hand_component:K2_GetComponentRotation().z
CurrentHandRoll_Left= left_hand_component:K2_GetComponentRotation().z
--print(CurrentSteerVal)
--print(LastSteerVal)
--print("   ")
--print("   ")


	
end)


uevr.params.sdk.callbacks.on_early_calculate_stereo_view_offset(

function(device, view_index, world_to_meters, position, rotation, is_double)
--print(rotation.x)
	    

	--		if LastTickRot~=rotation.x then
	--		RotDiff = rotation.x -LastTickRot
	--		
	--		LastTickRot = rotation.x
	--		end
	--		print("RotDiff    :"..RotDiff)
	--RotSave=1
	--		else
	--	elseif TrState==0 then
	--		RotSave=0
	--		RotDiff=0
	--	end
	--	if RotSave == 1 then
	--		RotDiff=rotation.x - RotationXStart
	--	end
		
		--local FinalAngle=tostring(PositiveIntegerMask(DefaultOffset)/1000000+RotDiff)
		--uevr.params.vr.set_mod_value("VR_ControllerPitchOffset", FinalAngle)
		pawn=api:get_local_pawn(0)
		if pawn ~= nil and isDriving==false then
			pawn_pos = pawn.RootComponent:K2_GetComponentLocation()
			
			position.x = pawn_pos.x 
			position.y = pawn_pos.y -- +5
		elseif pawn~=nil and isDriving==true then
			
		end
	

end)