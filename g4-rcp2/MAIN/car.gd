extends RigidBody3D
##A class representing a car in VitaVehicle.
class_name ViVeCar

var stats:ViVeCarSS = ViVeCarSS.new()

var c_pws:Array[ViVeWheel]

##A set of wheels that are powered parented under the vehicle.
@export var Powered_Wheels:PackedStringArray = ["fl", "fr"]

@onready var front_left:ViVeWheel = $"fl"
@onready var front_right:ViVeWheel = $"fr"
@onready var back_left:ViVeWheel = $"rl"
@onready var back_right:ViVeWheel = $"rr"

##An array containing the front wheels of the car.
@onready var front_wheels:Array[ViVeWheel] = [front_left, front_right]
##An array containing the rear wheels of the car.
@onready var rear_wheels:Array[ViVeWheel] = [back_left, back_right]

##Whether or not debug mode is active. [br]
##TODO: Make this do more than just hide weight distribution.
@export var Debug_Mode :bool = false

@export_group("Controls")
@export var car_controls:ViVeCarControls = ViVeCarControls.new()
var car_controls_cache:ViVeCarControls.ControlType = ViVeCarControls.ControlType.CONTROLS_KEYBOARD_MOUSE
var _control_func:Callable = car_controls.controls_keyboard_mouse

@export var GearAssist:ViVeGearAssist = ViVeGearAssist.new()

@export_group("Meta")
@export var Controlled:bool = true

@export_group("Chassis")
##Vehicle weight in kilograms.
@export var Weight:float = 900.0 # kg

@export_group("Body")
##Up-pitch force based on the car’s velocity.
@export var LiftAngle:float = 0.1
##A force moving opposite in relation to the car’s velocity.
@export var DragCoefficient:float = 0.25
##A force moving downwards in relation to the car’s velocity.
@export var Downforce:float = 0.0

@export_group("Steering")
##The longitudinal pivot point from the car’s geometry (measured in default unit scale).
@export var AckermannPoint:float = -3.8
##Minimum turning circle (measured in default unit scale).
@export var Steer_Radius:float = 13.0

@export_group("Drivetrain")
##Final Drive Ratio refers to the last set of gears that connect a vehicle's engine to the driving axle.
@export var FinalDriveRatio:float = 4.250
##A set of gears a vehicle%ss transmission has in order. [br]
##A gear ratio is the ratio of the number of rotations of a driver gear to the number of rotations of a driven gear.
@export var GearRatios :Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
##The reversed equivalent to GearRatios, only containing one gear.
@export var ReverseRatio:float = 3.153
##Similar to FinalDriveRatio, but this should not relate to any real-life data. You may keep the value as it is.
@export var RatioMult:float = 9.5
##The amount of stress put into the transmission (as in accelerating or decelerating) to restrict clutchless gear shifting.
@export var StressFactor:float = 1.0
##A space between the teeth of all gears to perform clutchless gear shifts. Higher values means more noise. Compensate with StressFactor.
@export var GearGap:float = 60.0
## Leave this be, unless you know what you're doing.
@export var DSWeight:float = 150.0

##The [ViVeCar.TransmissionTypes] used for this car.
@export_enum("Fully Manual", "Automatic", "Continuously Variable", "Semi-Auto") var TransmissionType:int = 0

##Selection of transmission types that are implemented in VitaVehicle.
enum TransmissionTypes {
	full_manual = 0,
	auto = 1,
	continuous_variable = 2,
	semi_auto = 3
}

##Transmission automation settings (for Automatic, CVT and Semi-Auto).
class newAutoSettings:
	extends Resource
	## Shift rpm (auto).
	@export var shift_rpm:float = 6500.0
	## Downshift threshold (auto).
	@export var downshift_thresh:float = 300.0
	## Throttle efficiency threshold (auto/dct).
	@export_range(0, 1) var throt_eff_thresh:float = 0.5
	## Engagement rpm threshold (auto/dct/cvt).
	@export var engage_rpm_thresh:float = 0.0
	## Engagement rpm (auto/dct/cvt).
	@export var engage_rpm:float = 4000.0

@export var AutoSettings:Array[float] = [
6500.0, # shift rpm (auto)
300.0, # downshift threshold (auto)
0.5, # throttle efficiency threshold (range: 0 - 1) (auto/dct)
0.0, # engagement rpm threshold (auto/dct/cvt)
4000.0, # engagement rpm (auto/dct/cvt)
]

@export var CVTSettings:ViVeCVT = ViVeCVT.new()

@export_group("Stability")
@export var ABS:ViVeABS = ViVeABS.new()
@export var ESP:ViVeESP = ViVeESP.new()
@export var BTCS:ViVeBTCS = ViVeBTCS.new()
@export var TTCS:ViVeTTCS = ViVeTTCS.new()

@export_group("Differentials")
## Locks differential under acceleration.
@export var Locking:float = 0.1
## Locks differential under deceleration.
@export var CoastLocking:float = 0.0
## Static differential locking.
@export_range(0.0, 1.0) var Preload:float = 0.0
## Locks centre differential under acceleration.
@export var Centre_Locking:float = 0.5
## Locks centre differential under deceleration.
@export var Centre_CoastLocking:float = 0.5
## Static centre differential locking.
@export_range(0.0, 1.0) var Centre_Preload:float = 0.0

