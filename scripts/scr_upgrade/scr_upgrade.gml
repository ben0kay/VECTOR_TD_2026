/// @description Upgrade ownership helpers for profile and current-level upgrades.


/// ============================================================================
/// RUNTIME CREATION
/// ============================================================================

/// @description Creates the permanent campaign/profile upgrade runtime.
function scr_upgrade_profile_runtime_create()
{
    return
    {
        owned: []
    };
}


/// @description Creates the current level's temporary upgrade runtime.
function scr_upgrade_level_runtime_create()
{
    return
    {
        owned: []
    };
}


/// ============================================================================
/// OWNERSHIP
/// ============================================================================

/// @description Returns whether an upgrade-key array contains one key.
function scr_upgrade_owned_has(
    _owned_keys,
    _upgrade_key
)
{
    if (!is_array(_owned_keys))
        return false;

    for (
        var i = 0;
        i < array_length(_owned_keys);
        ++i
    )
    {
        if (_owned_keys[i] == _upgrade_key)
            return true;
    }

    return false;
}


/// @description Returns whether the active profile owns one upgrade.
function scr_upgrade_profile_owned_has(_upgrade_key)
{
    if (!variable_global_exists("vtd"))
    {
        return false;
    }

    if (!is_struct(global.vtd))
    {
        return false;
    }

    if (!is_struct(global.vtd.profile))
    {
        return false;
    }

    if (!is_struct(global.vtd.profile.upgrades))
    {
        return false;
    }

    return scr_upgrade_owned_has(
        global.vtd.profile.upgrades.owned,
        _upgrade_key
    );
}


/// @description Returns whether the current level owns one temporary upgrade.
function scr_upgrade_level_owned_has(_upgrade_key)
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!is_struct(global.vtd_level.upgrades))
        return false;

    if (!is_struct(global.vtd_level.upgrades.level))
        return false;

    return scr_upgrade_owned_has(
        global.vtd_level.upgrades.level.owned,
        _upgrade_key
    );
}

/// ============================================================================
/// STAT-LAYER APPLICATION
/// ============================================================================

/// @description Returns whether an upgrade applies to one building key.
function scr_upgrade_building_key_matches(
    _upgrade,
    _building_key
)
{
    if (!is_struct(_upgrade))
        return false;

    if (
        !variable_struct_exists(
            _upgrade,
            "building_keys"
        )
    )
    {
        return true;
    }

    if (!is_array(_upgrade.building_keys))
        return false;

    // An empty list deliberately means every valid building.
    if (array_length(_upgrade.building_keys) <= 0)
        return true;

    for (
        var i = 0;
        i < array_length(_upgrade.building_keys);
        ++i
    )
    {
        if (
            _upgrade.building_keys[i]
            == _building_key
        )
        {
            return true;
        }
    }

    return false;
}


/// @description Rebuilds one stat modifier layer from owned upgrade keys.
function scr_upgrade_stats_layer_rebuild(
    _stats,
    _owned_keys,
    _target,
    _building_key,
    _layer_name
)
{
    if (!is_struct(_stats))
        return false;

    if (!is_array(_owned_keys))
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


    // Rebuild from ownership every time. This prevents stale modifiers
    // remaining after an upgrade is removed or a profile changes.

    _layer.flat = {};
    _layer.multiplier = {};


    for (
        var i = 0;
        i < array_length(_owned_keys);
        ++i
    )
    {
        var _upgrade =
            scr_upgrade_data_get(
                _owned_keys[i]
            );

        if (!is_struct(_upgrade))
            continue;

        if (_upgrade.target != _target)
            continue;

        if (
            !scr_upgrade_building_key_matches(
                _upgrade,
                _building_key
            )
        )
        {
            continue;
        }

        if (
            !variable_struct_exists(
                _upgrade,
                "stat_key"
            )
        )
        {
            continue;
        }

        if (
            !variable_struct_exists(
                _upgrade,
                "modifier"
            )
        )
        {
            continue;
        }

        if (!is_struct(_upgrade.modifier))
            continue;


        var _stat_key =
            _upgrade.stat_key;

        var _modifier =
            _upgrade.modifier;


        if (
            variable_struct_exists(
                _modifier,
                "flat"
            )
            && is_real(_modifier.flat)
        )
        {
            var _flat_current = 0;

            if (
                variable_struct_exists(
                    _layer.flat,
                    _stat_key
                )
            )
            {
                _flat_current =
                    variable_struct_get(
                        _layer.flat,
                        _stat_key
                    );
            }

            variable_struct_set(
                _layer.flat,
                _stat_key,

                _flat_current
                + _modifier.flat
            );
        }


        if (
            variable_struct_exists(
                _modifier,
                "multiplier"
            )
            && is_real(_modifier.multiplier)
        )
        {
            var _multiplier_current = 1;

            if (
                variable_struct_exists(
                    _layer.multiplier,
                    _stat_key
                )
            )
            {
                _multiplier_current =
                    variable_struct_get(
                        _layer.multiplier,
                        _stat_key
                    );
            }

            variable_struct_set(
                _layer.multiplier,
                _stat_key,

                _multiplier_current
                * _modifier.multiplier
            );
        }
    }

    return true;
}


