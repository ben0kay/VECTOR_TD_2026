/// @description Generic numeric stat runtime and modifier pipeline.


/// ============================================================================
/// CREATION
/// ============================================================================

/// @description Creates one empty modifier layer.
function scr_stats_modifiers_create()
{
    return
    {
        flat: {},
        multiplier: {}
    };
}


/// @description Returns a shallow copy of a numeric stat struct.
function scr_stats_base_copy(_base)
{
    var _copy = {};

    if (!is_struct(_base))
        return _copy;

    var _names =
        variable_struct_get_names(
            _base
        );

    for (
        var i = 0;
        i < array_length(_names);
        ++i
    )
    {
        var _key =
            _names[i];

        variable_struct_set(
            _copy,
            _key,

            variable_struct_get(
                _base,
                _key
            )
        );
    }

    return _copy;
}


/// @description Creates one complete stat runtime from baseline stat values.
function scr_stats_runtime_create(_base)
{
    return
    {
        base:
            scr_stats_base_copy(
                _base
            ),

        // Campaign/profile-wide upgrade modifiers.
        profile:
            scr_stats_modifiers_create(),

        // Temporary upgrades earned during this individual level.
        level:
            scr_stats_modifiers_create(),

        // Bonuses or penalties belonging to this specific instance.
        local:
            scr_stats_modifiers_create(),

        // Gameplay must read this layer, never base directly.
        final: {}
		
    };
}


/// ============================================================================
/// RECALCULATION
/// ============================================================================

/// @description Rebuilds final values from base and every modifier layer.
function scr_stats_recalculate(_stats)
{
    if (!is_struct(_stats))
        return false;

    if (!is_struct(_stats.base))
        return false;

    if (!is_struct(_stats.profile))
        return false;

    if (!is_struct(_stats.level))
        return false;

    if (!is_struct(_stats.local))
        return false;


    _stats.final = {};

    var _base_names =
        variable_struct_get_names(
            _stats.base
        );

    var _layer_names =
    [
        "profile",
        "level",
        "local"
    ];


    for (
        var i = 0;
        i < array_length(_base_names);
        ++i
    )
    {
        var _stat_key =
            _base_names[i];

        var _base_value =
            variable_struct_get(
                _stats.base,
                _stat_key
            );


        // This shared system is for numeric gameplay stats.
        if (!is_real(_base_value))
        {
            variable_struct_set(
                _stats.final,
                _stat_key,
                _base_value
            );

            continue;
        }


        var _flat_bonus = 0;
        var _multiplier = 1;


        for (
            var j = 0;
            j < array_length(_layer_names);
            ++j
        )
        {
            var _layer =
                variable_struct_get(
                    _stats,
                    _layer_names[j]
                );


            if (
                variable_struct_exists(
                    _layer.flat,
                    _stat_key
                )
            )
            {
                _flat_bonus +=
                    variable_struct_get(
                        _layer.flat,
                        _stat_key
                    );
            }


            if (
                variable_struct_exists(
                    _layer.multiplier,
                    _stat_key
                )
            )
            {
                _multiplier *=
                    variable_struct_get(
                        _layer.multiplier,
                        _stat_key
                    );
            }
        }


        variable_struct_set(
            _stats.final,
            _stat_key,

            max(
                0,
                (_base_value + _flat_bonus)
                * _multiplier
            )
        );
    }

    return true;
}


/// ============================================================================
/// ACCESS / MODIFICATION
/// ============================================================================

/// @description Returns one recalculated stat, or a fallback if it does not exist.
function scr_stats_final_get(
    _stats,
    _stat_key,
    _fallback = 0
)
{
    if (!is_struct(_stats))
        return _fallback;

    if (!is_struct(_stats.final))
        return _fallback;

    if (
        !variable_struct_exists(
            _stats.final,
            _stat_key
        )
    )
    {
        return _fallback;
    }

    return variable_struct_get(
        _stats.final,
        _stat_key
    );
}


/// @description Sets one flat or multiplier modifier and rebuilds final stats.
function scr_stats_modifier_set(
    _stats,
    _layer_name,
    _modifier_type,
    _stat_key,
    _value
)
{
    if (!is_struct(_stats))
        return false;

    if (
        !variable_struct_exists(
            _stats,
            _layer_name
        )
    )
    {
        return false;
    }

    var _layer =
        variable_struct_get(
            _stats,
            _layer_name
        );

    if (!is_struct(_layer))
        return false;

    if (
        _modifier_type != "flat"
        && _modifier_type != "multiplier"
    )
    {
        return false;
    }

    var _modifiers =
        variable_struct_get(
            _layer,
            _modifier_type
        );

    if (!is_struct(_modifiers))
        return false;

    variable_struct_set(
        _modifiers,
        _stat_key,
        _value
    );

    return scr_stats_recalculate(
        _stats
    );
}


/// @description Removes one modifier and rebuilds final stats.
function scr_stats_modifier_remove(
    _stats,
    _layer_name,
    _modifier_type,
    _stat_key
)
{
    if (!is_struct(_stats))
        return false;

    if (
        !variable_struct_exists(
            _stats,
            _layer_name
        )
    )
    {
        return false;
    }

    var _layer =
        variable_struct_get(
            _stats,
            _layer_name
        );

    if (!is_struct(_layer))
        return false;

    if (
        _modifier_type != "flat"
        && _modifier_type != "multiplier"
    )
    {
        return false;
    }

    var _modifiers =
        variable_struct_get(
            _layer,
            _modifier_type
        );

    if (!is_struct(_modifiers))
        return false;

    if (
        variable_struct_exists(
            _modifiers,
            _stat_key
        )
    )
    {
        variable_struct_remove(
            _modifiers,
            _stat_key
        );
    }

    return scr_stats_recalculate(
        _stats
    );
}