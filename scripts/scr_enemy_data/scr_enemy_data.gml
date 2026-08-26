/// @description Data-driven enemy definitions and lookup.

/// @description Registers every enemy definition.

function scr_enemy_data_initialize()
{
    global.vtd.data.enemies = {};


    if (!scr_enemy_data_weak()) return false;
	if (!scr_enemy_data_weak_mk2()) return false;

	if (!scr_enemy_data_hunter()) return false;
	if (!scr_enemy_data_hunter_mk2()) return false;
	if (!scr_enemy_data_phaser()) return false;
    if (!scr_enemy_data_shooter_single()) return false;
    if (!scr_enemy_data_shooter_triple()) return false;
	if (!scr_enemy_data_sniper()) return false;
    if (!scr_enemy_data_kamikaze()) return false;
    if (!scr_enemy_data_splitter()) return false;
    if (!scr_enemy_data_splitter_child()) return false;
	
	// flyers
    if (!scr_enemy_data_flyer()) return false;
	if (!scr_enemy_data_heavy_flyer()) return false;
	if (!scr_enemy_data_gunship()) return false;


    // Modernized original Vector enemies.

    if (!scr_enemy_data_brute()) return false;
    if (!scr_enemy_data_transporter()) return false;
    if (!scr_enemy_data_shield_generator()) return false;


    // Heavy siege enemies.

    if (!scr_enemy_data_siege_beam()) return false;
    if (!scr_enemy_data_siege_rocket()) return false;


    // Formation enemies.

    if (!scr_enemy_data_centipede_head()) return false;
    if (!scr_enemy_data_centipede_child()) return false;


    // FUTURE:
    // scr_enemy_data_underground();
    // scr_enemy_data_stealth();
    // scr_enemy_data_elite();
    // scr_enemy_data_boss();


    show_debug_message(
        "VECTOR TD 2026 - ENEMY DATA INITIALIZED"
    );

    return true;
}

/// @description Creates one enemy reward definition.

