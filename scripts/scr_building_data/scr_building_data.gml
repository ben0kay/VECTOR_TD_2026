/// @description Data-driven building definitions and lookup.


/// @description Registers every building definition.

function scr_building_data_initialize()
{
    global.vtd.data.buildings =
    {
        // ====================================================================
        // BASIC WALL
        // ====================================================================

        wall_basic:
        {
            identity:
            {
                key:
                    "wall_basic",

                name:
                    "Basic Wall",

                type:
                    BuildingType.WALL
            },

            visual:
            {
                color:
                    c_fuchsia
            },

            footprint:
            {
                width_cells:
                    1,

                height_cells:
                    1
            },

            vitals:
            {
                hp_maximum:
                    200
            },

            construction:
            {
                time_seconds:
                    0
            },

            economy:
            {
                cost:
                    []
            }
        },


        // ====================================================================
        // BASIC TOWER
        // ====================================================================

        tower_basic:
        {
            identity:
            {
                key:
                    "tower_basic",

                name:
                    "Basic Tower",

                type:
                    BuildingType.TOWER
            },

            visual:
            {
                color:
                    c_aqua,

                turret_color:
                    c_yellow
            },

            footprint:
            {
                width_cells:
                    2,

                height_cells:
                    2
            },

            vitals:
            {
                hp_maximum:
                    300
            },

            construction:
            {
                time_seconds:
                    0
            },

            economy:
            {
                cost:
                    []
            },

            tower:
            {
                range:
                    280,

                target_mode:
                    TowerTargetMode.CLOSEST,

                target_layer:
                    EnemyMovementLayer.GROUND,

                weapon:
                {
                    damage:
                        10,

                    cooldown_seconds:
                        0.6,

                    projectile:
                    {
                        speed:
                            12,

                        lifetime_seconds:
                            3,

                        radius:
                            4,

                        color:
                            c_yellow,

                        impact:
                            ProjectileImpact.DIRECT,

                        // Zero means direct damage only.
                        // Future explosive towers can use 64, 96, 160, etc.

                        damage_radius:
                            0
                    }
                }
            }
        }
    };


    show_debug_message(
        "VECTOR TD 2026 - BUILDING DATA INITIALIZED"
    );


    return true;
}


/// @description Returns one building definition.

function scr_building_data_get(_building_key)
{
    if (!is_string(_building_key))
        return undefined;

    if (_building_key == "")
        return undefined;


    if (
        !variable_struct_exists(
            global.vtd.data.buildings,
            _building_key
        )
    )
    {
        show_debug_message(
            "BUILDING DATA ERROR - unknown key: "
            + _building_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.buildings,
        _building_key
    );
}


/// @description Returns whether a building definition contains required data.

function scr_building_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(
        _data,
        "identity"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "visual"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "footprint"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "vitals"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "construction"
    ))
    {
        return false;
    }

    if (!variable_struct_exists(
        _data,
        "economy"
    ))
    {
        return false;
    }


    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.visual))
        return false;

    if (!is_struct(_data.footprint))
        return false;

    if (!is_struct(_data.vitals))
        return false;

    if (!is_struct(_data.construction))
        return false;

    if (!is_struct(_data.economy))
        return false;


    if (!is_string(_data.identity.key))
        return false;

    if (!is_string(_data.identity.name))
        return false;

    if (_data.identity.key == "")
        return false;

    if (_data.identity.name == "")
        return false;


    if (
        _data.footprint.width_cells
        <= 0
    )
    {
        return false;
    }

    if (
        _data.footprint.height_cells
        <= 0
    )
    {
        return false;
    }

    if (_data.vitals.hp_maximum <= 0)
        return false;


    return true;
}