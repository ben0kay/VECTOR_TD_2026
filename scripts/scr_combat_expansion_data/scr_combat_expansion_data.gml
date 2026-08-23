/// @description Registers the first flying enemy and anti-air tower.

function scr_combat_expansion_data_initialize()
{
    // ========================================================================
    // FLYING ENEMY
    // ========================================================================

    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_flyer",
        {
            identity:
            {
                key: "enemy_flyer",
                name: "Flying Drone"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_flyer,
                radius: 18,
                color: c_aqua
            },

            vitals:
            {
                hp_maximum: 45
            },

            movement:
            {
                speed: 2.2,
                layer: EnemyMovementLayer.FLYING
            },

            targeting:
            {
                target_type: EnemyTarget.CPU
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.WAIT
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 7,
                range: 8,
                cooldown_seconds: 0.8
            },

            abilities: []
        }
    );


    // ========================================================================
    // BASIC GROUND TOWER VISUAL
    // ========================================================================

    global.vtd.data.buildings
        .tower_basic.tower.draw_function =
        scr_tower_visual_ground;


    // ========================================================================
    // ANTI-AIR TOWER
    // ========================================================================

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


    show_debug_message(
        "VECTOR TD 2026 - COMBAT EXPANSION DATA INITIALIZED"
    );

    return true;
}