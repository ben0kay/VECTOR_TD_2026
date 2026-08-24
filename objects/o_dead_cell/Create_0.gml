/// @description Validates one generated dead terrain cell.

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
    scr_world_cell_type_get(world_cell_x, world_cell_y)
    != WorldCellType.DEAD
)
{
    show_debug_message(
        "DEAD CELL ERROR - cell is not marked as dead terrain."
    );

    instance_destroy();
    exit;
}