function scr_enemy_rewards_create(
    _credits,
    _experience,
    _pickup_chance = 0.2,
    _pickup_multiplier = 0.5
)
{
    return
    {
        experience:
            max(0, _experience),

        resources:
        [{
            resource_key: "resource_credits",
            amount: max(0, _credits),
            chance: 1
        }],

        physical_drop:
        {
            enabled: true,
            resource_key: "resource_credits",

            chance:
                clamp(
                    _pickup_chance,
                    0,
                    1
                ),

            amount:
                ceil(
                    max(0, _credits)
                    * max(0, _pickup_multiplier)
                )
        }
    };
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
	
	if (!variable_struct_exists(_data, "rewards"))
    return false;

	if (!is_struct(_data.rewards))
	    return false;

	if (!variable_struct_exists(_data.rewards, "experience"))
	    return false;

	if (!variable_struct_exists(_data.rewards, "resources"))
	    return false;

	if (_data.rewards.experience < 0)
	    return false;

	if (!is_array(_data.rewards.resources))
	    return false;


	for (
	    var i = 0;
	    i < array_length(_data.rewards.resources);
	    ++i
	)
	{
	    var _reward =
	        _data.rewards.resources[i];

	    if (!is_struct(_reward))
	        return false;

	    if (!variable_struct_exists(_reward, "resource_key"))
	        return false;

	    if (!variable_struct_exists(_reward, "amount"))
	        return false;

	    if (!variable_struct_exists(_reward, "chance"))
	        return false;

	    if (!is_string(_reward.resource_key))
	        return false;

	    if (_reward.amount < 0)
	        return false;

	    if (_reward.chance < 0 || _reward.chance > 1)
	        return false;
	}


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
	
	if (!variable_struct_exists(_data.vitals, "shield_maximum"))
    return false;

	if (_data.vitals.shield_maximum < 0)
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





function scr_enemy_data_weak()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_weak",
        {
            identity:
            {
                key: "enemy_weak",
                name: "Weak CPU Seeker"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_weak,
                radius: 11,
                color: c_yellow
            },

            vitals:
            {
                hp_maximum: 20,
                shield_maximum: 25
            },

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

            rewards:
            scr_enemy_rewards_create(5, 1),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the building-hunting enemy.

function scr_enemy_data_hunter()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_hunter",
        {
            identity:
            {
                key: "enemy_hunter",
                name: "Building Hunter"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_enemy_visual_hunter,
 				scale_x: 1,
 				scale_y: 1,
                radius: 11,
                color: c_red
            },

            vitals:
            {
                hp_maximum: 40,
                shield_maximum: 25
            },

            movement:
            {
                speed: 1.6,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING,

                player:
                {
                    enabled: true,

                    acquire_range: 420,
                    forget_range_multiplier: 1.3,
                    acquire_chance: 0.30,

                    require_line_of_sight: true,
                    require_reachable: true
                },

                strategic_retarget:
                {
                    enabled: true,
					scan_range: 896,

                    interval_minimum: 0.75,
                    interval_maximum: 1.5,

                    minimum_distance_advantage: 64,
                    switch_ratio: 0.85
                }
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

            rewards:
                scr_enemy_rewards_create(
                    8,
                    2
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the CPU-seeking phasing enemy.

function scr_enemy_data_phaser()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_phaser",
        {
            identity:
            {
                key: "enemy_phaser",
                name: "Phaser"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_triangle,
                radius: 14,
                color: c_aqua
            },

            vitals:
            {
                hp_maximum: 30,
                shield_maximum: 25
            },

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
		
            rewards:
            scr_enemy_rewards_create(12, 2),

            abilities:
            [
                EnemyAbility.PHASING
            ]
        }
    );

    return true;
}

/// @description Registers the single-projectile shooter.

function scr_enemy_data_shooter_single()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_shooter_single",
        {
            identity:
            {
                key: "enemy_shooter_single",
                name: "Single Shooter"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_triangle,
                radius: 15.5,
                color: c_orange
            },

            vitals:
            {
                hp_maximum: 35,
                shield_maximum: 25
            },

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
			
            rewards:
            scr_enemy_rewards_create(10, 2),	

            abilities: []
        }
    );

    return true;
}

/// @description Registers the triple-projectile shooter.

function scr_enemy_data_shooter_triple()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_shooter_triple",
        {
            identity:
            {
                key: "enemy_shooter_triple",
                name: "Triple Shooter"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_triangle,
                radius: 16,
                color: c_purple
            },

            vitals:
            {
                hp_maximum: 60,
                shield_maximum: 25
            },

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
                    spread_degrees: 18
                }
            },

            rewards:
            scr_enemy_rewards_create(16, 3),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the contact-exploding kamikaze enemy.

function scr_enemy_data_kamikaze()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_kamikaze",
        {
            identity:
            {
                key: "enemy_kamikaze",
                name: "Kamikaze Exploder"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_kamikaze,
                radius: 15,
                color: c_lime
            },

            vitals:
            {
                hp_maximum: 24,
                shield_maximum: 25
            },

            movement:
            {
                speed: 3.2,
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

            rewards:
            scr_enemy_rewards_create(12, 2),

            abilities:
            [
                EnemyAbility.EXPLODE_ON_DEATH
            ]
        }
    );

    return true;
}

/// @description Registers the large splitting enemy.

function scr_enemy_data_splitter()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_splitter",
        {
            identity:
            {
                key: "enemy_splitter",
                name: "Splitter"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_splitter,
                radius: 24,
                color: c_purple
            },

            vitals:
            {
                hp_maximum: 80,
                shield_maximum: 25
            },

            movement:
            {
                speed: 1.4,
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
			
            rewards:
            scr_enemy_rewards_create(18, 4),	

            abilities:
            [
                EnemyAbility.SPLIT_ON_DEATH
            ]
        }
    );

    return true;
}

/// @description Registers the brainless splitter child.

