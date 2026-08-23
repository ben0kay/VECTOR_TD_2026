/// @description Data-driven enemy definitions and lookup.


/// @description Registers every enemy definition.

function scr_enemy_data_initialize()
{
    global.vtd.data.enemies =
    {
        // ====================================================================
        // YELLOW — CPU SEEKER
        // ====================================================================

        enemy_weak:
        {
            identity: { key: "enemy_weak", name: "Weak CPU Seeker" },
            visual: { radius: 16, color: c_yellow },
            vitals: { hp_maximum: 20 },

            movement:
            {
                speed: 2,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.CPU
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 5,
                range: 4,
                cooldown_seconds: 1
            },

            abilities: []
        },


        // ====================================================================
        // RED — BUILDING HUNTER
        // ====================================================================

        enemy_hunter:
        {
            identity: { key: "enemy_hunter", name: "Building Hunter" },
            visual: { radius: 18, color: c_red },
            vitals: { hp_maximum: 40 },

            movement:
            {
                speed: 1.6,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 8,
                range: 4,
                cooldown_seconds: 1
            },

            abilities: []
        },


        // ====================================================================
        // CYAN — PHASER
        // ====================================================================

        enemy_phaser:
        {
            identity: { key: "enemy_phaser", name: "Phaser" },
            visual: { radius: 14, color: c_aqua },
            vitals: { hp_maximum: 30 },

            movement:
            {
                speed: 2.4,
                layer: EnemyMovementLayer.GROUND
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
                damage: 6,
                range: 4,
                cooldown_seconds: 0.8
            },

            abilities:
            [
                EnemyAbility.PHASING
            ]
        },


        // ====================================================================
        // ORANGE — SINGLE SHOOTER
        // ====================================================================

        enemy_shooter_single:
        {
            identity: { key: "enemy_shooter_single", name: "Single Shooter" },
            visual: { radius: 18, color: c_orange },
            vitals: { hp_maximum: 35 },

            movement:
            {
                speed: 1.5,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.CPU
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,
                damage: 4,
                range: 240,
                cooldown_seconds: 1.2,

                projectile:
                {
                    speed: 8,
                    lifetime_seconds: 5,
                    radius: 4,
                    color: c_orange,
                    shot_count: 1,
                    spread_degrees: 0
                }
            },

            abilities: []
        },


        // ====================================================================
        // PURPLE — TRIPLE SHOOTER
        // ====================================================================

        enemy_shooter_triple:
        {
            identity: { key: "enemy_shooter_triple", name: "Triple Shooter" },
            visual: { radius: 22, color: c_purple },
            vitals: { hp_maximum: 60 },

            movement:
            {
                speed: 1.25,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.CPU
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,
                damage: 4,
                range: 260,
                cooldown_seconds: 1.5,

                projectile:
                {
                    speed: 8,
                    lifetime_seconds: 5,
                    radius: 4,
                    color: c_purple,
                    shot_count: 3,

                    // This is the complete spread from the left projectile
                    // to the right projectile.

                    spread_degrees: 18
                }
            },

            abilities: []
        }
    };


    show_debug_message("VECTOR TD 2026 - ENEMY DATA INITIALIZED");

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