/// @description Player initialization, input, movement, and drawing.


/// @description Initializes one player instance.

function scr_player_initialize(_player)
{
    if (!instance_exists(_player))
        return false;


    _player.player_state =
        PlayerState.ACTIVE;


    _player.movement =
    {
        speed:
            6,

        input:
        {
            x:
                0,

            y:
                0
        },

        moving:
            false
    };


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


    _player.visual =
    {
        // All game entities face right at zero degrees.
        // We use this custom value instead of image_angle.

        draw_angle:
            0,

        radius:
            20,

        color:
            c_aqua
    };


    _player.combat =
    {
        kills:
            0

        // FUTURE:
        // weapon
        // firing state
        // fire cooldown
        // overheat
        // damage modifiers
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


/// @description Moves the player and clamps them inside the current map.

function scr_player_movement_update(_player)
{
    if (!instance_exists(_player))
        return false;


    var _movement =
        _player.movement;

    var _radius =
        _player.visual.radius;


    _player.x +=
        _movement.input.x
        * _movement.speed;

    _player.y +=
        _movement.input.y
        * _movement.speed;


    _player.x =
        clamp(
            _player.x,
            _radius,
            room_width - _radius
        );

    _player.y =
        clamp(
            _player.y,
            _radius,
            room_height - _radius
        );


    // FUTURE:
    // Collision against terrain and solid buildings can be inserted here
    // without changing the input or state functions.


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


    switch (_player.player_state)
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


            // FUTURE:
            // scr_player_combat_update(_player);
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