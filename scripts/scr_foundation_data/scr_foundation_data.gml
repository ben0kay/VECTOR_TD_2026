/// @description Registers every foundation definition.

function scr_building_data_foundations_initialize()
{
    scr_building_data_foundation_accelerator();
    scr_building_data_foundation_reinforced();
    scr_building_data_foundation_shock_grid();

    return true;
}


/// @description Registers the basic structural foundation. ????? not being used ????

function scr_building_data_foundation_basic()
{
    variable_struct_set(
        global.vtd.data.buildings,
        "foundation_basic",
        {
            identity:
            {
                key: "foundation_basic",
                name: "Basic Foundation",
                type: BuildingType.FOUNDATION,

                description_short:
                    "Structural flooring for buildings and player movement.",

                description_long:
                    "A flat construction platform placed before ordinary buildings. Fully supported buildings gain 5% maximum integrity, while the player moves 15% faster across completed foundation tiles."
            },

            visual:
            {
                color: make_color_rgb(30, 150, 170)
            },

            footprint:
            {
                width_cells: 1,
                height_cells: 1
            },

            vitals:
            {
                hp_maximum: 75
            },

            construction:
            {
                time_seconds: 1.5
            },

            economy:
            {
                cost:
                [{
                    resource_key: "resource_credits",
                    amount: 5
                }]
            },

            foundation:
            {
                building_hp_multiplier: 1.05,
                player_speed_multiplier: 1.15
            }
        }
    );

    return true;
}


/// @description Registers the Accelerator Foundation.

function scr_building_data_foundation_accelerator()
{
variable_struct_set(
global.vtd.data.buildings,
"foundation_accelerator",
{
identity:
{
key: "foundation_accelerator",
name: "Accelerator Foundation",
type: BuildingType.FOUNDATION,

            description_short:
                "Accelerates players and defensive towers.",

            description_long:
                "A high-speed floor network. Players move and fire 10% faster while standing on it. Fully supported towers fire 5% faster."
        },

        build_menu:
        {
            order: 10
        },

        visual:
        {
            color: c_aqua
        },

        footprint:
        {
            width_cells: 1,
            height_cells: 1
        },

        vitals:
        {
            hp_maximum: 75
        },

        construction:
        {
            time_seconds: 1
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 8
            }]
        },

        foundation:
        {
            type: FoundationType.ACCELERATOR,

            modifiers:
            {
                player_move_speed: 1.10,
                player_fire_rate: 1.10,
                player_damage_received: 1,
                building_hp: 1,
                tower_fire_rate: 1.05
            },

            shock:
            {
                enabled: false
            }
        }
    }
);

return true;
}

/// @description Registers the Reinforced Foundation.

function scr_building_data_foundation_reinforced()
{
variable_struct_set(
global.vtd.data.buildings,
"foundation_reinforced",
{
identity:
{
key: "foundation_reinforced",
name: "Reinforced Foundation",
type: BuildingType.FOUNDATION,

            description_short:
                "Protects players and supported structures.",

            description_long:
                "Dense structural flooring. Fully supported buildings gain 10% maximum integrity. Players standing on it receive 10% less damage."
        },

        build_menu:
        {
            order: 20
        },

        visual:
        {
            color: make_color_rgb(100, 130, 170)
        },

        footprint:
        {
            width_cells: 1,
            height_cells: 1
        },

        vitals:
        {
            hp_maximum: 125
        },

        construction:
        {
            time_seconds: 1.5
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 12
            }]
        },

        foundation:
        {
            type: FoundationType.REINFORCED,

            modifiers:
            {
                player_move_speed: 1,
                player_fire_rate: 1,
                player_damage_received: 0.90,
                building_hp: 1.10,
                tower_fire_rate: 1
            },

            shock:
            {
                enabled: false
            }
        }
    }
);

return true;
}

/// @description Registers the powered Shock Grid.

function scr_building_data_foundation_shock_grid()
{
variable_struct_set(
global.vtd.data.buildings,
"foundation_shock_grid",
{
identity:
{
key: "foundation_shock_grid",
name: "Shock Grid",
type: BuildingType.FOUNDATION,

            description_short:
                "Zaps ground enemies crossing the tile.",

            description_long:
                "Powered defensive flooring. Ground enemies may cross it, but receive electrical damage while occupying the tile. Multiple grids can form a damaging corridor."
        },

        build_menu:
        {
            order: 30
        },

        visual:
        {
            color: c_yellow
        },

        footprint:
        {
            width_cells: 1,
            height_cells: 1
        },

        vitals:
        {
            hp_maximum: 80
        },

        construction:
        {
            time_seconds: 1.5
        },

        economy:
        {
            cost:
            [{
                resource_key: "resource_credits",
                amount: 18
            }]
        },

        foundation:
        {
            type: FoundationType.SHOCK_GRID,

            modifiers:
            {
                player_move_speed: 1,
                player_fire_rate: 1,
                player_damage_received: 1,
                building_hp: 1,
                tower_fire_rate: 1
            },

            shock:
            {
                enabled: true,
                damage: 8,
                interval_seconds: 0.35,
                color: c_yellow
            }
        },

        energy:
        {
            role: EnergyRole.CONSUMER,
            priority: EnergyPriority.NORMAL,

            connection_range: 224,
            generation_per_second: 0,
            input_rate: 8,

            idle_demand: 0.10,
            activity_cost: 1.5,

            buffer:
            {
                capacity: 5,
                starting_ratio: 1
            }
        }
    }
);

return true;
}