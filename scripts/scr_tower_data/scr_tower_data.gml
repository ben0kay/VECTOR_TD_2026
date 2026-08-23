/// @description Registers the basic ground tower.

function scr_tower_data_basic_ground()
{
    variable_struct_set(global.vtd.data.buildings, "tower_basic",
    {
        identity:
        {
            key: "tower_basic",
            name: "Basic Tower",
            type: BuildingType.TOWER,
            description_short: "Reliable general-purpose ground defense.",
            description_long: "A balanced defensive tower with dependable damage, range and firing speed against ordinary ground enemies."
        },

        visual:
        {
            color: c_aqua,
            turret_color: c_yellow
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 300 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 100
            }]
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
                type: TowerWeaponType.PROJECTILE,
                damage_type: DamageType.KINETIC,
                damage: 10,
                cooldown_seconds: 0.6,

                muzzle:
                {
                    mode: TowerMuzzleMode.CENTER,
                    distance: 36,
                    spacing: 0
                },

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
    });

    return true;
}


/// @description Registers the single-barrel anti-air tower.

function scr_tower_data_anti_air()
{
    variable_struct_set(global.vtd.data.buildings, "tower_anti_air",
    {
        identity:
        {
            key: "tower_anti_air",
            name: "Anti-Air Tower",
            type: BuildingType.TOWER,
            description_short: "Dedicated defense against flying enemies.",
            description_long: "A fast-tracking single-barrel installation that fires over buildings and dead terrain at flying enemies. It cannot target ground units."
        },

        visual:
        {
            color: make_color_rgb(30, 80, 110),
            turret_color: c_aqua
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 260 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 120
            }]
        },

        tower:
        {
            range: 360,
            target_mode: TowerTargetMode.CLOSEST,
            target_layer: EnemyMovementLayer.FLYING,
            requires_line_of_sight: false,
            draw_function: scr_tower_visual_anti_air,

            weapon:
            {
                type: TowerWeaponType.PROJECTILE,
                damage_type: DamageType.KINETIC,
                damage: 12,
                cooldown_seconds: 0.45,

                muzzle:
                {
                    mode: TowerMuzzleMode.CENTER,
                    distance: 38,
                    spacing: 0
                },

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
    });

    return true;
}


/// @description Registers the alternating twin-minigun tower.

function scr_tower_data_minigun()
{
    variable_struct_set(global.vtd.data.buildings, "tower_minigun",
    {
        identity:
        {
            key: "tower_minigun",
            name: "Twin Minigun",
            type: BuildingType.TOWER,
            description_short: "Rapid alternating kinetic fire.",
            description_long: "Two rotary cannons alternate shots at very high speed. Excellent against numerous weaker ground enemies, but less efficient against shields."
        },

        visual:
        {
            color: make_color_rgb(25, 75, 65),
            turret_color: c_lime
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 280 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 180
            }]
        },

        tower:
        {
            range: 250,
            target_mode: TowerTargetMode.CLOSEST,
            target_layer: EnemyMovementLayer.GROUND,
            requires_line_of_sight: true,
            draw_function: scr_tower_visual_minigun,

            weapon:
            {
                type: TowerWeaponType.PROJECTILE,
                damage_type: DamageType.KINETIC,
                damage: 3,
                cooldown_seconds: 0.09,

                muzzle:
                {
                    mode: TowerMuzzleMode.ALTERNATING,
                    distance: 38,
                    spacing: 7
                },

                projectile:
                {
                    speed: 18,
                    lifetime_seconds: 2,
                    radius: 3,
                    color: c_lime,
                    impact: ProjectileImpact.DIRECT,
                    damage_radius: 0
                }
            }
        }
    });

    return true;
}


/// @description Registers the explosive ground cannon.

