export structures_manager

addEventHandler "onResourceStart", resourceRoot, ->
	outputServerLog "Starting Rust building..."

	structures_manager = StructuresManager!
	structures_manager\create_structure Vector3 0, 0, 0