@export_group("Engine")
## Flywheel lightness.
@export var RevSpeed:float = 2.0 
## Chance of stalling.
@export var EngineFriction:float = 18000.0
## Rev drop rate.
@export var EngineDrag:float = 0.006
## How instant the engine corresponds with throttle input.
@export_range(0.0, 1.0) var ThrottleResponse:float = 0.5
## RPM below this threshold would stall the engine.
@export var DeadRPM:float = 100.0

@export_group("ECU")

@export var RPMLimit:float = 7000.0

@export var LimiterDelay:float = 4

@export var IdleRPM:float = 800.0

@export var ThrottleLimit:float = 0.0

@export var ThrottleIdle:float = 0.25

@export var VVTRPM:float = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

@export_group("Torque normal state")
@export var torque_norm:ViVeCarTorque = ViVeCarTorque.new()

@export_group("Torque")
@export var torque_vvt:ViVeCarTorque = ViVeCarTorque.new("VVT")

@export_group("Clutch")
@export var ClutchStable:float = 0.5
@export var GearRatioRatioThreshold:float = 200.0
@export var ThresholdStable:float = 0.01
@export var ClutchGrip:float = 176.125
@export var ClutchFloatReduction:float = 27.0
@export var ClutchWobble:float = 2.5 * 0
@export var ClutchElasticity:float = 0.2 * 0
@export var WobbleRate:float = 0.0

@export_group("Forced Inductions")
@export var MaxPSI:float = 9.0 # Maximum air generated by any forced inductions
@export var EngineCompressionRatio:float = 8.0 # Piston travel distance

@export_group("Turbo")
@export var TurboEnabled:bool = false # Enables turbo
@export var TurboAmount:float = 1.0 # Turbo power multiplication.
@export var TurboSize:float = 8.0 # Higher = More turbo lag
@export var Compressor:float = 0.3 # Higher = Allows more spooling on low RPM
@export var SpoolThreshold:float = 0.1 # Range: 0 - 0.9999
@export var BlowoffRate:float = 0.14
@export var TurboEfficiency:float = 0.075 # Range: 0 - 1
@export var TurboVacuum:float = 1.0 # Performance deficiency upon turbo idle

@export_group("Supercharger")
@export var SuperchargerEnabled:bool = false # Enables supercharger
@export var SCRPMInfluence:float = 1.0
@export var BlowRate:float = 35.0
@export var SCThreshold:float = 6.0

#TODO: Prepend any non-exported variables with a "_" so they are hidden from docs.

var rpm:float = 0.0
var rpmspeed:float = 0.0
var resistancerpm:float = 0.0
var resistancedv:float = 0.0

var limdel:float = 0.0
var actualgear:int = 0
var gearstress:float = 0.0
var throttle:float = 0.0
var cvtaccel:float = 0.0
var sassistdel:float = 0.0
var sassiststep:int = 0
var clutchpedalreal:float = 0.0
var abspump:float = 0.0
var tcsweight:float = 0.0
var tcsflash:bool = false
var espflash:bool = false
var ratio:float = 0.0
var vvt:bool = false
var brake_allowed:float = 0.0
var readout_torque:float = 0.0

var brakeline:float = 0.0
var dsweight:float = 0.0
var dsweightrun:float = 0.0
var diffspeed:float = 0.0
var diffspeedun:float = 0.0
var locked:float = 0.0
var c_locked:float = 0.0
var wv_difference:float = 0.0
var rpmforce:float = 0.0
var whinepitch:float = 0.0
var turbopsi:float = 0.0
var scrpm:float = 0.0
var boosting:float = 0.0
var rpmcs:float = 0.0
var rpmcsm:float = 0.0
var currentstable:float = 0.0
var steering_geometry:Array[float] = [0.0,0.0] #0 is x, 1 is z?
var resistance:float = 0.0
var wob:float = 0.0
var ds_weight:float = 0.0
var steer_torque:float = 0.0

var drivewheels_size:float = 1.0

var steering_angles:Array[float] = []
var max_steering_angle:float = 0.0


var pastvelocity:Vector3 = Vector3(0,0,0)
var gforce:Vector3 = Vector3(0,0,0)
var clock_mult:float = 1.0
var dist:float = 0.0
var stress:float = 0.0

var velocity:Vector3 = Vector3(0,0,0)
var rvelocity:Vector3 = Vector3(0,0,0)

var stalled:float = 0.0

func bullet_fix() -> void:
	var offset:Vector3 = $DRAG_CENTRE.position
	stats.AckermannPoint -= offset.z
	
	for i:Node in get_children():
		i.position -= offset

signal wheels_ready

func _ready() -> void:
#	bullet_fix()
	stats.rpm = stats.IdleRPM
	for i:String in Powered_Wheels:
		var wh:ViVeWheel = get_node(str(i))
		c_pws.append(wh)
	emit_signal("wheels_ready")

##Get the wheels of the car.
func get_wheels() -> Array[ViVeWheel]:
	return [front_left, front_right, back_left, back_right]

