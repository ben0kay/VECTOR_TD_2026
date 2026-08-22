/// @description Data-driven enemy definitions and lookup.


/// @description Registers every enemy definition.

function scr_enemy_data_initialize()
{
    global.vtd.data.enemies =
    {
        enemy_weak:
        {
            identity:
            {
                key:
                    "enemy_weak",

                name:
                    "Weak Drone"
            },

            visual:
            {
                radius:
                    16,

                color:
                    c_yellow
            },

            vitals:
            {
                hp_maximum:
                    20
            },

            movement:
            {
                speed:
                    2,

                layer:
                    EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type:
                    EnemyTarget.CPU
            },

            navigation:
            {
                blocked_action:
                    EnemyBlockedAction.BREACH
            },

            attack:
            {
                type:
                    EnemyAttack.CONTACT,

                damage:
                    5,

                range:
                    4,

                cooldown_seconds:
                    1
            },

            abilities:
            [
                // The first basic drone has no special abilities.
            ]
        }
    };


    show_debug_message(
        "VECTOR TD 2026 - ENEMY DATA INITIALIZED"
    );


    return true;
}


/// @description Returns one enemy definition.

function scr_enemy_data_get(_enemy_key)
{
    if (!is_string(_enemy_key))
        return undefined;

    if (_enemy_key == "")
        return undefined;


    if (
        !variable_struct_exists(
            global.vtd.data.enemies,
            _enemy_key
        )
    )
    {
        show_debug_message(
            "ENEMY DATA ERROR - unknown key: "
            + _enemy_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.enemies,
        _enemy_key
    );
}


/// @description Returns whether an enemy definition has the required data.

function scr_enemy_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.visual))
        return false;

    if (!is_struct(_data.vitals))
        return false;

    if (!is_struct(_data.movement))
        return false;

    if (!is_struct(_data.targeting))
        return false;

    if (!is_struct(_data.navigation))
        return false;

    if (!is_struct(_data.attack))
        return false;

    if (!is_array(_data.abilities))
        return false;

    if (!is_string(_data.identity.key))
        return false;

    if (_data.identity.key == "")
        return false;

    if (_data.visual.radius <= 0)
        return false;

    if (_data.vitals.hp_maximum <= 0)
        return false;

    if (_data.movement.speed < 0)
        return false;


    return true;
}