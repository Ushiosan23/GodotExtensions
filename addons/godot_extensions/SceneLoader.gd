# This node is not visible in scene
extends Node

# Register class in godot
class_name SceneLoader

# ---------------------------------------------------
# Signals
# ---------------------------------------------------

# Called when any scene loading started
signal loading_started()

# Called when scene is loading and get progress loading
signal loading_progress(progress)

# Called when scene finished to load
signal loading_finished()

# Called when loading failed
signal loading_failed()

# ---------------------------------------------------
# Properties
# ---------------------------------------------------

# Max time to wait in scene
var _max_loading_time: int = 0

# Loading status
var _is_loading: bool = false

# Native scene loader object
var _scene_loader: ResourceInteractiveLoader = null

# Result of interactive resource
var _result_resource: Resource = null

# ---------------------------------------------------
# Implemented methods
# ---------------------------------------------------

# Initialize object
func _init(max_time: int = 1000 * 60):
    _max_loading_time = max_time

# Called each frame
func _process(_delta: float):
    # Check loading status
    if !_is_loading || _scene_loader == null:
        return

    # Load scene
    var ticks = OS.get_ticks_msec()
    # Check time loading
    while OS.get_ticks_msec() < ticks + _max_loading_time:
        # Create poll
        var poll_err = _scene_loader.poll()
        # Check poll status
        if poll_err == ERR_FILE_EOF: # Finish loading
            _result_resource = _scene_loader.get_resource()
            _scene_loader = null
            _is_loading = false
            emit_signal("loading_finished")
            break
        elif poll_err == OK: # Progress loading
            var progress = _scene_loader.get_stage() * 100.0 / _scene_loader.get_stage_count()
            emit_signal("loading_progress", progress)
            break
        else:
            printerr("Error to load scene resource")
            _scene_loader = null
            _is_loading = false
            emit_signal("loading_failed")
            break

# ---------------------------------------------------
# Custom methods
# ---------------------------------------------------

# Get resource result
func get_result_resource() -> Resource:
    return _result_resource

# Load scene from custom location
func load_scene(location: String):
    # Create resource loader
    _scene_loader = ResourceLoader.load_interactive(location)
    # Check if scene is valid
    if _scene_loader == null:
        printerr("Error to load scene location: ", location, " is not valid")
        return
    # Start loading scene
    _is_loading = true
    # Emit signal
    emit_signal("loading_started")
