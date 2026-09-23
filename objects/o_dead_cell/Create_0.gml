/// @description Initializes generated or handcrafted dead terrain.

if (global.vtd_level.identity.handcrafted)
{
    var _cell =
        scr_building_position_to_cell(x, y);

    world_cell_x = _cell.x;
    world_cell_y = _cell.y;

    var _position =
        scr_building_cell_to_position(
            world_cell_x,
            world_cell_y
        );

    x = _position.x;
    y = _position.y;

    if (!scr_world_cell_set(
        world_cell_x,
        world_cell_y,
        WorldCellType.DEAD
    ))
    {
        show_debug_message(
            "DEAD CELL ERROR - handcrafted cell registration failed."
        );

        instance_destroy();
        exit;
    }
}
else
{
    if (
        !variable_instance_exists(id, "world_cell_x")
        || !variable_instance_exists(id, "world_cell_y")
    )
    {
        show_debug_message(
            "DEAD CELL ERROR - world-cell position was not supplied."
        );

        instance_destroy();
        exit;
    }

    if (
        scr_world_cell_type_get(
            world_cell_x,
            world_cell_y
        )
        != WorldCellType.DEAD
    )
    {
        show_debug_message(
            "DEAD CELL ERROR - cell is not marked as dead terrain."
        );

        instance_destroy();
        exit;
    }
}