function scr_enemy_data_splitter_child()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_splitter_child",
        {
            identity:
            {
                key: "enemy_splitter_child",
                name: "Splitter Shard"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_splitter_child,
                radius: 9,
                color: c_purple
            },

            vitals:
            {
                hp_maximum: 12,
                shield_maximum: 25
            },

            movement:
            {
                speed: 3,
                layer: EnemyMovementLayer.GROUND,
                brainless: true,
                destroy_on_impact: true
            },

            // These remain present so every enemy definition has the same
            // predictable structure. Brainless movement ignores targeting.

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
                damage: 8,
                range: 0,
                cooldown_seconds: 0
            },
			
            rewards:
            scr_enemy_rewards_create(0, 0),	

            abilities: []
        }
    );

    return true;
}

/// @description Registers the first flying enemy.

function scr_enemy_data_flyer()
{
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
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_flyer,
                radius: 18,
                color: c_aqua
            },

            vitals:
            {
                hp_maximum: 45,
 				shield_maximum: 25
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
                // Flyers ignore ground terrain and buildings.
                blocked_action: EnemyBlockedAction.WAIT
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 7,
                range: 8,
                cooldown_seconds: 0.8
            },
				
 			rewards:
    scr_enemy_rewards_create(12, 2),	

            abilities: []
        }
    );

    return true;
}

/// @description Registers the heavy building-hunting Brute.

function scr_enemy_data_brute()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_brute",
        {
            identity:
            {
                key: "enemy_brute",
                name: "Heavy Brute"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_brute,
                radius: 28,
                color: make_color_rgb(210, 70, 35)
            },

            vitals:
            {
                hp_maximum: 350,
                shield_maximum: 80
            },

            movement:
            {
                speed: 0.95,
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
                damage: 40,
                range: 7,
                cooldown_seconds: 1.2
            },

            rewards:
                scr_enemy_rewards_create(
                    35,
                    7
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the ground enemy Transporter.

function scr_enemy_data_transporter()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_transporter",
        {
            identity:
            {
                key: "enemy_transporter",
                name: "Ground Transporter"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_transporter,
                radius: 32,
                color: make_color_rgb(190, 45, 210)
            },

            vitals:
            {
                hp_maximum: 500,
                shield_maximum: 100
            },

            movement:
            {
                speed: 0.8,
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
                damage: 25,
                range: 8,
                cooldown_seconds: 1.2
            },

            rewards:
                scr_enemy_rewards_create(
                    50,
                    10
                ),

            abilities:
            [
                EnemyAbility.TRANSPORT_ENEMIES
            ],

            ability_data:
            {
                transport:
                {
                    spawn_radius: 38,

                    cargo:
                    [
                        {
                            enemy_key: "enemy_weak",
                            count_min: 5,
                            count_max: 8,

                            // A shielded transporter may release
                            // shielded children too.
                            inherit_modifiers: true
                        }
                    ]
                }
            }
        }
    );

    return true;
}

/// @description Registers the orbiting ranged Gunship.

function scr_enemy_data_gunship()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_gunship",
        {
            identity:
            {
                key: "enemy_gunship",
                name: "Orbiting Gunship"
            },
			
 			behavior:
 	    EnemyBehavior.ORBIT,

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_gunship,
                radius: 22,
                color: make_color_rgb(80, 210, 255)
            },

            vitals:
            {
                hp_maximum: 120,
                shield_maximum: 60
            },

            movement:
            {
                speed: 2.4,
                layer: EnemyMovementLayer.FLYING
            },

            targeting:
            {
                target_type: EnemyTarget.CPU
            },

            navigation:
            {
                // The gunship performs direct flying movement.
                blocked_action: EnemyBlockedAction.WAIT
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,
                damage: 8,
                range: 340,
                cooldown_seconds: 0.7,

                projectile:
                {
                    speed: 14,
                    lifetime_seconds: 4,
                    radius: 4,
                    color: c_aqua,
                    shot_count: 1,
                    spread_degrees: 0
                }
            },

            rewards:
                scr_enemy_rewards_create(
                    25,
                    5
                ),

            abilities:
            [
               
            ],

            ability_data:
            {
                orbit:
                {
                    radius: 285,

                    // Degrees travelled around the target each second.
                    angular_speed: 18,

                    // Prevents constant switching between approach and orbit.
                    entry_tolerance: 24
                }
            }
        }
    );

    return true;
}

