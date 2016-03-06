export class StructuresManager
	
	new: =>
		@_structures = {}

	get_structure: (id) => 
		return if not id or type(id) ~= "number"
		@_structures[id]

	create_structure: (position, rotation) =>
		structure = Structure position, rotation
		table.insert @_structures, structure
		structure.id = #@_structures
		structure\setup!
		return structure.id

	destroy_structure: (id) =>
		-- TODO: Destroy structure