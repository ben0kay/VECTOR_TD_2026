/// @description Registers the basic ground tower definition.

function scr_tower_data_basic_ground()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "tower_basic",
        {
            identity:
            {
                key: "tower_basic",
                name: "Basic Tower",
                type: BuildingType.TOWER
            },

            visual:
            {
                color: c_aqua,
                turret_color: c_yellow
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 300
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost: []
            },

            tower:
            {
                range: 280,
                target_mode: TowerTargetMode.CLOSEST,
                target_layer: EnemyMovementLayer.GROUND,
                requires_line_of_sight: true,
                draw_function: scr_tower_visual_ground,

                weapon:
                {
                    damage: 10,
                    cooldown_seconds: 0.6,

                    projectile:
                    {
                        speed: 12,
                        lifetime_seconds: 3,
                        radius: 4,
                        color: c_yellow,
                        impact: ProjectileImpact.DIRECT,
                        damage_radius: 0
                    }
                }
            }
        }
    );

    return true;
}


/// @description Registers the dedicated anti-air tower definition.

function scr_tower_data_anti_air()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "tower_anti_air",
        {
            identity:
            {
                key: "tower_anti_air",
                name: "Anti-Air Tower",
                type: BuildingType.TOWER
            },

            visual:
            {
                color: make_color_rgb(30, 80, 110),
                turret_color: c_aqua
            },

            footprint:
            {
                width_cells: 2,
                height_cells: 2
            },

            vitals:
            {
                hp_maximum: 260
            },

            construction:
            {
                time_seconds: 0
            },

            economy:
            {
                cost: []
            },

            tower:
            {
                range: 360,
                target_mode: TowerTargetMode.CLOSEST,
                target_layer: EnemyMovementLayer.FLYING,
                requires_line_of_sight: true,
                draw_function: scr_tower_visual_anti_air,

                weapon:
                {
                    damage: 12,
                    cooldown_seconds: 0.45,

                    projectile:
                    {
                        speed: 15,
                        lifetime_seconds: 3,
                        radius: 4,
                        color: c_aqua,
                        impact: ProjectileImpact.DIRECT,
                        damage_radius: 0
                    }
                }
            }
        }
    );

    return true;
}


/// @description Registers every tower building definition.

function scr_tower_data_initialize()
{
    if (!scr_tower_data_basic_ground())
    {
        show_debug_message(
            "TOWER DATA ERROR - basic ground tower failed."
        );

        return false;
    }


    if (!scr_tower_data_anti_air())
    {
        show_debug_message(
            "TOWER DATA ERROR - anti-air tower failed."
        );

        return false;
    }


    // FUTURE:
    // scr_tower_data_rapid_fire();
    // scr_tower_data_artillery();
    // scr_tower_data_laser();
    // scr_tower_data_anti_armour();
    // scr_tower_data_hybrid();
    // scr_tower_data_support();


    show_debug_message(
        "VECTOR TD 2026 - TOWER DATA INITIALIZED"
    );

    return true;
}