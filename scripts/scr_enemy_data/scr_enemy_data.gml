/// @description Data-driven enemy definitions and lookup.


/// @description Registers every enemy definition.

function scr_enemy_data_initialize()
{
    global.vtd.data.enemies =
    {
        enemy_weak:
        {
            identity: { key: "enemy_weak", name: "Weak CPU Seeker" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_triangle,
                radius: 16,
                color: c_yellow
            },

            vitals: { hp_maximum: 20 },

            movement:
            {
                speed: 2,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 5,
                range: 4,
                cooldown_seconds: 1
            },

            abilities: []
        },


        enemy_hunter:
        {
            identity: { key: "enemy_hunter", name: "Building Hunter" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_triangle,
                radius: 18,
                color: c_red
            },

            vitals: { hp_maximum: 40 },

            movement:
            {
                speed: 1.6,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.BUILDING },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 8,
                range: 4,
                cooldown_seconds: 1
            },

            abilities: []
        },


        enemy_phaser:
        {
            identity: { key: "enemy_phaser", name: "Phaser" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_triangle,
                radius: 14,
                color: c_aqua
            },

            vitals: { hp_maximum: 30 },

            movement:
            {
                speed: 2.4,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.WAIT },

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


        enemy_shooter_single:
        {
            identity: { key: "enemy_shooter_single", name: "Single Shooter" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_triangle,
                radius: 18,
                color: c_orange
            },

            vitals: { hp_maximum: 35 },

            movement:
            {
                speed: 1.5,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

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


        enemy_shooter_triple:
        {
            identity: { key: "enemy_shooter_triple", name: "Triple Shooter" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_triangle,
                radius: 22,
                color: c_purple
            },

            vitals: { hp_maximum: 60 },

            movement:
            {
                speed: 1.25,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

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
                    spread_degrees: 18
                }
            },

            abilities: []
        },


        enemy_kamikaze:
        {
            identity: { key: "enemy_kamikaze", name: "Kamikaze Exploder" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_kamikaze,
                radius: 15,
                color: c_lime
            },

            vitals: { hp_maximum: 24 },

            movement:
            {
                speed: 3.2,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 0,
                range: 12,
                cooldown_seconds: 1
            },

            ability_data:
            {
                explosion:
                {
                    damage: 35,
                    radius: 110
                }
            },

            abilities:
            [
                EnemyAbility.EXPLODE_ON_DEATH
            ]
        },


        // ====================================================================
        // BLUE — SPLITTER
        // ====================================================================

        enemy_splitter:
        {
            identity: { key: "enemy_splitter", name: "Splitter" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_splitter,
                radius: 24,
                color: c_blue
            },

            vitals: { hp_maximum: 80 },

            movement:
            {
                speed: 1.4,
                layer: EnemyMovementLayer.GROUND
            },

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.BREACH },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 10,
                range: 4,
                cooldown_seconds: 1
            },

            ability_data:
            {
                split:
                {
                    enemy_key: "enemy_splitter_child",
                    count: 4,
                    spawn_distance: 22,

                    // Rotates the complete equal-angle pattern.
                    angle_offset: 0
                }
            },

            abilities:
            [
                EnemyAbility.SPLIT_ON_DEATH
            ]
        },


        // ====================================================================
        // BLUE — BRAINLESS SPLITTER CHILD
        // ====================================================================

        enemy_splitter_child:
        {
            identity: { key: "enemy_splitter_child", name: "Splitter Shard" },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_splitter_child,
                radius: 10,
                color: c_aqua
            },

            vitals: { hp_maximum: 12 },

            movement:
            {
                speed: 3,
                layer: EnemyMovementLayer.GROUND,
                brainless: true,
                destroy_on_impact: true
            },

            // These fields remain present so every enemy definition has the
            // same readable structure. Brainless movement ignores targeting.

            targeting: { target_type: EnemyTarget.CPU },
            navigation: { blocked_action: EnemyBlockedAction.WAIT },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 8,
                range: 0,
                cooldown_seconds: 0
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


    // ========================================================================
    // REQUIRED STRUCTS
    // ========================================================================

    if (!variable_struct_exists(_data, "identity"))
        return false;

    if (!variable_struct_exists(_data, "visual"))
        return false;

    if (!variable_struct_exists(_data, "vitals"))
        return false;

    if (!variable_struct_exists(_data, "movement"))
        return false;

    if (!variable_struct_exists(_data, "targeting"))
        return false;

    if (!variable_struct_exists(_data, "navigation"))
        return false;

    if (!variable_struct_exists(_data, "attack"))
        return false;

    if (!variable_struct_exists(_data, "abilities"))
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


    // ========================================================================
    // CORE VALUES
    // ========================================================================

    if (!variable_struct_exists(_data.identity, "key"))
        return false;

    if (!is_string(_data.identity.key))
        return false;

    if (_data.identity.key == "")
        return false;

    if (!variable_struct_exists(_data.visual, "radius"))
        return false;

    if (_data.visual.radius <= 0)
        return false;

    if (!variable_struct_exists(_data.vitals, "hp_maximum"))
        return false;

    if (_data.vitals.hp_maximum <= 0)
        return false;

    if (!variable_struct_exists(_data.movement, "speed"))
        return false;

    if (_data.movement.speed < 0)
        return false;


    // ========================================================================
    // PROJECTILE ATTACK
    // ========================================================================

    if (_data.attack.type == EnemyAttack.PROJECTILE)
    {
        if (!variable_struct_exists(_data.attack, "projectile"))
            return false;

        if (!is_struct(_data.attack.projectile))
            return false;

        var _projectile = _data.attack.projectile;

        if (_projectile.speed <= 0)
            return false;

        if (_projectile.lifetime_seconds <= 0)
            return false;

        if (_projectile.radius <= 0)
            return false;

        if (_projectile.shot_count <= 0)
            return false;

        if (_projectile.spread_degrees < 0)
            return false;
    }


    // ========================================================================
    // EXPLOSION ABILITY
    // ========================================================================

    var _has_explosion = false;

    for (var i = 0; i < array_length(_data.abilities); ++i)
    {
        if (_data.abilities[i] == EnemyAbility.EXPLODE_ON_DEATH)
        {
            _has_explosion = true;
            break;
        }
    }


    if (_has_explosion)
    {
        if (!variable_struct_exists(_data, "ability_data"))
            return false;

        if (!is_struct(_data.ability_data))
            return false;

        if (!variable_struct_exists(_data.ability_data, "explosion"))
            return false;

        if (!is_struct(_data.ability_data.explosion))
            return false;

        if (_data.ability_data.explosion.damage <= 0)
            return false;

        if (_data.ability_data.explosion.radius <= 0)
            return false;
    }


    return true;
}