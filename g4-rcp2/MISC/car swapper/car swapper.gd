extends ScrollContainer

@onready var button:Button = $container/_DEFAULT.duplicate()
@onready var default_position:Vector3 #= ViVeEnvironment.get_singleton().car.global_position

const base_path:String = "res://MISC/car swapper/"
var loaded_car_full_path:String
var car_packed_scene:PackedScene

signal threaded_car_load_done
var loading_check_thread:Thread = Thread.new()


var literal_cache:Dictionary = {}

func list_files_in_directory(path:String) -> PackedStringArray:
	var files:PackedStringArray = []
	var dir:DirAccess = DirAccess.open(path)
	
	dir.list_dir_begin()
	
	while true:
		var file:String = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

func load_and_cache(path:String) -> PackedScene:
	if not literal_cache.has(path):
		literal_cache[path] = load(path)
	
	return literal_cache[path]

func swapcar(naem:String) -> void:
	#old_load_car(naem)
	threaded_load_car(naem)

##The old way to switch cars. This is single threaded and causes a lag spike.
func old_load_car(naem:String) -> void:
	ViVeDebug.singleton.get_node("vgs").clear()
	
	default_position = ViVeEnvironment.get_singleton().car.global_position
	
	var control_cache:ViVeCarControls = ViVeEnvironment.get_singleton().car.car_controls
	
	ViVeEnvironment.get_singleton().car.queue_free()
	
	await get_tree().create_timer(1.0).timeout
	
	var d:ViVeCar
	
	if naem == "_DEFAULT_CAR_":
		d = load_and_cache("res://base car.tscn").instantiate()
	else:
		d = load_and_cache(base_path + "cars/"+ naem + "/scene.tscn").instantiate()
	
	ViVeEnvironment.get_singleton().add_child(d)
	ViVeEnvironment.get_singleton().car = d
	
	ViVeEnvironment.get_singleton().car.car_controls = control_cache
	
	d.global_position = default_position + Vector3(0, 5, 0)
	
	var debug_child:ViVeTachometer = ViVeDebug.singleton.get_node("tacho")
	
	debug_child.Redline = int(float(d.RPMLimit / 1000.0)) * 1000
	debug_child.RPM_Range = int(float(d.RPMLimit / 1000.0)) * 1000 + 2000
	debug_child.Turbo_Visible = d.TurboEnabled
	debug_child.Max_PSI = d.MaxPSI * d.TurboAmount
	
	debug_child._ready()
	
	ViVeDebug.singleton.setup()

##Part 1 of loading a car with threaded loading. Causes minimal lag.
func threaded_load_car(naem:String) -> void:
	ViVeDebug.singleton.get_node("vgs").clear()
	
	default_position = ViVeEnvironment.get_singleton().car.global_position
	
	var control_cache:ViVeCarControls = ViVeEnvironment.get_singleton().car.car_controls
	
	if naem == "_DEFAULT_CAR_":
		loaded_car_full_path = "res://base car.tscn"
	else:
		loaded_car_full_path = base_path + "cars/"+ naem + "/scene.tscn"
	
	connect("threaded_car_load_done", threaded_load_car_step_2, CONNECT_ONE_SHOT)
	ResourceLoader.load_threaded_request(loaded_car_full_path, "PackedScene", true, ResourceLoader.CACHE_MODE_REUSE)
	loading_check_thread.start(threaded_load_check_loading, Thread.PRIORITY_NORMAL)

func threaded_load_car_step_2() -> void:
	loading_check_thread.wait_to_finish()
	assert(car_packed_scene != null, "Car did not load properly")
	
	var control_cache:ViVeCarControls = ViVeEnvironment.get_singleton().car.car_controls
	var new_car:ViVeCar = car_packed_scene.instantiate()
	
	ViVeEnvironment.get_singleton().car.queue_free()
	ViVeEnvironment.get_singleton().add_child(new_car)
	ViVeEnvironment.get_singleton().car = new_car
	
	ViVeEnvironment.get_singleton().car.car_controls = control_cache
	
	new_car.global_position = default_position + Vector3(0, 5, 0)
	
	var debug_child:ViVeTachometer = ViVeDebug.singleton.get_node("tacho")
	
	debug_child.Redline = int(float(new_car.RPMLimit / 1000.0)) * 1000
	debug_child.RPM_Range = int(float(new_car.RPMLimit / 1000.0)) * 1000 + 2000
	debug_child.Turbo_Visible = new_car.TurboEnabled
	debug_child.Max_PSI = new_car.MaxPSI * new_car.TurboAmount
	
	debug_child._ready()
	
	ViVeDebug.singleton.setup()

func threaded_load_check_loading() -> void:
	var status:ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(loaded_car_full_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		car_packed_scene = ResourceLoader.load_threaded_get(loaded_car_full_path)
		emit_signal.call_deferred("threaded_car_load_done")
	elif (status == ResourceLoader.THREAD_LOAD_FAILED) or (status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE):
		car_packed_scene = null
		emit_signal.call_deferred("threaded_car_load_done")
	

func _ready() -> void:
	var d:PackedStringArray = list_files_in_directory(base_path + "cars")
	
	for i:String in d:
		var but:Button = button.duplicate()
		$container.add_child(but)
		but.get_node("carname").text = i
		but.get_node("icon").texture = load(base_path + "cars/" + i + "/thumbnail.png")
#		but.connect("pressed", self, "swapcar",[i])
		but.pressed.connect(swapcar.bind(i))
	
#	$scroll/container/_DEFAULT.connect("pressed", self, "swapcar",["_DEFAULT_CAR_"])
	$container/_DEFAULT.pressed.connect(swapcar.bind("_DEFAULT_CAR_"))