/// @description Registers the long-range enemy Shield Generator.

function scr_enemy_data_shield_generator()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_shield_generator",
        {
            identity:
            {
                key: "enemy_shield_generator",
                name: "Shield Generator"
            },

 			behavior:
 			EnemyBehavior.SUPPORT,

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_shield_generator,
                radius: 34,
                color: make_color_rgb(255, 190, 40)
            },

            vitals:
            {
                hp_maximum: 700,
                shield_maximum: 120
            },

            movement:
            {
                speed: 0.7,
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

            // The generator does not use its ordinary attack while operating
            // as a support unit. These values remain valid fallback data.

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 5,
                range: 8,
                cooldown_seconds: 1
            },

            rewards:
                scr_enemy_rewards_create(
                    65,
                    14
                ),

            abilities:
            [
                EnemyAbility.SHIELD_ALLIES
            ],

            ability_data:
            {
                support_shield:
                {
                    standoff_range: 500,
                    field_radius: 340,

                    shield_capacity: 60,
                    recharge_per_pulse: 15,

                    pulse_seconds: 1,
                    linger_seconds: 2.5,

                    maximum_target_radius: 28,
                    color: c_yellow
                }
            }
        }
    );

    return true;
}

/// @description Registers the continuous-beam siege enemy.

function scr_enemy_data_siege_beam()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_siege_beam",
        {
            identity:
            {
                key: "enemy_siege_beam",
                name: "Siege Beam Platform"
            },

 			behavior:
    EnemyBehavior.ANCHOR_BEAM,

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function:
                    scr_enemy_visual_siege_beam,

                radius: 44,
                color:
                    make_color_rgb(
                        220,
                        70,
                        255
                    )
            },

            vitals:
            {
                hp_maximum: 1400,
                shield_maximum: 180
            },

            movement:
            {
                speed: 0.45,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type:
                    EnemyTarget.BUILDING,

                // Siege platforms remain committed to structures.

                player:
                {
                    enabled: false
                }
            },

            navigation:
            {
                blocked_action:
                    EnemyBlockedAction.BREACH
            },

            // Damage is measured per second.

            attack:
{
    // Continuous-beam damage is measured per second.

    type:
        EnemyAttack.CONTINUOUS_BEAM,

    damage:
        24,

    range:
        620,

    cooldown_seconds:
        0
},

            combat_movement:
            {
                type:
                    EnemyCombatMovement.ANCHOR_ROAM,

                preferred_range: 500,
                minimum_range: 360,
                maximum_range: 620,

                anchor_radius: 128,

                speed_multiplier: 0.8,

                hull_turn_speed: 1.8,
                turret_turn_speed: 6,

                reposition:
                {
                    enabled: true,
                    chance: 0.65,

                    interval_minimum: 2.5,
                    interval_maximum: 4,

                    distance_minimum: 48,
                    distance_maximum: 112,

                    candidate_attempts: 9,
                    arrival_tolerance: 5,

                    require_line_of_sight: true
                }
            },

            rewards:
                scr_enemy_rewards_create(
                    120,
                    24
                ),

            abilities:
            [
			
            ],

            ability_data:
            {
                beam:
                {
                    color:
                        make_color_rgb(
                            255,
                            70,
                            240
                        ),

                    inner_color:
                        c_white,

                    width: 5
                }
            }
        }
    );

    return true;
}

/// @description Registers the explosive-rocket siege enemy.

