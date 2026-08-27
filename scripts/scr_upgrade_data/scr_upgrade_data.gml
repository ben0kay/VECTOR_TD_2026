/// @description Data-driven upgrade definitions.

function scr_upgrade_data_initialize()
{
    global.vtd.data.upgrades =
    {
        tower_weapon_calibration:
        {
            identity:
            {
                key:
                    "tower_weapon_calibration",

                name:
                    "WEAPON CALIBRATION",

                description:
                    "All tower weapons deal 10% more damage."
            },

            scope:
                UpgradeScope.PROFILE,

            target:
                UpgradeTarget.TOWER_COMBAT,

            // Empty means every tower. Later this can contain only selected
            // building keys, such as ["tower_laser", "tower_sniper"].
            building_keys: [],

            stat_key:
                "weapon_damage",

            modifier:
            {
                flat: 0,
                multiplier: 1.10
            }
        }
    };

    return true;
}


/// @description Returns one upgrade definition by key.
function scr_upgrade_data_get(_upgrade_key)
{
    if (
        !variable_global_exists("vtd")
        || !is_struct(global.vtd)
    )
    {
        return undefined;
    }

    if (
        !variable_struct_exists(
            global.vtd.data,
            "upgrades"
        )
    )
    {
        return undefined;
    }

    if (
        !variable_struct_exists(
            global.vtd.data.upgrades,
            _upgrade_key
        )
    )
    {
        return undefined;
    }

    return variable_struct_get(
        global.vtd.data.upgrades,
        _upgrade_key
    );
}