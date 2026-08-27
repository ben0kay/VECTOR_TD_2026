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

/// @description Draws a segmented vector-tech frame with clipped corners.

function scr_hud_chassis_select_frame_draw(
    _left,
    _top,
    _right,
    _bottom,
    _color,
    _corner_size = 16,
    _line_width = 1
)
{
    var _corner =
        max(
            4,
            _corner_size
        );

    draw_set_color(_color);


    // Main segmented edges.

    draw_line_width(
        _left + _corner,
        _top,
        _right - _corner,
        _top,
        _line_width
    );

    draw_line_width(
        _left + _corner,
        _bottom,
        _right - _corner,
        _bottom,
        _line_width
    );

    draw_line_width(
        _left,
        _top + _corner,
        _left,
        _bottom - _corner,
        _line_width
    );

    draw_line_width(
        _right,
        _top + _corner,
        _right,
        _bottom - _corner,
        _line_width
    );


    // Clipped corner braces.

    draw_line_width(
        _left,
        _top + _corner,
        _left + _corner,
        _top,
        _line_width
    );

    draw_line_width(
        _right - _corner,
        _top,
        _right,
        _top + _corner,
        _line_width
    );

    draw_line_width(
        _left,
        _bottom - _corner,
        _left + _corner,
        _bottom,
        _line_width
    );

    draw_line_width(
        _right - _corner,
        _bottom,
        _right,
        _bottom - _corner,
        _line_width
    );


    // Small inset technical marks.

    var _mark_length =
        min(
            24,
            (_right - _left) * 0.12
        );

    draw_line_width(
        _left + _corner + 10,
        _top + 5,
        _left + _corner + 10 + _mark_length,
        _top + 5,
        _line_width
    );

    draw_line_width(
        _right - _corner - 10 - _mark_length,
        _bottom - 5,
        _right - _corner - 10,
        _bottom - 5,
        _line_width
    );

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
    // BACKDROP
    // ========================================================================

    draw_set_alpha(0.74);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );


    // ========================================================================
    // MAIN VECTOR WINDOW
    // ========================================================================

    draw_set_alpha(0.96);
    draw_set_color(c_black);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );

    draw_set_alpha(1);

    scr_hud_chassis_select_frame_draw(
        _left,
        _top,
        _right,
        _bottom,
        c_aqua,
        20,
        2
    );


    // Header separator and technical rails.

    draw_set_alpha(0.85);
    draw_set_color(c_aqua);

    draw_line_width(
        _left + 20,
        _top + _select.header_height,
        _right - 20,
        _top + _select.header_height,
        1
    );

    draw_line_width(
        _left + 32,
        _top + _select.header_height + 6,
        _left + 190,
        _top + _select.header_height + 6,
        1
    );

    draw_line_width(
        _right - 190,
        _top + _select.header_height + 6,
        _right - 32,
        _top + _select.header_height + 6,
        1
    );


    // ========================================================================
    // HEADER
    // ========================================================================

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_aqua);

    draw_text(
        (_left + _right) * 0.5,
        _top + 16,
        "CHASSIS DEPLOYMENT ARRAY"
    );

    draw_set_color(c_white);

    draw_text(
        (_left + _right) * 0.5,
        _top + 42,
        "SELECT PLAYER CHASSIS"
    );

    draw_set_color(c_gray);

    draw_text(
        (_left + _right) * 0.5,
        _top + 68,
        "CHOOSE YOUR BASELINE COMBAT ROLE FOR THIS LEVEL"
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_aqua);

    draw_text(
        _left + 24,
        _top + 18,
        "SYS // READY"
    );

    draw_set_halign(fa_right);

    draw_text(
        _right - 24,
        _top + 18,
        "UNIT // 01"
    );


    // ========================================================================
    // CHASSIS CARDS
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

        var _card_left =
            _card.x;

        var _card_top =
            _card.y;

        var _card_right =
            _card.x + _card.width;

        var _card_bottom =
            _card.y + _card.height;


        // Dark panel body.

        draw_set_alpha(
            _hovered
            ? 0.52
            : 0.34
        );

        draw_set_color(c_black);

        draw_rectangle(
            _card_left,
            _card_top,
            _card_right,
            _card_bottom,
            false
        );


        // Aqua structural frame, with chassis-colour corner highlights.

        draw_set_alpha(
            _hovered
            ? 0.95
            : 0.55
        );

        scr_hud_chassis_select_frame_draw(
            _card_left,
            _card_top,
            _card_right,
            _card_bottom,
            c_aqua,
            12,
            1
        );

        draw_set_alpha(1);

        scr_hud_chassis_select_frame_draw(
            _card_left + 4,
            _card_top + 4,
            _card_right - 4,
            _card_bottom - 4,
            _card_color,
            8,
            _hovered
            ? 2
            : 1
        );


        // Left identity rail.

        draw_set_alpha(
            _hovered
            ? 1
            : 0.75
        );

        draw_set_color(_card_color);

        draw_line_width(
            _card_left + 14,
            _card_top + 18,
            _card_left + 14,
            _card_bottom - 18,
            _hovered
            ? 3
            : 2
        );


        // Icon containment panel.

        draw_set_alpha(0.65);
        draw_set_color(c_aqua);

        draw_rectangle(
            _card_left + 28,
            _card_top + 24,
            _card_left + 96,
            _card_top + 92,
            true
        );

        draw_set_alpha(1);

        scr_hud_chassis_select_icon_draw(
            _card_left + 62,
            _card_top + 58,
            _data.visual.style,
            _card_color
        );


        // Chassis number / title.

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        draw_set_color(c_aqua);

        draw_text(
            _card_left + 118,
            _card_top + 18,
            "CHASSIS // "
            + string(i + 1)
        );

        draw_set_color(_card_color);

        draw_text(
            _card_left + 118,
            _card_top + 42,
            _data.name
        );

        draw_set_color(c_white);

        draw_text_ext(
            _card_left + 118,
            _card_top + 70,
            _data.description,
            18,
            _card.width - 142
        );


        // Divider above loadout data.

        draw_set_alpha(0.60);
        draw_set_color(c_aqua);

        draw_line_width(
            _card_left + 28,
            _card_bottom - 76,
            _card_right - 28,
            _card_bottom - 76,
            1
        );


        // Secondary ability label.

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


        // Loadout information.

        draw_set_alpha(1);
        draw_set_color(c_ltgray);

        draw_text(
            _card_left + 30,
            _card_bottom - 62,
            "PRIMARY // PULSE"
        );

        draw_text(
            _card_left + 30,
            _card_bottom - 38,
            "SECONDARY // "
            + _secondary_name
        );


        // Selection prompt.

        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);

        draw_set_color(
            _hovered
            ? _card_color
            : c_gray
        );

        draw_text(
            _card_right - 24,
            _card_bottom - 18,
            _hovered
            ? "CLICK TO DEPLOY >"
            : "SELECT >"
        );


        // Small animated-looking corner status glyph.

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(_card_color);

        draw_text(
            _card_left + 28,
            _card_top + _card.height - 22,
            _hovered
            ? "[ ACTIVE ]"
            : "[ STANDBY ]"
        );
    }


    // ========================================================================
    // FOOTER DETAILS
    // ========================================================================

    draw_set_alpha(0.65);
    draw_set_color(c_aqua);

    draw_line_width(
        _left + 24,
        _bottom - 16,
        _left + 170,
        _bottom - 16,
        1
    );

    draw_line_width(
        _right - 170,
        _bottom - 16,
        _right - 24,
        _bottom - 16,
        1
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}