function scr_enemy_data_siege_rocket()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_siege_rocket",
        {
            identity:
            {
                key: "enemy_siege_rocket",
                name: "Siege Rocket Platform"
            },
				
 			behavior:
    EnemyBehavior.STANDOFF,	

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_siege_rocket,
                radius: 48,
                color: make_color_rgb(255, 110, 40)
            },

            vitals:
            {
                hp_maximum: 1800,
                shield_maximum: 120
            },

            movement:
            {
                speed: 0.38,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING,

                player:
                {
                    enabled: false
                }
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,
                damage: 135,
                range: 720,
                cooldown_seconds: 5,

                projectile:
                {
                    speed: 3.5,
                    lifetime_seconds: 12,

                    radius: 9,
                    color: make_color_rgb(255, 120, 30),

                    shot_count: 1,
                    spread_degrees: 0,

                    impact: ProjectileImpact.EXPLOSIVE,
                    damage_radius: 150,
                    rocket: true
                }
            },

            combat_movement:
            {
                type: EnemyCombatMovement.STATIONARY,

                preferred_range: 620,
                minimum_range: 400,
                maximum_range: 720,

                requires_line_of_sight: true
            },

            rewards:
                scr_enemy_rewards_create(
                    150,
                    30
                ),

            abilities:
            [

            ]
        }
    );

    return true;
}

/// @description Registers the navigating Centipede head.

function scr_enemy_data_centipede_head()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_centipede_head",
        {
            identity:
            {
                key: "enemy_centipede_head",
                name: "Centipede"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_centipede_head,
                radius: 20,
                color: make_color_rgb(110, 255, 90)
            },

            vitals:
            {
                hp_maximum: 240,
                shield_maximum: 60
            },

            movement:
            {
                speed: 2.5,
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
                damage: 25,
                range: 6,
                cooldown_seconds: 0.9
            },

            centipede:
            {
                child_key: "enemy_centipede_child",

                child_count_minimum: 5,
                child_count_maximum: 8,

                // Number of recorded frames separating each child.
                trail_stagger: 11
            },

            rewards:
                scr_enemy_rewards_create(
                    35,
                    7
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers one Centipede child.

function scr_enemy_data_centipede_child()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_centipede_child",
        {
            identity:
            {
                key: "enemy_centipede_child",
                name: "Centipede Child"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_centipede_child,
                radius: 15,
                color: make_color_rgb(70, 210, 80)
            },

            vitals:
            {
                hp_maximum: 60,
                shield_maximum: 15
            },

            movement:
            {
                speed: 2.5,
                layer: EnemyMovementLayer.GROUND,

                brainless: true,
                destroy_on_impact: true
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.WAIT
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 10,
                range: 4,
                cooldown_seconds: 1
            },

            rewards:
                scr_enemy_rewards_create(
                    5,
                    1,
                    0.05,
                    0.5
                ),

            abilities: []
			
        }
    );

    return true;
}

/// @description Registers the slow CPU-sieging Heavy Flyer.

