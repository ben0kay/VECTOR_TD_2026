/// @description Player initialization, input, movement, and drawing.

/// @description Initializes one player instance.

function scr_player_initialize(_player)
{
    if (!instance_exists(_player))
        return false;


    _player.PlayerState =
        PlayerState.ACTIVE;


    // ========================================================================
    // MOVEMENT
    // ========================================================================

    _player.movement =
    {
        speed: 6,
        speed_base: 6,
        speed_multiplier: 1,

        input:
        {
            x: 0,
            y: 0
        },

        moving: false
    };


    // ========================================================================
	// COLLISION
	// ========================================================================

	_player.collision =
	{
	    half_width: 14,
	    half_height: 14
	};

	_player.mask_index = s_collision_square;

	_player.image_xscale =
	    (_player.collision.half_width * 2)
	    / sprite_get_width(s_collision_square);

	_player.image_yscale =
	    (_player.collision.half_height * 2)
	    / sprite_get_height(s_collision_square);


    // ========================================================================
    // VITALS
    // ========================================================================

    _player.vitals =
    {
        hp:
        {
            current: 100,
            maximum: 100
        },

        shield:
        {
            enabled: false,
            current: 0,
            maximum: 0,

            color:
                make_color_rgb(
                    100,
                    190,
                    255
                )
        },

        feedback:
        {
            hit_flash: 0
        }
    };


    // ========================================================================
    // VISUAL
    // ========================================================================

    _player.visual =
    {
        // All entities face right at zero degrees.
        // Gameplay rotation uses draw_angle, never image_angle.

        draw_angle: 0,
        radius: 17,
        color: c_aqua
    };


    // ========================================================================
    // COMBAT
    // ========================================================================

    _player.combat =
    {
        kills: 0,
        firing: false,

        weapon:
        {
            damage: 20,

            cooldown:
            {
                duration: 0.18,
                remaining: 0
            },

            projectile:
            {
                speed: 20,
                lifetime_seconds: 1.5,
                radius: 4,
                color: c_aqua
            }
        }
    };

	// ========================================================================
	// CHASSIS / STATS
	// ========================================================================

	_player.chassis =
	    scr_player_chassis_runtime_create();

		
    global.vtd_level.entities.player =
        _player;


    show_debug_message(
        "VECTOR TD 2026 - PLAYER INITIALIZED"
    );


    return true;
}

/// @description Reads player movement input for the current camera mode.

function scr_player_input_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _input =
        _player.movement.input;


    // WASD always controls the player.

    var _move_x =
        keyboard_check(ord("D"))
        - keyboard_check(ord("A"));

    var _move_y =
        keyboard_check(ord("S"))
        - keyboard_check(ord("W"));


    // Arrow keys control the player only while the camera follows them.
    // In roaming mode, the camera consumes the arrow keys instead.

    switch (global.CameraState)
    {
        case CameraState.FOLLOW_PLAYER:
        {
            _move_x +=
                keyboard_check(vk_right)
                - keyboard_check(vk_left);

            _move_y +=
                keyboard_check(vk_down)
                - keyboard_check(vk_up);
        }
        break;


        case CameraState.ROAMING:
        {
            // Arrow keys belong exclusively to the roaming camera.
        }
        break;
    }


    // Prevent combined WASD and arrow input from exceeding one direction.

    _move_x =
        clamp(
            _move_x,
            -1,
            1
        );

    _move_y =
        clamp(
            _move_y,
            -1,
            1
        );


    // Normalize diagonal movement.

    if (
        _move_x != 0
        && _move_y != 0
    )
    {
        var _normalizer =
            1 / sqrt(2);

        _move_x *=
            _normalizer;

        _move_y *=
            _normalizer;
    }


    _input.x =
        _move_x;

    _input.y =
        _move_y;


    _player.movement.moving =
        (
            _input.x != 0
            || _input.y != 0
        );


    return true;
}

/// @description Moves the player with square collision and clean sliding.