##Get the powered wheels of the car.
func get_powered_wheels() -> Array[ViVeWheel]:
	var return_this:Array[ViVeWheel] = []
	for wheels:String in Powered_Wheels:
		return_this.append(get_node(wheels))
	return return_this

func _mouse_wrapper() -> void:
	var mouseposx:float = 0.0
	if get_viewport().size.x > 0.0:
		mouseposx = get_viewport().get_mouse_position().x / get_viewport().size.x
	car_controls.controls_keyboard_mouse(mouseposx)

##Check which [Callable] to use for the car's controls.
func decide_controls() -> Callable:
	match car_controls.control_type as ViVeCarControls.ControlType:
		ViVeCarControls.ControlType.CONTROLS_KEYBOARD_MOUSE:
			return _mouse_wrapper
		ViVeCarControls.ControlType.CONTROLS_TOUCH:
			return car_controls.controls_touchscreen
		ViVeCarControls.ControlType.CONTROLS_JOYPAD:
			return car_controls.controls_joypad
	return _mouse_wrapper

func new_controls() -> void:
	if car_controls.control_type != car_controls_cache:
		_control_func = decide_controls()
		car_controls_cache = car_controls.control_type as ViVeCarControls.ControlType
	_control_func.call()

func controls() -> void:
	
	#Tbh I don't see why these need to be divided, but...
	if car_controls.UseMouseSteering:
		car_controls.gas = Input.is_action_pressed("gas_mouse")
		car_controls.brake = Input.is_action_pressed("brake_mouse")
		car_controls.su = Input.is_action_just_pressed("shiftup_mouse")
		car_controls.sd = Input.is_action_just_pressed("shiftdown_mouse")
		car_controls.handbrake = Input.is_action_pressed("handbrake_mouse")
	else:
		car_controls.gas = Input.is_action_pressed("gas")
		car_controls.brake = Input.is_action_pressed("brake")
		car_controls.su = Input.is_action_just_pressed("shiftup")
		car_controls.sd = Input.is_action_just_pressed("shiftdown")
		car_controls.handbrake = Input.is_action_pressed("handbrake")
	
	car_controls.left = Input.is_action_pressed("left")
	car_controls.right = Input.is_action_pressed("right")
	
	if car_controls.left:
		car_controls.steer_velocity -= 0.01
	elif car_controls.right:
		car_controls.steer_velocity += 0.01
	
	if car_controls.LooseSteering:
		car_controls.steer += car_controls.steer_velocity
		
		if abs(car_controls.steer) > 1.0:
			car_controls.steer_velocity *= -0.5
		
		for i:ViVeWheel in [front_left,front_right]:
			car_controls.steer_velocity += (i.directional_force.x * 0.00125) * i.Caster
			car_controls.steer_velocity -= (i.stress * 0.0025) * (atan2(abs(i.wv), 1.0) * i.angle)
			
			car_controls.steer_velocity += car_controls.steer * (i.directional_force.z * 0.0005) * i.Caster
			
			if i.position.x > 0:
				car_controls.steer_velocity += i.directional_force.z * 0.0001
			else:
				car_controls.steer_velocity -= i.directional_force.z * 0.0001
		
			car_controls.steer_velocity /= i.stress / (i.slip_percpre * (i.slip_percpre * 100.0) + 1.0) + 1.0
	
	if Controlled:
		if GearAssist.assist_level == 2:
			if (car_controls.gas and not car_controls.gasrestricted and not car_controls.gear == -1) or (car_controls.brake and car_controls.gear == -1) or car_controls.revmatch:
				car_controls.gaspedal += car_controls.OnThrottleRate / clock_mult
			else:
				car_controls.gaspedal -= car_controls.OffThrottleRate / clock_mult
			if (car_controls.brake and not car_controls.gear == -1) or (car_controls.gas and car_controls.gear == -1):
				car_controls.brakepedal += car_controls.OnBrakeRate / clock_mult
			else:
				car_controls.brakepedal -= car_controls.OffBrakeRate / clock_mult
		else:
			if GearAssist.assist_level == 0:
				car_controls.gasrestricted = false
				car_controls.clutchin = false
				car_controls.revmatch = false
			
			if car_controls.gas and not car_controls.gasrestricted or car_controls.revmatch:
				car_controls.gaspedal += car_controls.OnThrottleRate / clock_mult
			else:
				car_controls.gaspedal -= car_controls.OffThrottleRate / clock_mult
			
			if car_controls.brake:
				car_controls.brakepedal += car_controls.OnBrakeRate / clock_mult
			else:
				car_controls.brakepedal -= car_controls.OffBrakeRate / clock_mult
		
		if car_controls.handbrake:
			car_controls.handbrakepull += car_controls.OnHandbrakeRate / clock_mult
		else:
			car_controls.handbrakepull -= car_controls.OffHandbrakeRate / clock_mult
		
		var siding:float = abs(velocity.x)
		
		#Based on the syntax, I'm unsure if this is doing what it "should" do...?
		if (velocity.x > 0 and car_controls.steer2 > 0) or (velocity.x < 0 and car_controls.steer2 < 0):
			siding = 0.0
		
		var going:float = velocity.z / (siding + 1.0)
		going = maxf(going, 0)
		
		#Steer based on control options
		if not car_controls.LooseSteering:
			
			if car_controls.UseMouseSteering:
				var mouseposx:float = 0.0
				if get_viewport().size.x > 0.0:
					mouseposx = get_viewport().get_mouse_position().x / get_viewport().size.x
				
				
				car_controls.steer2 = (mouseposx - 0.5) * 2.0
				car_controls.steer2 *= car_controls.SteerSensitivity
				
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
				
				var s:float = abs(car_controls.steer2) * 1.0 + 0.5
				s = minf(s, 1.0)
				
				car_controls.steer2 *= s
				mouseposx = (mouseposx - 0.5) * 2.0
				#steer2 = control_steer_analog(mouseposx)
				
				#steer2 = control_steer_analog(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
				
			elif car_controls.UseAccelerometreSteering:
				car_controls.steer2 = Input.get_accelerometer().x / 10.0
				car_controls.steer2 *= car_controls.SteerSensitivity
				
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
				
				var s:float = abs(car_controls.steer2) * 1.0 +0.5
				s = minf(s, 1.0)
				
				car_controls.steer2 *= s
			else:
				if car_controls.right:
					if car_controls.steer2 > 0:
						car_controls.steer2 += car_controls.KeyboardSteerSpeed
					else:
						car_controls.steer2 += car_controls.KeyboardCompensateSpeed
				elif car_controls.left:
					if car_controls.steer2 < 0:
						car_controls.steer2 -= car_controls.KeyboardSteerSpeed
					else:
						car_controls.steer2 -= car_controls.KeyboardCompensateSpeed
				else:
					if car_controls.steer2 > car_controls.KeyboardReturnSpeed:
						car_controls.steer2 -= car_controls.KeyboardReturnSpeed
					elif car_controls.steer2 < - car_controls.KeyboardReturnSpeed:
						car_controls.steer2 += car_controls.KeyboardReturnSpeed
					else:
						car_controls.steer2 = 0.0
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
			
			
			if car_controls.assistance_factor > 0.0:
				var maxsteer:float = 1.0 / (going * (car_controls.SteerAmountDecay / car_controls.assistance_factor) + 1.0)
				
				var assist_commence:float = linear_velocity.length() / 10.0
				assist_commence = minf(assist_commence, 1.0)
				
				car_controls.steer = (car_controls.steer2 * maxsteer) - (velocity.normalized().x * assist_commence) * (car_controls.SteeringAssistance * car_controls.assistance_factor) + rvelocity.y * (car_controls.SteeringAssistanceAngular * car_controls.assistance_factor)
			else:
				car_controls.steer = car_controls.steer2