function scr_enemy_data_heavy_flyer()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_heavy_flyer",
        {
            identity:
            {
                key: "enemy_heavy_flyer",
                name: "Heavy Flyer"
            },

            behavior:
                EnemyBehavior.STANDARD,

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_heavy_flyer,
                radius: 34,
                color: make_color_rgb(60, 210, 255)
            },

            vitals:
            {
                hp_maximum: 325,
                shield_maximum: 100
            },

            movement:
            {
                speed: 0.78,
                layer: EnemyMovementLayer.FLYING
            },

            targeting:
            {
                target_type: EnemyTarget.CPU,

                player:
                {
                    enabled: false
                }
            },

            navigation:
            {
                // Flying enemies ignore normal ground obstruction.
                blocked_action: EnemyBlockedAction.WAIT
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,

                damage: 85,
                range: 500,
                cooldown_seconds: 4.25,

                projectile:
                {
                    // Deliberately large and slow.
                    speed: 3.25,
                    lifetime_seconds: 10,

                    radius: 10,
                    color: make_color_rgb(80, 220, 255),

                    shot_count: 1,
                    spread_degrees: 0,

                    impact: ProjectileImpact.EXPLOSIVE,
                    damage_radius: 110,

                    // Uses the existing rocket projectile visual.
                    rocket: true
                }
            },

            rewards:
                scr_enemy_rewards_create(
                    60,
                    12
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the Mk.II version of the Weak CPU Seeker.

function scr_enemy_data_weak_mk2()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_weak_mk2",
        {
            identity:
            {
                key: "enemy_weak_mk2",
                name: "Weak CPU Seeker Mk.II"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_weak_mk2,
                radius: 14,
                color: c_yellow
            },

            vitals:
            {
                hp_maximum: 35,
                shield_maximum: 35
            },

            movement:
            {
                speed: 1.7,
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
                damage: 7,
                range: 4,
                cooldown_seconds: 1
            },

            rewards:
                scr_enemy_rewards_create(
                    8,
                    2
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the Mk.II version of the Building Hunter.

function scr_enemy_data_hunter_mk2()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_hunter_mk2",
        {
            identity:
            {
                key: "enemy_hunter_mk2",
                name: "Building Hunter Mk.II"
            },

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_hunter_mk2,
                radius: 14,
                color: c_red
            },

            vitals:
            {
                hp_maximum: 65,
                shield_maximum: 40
            },

            movement:
            {
                speed: 1.35,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING,

                player:
                {
                    enabled: true,

                    acquire_range: 420,
                    forget_range_multiplier: 1.3,
                    acquire_chance: 0.30,

                    require_line_of_sight: true,
                    require_reachable: true
                },

                strategic_retarget:
                {
                    enabled: true,
					scan_range: 896,

                    interval_minimum: 0.75,
                    interval_maximum: 1.5,

                    minimum_distance_advantage: 64,
                    switch_ratio: 0.85
                }
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.CONTACT,
                damage: 11,
                range: 4,
                cooldown_seconds: 1
            },

            rewards:
                scr_enemy_rewards_create(
                    12,
                    3
                ),

            abilities: []
        }
    );

    return true;
}

/// @description Registers the long-range building Sniper.

function scr_enemy_data_sniper()
{
    variable_struct_set(
        global.vtd.data.enemies,
        "enemy_sniper",
        {
            identity:
            {
                key: "enemy_sniper",
                name: "Sniper"
            },

            behavior:
                EnemyBehavior.STANDARD,

            visual:
            {
                sprite: -1,
                scale_x: 1,
                scale_y: 1,
                draw_function: scr_enemy_visual_sniper,
                radius: 14,
                color: make_color_rgb(255, 70, 70)
            },

            vitals:
            {
                hp_maximum: 32,
                shield_maximum: 20
            },

            movement:
            {
                speed: 1.25,
                layer: EnemyMovementLayer.GROUND
            },

            targeting:
            {
                target_type: EnemyTarget.BUILDING,

                // Snipers never deliberately acquire the player.

                player:
                {
                    enabled: false
                },

                // Periodically reconsider which building is worth attacking.

                strategic_retarget:
                {
                    enabled: true,

                    interval_minimum: 1,
                    interval_maximum: 2,

                    minimum_distance_advantage: 96,
                    switch_ratio: 0.80
                }
            },

            navigation:
            {
                blocked_action: EnemyBlockedAction.BREACH
            },

            attack:
            {
                type: EnemyAttack.PROJECTILE,

                damage: 20,
                range: 640,
                cooldown_seconds: 3.5,

                projectile:
                {
                    speed: 22,
                    lifetime_seconds: 6,

                    radius: 2.5,
                    color: make_color_rgb(255, 90, 90),

                    shot_count: 1,
                    spread_degrees: 0
                }
            },

            rewards:
                scr_enemy_rewards_create(
                    18,
                    4
                ),

            abilities: []
        }
    );

    return true;
}