function scr_player_movement_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _movement =
        _player.movement;


    // ========================================================================
    // FOUNDATION MOVEMENT BONUS
    // ========================================================================

    var _cell =
        scr_building_position_to_cell(
            _player.x,
            _player.y
        );

    var _foundation =
        scr_foundation_at_cell(
            _cell.x,
            _cell.y
        );


    _movement.speed_multiplier =
        1;


    if (
        instance_exists(_foundation)
        && _foundation.BuildingState
            == BuildingState.ACTIVE
    )
    {
        _movement.speed_multiplier =
    scr_foundation_position_modifier_get(
        _player.x,
        _player.y,
        "player_move_speed",
        1
    );


_movement.speed =
    _movement.speed_base
    * _movement.speed_multiplier;
    }


    _movement.speed =
        _movement.speed_base
        * _movement.speed_multiplier;


    var _move_x =
        _movement.input.x
        * _movement.speed;

    var _move_y =
        _movement.input.y
        * _movement.speed;


    // Separate axis resolution allows clean sliding along structures.

    scr_player_axis_move(
        _player,
        _move_x,
        true
    );

    scr_player_axis_move(
        _player,
        _move_y,
        false
    );


    _player.x =
        clamp(
            _player.x,
            _player.collision.half_width,
            room_width
                - _player.collision.half_width
        );

    _player.y =
        clamp(
            _player.y,
            _player.collision.half_height,
            room_height
                - _player.collision.half_height
        );


    return true;
}


/// @description Updates the player's custom facing angle.

function scr_player_aim_update(_player)
{
    if (!instance_exists(_player))
        return false;


    _player.visual.draw_angle =
        point_direction(
            _player.x,
            _player.y,
            mouse_x,
            mouse_y
        );


    return true;
}

/// @description Processes one complete player update.

function scr_player_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _player.vitals.feedback.hit_flash =
        max(
            0,
            _player.vitals.feedback.hit_flash
            - (5 / _fps)
        );


    switch (_player.PlayerState)
    {
        case PlayerState.ACTIVE:
        {
            scr_player_input_update(
                _player
            );

            scr_player_movement_update(
                _player
            );

            scr_player_enemy_contact_update(
                _player
            );


            if (_player.PlayerState == PlayerState.DEAD)
                return true;


            scr_player_aim_update(
                _player
            );

            scr_player_combat_update(
                _player
            );
			
			scr_player_alternate_ability_update(
			    _player
			);


            // FUTURE:
            // scr_player_interaction_update(_player);
        }
        break;


        case PlayerState.STUNNED:
        {
            _player.movement.input.x =
                0;

            _player.movement.input.y =
                0;

            _player.movement.moving =
                false;

            _player.combat.firing =
                false;


            scr_player_enemy_contact_update(
                _player
            );

            scr_player_aim_update(
                _player
            );
        }
        break;


        case PlayerState.DEAD:
        {
            _player.movement.input.x =
                0;

            _player.movement.input.y =
                0;

            _player.movement.moving =
                false;

            _player.combat.firing =
                false;


            // FUTURE:
            // death animation
            // respawn handling
            // level failure rules
        }
        break;
    }


    return true;
}

/// @description Processes player weapon input and firing.

function scr_player_combat_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _combat =
        _player.combat;

    var _weapon =
        _combat.weapon;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    var _foundation_fire_rate =
    scr_foundation_position_modifier_get(
        _player.x,
        _player.y,
        "player_fire_rate",
        1
    );


_weapon.cooldown.remaining =
    max(
        0,
        _weapon.cooldown.remaining
        - (
            (1 / _fps)
            * _foundation_fire_rate
        )
    );


    // Left-click belongs to building placement while build mode is active.

    if (
        global.BuildState
        != BuildState.NONE
    )
    {
        _combat.firing =
            false;

        return true;
    }


    _combat.firing =
        mouse_check_button(
            mb_left
        );


    if (!_combat.firing)
        return true;

    if (_weapon.cooldown.remaining > 0)
        return true;


    var _angle =
        _player.visual.draw_angle;

    var _spawn_distance =
        _player.visual.radius + 8;


    var _projectile =
        scr_projectile_player_create(
            _player,

            _player.x
                + lengthdir_x(
                    _spawn_distance,
                    _angle
                ),

            _player.y
                + lengthdir_y(
                    _spawn_distance,
                    _angle
                ),

            _angle,
            _weapon.damage,
            _weapon.projectile
        );


    if (!instance_exists(_projectile))
        return false;


    _weapon.cooldown.remaining =
        _weapon.cooldown.duration;


    return true;
}

/// @description Applies one damage packet to the player.