/// @description Rebuilds one tower's profile/level combat upgrades.
function scr_upgrade_tower_combat_stats_apply(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.combat))
        return false;

    if (!is_struct(_tower.combat.stats))
        return false;


    var _stats =
        _tower.combat.stats;

    var _building_key =
        _tower.identity.key;


    // ========================================================================
    // PROFILE UPGRADES
    // ========================================================================

    var _profile_owned = [];

    if (
        variable_global_exists("vtd")
        && is_struct(global.vtd)
        && is_struct(global.vtd.profile)
        && is_struct(global.vtd.profile.upgrades)
        && is_array(global.vtd.profile.upgrades.owned)
    )
    {
        _profile_owned =
            global.vtd.profile.upgrades.owned;
    }

    scr_upgrade_stats_layer_rebuild(
        _stats,
        _profile_owned,
        UpgradeTarget.TOWER_COMBAT,
        _building_key,
        "profile"
    );


    // ========================================================================
    // LEVEL UPGRADES
    // ========================================================================

    var _level_owned = [];

    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && is_struct(global.vtd_level.upgrades)
        && is_struct(global.vtd_level.upgrades.level)
        && is_array(global.vtd_level.upgrades.level.owned)
    )
    {
        _level_owned =
            global.vtd_level.upgrades.level.owned;
    }

    scr_upgrade_stats_layer_rebuild(
        _stats,
        _level_owned,
        UpgradeTarget.TOWER_COMBAT,
        _building_key,
        "level"
    );


    // Keeps veteran rank and foundation bonuses in the local layer,
    // then recalculates the final live combat values.

    return scr_tower_progression_stats_apply(
        _tower
    );
}

/// ============================================================================
/// GRANTING / REFRESH
/// ============================================================================

/// @description Rebuilds upgrade-derived combat stats for every placed tower.
function scr_upgrade_towers_refresh()
{
    with (o_tower)
    {
        scr_upgrade_tower_combat_stats_apply(id);
    }

    return true;
}


/// @description Grants one permanent profile upgrade and refreshes active towers.
function scr_upgrade_profile_grant(_upgrade_key)
{
    var _upgrade =
        scr_upgrade_data_get(
            _upgrade_key
        );

    if (!is_struct(_upgrade))
        return false;

    if (_upgrade.scope != UpgradeScope.PROFILE)
        return false;

    if (!variable_global_exists("vtd"))
        return false;

    if (!is_struct(global.vtd))
        return false;

    if (!is_struct(global.vtd.profile))
        return false;

    if (!is_struct(global.vtd.profile.upgrades))
        return false;

    if (
        !is_array(
            global.vtd.profile.upgrades.owned
        )
    )
    {
        global.vtd.profile.upgrades.owned = [];
    }

    if (
        scr_upgrade_owned_has(
            global.vtd.profile.upgrades.owned,
            _upgrade_key
        )
    )
    {
        return false;
    }


    var _owned =
        global.vtd.profile.upgrades.owned;

    array_push(
        _owned,
        _upgrade_key
    );

    global.vtd.profile.upgrades.owned =
        _owned;


    if (!scr_profile_save())
        return false;

    scr_upgrade_towers_refresh();

    show_debug_message(
        "PROFILE UPGRADE GRANTED: "
        + _upgrade.identity.name
    );

    return true;
}


/// @description Grants one temporary level upgrade and refreshes active towers.
function scr_upgrade_level_grant(_upgrade_key)
{
    var _upgrade =
        scr_upgrade_data_get(
            _upgrade_key
        );

    if (!is_struct(_upgrade))
        return false;

    if (_upgrade.scope != UpgradeScope.LEVEL)
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!is_struct(global.vtd_level.upgrades))
        return false;

    if (!is_struct(global.vtd_level.upgrades.level))
        return false;

    if (
        !is_array(
            global.vtd_level.upgrades.level.owned
        )
    )
    {
        global.vtd_level.upgrades.level.owned = [];
    }

    if (
        scr_upgrade_owned_has(
            global.vtd_level.upgrades.level.owned,
            _upgrade_key
        )
    )
    {
        return false;
    }


    var _owned =
        global.vtd_level.upgrades.level.owned;

    array_push(
        _owned,
        _upgrade_key
    );

    global.vtd_level.upgrades.level.owned =
        _owned;

    scr_upgrade_towers_refresh();

    show_debug_message(
        "LEVEL UPGRADE GRANTED: "
        + _upgrade.identity.name
    );

    return true;
}