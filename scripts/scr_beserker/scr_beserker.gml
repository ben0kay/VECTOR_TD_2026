


/// @description Increases Berserker movement speed as its health decreases.

function scr_enemy_unique_berserker_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    if (
        !variable_struct_exists(
            _enemy.enemy_data,
            "unique"
        )
        || !is_struct(
            _enemy.enemy_data.unique
        )
        || !variable_struct_exists(
            _enemy.enemy_data.unique,
            "berserker"
        )
        || !is_struct(
            _enemy.enemy_data.unique.berserker
        )
    )
    {
        show_debug_message(
            "BERSERKER ERROR - unique data is missing: "
            + _enemy.identity.key
        );

        return false;
    }


    var _data =
        _enemy.enemy_data.unique.berserker;


    var _health_percentage =
        clamp(
            _enemy.vitals.hp.current
            / _enemy.vitals.hp.maximum,
            0,
            1
        );

    var _missing_health_percentage =
        1
        - _health_percentage;

    var _rage_amount =
        power(
            _missing_health_percentage,
            _data.curve_power
        );

    var _speed_multiplier =
        lerp(
            1,
            _data.maximum_speed_multiplier,
            _rage_amount
        );


    // Multiply the current speed so slow and stasis effects remain respected.

    _enemy.movement.speed *=
        _speed_multiplier;


    return true;
}