function scr_player_damage(
    _player,
    _damage
)
{
    if (!instance_exists(_player))
        return false;

    if (!is_struct(_damage))
        return false;

    if (_player.PlayerState == PlayerState.DEAD)
        return false;

    if (_damage.amount <= 0)
        return false;


    var _damage_type =
        DamageType.KINETIC;

    if (
        variable_struct_exists(
            _damage,
            "damage_type"
        )
    )
    {
        _damage_type =
            _damage.damage_type;
    }


    var _remaining_damage =
        _damage.amount;
		
		_remaining_damage *=
    scr_foundation_position_modifier_get(
        _player.x,
        _player.y,
        "player_damage_received",
        1
    );

    var _shield =
        _player.vitals.shield;


    // ========================================================================
    // SHIELD
    // ========================================================================

    if (
        _shield.enabled
        && _shield.current > 0
    )
    {
        var _shield_multiplier =
            max(
                0.01,
                scr_damage_shield_multiplier(
                    _damage_type
                )
            );

        var _shield_damage =
            min(
                _shield.current,
                _remaining_damage
                * _shield_multiplier
            );


        _shield.current -=
            _shield_damage;

        _remaining_damage =
            max(
                0,
                _remaining_damage
                - (
                    _shield_damage
                    / _shield_multiplier
                )
            );


        if (_shield.current <= 0)
        {
            _shield.current =
                0;

            _shield.enabled =
                false;


            scr_effect_shockwave_create(
                _player.x,
                _player.y,
                _player.visual.radius + 18,
                _shield.color,
                EnemyMovementLayer.GROUND
            );


            scr_particles_shield_break(
                _player.x,
                _player.y,
                _shield.color,
                _player.visual.radius + 18
            );
        }
    }


    // ========================================================================
    // HEALTH
    // ========================================================================

    if (_remaining_damage > 0)
    {
        var _health_damage =
            _remaining_damage
            * scr_damage_health_multiplier(
                _damage_type
            );


        _player.vitals.hp.current =
            max(
                0,
                _player.vitals.hp.current
                - _health_damage
            );
    }


    _player.vitals.feedback.hit_flash =
        1;


    scr_particles_impact(
        _player.x,
        _player.y,
        c_red,
        5
    );


    // ========================================================================
    // DEATH
    // ========================================================================

    if (_player.vitals.hp.current <= 0)
    {
        // A future upgrade gets the first opportunity to prevent defeat.

        if (scr_player_respawn_try(_player))
            return true;


        _player.vitals.hp.current =
            0;

        _player.PlayerState =
            PlayerState.DEAD;

        _player.combat.firing =
            false;


        scr_particles_explosion(
            _player.x,
            _player.y,
            c_aqua,
            1.25
        );


        show_debug_message(
            "VECTOR TD 2026 - PLAYER DESTROYED"
        );


        scr_level_result_resolve(
            false,
            "PLAYER DESTROYED"
        );
    }


    return true;
}

/// @description Moves the player along one axis against square solids.

function scr_player_axis_move(_player, _amount, _horizontal)
{
    if (_amount == 0)
        return true;

    var _steps = max(1, ceil(abs(_amount)));
    var _step = _amount / _steps;

    repeat (_steps)
    {
        var _next_x = _player.x + (_horizontal ? _step : 0);
        var _next_y = _player.y + (_horizontal ? 0 : _step);

        if (place_meeting(_next_x, _next_y, o_solid_par))
            break;

        _player.x = _next_x;
        _player.y = _next_y;
    }

    return true;
}

/// @description Tests the player's square body against one enemy circle.

function scr_player_enemy_contact_check(
    _player,
    _enemy
)
{
    if (!instance_exists(_player))
        return false;

    if (!instance_exists(_enemy))
        return false;


    var _left =
        _player.x
        - _player.collision.half_width;

    var _right =
        _player.x
        + _player.collision.half_width;

    var _top =
        _player.y
        - _player.collision.half_height;

    var _bottom =
        _player.y
        + _player.collision.half_height;


    var _closest_x =
        clamp(
            _enemy.x,
            _left,
            _right
        );

    var _closest_y =
        clamp(
            _enemy.y,
            _top,
            _bottom
        );


    var _distance_squared =
        sqr(_enemy.x - _closest_x)
        + sqr(_enemy.y - _closest_y);

    var _enemy_radius =
        max(
            1,
            _enemy.visual.radius
        );


    return _distance_squared
        <= sqr(_enemy_radius);
}

/// @description Resolves enemy collisions against the player.

