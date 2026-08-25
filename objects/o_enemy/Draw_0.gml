/// @description Draws one enemy using its cached visibility result.

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


scr_enemy_draw(id);