function scr_tower_data_cannon()
{
    variable_struct_set(global.vtd.data.buildings, "tower_cannon",
    {
        identity:
        {
            key: "tower_cannon",
            name: "Explosive Cannon",
            type: BuildingType.TOWER,
            description_short: "Heavy explosive area damage.",
            description_long: "Launches slow heavy shells that damage groups of ground enemies. Damage falls away toward the edge of each explosion."
        },

        visual:
        {
            color: make_color_rgb(90, 55, 25),
            turret_color: c_orange
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 360 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 250
            }]
        },

        tower:
        {
            range: 320,
            target_mode: TowerTargetMode.CLOSEST,
            target_layer: EnemyMovementLayer.GROUND,
            requires_line_of_sight: true,
            draw_function: scr_tower_visual_cannon,

            weapon:
            {
                type: TowerWeaponType.PROJECTILE,
                damage_type: DamageType.EXPLOSIVE,
                damage: 70,
                cooldown_seconds: 2.3,

                muzzle:
                {
                    mode: TowerMuzzleMode.CENTER,
                    distance: 40,
                    spacing: 0
                },

                projectile:
                {
                    speed: 9,
                    lifetime_seconds: 5,
                    radius: 7,
                    color: c_orange,
                    impact: ProjectileImpact.EXPLOSIVE,
                    damage_radius: 96
                }
            }
        }
    });

    return true;
}


/// @description Registers the continuous shield laser tower.

function scr_tower_data_laser()
{
    variable_struct_set(global.vtd.data.buildings, "tower_laser",
    {
        identity:
        {
            key: "tower_laser",
            name: "Shield Laser",
            type: BuildingType.TOWER,
            description_short: "Continuous beam specialized against shields.",
            description_long: "Maintains a focused thermal beam against its target. It rapidly strips shields but causes limited damage to exposed enemy hulls."
        },

        visual:
        {
            color: make_color_rgb(80, 20, 20),
            turret_color: c_red
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 250 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 220
            }]
        },

        tower:
        {
            range: 270,
            target_mode: TowerTargetMode.CLOSEST,
            target_layer: EnemyMovementLayer.GROUND,
            requires_line_of_sight: true,
            draw_function: scr_tower_visual_laser,

            weapon:
            {
                type: TowerWeaponType.BEAM,
                damage_type: DamageType.LASER,
                damage: 4,
                cooldown_seconds: 0.1,

                muzzle:
                {
                    mode: TowerMuzzleMode.CENTER,
                    distance: 31,
                    spacing: 0
                },

                beam:
                {
                    color_outer: c_red,
                    color_core: make_color_rgb(255, 220, 180),
                    width: 4,
                    visual_seconds: 0.14
                }
            }
        }
    });

    return true;
}


/// @description Registers the long-range sniper tower.

function scr_tower_data_sniper()
{
    variable_struct_set(global.vtd.data.buildings, "tower_sniper",
    {
        identity:
        {
            key: "tower_sniper",
            name: "Sniper Tower",
            type: BuildingType.TOWER,
            description_short: "Extremely long-range precision weapon.",
            description_long: "A slow precision rail weapon that prioritizes high-health ground targets. Its hitscan projectile reaches the target immediately."
        },

        visual:
        {
            color: make_color_rgb(35, 35, 80),
            turret_color: make_color_rgb(170, 150, 255)
        },

        footprint: { width_cells: 2, height_cells: 2 },
        vitals: { hp_maximum: 230 },
        construction: { time_seconds: 0 },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 300
            }]
        },

        tower:
        {
            range: 600,
            target_mode: TowerTargetMode.HIGHEST_HP,
            target_layer: EnemyMovementLayer.GROUND,
            requires_line_of_sight: true,
            draw_function: scr_tower_visual_sniper,

            weapon:
            {
                type: TowerWeaponType.HITSCAN,
                damage_type: DamageType.KINETIC,
                damage: 100,
                cooldown_seconds: 2.8,

                muzzle:
                {
                    mode: TowerMuzzleMode.CENTER,
                    distance: 44,
                    spacing: 0
                },

                hitscan:
                {
                    color: make_color_rgb(190, 170, 255),
                    width: 2,
                    visual_seconds: 0.12
                }
            }
        }
    });

    return true;
}


/// @description Registers every tower definition.

function scr_tower_data_initialize()
{
    if (!scr_tower_data_basic_ground()) return false;
    if (!scr_tower_data_anti_air()) return false;
    if (!scr_tower_data_minigun()) return false;
    if (!scr_tower_data_cannon()) return false;
    if (!scr_tower_data_laser()) return false;
    if (!scr_tower_data_sniper()) return false;

    // FUTURE TOWERS:
    // artillery
    // anti-armour
    // ground-and-air hybrid
    // slowing
    // support and repair
    // shield disruption
    // chain lightning

    show_debug_message("VECTOR TD 2026 - TOWER DATA INITIALIZED");

    return true;
}