function scr_player_enemy_contact_update(_player)
{
    if (!instance_exists(_player))
        return false;

    if (_player.PlayerState == PlayerState.DEAD)
        return false;


    var _enemy_count =
        instance_number(o_enemy);


    for (var i = _enemy_count - 1; i >= 0; --i)
    {
        var _enemy =
            instance_find(
                o_enemy,
                i
            );

        if (!instance_exists(_enemy))
            continue;

        if (_enemy.EnemyState == EnemyState.DEAD)
            continue;

        // Underground enemies occupy a separate physical layer.

        if (
            _enemy.movement.layer
            == EnemyMovementLayer.UNDERGROUND
        )
        {
            continue;
        }


        var _search_width =
            _player.collision.half_width
            + _enemy.visual.radius;

        var _search_height =
            _player.collision.half_height
            + _enemy.visual.radius;


        // Cheap broad-phase rejection.

        if (
            abs(_enemy.x - _player.x)
            > _search_width
        )
        {
            continue;
        }

        if (
            abs(_enemy.y - _player.y)
            > _search_height
        )
        {
            continue;
        }


        if (
            !scr_player_enemy_contact_check(
                _player,
                _enemy
            )
        )
        {
            continue;
        }


        // Player receives the enemy's normal configured attack damage.

        var _damage =
            scr_damage_create(
                _enemy.attack.damage,
                _enemy,
                DamageSource.ENEMY,
                DamageType.KINETIC
            );


        scr_player_damage(
            _player,
            _damage
        );


        // Contact destroys the enemy without granting a normal kill reward.
        // Death abilities such as explosions still execute normally.

        if (instance_exists(_enemy))
        {
            scr_enemy_die(
                _enemy,
                undefined
            );
        }


        // Stop processing contacts once the player dies.

        if (_player.PlayerState == PlayerState.DEAD)
            return true;
    }


    return true;
}

/// @description Draws the player's health and future shield bars.

function scr_player_vitals_draw(_player)
{
    if (!instance_exists(_player))
        return false;


    var _hp =
        _player.vitals.hp;

    var _shield =
        _player.vitals.shield;

    var _bar_width =
        44;

    var _bar_left =
        _player.x
        - (_bar_width * 0.5);

    var _hp_top =
        _player.y
        - _player.visual.radius
        - 12;

    var _hp_percent =
        clamp(
            _hp.current
            / max(1, _hp.maximum),
            0,
            1
        );


    // ========================================================================
    // HEALTH BAR
    // ========================================================================

    draw_set_alpha(0.85);
    draw_set_color(c_dkgray);

    draw_rectangle(
        _bar_left,
        _hp_top,
        _bar_left + _bar_width,
        _hp_top + 5,
        false
    );


    draw_set_alpha(1);

    draw_set_color(
        _hp_percent <= 0.25
        ? c_red
        : c_lime
    );

    draw_rectangle(
        _bar_left,
        _hp_top,
        _bar_left
            + (_bar_width * _hp_percent),
        _hp_top + 5,
        false
    );


    // ========================================================================
    // FUTURE SHIELD BAR
    // ========================================================================

    if (_shield.maximum > 0)
    {
        var _shield_percent =
            clamp(
                _shield.current
                / max(1, _shield.maximum),
                0,
                1
            );

        var _shield_top =
            _hp_top - 5;


        draw_set_color(c_dkgray);

        draw_rectangle(
            _bar_left,
            _shield_top,
            _bar_left + _bar_width,
            _shield_top + 3,
            false
        );


        draw_set_color(
            _shield.color
        );

        draw_rectangle(
            _bar_left,
            _shield_top,
            _bar_left
                + (_bar_width * _shield_percent),
            _shield_top + 3,
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Attempts to prevent player death through a future respawn source.

function scr_player_respawn_try(_player)
{
    if (!instance_exists(_player))
        return false;


    // FUTURE:
    // persistent respawn upgrade
    // level-only extra life
    // rescue drone
    // respawn cooldown
    // respawn-position selection
    //
    // Return true after successfully restoring the player.

    return false;
}

/// @description Handles the player's chassis-specific secondary ability input.
function scr_player_alternate_ability_update(_player)
{
    if (!instance_exists(_player))
        return false;

    if (!mouse_check_button_pressed(mb_middle))
        return true;


    switch (_player.chassis.alternate_ability)
    {
        case PlayerAlternateAbility.COMBAT_BURST:
        {
            // FUTURE:
            // Assault secondary ability.
        }
        break;


        case PlayerAlternateAbility.ROCKET:
        {
            // FUTURE:
            // Heavy secondary ability.
        }
        break;


        case PlayerAlternateAbility.REPAIR:
        {
            // FUTURE:
            // Engineer secondary ability.
        }
        break;


        case PlayerAlternateAbility.COMMAND_PULSE:
        {
            // FUTURE:
            // Support secondary ability.
        }
        break;
    }

    return true;
}