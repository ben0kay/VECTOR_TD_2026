/// @description Chassis-selection HUD shown before a level begins.

function scr_hud_chassis_select_create()
{
    return
    {
        width: 1040,
        height: 620,

        padding: 24,
        header_height: 104,
        card_gap: 16,

        color: c_aqua,
        background_alpha: 0.94,

        cards:
        [
            {
                chassis: PlayerChassis.ASSAULT,
                x: 0,
                y: 0,
                width: 0,
                height: 0
            },

            {
                chassis: PlayerChassis.HEAVY,
                x: 0,
                y: 0,
                width: 0,
                height: 0
            },

            {
                chassis: PlayerChassis.ENGINEER,
                x: 0,
                y: 0,
                width: 0,
                height: 0
            },

            {
                chassis: PlayerChassis.SUPPORT,
                x: 0,
                y: 0,
                width: 0,
                height: 0
            }
        ]
    };
}


/// @description Updates card bounds for the current GUI resolution.
function scr_hud_chassis_select_layout_update(_hud)
{
    var _select =
        _hud.hud.chassis_select;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _left =
        floor(
            (_gui_width - _select.width)
            * 0.5
        );

    var _top =
        floor(
            (_gui_height - _select.height)
            * 0.5
        );

    var _content_left =
        _left + _select.padding;

    var _content_top =
        _top
        + _select.header_height;

    var _content_width =
        _select.width
        - (_select.padding * 2);

    var _content_height =
        _select.height
        - _select.header_height
        - _select.padding;

    var _card_width =
        floor(
            (
                _content_width
                - _select.card_gap
            )
            * 0.5
        );

    var _card_height =
        floor(
            (
                _content_height
                - _select.card_gap
            )
            * 0.5
        );

    for (
        var i = 0;
        i < array_length(_select.cards);
        ++i
    )
    {
        var _card =
            _select.cards[i];

        var _column =
            i mod 2;

        var _row =
            floor(i / 2);

        _card.x =
            _content_left
            + (
                _column
                * (
                    _card_width
                    + _select.card_gap
                )
            );

        _card.y =
            _content_top
            + (
                _row
                * (
                    _card_height
                    + _select.card_gap
                )
            );

        _card.width =
            _card_width;

        _card.height =
            _card_height;
    }

    return true;
}


/// @description Returns whether a GUI point is inside one chassis card.
function scr_hud_chassis_select_card_contains(
    _card,
    _x,
    _y
)
{
    return
        _x >= _card.x
        && _x <= _card.x + _card.width
        && _y >= _card.y
        && _y <= _card.y + _card.height;
}


/// @description Starts ordinary level gameplay after a chassis is chosen.
function scr_hud_chassis_select_confirm(
    _hud,
    _chassis
)
{
    if (!instance_exists(_hud))
        return false;

    var _player =
        global.vtd_level.entities.player;

    if (!instance_exists(_player))
        return false;

    if (
        !scr_player_chassis_select(
            _player,
            _chassis
        )
    )
    {
        return false;
    }

    global.LevelState =
        LevelState.PLAYING;

    return true;
}


/// @description Processes chassis-card selection input.
function scr_hud_chassis_select_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (
        global.LevelState
        != LevelState.CHASSIS_SELECT
    )
    {
        return true;
    }

    scr_hud_chassis_select_layout_update(
        _hud
    );

    if (!mouse_check_button_pressed(mb_left))
        return true;

    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);

    var _cards =
        _hud.hud.chassis_select.cards;

    for (
        var i = 0;
        i < array_length(_cards);
        ++i
    )
    {
        var _card =
            _cards[i];

        if (
            !scr_hud_chassis_select_card_contains(
                _card,
                _mouse_x,
                _mouse_y
            )
        )
        {
            continue;
        }

        return scr_hud_chassis_select_confirm(
            _hud,
            _card.chassis
        );
    }

    return true;
}