func limits() -> void:
	car_controls.gaspedal = clampf(car_controls.gaspedal, 0.0, car_controls.MaxThrottle)
	car_controls.brakepedal = clampf(car_controls.brakepedal, 0.0, car_controls.MaxBrake)
	car_controls.handbrakepull = clampf(car_controls.handbrakepull, 0.0, car_controls.MaxHandbrake)
	car_controls.steer = clampf(car_controls.steer, -1.0, 1.0)

func transmission() -> void:
	car_controls.su = (Input.is_action_just_pressed("shiftup") and not car_controls.UseMouseSteering) or (Input.is_action_just_pressed("shiftup_mouse") and car_controls.UseMouseSteering)
	car_controls.sd = (Input.is_action_just_pressed("shiftdown") and not car_controls.UseMouseSteering) or (Input.is_action_just_pressed("shiftdown_mouse") and car_controls.UseMouseSteering)
	
	#var clutch:bool
	car_controls.clutch = Input.is_action_pressed("clutch") and not car_controls.UseMouseSteering or Input.is_action_pressed("clutch_mouse") and car_controls.UseMouseSteering
	if not GearAssist.assist_level == 0:
		car_controls.clutch = Input.is_action_pressed("handbrake") and not car_controls.UseMouseSteering or Input.is_action_pressed("handbrake_mouse") and car_controls.UseMouseSteering
	car_controls.clutch = not car_controls.clutch
	
	if TransmissionType == 0:
		if car_controls.clutch and not car_controls.clutchin:
			clutchpedalreal -= car_controls.OffClutchRate / clock_mult
		else:
			clutchpedalreal += car_controls.OnClutchRate / clock_mult
		
		clutchpedalreal = clamp(clutchpedalreal, 0, car_controls.MaxClutch)
		
		car_controls.clutchpedal = 1.0 - clutchpedalreal
		
		if car_controls.gear > 0:
			ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		elif car_controls.gear == -1:
			ratio = ReverseRatio * FinalDriveRatio * RatioMult
		if GearAssist.assist_level == 0:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					if gearstress < GearGap:
						actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					if gearstress < GearGap:
						actualgear -= 1
		elif GearAssist.assist_level == 1:
			if rpm < GearAssist.clutch_out_RPM:
				var irga_ca:float = (GearAssist.clutch_out_RPM - rpm) / (GearAssist.clutch_out_RPM - IdleRPM)
				clutchpedalreal = pow(irga_ca, 2)
				clutchpedalreal = minf(1.0, clutchpedalreal)
			else:
				if not car_controls.gasrestricted and not car_controls.revmatch:
					car_controls.clutchin = false
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					if rpm < GearAssist.clutch_out_RPM:
						actualgear += 1
					else:
						if actualgear < 1:
							actualgear += 1
							if rpm > GearAssist.clutch_out_RPM:
								car_controls.clutchin = false
						else:
							if sassistdel > 0:
								actualgear += 1
							sassistdel = GearAssist.shift_delay / 2.0
							sassiststep = -4
							
							car_controls.clutchin = true
							car_controls.gasrestricted = true
			elif car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					if rpm < GearAssist.clutch_out_RPM:
						actualgear -= 1
					else:
						if actualgear == 0 or actualgear == 1:
							actualgear -= 1
							car_controls.clutchin = false
						else:
							if sassistdel > 0:
								actualgear -= 1
							sassistdel = GearAssist.shift_delay / 2.0
							sassiststep = -2
							
							car_controls.clutchin = true
							car_controls.revmatch = true
							car_controls.gasrestricted = false
		elif GearAssist.assist_level == 2:
			var assistshiftspeed:float = (GearAssist.upshift_RPM / ratio) * GearAssist.speed_influence
			var assistdownshiftspeed:float = (GearAssist.down_RPM / abs((GearRatios[car_controls.gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssist.speed_influence
			if car_controls.gear == 0:
				if car_controls.gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif car_controls.brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length() < 5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					sassistdel = 60
					actualgear = 0
			if sassiststep == 0:
				if rpm < GearAssist.clutch_out_RPM:
					var irga_ca:float = (GearAssist.clutch_out_RPM - rpm) / (GearAssist.clutch_out_RPM - IdleRPM)
					clutchpedalreal = irga_ca * irga_ca
					clutchpedalreal = minf(clutchpedalreal, 1.0)
					
				else:
					car_controls.clutchin = false
				if not car_controls.gear == -1:
					if car_controls.gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						sassistdel = GearAssist.shift_delay / 2.0
						sassiststep = -4
						
						car_controls.clutchin = true
						car_controls.gasrestricted = true
					if car_controls.gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						sassistdel = GearAssist.shift_delay / 2.0
						sassiststep = -2
						
						car_controls.clutchin = true
						car_controls.gasrestricted = false
						car_controls.revmatch = true
		
		if sassiststep == -4 and sassistdel < 0:
			sassistdel = GearAssist.shift_delay / 2.0
			if car_controls.gear < len(GearRatios):
				actualgear += 1
			sassiststep = -3
		elif sassiststep == -3 and sassistdel < 0:
			if rpm > GearAssist.clutch_out_RPM:
				car_controls.clutchin = false
			if sassistdel < - GearAssist.input_delay:
				sassiststep = 0
				car_controls.gasrestricted = false
		elif sassiststep == -2 and sassistdel < 0:
			sassiststep = 0
			if car_controls.gear > -1:
				actualgear -= 1
			if rpm > GearAssist.clutch_out_RPM:
				car_controls.clutchin = false
			car_controls.gasrestricted = false
			car_controls.revmatch = false
		car_controls.gear = actualgear
	
	elif TransmissionType == 1:
		car_controls.clutchpedal = (rpm - float(AutoSettings[3]) * (car_controls.gaspedal * float(AutoSettings[2]) + (1.0 - float(AutoSettings[2]))) ) / float(AutoSettings[4])
		
		if not GearAssist.assist_level == 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < 1:
					actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					actualgear -= 1
		else:
			if car_controls.gear == 0:
				if car_controls.gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif car_controls.brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					sassistdel = 60
					actualgear = 0
				
		if actualgear == -1:
			ratio = ReverseRatio * FinalDriveRatio * RatioMult
		else:
			ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		if actualgear > 0:
			var lastratio:float = GearRatios[car_controls.gear - 2] * FinalDriveRatio * RatioMult
			car_controls.su = false
			car_controls.sd = false
			for i:ViVeWheel in c_pws:
				if (i.wv / GearAssist.speed_influence) > (float(AutoSettings[0]) * (car_controls.gaspedal *float(AutoSettings[2]) + (1.0 - float(AutoSettings[2])))) / ratio:
					car_controls.su = true
				elif (i.wv / GearAssist.speed_influence) < ((float(AutoSettings[0]) - float(AutoSettings[1])) * (car_controls.gaspedal * float(AutoSettings[2]) + (1.0 - float(AutoSettings[2])))) / lastratio:
					car_controls.sd = true
					
			if car_controls.su:
				car_controls.gear += 1
			elif car_controls.sd:
				car_controls.gear -= 1
			
			car_controls.gear = clampi(car_controls.gear, 1, len(GearRatios))
			
		else:
			car_controls.gear = actualgear
	elif TransmissionType == 2:
		
		car_controls.clutchpedal = (rpm - float(AutoSettings[3]) * (car_controls.gaspedal * float(AutoSettings[2]) + (1.0 - float(AutoSettings[2]))) ) / float(AutoSettings[4])
		
			#clutchpedal = 1
		
		if not GearAssist.assist_level == 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < 1:
					actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					actualgear -= 1
		else:
			if car_controls.gear == 0:
				if car_controls.gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif car_controls.brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length() < 5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					sassistdel = 60
					actualgear = 0
		
		car_controls.gear = actualgear
		var wv:float = 0.0
		
		for i:ViVeWheel in c_pws:
			wv += i.wv / len(c_pws)
		
		cvtaccel -= (cvtaccel - (car_controls.gaspedal * CVTSettings.throt_eff_thresh + (1.0 - CVTSettings.throt_eff_thresh))) * CVTSettings.accel_rate
		
		var a:float = CVTSettings.iteration_3 / ((abs(wv) / 10.0) * cvtaccel + 1.0)
		
		a = maxf(a, CVTSettings.iteration_4)
		
		ratio = (CVTSettings.iteration_1 * 10000000.0) / (abs(wv) * (rpm * a) + 1.0)
		
		
		ratio = minf(ratio, CVTSettings.iteration_2)
	
	elif TransmissionType == 3:
		car_controls.clutchpedal = (rpm - float(AutoSettings[3]) * (car_controls.gaspedal * float(AutoSettings[2]) + (1.0 - float(AutoSettings[2]))) ) /float(AutoSettings[4])
		
		if car_controls.gear > 0:
			ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		elif car_controls.gear == -1:
			ratio = ReverseRatio * FinalDriveRatio * RatioMult
		
		if GearAssist.assist_level < 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					actualgear -= 1
		else:
			var assistshiftspeed:float = (GearAssist.upshift_RPM / ratio) * GearAssist.speed_influence
			var assistdownshiftspeed:float = (GearAssist.down_RPM / abs((GearRatios[car_controls.gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssist.speed_influence
			if car_controls.gear == 0:
				if car_controls.gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif car_controls.brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					sassistdel = 60
					actualgear = 0
			if sassiststep == 0:
				if not car_controls.gear == -1:
					if car_controls.gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						actualgear += 1
					if car_controls.gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						actualgear -= 1
		
		car_controls.gear = actualgear
	
	car_controls.clutchpedal = clampf(car_controls.clutchpedal, 0.0, 1.0)

func drivetrain() -> void:
	
		rpmcsm -= (rpmcs - resistance)
	
		rpmcs += rpmcsm * ClutchElasticity
		
		rpmcs -= rpmcs * (1.0 - car_controls.clutchpedal)
		
		wob = ClutchWobble * car_controls.clutchpedal
		
		wob *= ratio * WobbleRate
		
		rpmcs -= (rpmcs - resistance) * (1.0 / (wob + 1.0))
		
		#torquereadout = multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,rpm,DeclineRPM,DeclineRate,FloatRate,turbopsi,TurboAmount,EngineCompressionRatio,TurboEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SuperchargerEnabled,SCRPMInfluence,BlowRate,SCThreshold)
		if car_controls.gear < 0:
			rpm -= ((rpmcs * 1.0) / clock_mult) * (RevSpeed / 1.475)
		else:
			rpm += ((rpmcs * 1.0) / clock_mult) * (RevSpeed / 1.475)
		
		if "": #...what-
			rpm = 7000.0
			Locking = 0.0
			CoastLocking = 0.0
			Centre_Locking = 0.0
			Centre_CoastLocking = 0.0
			Preload = 1.0
			Centre_Preload = 1.0
			ClutchFloatReduction = 0.0
		
		gearstress = (abs(resistance) * StressFactor) * car_controls.clutchpedal
		var stabled:float = ratio * 0.9 + 0.1
		ds_weight = DSWeight / stabled
		
		whinepitch = abs(rpm / ratio) * 1.5
		
		if resistance > 0.0:
			locked = abs(resistance / ds_weight) * (CoastLocking / 100.0) + Preload
		else:
			locked = abs(resistance / ds_weight) * (Locking / 100.0) + Preload
		
		locked = clampf(locked, 0.0, 1.0)
		
		if wv_difference > 0.0:
			c_locked = abs(wv_difference) * (Centre_CoastLocking / 10.0) + Centre_Preload
		else:
			c_locked = abs(wv_difference) * (Centre_Locking / 10.0) + Centre_Preload
		if c_locked < 0.0 or len(c_pws) < 4:
			c_locked = 0.0
		elif c_locked > 1.0:
			c_locked = 1.0
		#c_locked = minf(c_locked, 1.0)
		
		var maxd:ViVeWheel = VitaVehicleSimulation.fastest_wheel(c_pws)
		#var mind:ViVeWheel = VitaVehicleSimulation.slowest_wheel(c_pws)
		var what:float = 0.0
		
		var floatreduction:float = ClutchFloatReduction
		
		if dsweightrun > 0.0:
			floatreduction = ClutchFloatReduction / dsweightrun
		else:
			floatreduction = 0.0
		
		var stabling:float = - (GearRatioRatioThreshold - ratio * drivewheels_size) * ThresholdStable
		stabling = maxf(stabling, 0.0)
		
		currentstable = ClutchStable + stabling
		currentstable *= (RevSpeed / 1.475)
		
		if dsweightrun > 0.0:
			what = (rpm -(((rpmforce * floatreduction) * pow(currentstable, 1.0)) / (ds_weight / dsweightrun)))
		else:
			what = rpm
			
		if car_controls.gear < 0.0:
			dist = maxd.wv + what / ratio
		else:
			dist = maxd.wv - what / ratio
		
		dist *= (car_controls.clutchpedal * car_controls.clutchpedal)
		
		if car_controls.gear == 0:
			dist *= 0.0
		
		wv_difference = 0.0
		drivewheels_size = 0.0
		for i:ViVeWheel in c_pws:
			drivewheels_size += i.w_size / len(c_pws)
			i.c_p = i.W_PowerBias
			wv_difference += ((i.wv - what / ratio) / (len(c_pws))) * (car_controls.clutchpedal * car_controls.clutchpedal)
			if car_controls.gear < 0:
				i.dist = dist * (1 - c_locked) + (i.wv + what / ratio) * c_locked
			else:
				i.dist = dist * (1 - c_locked) + (i.wv - what / ratio) * c_locked
			if car_controls.gear == 0:
				i.dist *= 0.0
		GearAssist.speed_influence = drivewheels_size
		resistance = 0.0
		dsweightrun = dsweight
		dsweight = 0.0
		tcsweight = 0.0
		stress = 0.0

func aero() -> void:
	var drag:float = DragCoefficient
	#var df:float = Downforce
	
#	var veloc = global_transform.basis.orthonormalized().xform_inv(linear_velocity)
	var veloc:Vector3 = global_transform.basis.orthonormalized().transposed() * (linear_velocity)
	
#	var torq = global_transform.basis.orthonormalized().xform_inv(Vector3(1,0,0))
	#var torq = global_transform.basis.orthonormalized().transposed() * (Vector3(1,0,0))
	
#	apply_torque_impulse(global_transform.basis.orthonormalized().xform( Vector3(((-veloc.length()*0.3)*LiftAngle),0,0)  ) )
	apply_torque_impulse(global_transform.basis.orthonormalized() * ( Vector3(((-veloc.length() * 0.3) * LiftAngle), 0, 0) ) )
	
	var vx:float = veloc.x * 0.15
	var vy:float = veloc.z * 0.15
	var vz:float = veloc.y * 0.15
	var vl:float = veloc.length() * 0.15
	
#	var forc = global_transform.basis.orthonormalized().xform(Vector3(1,0,0))*(-vx*drag)
	var forc:Vector3 = global_transform.basis.orthonormalized() * (Vector3(1, 0, 0)) * (- vx * drag)
#	forc += global_transform.basis.orthonormalized().xform(Vector3(0,0,1))*(-vy*drag)
	forc += global_transform.basis.orthonormalized() * (Vector3(0, 0, 1)) * (- vy * drag)
#	forc += global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*(-vl*df -vz*drag)
	forc += global_transform.basis.orthonormalized() * (Vector3(0, 1, 0)) * (- vl * Downforce - vz * drag)
	
	if has_node("DRAG_CENTRE"):
#		apply_impulse(global_transform.basis.orthonormalized().xform($DRAG_CENTRE.position),forc)
		apply_impulse(forc, global_transform.basis.orthonormalized() * ($DRAG_CENTRE.position))
	else:
		apply_central_impulse(forc)

func _physics_process(_delta:float) -> void:
	
	if len(steering_angles) > 0:
		max_steering_angle = 0.0
		for i:float in steering_angles:
			max_steering_angle = maxf(max_steering_angle,i)
		
		car_controls.assistance_factor = 90.0 / max_steering_angle
	steering_angles = []
	
	if car_controls.Use_Global_Control_Settings:
		car_controls = VitaVehicleSimulation.universal_controls
		
		GearAssist.assist_level = VitaVehicleSimulation.GearAssistant
	
	if Input.is_action_just_pressed("toggle_debug_mode"):
		if Debug_Mode:
			Debug_Mode = false
		else:
			Debug_Mode = true
	
#	velocity = global_transform.basis.orthonormalized().xform_inv(linear_velocity)
	velocity = global_transform.basis.orthonormalized().transposed() * (linear_velocity)
#	rvelocity = global_transform.basis.orthonormalized().xform_inv(angular_velocity)
	rvelocity = global_transform.basis.orthonormalized().transposed() * (angular_velocity)
	
	#if not mass == Weight / 10.0:
	#	mass = Weight/10.0
	mass = Weight / 10.0
	aero()
	
	gforce = (linear_velocity - pastvelocity) * ((0.30592 / 9.806) * 60.0)
	pastvelocity = linear_velocity
	
#	gforce = global_transform.basis.orthonormalized().xform_inv(gforce)
	gforce = global_transform.basis.orthonormalized().transposed() * (gforce)
	
	car_controls.front_left = front_left
	car_controls.front_right = front_right
	car_controls.velocity = velocity
	car_controls.rvelocity = rvelocity
	car_controls.linear_velocity = linear_velocity
	car_controls.GearAssist = GearAssist
	new_controls()
	#controls()
	
	ratio = 10.0
	
	sassistdel -= 1
	
	transmission()
	
	car_controls.gaspedal = clampf(car_controls.gaspedal, 0.0, car_controls.MaxThrottle)
	car_controls.brakepedal = clampf(car_controls.brakepedal, 0.0, car_controls.MaxBrake)
	car_controls.handbrakepull = clampf(car_controls.handbrakepull, 0.0, car_controls.MaxHandbrake)
	car_controls.steer = clampf(car_controls.steer, -1.0, 1.0)
	
	var steeroutput:float = car_controls.steer
	
	var uhh:float = (max_steering_angle / 90.0) * (max_steering_angle / 90.0)
	uhh *= 0.5
	steeroutput *= abs(car_controls.steer) * (uhh) + (1.0 - uhh)
	
	if abs(steeroutput) > 0.0:
		steering_geometry = [ 
			- Steer_Radius / steeroutput, 
			AckermannPoint
		]
		#steering_geometry[0] = (- Steer_Radius / steeroutput)
		#steering_geometry[1] = AckermannPoint
	
	abspump -= 1    
	
	if abspump < 0:
		brake_allowed += ABS.pump_force
	else:
		brake_allowed -= ABS.pump_force
	
	brake_allowed = clampf(brake_allowed, 0.0, 1.0)
	
	brakeline = car_controls.brakepedal * brake_allowed
	
	brakeline = maxf(brakeline, 0.0)
	
	limdel -= 1
	
	if limdel < 0:
		throttle -= (throttle - (car_controls.gaspedal / (tcsweight * car_controls.clutchpedal + 1.0))) * (ThrottleResponse / clock_mult)
	else:
		throttle -= throttle * (ThrottleResponse / clock_mult)
	
	if rpm > RPMLimit:
		if throttle > ThrottleLimit:
			throttle = ThrottleLimit
			limdel = LimiterDelay
	elif rpm < IdleRPM:
		throttle = maxf(throttle, ThrottleIdle)
	
	#var stab:float = 300.0
	var thr:float = 0.0
	
	if TurboEnabled:
		thr = (throttle - SpoolThreshold) / (1 - SpoolThreshold)
		
		if boosting > thr:
			boosting = thr
		else:
			boosting -= (boosting - thr) * TurboEfficiency
		 
		turbopsi += (boosting * rpm) / ((TurboSize / Compressor) * 60.9)
		
		turbopsi -= turbopsi * BlowoffRate
		
		turbopsi = minf(turbopsi, MaxPSI)
		
		turbopsi = maxf(turbopsi, -TurboVacuum)
	
	elif SuperchargerEnabled:
		scrpm = rpm * SCRPMInfluence
		turbopsi = (scrpm / 10000.0) * BlowRate - SCThreshold
		
		turbopsi = clampf(turbopsi, 0.0, MaxPSI)
	
	else:
		turbopsi = 0.0
	
	vvt = rpm > VVTRPM
	
	var torque:float = 0.0
	
	var torque_local:ViVeCarTorque
	if vvt:
		torque_local = torque_vvt
	else:
		torque_local = torque_norm
	
	var f:float = rpm - torque_local.RiseRPM
	f = maxf(f, 0.0)
	
	torque = (rpm * torque_local.BuildUpTorque + torque_local.OffsetTorque + (f * f) * (torque_local.TorqueRise / 10000000.0)) * throttle
	torque += ( (turbopsi * TurboAmount) * (EngineCompressionRatio * 0.609) )
	
	var j:float = rpm - torque_local.DeclineRPM
	j = maxf(j, 0.0)
	
	torque /= (j * (j * torque_local.DeclineSharpness + (1.0 - torque_local.DeclineSharpness))) * (torque_local.DeclineRate / 10000000.0) + 1.0
	torque /= abs(rpm * abs(rpm)) * (torque_local.FloatRate / 10000000.0) + 1.0
	
	rpmforce = (rpm / (abs(rpm * abs(rpm)) / (EngineFriction / clock_mult) + 1.0)) * 1.0
	if rpm < DeadRPM:
		torque = 0.0
		rpmforce /= 5.0
		stalled = 1.0 - rpm / DeadRPM
	else:
		stalled = 0.0
	
	rpmforce += (rpm * (EngineDrag / clock_mult)) * 1.0
	rpmforce -= (torque / clock_mult) * 1.0
	rpm -= rpmforce * RevSpeed
	
	drivetrain()


var front_load:float = 0.0
var total:float = 0.0

var weight_dist:Array[float] = [0.0,0.0]

func _process(_delta:float) -> void:
	if Debug_Mode:
		front_wheels = []
		rear_wheels = []
		#Why is this run?
		for i:ViVeWheel in get_wheels():
			if i.position.z > 0:
				front_wheels.append(i)
			else:
				rear_wheels.append(i)
		
		front_load = 0.0
		total = 0.0
		
		for f:ViVeWheel in front_wheels:
			front_load += f.directional_force.y
			total += f.directional_force.y
		for r:ViVeWheel in rear_wheels:
			front_load -= r.directional_force.y
			total += r.directional_force.y
		
		if total > 0:
			weight_dist[0] = (front_load / total) * 0.5 + 0.5
			weight_dist[1] = 1.0 - weight_dist[0]
	
	#readout_torque = VitaVehicleSimulation.multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,rpm,DeclineRPM,DeclineRate,FloatRate,MaxPSI,TurboAmount,EngineCompressionRatio,TurboEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SuperchargerEnabled,SCRPMInfluence,BlowRate,SCThreshold,DeclineSharpness,VVT_DeclineSharpness)
	readout_torque = VitaVehicleSimulation.multivariate(self)
