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
	
    // ========================================================================
    // VITALS
    // ========================================================================

    _player.vitals =
    {
        hp:
        {
            current:
                100,

            maximum:
                100
        }
    };


    // ========================================================================
    // VISUAL
    // ========================================================================

    _player.visual =
    {
        // All game entities face right at zero degrees.
        // Do not use image_angle for gameplay rotation.

        draw_angle:
            0,

        radius:
            17,

        color:
            c_aqua
    };


    // ========================================================================
    // COMBAT
    // ========================================================================

    _player.combat =
    {
        kills:
            0,

        firing:
            false,

        weapon:
        {
            damage:
                20,

            cooldown:
            {
                duration:
                    0.18,

                remaining:
                    0
            },

            projectile:
            {
                speed:
                    20,

                lifetime_seconds:
                    1.5,

                radius:
                    4,

                color:
                    c_aqua
            }
        }
    };


    global.vtd_level.entities.player =
        _player;


    show_debug_message(
        "VECTOR TD 2026 - PLAYER INITIALIZED"
    );


    return true;
}


/// @description Reads player movement input.

function scr_player_input_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _input =
        _player.movement.input;


    _input.x =
        keyboard_check(
            ord("D")
        )
        - keyboard_check(
            ord("A")
        );

    _input.y =
        keyboard_check(
            ord("S")
        )
        - keyboard_check(
            ord("W")
        );


    // Normalize diagonal movement.

    if (
        _input.x != 0
        && _input.y != 0
    )
    {
        var _normalizer =
            1 / sqrt(2);

        _input.x *=
            _normalizer;

        _input.y *=
            _normalizer;
    }


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
            _foundation.building_data
                .foundation
                .player_speed_multiplier;
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

            scr_player_aim_update(
                _player
            );

            scr_player_combat_update(
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


            // The player may still face the cursor while stunned.

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


/// @description Draws the player using their custom draw angle.

function scr_player_draw(_player)
{
    if (!instance_exists(_player))
        return false;


    var _visual =
        _player.visual;


    if (_player.sprite_index != -1)
    {
        draw_sprite_ext(
            _player.sprite_index,
            _player.image_index,
            _player.x,
            _player.y,
            1,
            1,
            _visual.draw_angle,
            c_white,
            1
        );
    }
    else
    {
        // Primitive fallback so the player can be tested before a sprite
        // is assigned.

        draw_set_color(
            _visual.color
        );

        draw_circle(
            _player.x,
            _player.y,
            _visual.radius,
            false
        );

        draw_line_width(
            _player.x,
            _player.y,
            _player.x
                + lengthdir_x(
                    _visual.radius + 10,
                    _visual.draw_angle
                ),
            _player.y
                + lengthdir_y(
                    _visual.radius + 10,
                    _visual.draw_angle
                ),
            3
        );
    }


    draw_set_color(
        c_white
    );


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


    _weapon.cooldown.remaining =
        max(
            0,
            _weapon.cooldown.remaining
            - (1 / _fps)
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

function scr_player_damage(_player, _damage)
{
    if (!instance_exists(_player))
        return false;

    if (!is_struct(_damage))
        return false;

    if (_player.PlayerState == PlayerState.DEAD)
        return false;

    if (_damage.amount <= 0)
        return false;


    _player.vitals.hp.current = max(
        0,
        _player.vitals.hp.current - _damage.amount
    );


    if (_player.vitals.hp.current <= 0)
    {
        _player.PlayerState = PlayerState.DEAD;

        show_debug_message("VECTOR TD 2026 - PLAYER DESTROYED");

        // FUTURE:
        // player respawn
        // lives
        // level failure rules
        // death particles
    }


    return true;
}


/// @description Creates one physical resource pickup.

function scr_pickup_create(
    _world_x,
    _world_y,
    _resource_key,
    _amount
)
{
    if (!is_string(_resource_key))
        return noone;

    if (_resource_key == "")
        return noone;

    if (_amount <= 0)
        return noone;


    return instance_create_layer(
        _world_x,
        _world_y,
        "Effects_Ground",
        o_pickup,
        {
            pickup_resource_key: _resource_key,
            pickup_amount: _amount
        }
    );
}


/// @description Initializes one physical pickup.

function scr_pickup_initialize(_pickup)
{
    if (!instance_exists(_pickup))
        return false;

    if (!variable_instance_exists(_pickup, "pickup_resource_key"))
        return false;

    if (!variable_instance_exists(_pickup, "pickup_amount"))
        return false;


    var _resource_data =
        scr_resource_data_get(
            _pickup.pickup_resource_key
        );

    if (!scr_resource_data_valid(_resource_data))
        return false;


    _pickup.identity =
    {
        resource_key:
            _pickup.pickup_resource_key
    };


    _pickup.value =
    {
        amount:
            max(0, _pickup.pickup_amount)
    };


    _pickup.collection =
    {
        collected: false,

        magnet_range: 128,
        collection_range: 22,
        magnet_strength: 0.09
    };


    _pickup.life =
    {
        remaining_seconds: 20,
        flash_seconds: 4
    };


    _pickup.visual =
    {
        color: _resource_data.visual.color,
        radius: 8,

        hover_time:
            random(360),

        rotation:
            random(360)
    };


    return true;
}


/// @description Awards and removes one collected pickup.

function scr_pickup_collect(
    _pickup,
    _collector
)
{
    if (!instance_exists(_pickup))
        return false;

    if (_pickup.collection.collected)
        return false;


    var _accepted =
        scr_resource_amount_add(
            _pickup.identity.resource_key,
            _pickup.value.amount
        );


    if (_accepted <= 0)
        return false;


    _pickup.collection.collected = true;


    scr_hud_resource_gain_push(
        _pickup.identity.resource_key,
        _accepted
    );


    // FUTURE:
    // collection sound
    // collection beam
    // floating world text
    // player pickup statistics
    // automatic credit-magnet buildings


    instance_destroy(_pickup);

    return true;
}


/// @description Updates attraction, collection and expiration.

function scr_pickup_update(_pickup)
{
    if (!instance_exists(_pickup))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    _pickup.life.remaining_seconds =
        max(
            0,
            _pickup.life.remaining_seconds
            - _delta
        );


    if (_pickup.life.remaining_seconds <= 0)
    {
        instance_destroy(_pickup);
        return true;
    }


    _pickup.visual.hover_time +=
        5;

    _pickup.visual.rotation +=
        2;


    var _player =
        global.vtd_level.entities.player;


    if (!instance_exists(_player))
        return true;

    if (_player.PlayerState == PlayerState.DEAD)
        return true;


    var _distance =
        point_distance(
            _pickup.x,
            _pickup.y,
            _player.x,
            _player.y
        );


    if (_distance <= _pickup.collection.collection_range)
    {
        scr_pickup_collect(
            _pickup,
            _player
        );

        return true;
    }


    if (_distance <= _pickup.collection.magnet_range)
    {
        _pickup.x =
            lerp(
                _pickup.x,
                _player.x,
                _pickup.collection.magnet_strength
            );

        _pickup.y =
            lerp(
                _pickup.y,
                _player.y,
                _pickup.collection.magnet_strength
            );
    }


    return true;
}


/// @description Draws one primitive vector pickup.

function scr_pickup_draw(_pickup)
{
    if (!instance_exists(_pickup))
        return false;


    var _life =
        _pickup.life;

    var _alpha = 1;


    if (
        _life.remaining_seconds
        <= _life.flash_seconds
    )
    {
        _alpha =
            (
                floor(global.vtd.tick / 5)
                mod 2
            )
            ? 0.25
            : 1;
    }


    var _draw_y =
        _pickup.y
        + sin(_pickup.visual.hover_time)
        * 3;

    var _radius =
        _pickup.visual.radius;

    var _angle =
        _pickup.visual.rotation;


    draw_set_alpha(_alpha);
    draw_set_color(_pickup.visual.color);


    for (var i = 0; i < 4; ++i)
    {
        var _first_angle =
            _angle
            + (i * 90);

        var _second_angle =
            _angle
            + ((i + 1) * 90);

        draw_line_width(
            _pickup.x
                + lengthdir_x(
                    _radius,
                    _first_angle
                ),

            _draw_y
                + lengthdir_y(
                    _radius,
                    _first_angle
                ),

            _pickup.x
                + lengthdir_x(
                    _radius,
                    _second_angle
                ),

            _draw_y
                + lengthdir_y(
                    _radius,
                    _second_angle
                ),

            2
        );
    }


    draw_circle(
        _pickup.x,
        _draw_y,
        3,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}

/// @description Moves the player along one axis against square solids.

function scr_player_axis_move(
    _player,
    _amount,
    _horizontal
)
{
    if (!instance_exists(_player))
        return false;

    if (_amount == 0)
        return true;


    var _steps =
        max(
            1,
            ceil(abs(_amount))
        );

    var _step =
        _amount / _steps;


    repeat (_steps)
    {
        var _next_x =
            _player.x
            + (
                _horizontal
                ? _step
                : 0
            );

        var _next_y =
            _player.y
            + (
                _horizontal
                ? 0
                : _step
            );


        var _left =
            _next_x
            - _player.collision.half_width;

        var _right =
            _next_x
            + _player.collision.half_width;

        var _top =
            _next_y
            - _player.collision.half_height;

        var _bottom =
            _next_y
            + _player.collision.half_height;


        if (
            scr_world_rectangle_gameplay_solid(
                _left,
                _top,
                _right,
                _bottom
            )
        )
        {
            break;
        }


        _player.x = _next_x;
        _player.y = _next_y;
    }


    return true;
}