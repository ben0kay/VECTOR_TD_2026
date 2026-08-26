/// @description Draws one enemy using optional unique events.

if (
    !variable_instance_exists(
        id,
        "performance"
    )
    || !is_struct(performance)
)
{
    exit;
}


if (!performance.visibility.visible)
    exit;


// This is the only unique-enemy check performed by o_enemy's Draw event.

if (has_unique)
{
    scr_enemy_unique_draw_event(id);
    exit;
}


scr_enemy_draw(id);