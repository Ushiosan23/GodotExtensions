# This node is only used to manage instances
extends Position2D

# Create instances in scene
class_name NodeFactory

# ---------------------------------------------------
# Signals
# ---------------------------------------------------

# Called when instance was created
signal instance_created(node)

# Called when instance attached in scene
# warning-ignore: unused_signal
signal instance_attached(node)

# ---------------------------------------------------
# Properties
# ---------------------------------------------------

# Target scene to load
export var resource_scene: PackedScene

# Target node to attach instances
export var target_node_path: NodePath

# Create instances automatically
export var create_automatically: bool = false

# How many time needs to instance element
# Only works if create_automatically is true
export(float, 0, 1000, 0.1) var instance_time: float = 0.0

# ---------------------------------------------------
# Internal properties
# ---------------------------------------------------

# Node instance
var _target_node: Node = null

# Time counter
var _counter: float = 0

# ---------------------------------------------------
# Implemented methods
# ---------------------------------------------------

# Called when node is in screen and visible
func _ready():
    # Get node path
    _target_node = get_node(target_node_path)
    # Set creation
    set_creation_automatically(create_automatically)
    # Check if is auto
    if create_automatically:
        # warning-ignore: return_value_discarded
        create_and_attach()


# Called every frame
func _process(delta: float):
    # Check counter
    if _counter >= instance_time:
        # warning-ignore: return_value_discarded
        create_and_attach()
        _counter = 0
    
    # Update counter
    _counter += delta

# ---------------------------------------------------
# Custom methods
# ---------------------------------------------------

# Set instance creation automatically
func set_creation_automatically(status: bool):
    create_automatically = status
    set_process(create_automatically)

# Create a instance
func create_instance() -> Node:
    if resource_scene == null:
        printerr("Resource scene is not defined or is not valid.")
        return null

    var instance = resource_scene.instance()
    emit_signal("instance_created", instance)
    return instance

# Create instance and attach to target node
func create_and_attach() -> Node:
    # Check target node
    if _target_node == null:
        printerr("Target node is not defined or is not valid.")
        return null

    # Get instance
    var instance = create_instance()
    if instance == null:
        return null

    # Set node attributes
    instance.global_position = global_position
    instance.rotation_degress = rotation_degress

    # Attach to node
    _target_node.call_deferred("add_child", instance)
    # Emit signal
    call_deferred("emit_signal", "instance_attached", instance)

    return instance
