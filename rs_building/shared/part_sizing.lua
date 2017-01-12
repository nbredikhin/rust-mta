BUILDING_PART_WIDTH = 5
BUILDING_PART_HEIGHT = 8

PartSizing = {}

PartSizing.Floor = {
    x = BUILDING_PART_WIDTH,
    y = BUILDING_PART_WIDTH, 
    z = 0.21
}

PartSizing.Foundation = {
    x = PartSizing.Floor.x,
    y = PartSizing.Floor.y,
    z = PartSizing.Floor.x
}

PartSizing.Wall = {
    x = 1,
    y = PartSizing.Floor.y,
    z = BUILDING_PART_HEIGHT
}

PartSizing.Stairway = {
    x = PartSizing.Floor.x,
    y = PartSizing.Floor.y,
    z = BUILDING_PART_HEIGHT
}