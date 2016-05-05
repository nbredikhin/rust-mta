BUILDING_NODE_WIDTH = 5
BUILDING_NODE_HEIGHT = 4

partSize = {}

partSize.floor = {
	x = BUILDING_NODE_WIDTH,
	y = BUILDING_NODE_WIDTH, 
	z = 0.21
}

partSize.foundation = {
	x = partSize.floor.x,
	y = partSize.floor.y,
	z = partSize.floor.x
}

partSize.wall = {
	x = 1,
	y = partSize.floor.y,
	z = 8
}