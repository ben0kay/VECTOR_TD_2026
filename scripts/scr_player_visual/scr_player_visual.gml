/// @description Draws the player and their vitals.
function scr_player_draw(_player)
{
    if (!instance_exists(_player))
        return false;


    var _visual =
        _player.visual;

    var _draw_color =
        _player.vitals.feedback.hit_flash > 0
        ? c_red
        : _visual.color;

    var _x =
        _player.x;

    var _y =
        _player.y;

    var _radius =
        _visual.radius;

    var _angle =
        _visual.draw_angle;


    // ========================================================================
    // SPRITE OVERRIDE
    // ========================================================================

    if (_player.sprite_index != -1)
    {
        draw_sprite_ext(
            _player.sprite_index,
            _player.image_index,
            _x,
            _y,
            1,
            1,
            _angle,
            _draw_color,
            1
        );
    }
    else
    {
        draw_set_alpha(1);
        draw_set_color(_draw_color);


        // ====================================================================
        // CHASSIS BODY
        // ====================================================================

        switch (_player.chassis.type)
        {
            case PlayerChassis.ASSAULT:
            {
                // Narrow forward-pointing attack frame.
                draw_triangle(
                    _x + lengthdir_x(_radius + 8, _angle),
                    _y + lengthdir_y(_radius + 8, _angle),

                    _x + lengthdir_x(_radius, _angle + 145),
                    _y + lengthdir_y(_radius, _angle + 145),

                    _x + lengthdir_x(_radius, _angle - 145),
                    _y + lengthdir_y(_radius, _angle - 145),

                    true
                );

                draw_circle(
                    _x,
                    _y,
                    5,
                    false
                );
            }
            break;


            case PlayerChassis.HEAVY:
            {
                // Broad armoured square with a reinforced core.
                draw_rectangle(
                    _x - _radius,
                    _y - _radius,
                    _x + _radius,
                    _y + _radius,
                    true
                );

                draw_rectangle(
                    _x - 8,
                    _y - 8,
                    _x + 8,
                    _y + 8,
                    true
                );
            }
            break;


            case PlayerChassis.ENGINEER:
            {
                // Diamond utility frame with a central construction cross.
                draw_line_width(
                    _x,
                    _y - _radius,
                    _x + _radius,
                    _y,
                    2
                );

                draw_line_width(
                    _x + _radius,
                    _y,
                    _x,
                    _y + _radius,
                    2
                );

                draw_line_width(
                    _x,
                    _y + _radius,
                    _x - _radius,
                    _y,
                    2
                );

                draw_line_width(
                    _x - _radius,
                    _y,
                    _x,
                    _y - _radius,
                    2
                );

                draw_line_width(
                    _x - 7,
                    _y,
                    _x + 7,
                    _y,
                    2
                );

                draw_line_width(
                    _x,
                    _y - 7,
                    _x,
                    _y + 7,
                    2
                );
            }
            break;


            case PlayerChassis.SUPPORT:
            {
                // Circular command frame with a directional link bar.
                draw_circle(
                    _x,
                    _y,
                    _radius,
                    true
                );

                draw_circle(
                    _x,
                    _y,
                    7,
                    true
                );

                draw_line_width(
                    _x - _radius - 4,
                    _y,
                    _x + _radius + 4,
                    _y,
                    2
                );
            }
            break;


            default:
            {
                draw_circle(
                    _x,
                    _y,
                    _radius,
                    true
                );
            }
            break;
        }


        // ====================================================================
        // FACING / PRIMARY-WEAPON DIRECTION
        // ====================================================================

        draw_line_width(
            _x,
            _y,

            _x
                + lengthdir_x(
                    _radius + 10,
                    _angle
                ),

            _y
                + lengthdir_y(
                    _radius + 10,
                    _angle
                ),

            3
        );
    }


    scr_player_vitals_draw(
        _player
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}