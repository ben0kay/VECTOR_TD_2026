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

// ========================================================================
// TEMP DEBUG - ENEMY SNIPER LOS
// ========================================================================

if (
    identity.key == "enemy_sniper"
    && instance_exists(targeting.target)
)
{
    var _target =
        targeting.target;

    var _blocked =
        scr_world_line_blocked_by_dead(
            x,
            y,
            _target.x,
            _target.y
        );


    draw_set_alpha(1);

    draw_set_color(
        _blocked
        ? c_red
        : c_lime
    );

    draw_line_width(
        x,
        y,
        _target.x,
        _target.y,
        3
    );

    draw_set_color(c_white);

    draw_text(
        x + 16,
        y + 16,
        _blocked
        ? "BLOCKED"
        : "CLEAR"
    );
}