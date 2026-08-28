/// @description Creates floating feedback for one critical damage hit.
function scr_feedback_world_crit_damage(
    _enemy,
    _damage
)
{
    if (!instance_exists(_enemy))
        return false;


    if (
        !_damage.modifiers.critical.occurred
    )
    {
        return false;
    }


    scr_feedback_world_text_create(
        _enemy.x,
        _enemy.y
        - _enemy.visual.radius
        - 10,

        _enemy.movement.layer,

        "CRITICAL"
        + "\nx"
        + string(
            _damage.modifiers.critical.multiplier
        ),

        c_yellow,

        {
            duration_seconds: 0.8,
            rise_distance: 34,
            scale_start: 1.25,
            scale_end: 0.85,
            outline_color: c_white
        }
    );

    return true;
}