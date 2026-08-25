/// @description Shared Vector TD damage packet functions.


/// @description Creates one reusable damage packet.

function scr_damage_create(
    _amount,
    _source,
    _source_type,
    _damage_type = DamageType.KINETIC
)
{
    return
    {
        amount: max(0, _amount),

        source: _source,
        source_type: _source_type,
        damage_type: _damage_type
    };
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