/// @description Draws the small visual identity icon for one chassis card.
function scr_hud_chassis_select_icon_draw(
    _x,
    _y,
    _style,
    _color
)
{
    draw_set_alpha(1);
    draw_set_color(_color);

    switch (_style)
    {
        case "assault":
        {
            draw_triangle(
                _x + 28,
                _y,

                _x - 20,
                _y - 22,

                _x - 20,
                _y + 22,

                false
            );
        }
        break;


        case "heavy":
        {
            draw_rectangle(
                _x - 22,
                _y - 22,
                _x + 22,
                _y + 22,
                false
            );

            draw_rectangle(
                _x - 13,
                _y - 13,
                _x + 13,
                _y + 13,
                true
            );
        }
        break;


        case "engineer":
        {
            draw_line_width(
                _x,
                _y - 28,
                _x + 28,
                _y,
                3
            );

            draw_line_width(
                _x + 28,
                _y,
                _x,
                _y + 28,
                3
            );

            draw_line_width(
                _x,
                _y + 28,
                _x - 28,
                _y,
                3
            );

            draw_line_width(
                _x - 28,
                _y,
                _x,
                _y - 28,
                3
            );
        }
        break;


        case "support":
        {
            draw_circle(
                _x,
                _y,
                24,
                true
            );

            draw_line_width(
                _x - 34,
                _y,
                _x + 34,
                _y,
                3
            );

            draw_line_width(
                _x,
                _y - 34,
                _x,
                _y + 34,
                3
            );
        }
        break;
    }

    return true;
}


/// @description Draws the pre-level chassis-selection interface.
function scr_hud_chassis_select_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (
        global.LevelState
        != LevelState.CHASSIS_SELECT
    )
    {
        return true;
    }

    scr_hud_chassis_select_layout_update(
        _hud
    );

    var _select =
        _hud.hud.chassis_select;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _left =
        floor(
            (_gui_width - _select.width)
            * 0.5
        );

    var _top =
        floor(
            (_gui_height - _select.height)
            * 0.5
        );

    var _right =
        _left + _select.width;

    var _bottom =
        _top + _select.height;

    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);


    // ========================================================================
    // BACKDROP / WINDOW
    // ========================================================================

    draw_set_alpha(0.58);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );

    draw_set_alpha(
        _select.background_alpha
    );

    draw_set_color(c_black);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );

    draw_set_alpha(1);
    draw_set_color(_select.color);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        true
    );

    draw_line_width(
        _left,
        _top + _select.header_height,
        _right,
        _top + _select.header_height,
        2
    );


    // ========================================================================
    // HEADER
    // ========================================================================

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    draw_text(
        (_left + _right) * 0.5,
        _top + 22,
        "SELECT PLAYER CHASSIS"
    );

    draw_set_color(c_gray);

    draw_text(
        (_left + _right) * 0.5,
        _top + 58,
        "Choose your baseline combat role for this level"
    );


    // ========================================================================
    // CARDS
    // ========================================================================

    var _cards =
        _select.cards;

    for (
        var i = 0;
        i < array_length(_cards);
        ++i
    )
    {
        var _card =
            _cards[i];

        var _data =
            scr_player_chassis_data_get(
                _card.chassis
            );

        var _hovered =
            scr_hud_chassis_select_card_contains(
                _card,
                _mouse_x,
                _mouse_y
            );

        var _card_color =
            _data.visual.color;

        draw_set_alpha(
            _hovered
            ? 0.30
            : 0.12
        );

        draw_set_color(c_black);

        draw_rectangle(
            _card.x,
            _card.y,
            _card.x + _card.width,
            _card.y + _card.height,
            false
        );

        draw_set_alpha(1);
        draw_set_color(_card_color);

        draw_rectangle(
            _card.x,
            _card.y,
            _card.x + _card.width,
            _card.y + _card.height,
            true
        );

        scr_hud_chassis_select_icon_draw(
            _card.x + 62,
            _card.y + 62,
            _data.visual.style,
            _card_color
        );

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(_card_color);

        draw_text(
            _card.x + 118,
            _card.y + 24,
            _data.name
        );

        draw_set_color(c_white);

        draw_text_ext(
		    _card.x + 118,
		    _card.y + 56,
		    _data.description,
		    18,
		    _card.width - 140
		);

        var _secondary_name =
		    "COMBAT BURST";

		switch (_data.alternate_ability)
		{
		    case PlayerAlternateAbility.ROCKET:
		    {
		        _secondary_name =
		            "ROCKET";
		    }
		    break;


		    case PlayerAlternateAbility.REPAIR:
		    {
		        _secondary_name =
		            "REPAIR";
		    }
		    break;


		    case PlayerAlternateAbility.COMMAND_PULSE:
		    {
		        _secondary_name =
		            "COMMAND PULSE";
		    }
		    break;
		}


		draw_set_color(c_ltgray);

		draw_text(
		    _card.x + 22,
		    _card.y + _card.height - 58,

		    "PRIMARY: PULSE"
		    + "\nSECONDARY: "
		    + _secondary_name
		);

        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);

        draw_set_color(
            _hovered
            ? _card_color
            : c_gray
        );

        draw_text(
            _card.x + _card.width - 18,
            _card.y + _card.height - 18,
            _hovered
            ? "CLICK TO DEPLOY"
            : "SELECT"
        );
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}