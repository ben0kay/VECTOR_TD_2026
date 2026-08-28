/// @description Shared Vector TD damage packet functions.

/// @description Creates one reusable damage packet.
function scr_damage_create(
    _amount,
    _source,
    _source_type,
    _damage_type = DamageType.KINETIC
)
{
    var _source_x = 0;
    var _source_y = 0;

    if (instance_exists(_source))
    {
        _source_x = _source.x;
        _source_y = _source.y;
    }

    return
    {
        amount: max(0, _amount),

        source: _source,
        source_type: _source_type,
        damage_type: _damage_type,

        source_position:
        {
            x: _source_x,
            y: _source_y
        },

        modifiers:
        {
            critical:
            {
                occurred: false,
                multiplier: 1
            },

            rear_attack:
            {
                occurred: false,
                multiplier: 1
            }
        }
    };
}


/// @description Rolls and applies one source-side critical hit.
function scr_damage_critical_roll(
    _damage,
    _chance,
    _multiplier
)
{
    if (!is_struct(_damage))
        return false;

    var _chance_clamped =
        clamp(
            _chance,
            0,
            1
        );

    var _multiplier_clamped =
        max(
            1,
            _multiplier
        );

    if (
        _chance_clamped <= 0
        || _multiplier_clamped <= 1
    )
    {
        return false;
    }

    if (random(1) >= _chance_clamped)
        return false;

    _damage.amount *=
        _multiplier_clamped;

    _damage.modifiers.critical.occurred =
        true;

    _damage.modifiers.critical.multiplier =
        _multiplier_clamped;

    return true;
}


/// @description Returns the rear-attack multiplier for one enemy impact.
function scr_damage_rear_attack_multiplier_get(
    _enemy,
    _damage
)
{
    if (!instance_exists(_enemy))
        return 1;

    if (!is_struct(_damage))
        return 1;

    if (
        !variable_struct_exists(
            _damage,
            "source_position"
        )
    )
    {
        return 1;
    }

    var _attack_angle =
        point_direction(
            _enemy.x,
            _enemy.y,
            _damage.source_position.x,
            _damage.source_position.y
        );

    var _rear_angle =
        (_enemy.visual.draw_angle + 180)
        mod 360;

    var _difference =
        abs(
            (
                (
                    _attack_angle
                    - _rear_angle
                    + 540
                )
                mod 360
            )
            - 180
        );

    if (_difference > 10)
        return 1;

    return 1.1;
}


/// @description Returns a damage type's effectiveness against shields.
function scr_damage_shield_multiplier(_damage_type)
{
    switch (_damage_type)
    {
        case DamageType.KINETIC:
            return 0.5;

        case DamageType.EXPLOSIVE:
            return 0.75;

        case DamageType.LASER:
            return 2;

        case DamageType.ELECTRICAL:
            return 1.25;
    }

    return 1;
}


/// @description Returns a damage type's effectiveness against exposed health.
function scr_damage_health_multiplier(_damage_type)
{
    switch (_damage_type)
    {
        case DamageType.KINETIC:
        case DamageType.EXPLOSIVE:
        case DamageType.ELECTRICAL:
            return 1;

        case DamageType.LASER:
            return 0.25;
    }

    return 1;
}