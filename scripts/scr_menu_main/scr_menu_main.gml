/// @description Creates one reusable main-menu button.

function scr_menu_main_button_create(
    _action,
    _label,
    _status = "",
    _enabled = true
)
{
    return
    {
        action: _action,
        label: _label,
        status: _status,
        enabled: _enabled,

        hovered: false,
        animation: 0,

        bounds:
        {
            left: 0,
            top: 0,
            right: 0,
            bottom: 0
        }
    };
}


/// @description Creates the main-menu runtime.

function scr_menu_main_create()
{
    return
    {
        selected: 0,

        buttons:
        [
            scr_menu_main_button_create(
                MainMenuAction.CAMPAIGN,
                "CAMPAIGN",
                "BEGIN"
            ),

            scr_menu_main_button_create(
                MainMenuAction.SURVIVAL,
                "SURVIVAL",
                "COMING SOON",
                false
            ),

            scr_menu_main_button_create(
                MainMenuAction.SANDBOX,
                "SANDBOX",
                "COMING SOON",
                false
            ),

            scr_menu_main_button_create(
                MainMenuAction.RESEARCH,
                "RESEARCH",
                "PROFILE REQUIRED",
                false
            ),

            scr_menu_main_button_create(
                MainMenuAction.OPTIONS,
                "OPTIONS",
                "PLACEHOLDER"
            ),

            scr_menu_main_button_create(
                MainMenuAction.CHANGE_PROFILE,
                "CHANGE PROFILE",
                "PLACEHOLDER"
            ),

            scr_menu_main_button_create(
                MainMenuAction.EXIT_GAME,
                "EXIT GAME"
            )
        ],

        layout:
        {
            left: 72,
            top: 220,
            width: 310,
            button_height: 46,
            gap: 7
        },

        intro: 0,

        message:
        {
            text: "",
            timer: 0,
            color: c_aqua
        },

        transition:
        {
            active: false,
            alpha: 0,
            target_room: noone
        }
    };
}


/// @description Displays temporary main-menu feedback.

function scr_menu_main_message_set(
    _menu,
    _text,
    _color = c_aqua,
    _duration_seconds = 2.5
)
{
    if (!is_struct(_menu))
        return false;


    _menu.message.text = _text;
    _menu.message.color = _color;

    _menu.message.timer =
        _duration_seconds
        * max(
            1,
            game_get_speed(gamespeed_fps)
        );


    return true;
}


/// @description Returns whether the GUI pointer overlaps one menu button.

function scr_menu_main_button_pointer_inside(_button)
{
    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);

    var _bounds =
        _button.bounds;


    return point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _bounds.left,
        _bounds.top,
        _bounds.right,
        _bounds.bottom
    );
}


/// @description Moves keyboard selection to another enabled menu button.

function scr_menu_main_selection_move(_menu, _direction)
{
    if (!is_struct(_menu))
        return false;


    var _count =
        array_length(_menu.buttons);

    if (_count <= 0)
        return false;


    repeat (_count)
    {
        _menu.selected =
            (
                _menu.selected
                + _direction
                + _count
            )
            mod _count;


        if (_menu.buttons[_menu.selected].enabled)
            return true;
    }


    return false;
}


/// @description Begins a faded room transition.

function scr_menu_main_transition_begin(_menu, _room)
{
    if (!is_struct(_menu))
        return false;

    if (!room_exists(_room))
        return false;


    _menu.transition.active = true;
    _menu.transition.alpha = 0;
    _menu.transition.target_room = _room;


    return true;
}


/// @description Activates the selected main-menu action.

function scr_menu_main_action_execute(_menu, _action)
{
    if (!is_struct(_menu))
        return false;


    switch (_action)
    {
        case MainMenuAction.CAMPAIGN:
        {
            // TEMPORARY:
            // Campaign launches the test world until level selection exists.

            return scr_menu_main_transition_begin(
                _menu,
                r_world_test
            );
        }


        case MainMenuAction.SURVIVAL:
        {
            return scr_menu_main_message_set(
                _menu,
                "SURVIVAL MODE IS NOT YET AVAILABLE.",
                c_gray
            );
        }


        case MainMenuAction.SANDBOX:
        {
            return scr_menu_main_message_set(
                _menu,
                "SANDBOX MODE IS NOT YET AVAILABLE.",
                c_gray
            );
        }


        case MainMenuAction.RESEARCH:
        {
            return scr_menu_main_message_set(
                _menu,
                "RESEARCH REQUIRES A COMMANDER PROFILE.",
                c_gray
            );
        }


        case MainMenuAction.OPTIONS:
        {
            return scr_menu_main_message_set(
                _menu,
                "OPTIONS INTERFACE WILL BE ADDED LATER.",
                c_aqua
            );
        }


        case MainMenuAction.CHANGE_PROFILE:
        {
            // FUTURE:
            // Transition to r_boot and reopen profile selection.

            return scr_menu_main_message_set(
                _menu,
                "PROFILE SELECTION WILL BE HANDLED BY r_boot.",
                c_yellow
            );
        }


        case MainMenuAction.EXIT_GAME:
        {
            game_end();
            return true;
        }
    }


    return false;
}


/// @description Processes main-menu input and animation.

function scr_menu_main_update(_menu)
{
    if (!is_struct(_menu))
        return false;


    _menu.intro =
        lerp(
            _menu.intro,
            1,
            0.08
        );


    // ========================================================================
    // ROOM TRANSITION
    // ========================================================================

    if (_menu.transition.active)
    {
        _menu.transition.alpha =
            min(
                1,
                _menu.transition.alpha + 0.055
            );


        if (_menu.transition.alpha >= 1)
        {
            var _target_room =
                _menu.transition.target_room;


            // The menu must remain active until the fade completes.
            // Gameplay begins immediately before entering the level room.

            global.GameState =
                GameState.PLAYING;

            global.LevelState =
                LevelState.INITIALIZING;


            room_goto(_target_room);
        }


        return true;
    }


    // ========================================================================
    // MESSAGE
    // ========================================================================

    _menu.message.timer =
        max(
            0,
            _menu.message.timer - 1
        );


    // ========================================================================
    // BUTTON LAYOUT AND MOUSE INPUT
    // ========================================================================

    var _layout =
        _menu.layout;

    var _mouse_pressed =
        mouse_check_button_pressed(mb_left);


    for (var i = 0; i < array_length(_menu.buttons); ++i)
    {
        var _button =
            _menu.buttons[i];

        var _top =
            _layout.top
            + (
                i
                * (
                    _layout.button_height
                    + _layout.gap
                )
            );


        _button.bounds.left =
            _layout.left;

        _button.bounds.top =
            _top;

        _button.bounds.right =
            _layout.left
            + _layout.width;

        _button.bounds.bottom =
            _top
            + _layout.button_height;


        _button.hovered =
            scr_menu_main_button_pointer_inside(
                _button
            );


        if (_button.hovered)
        {
            _menu.selected = i;

            if (_mouse_pressed)
            {
                if (_button.enabled)
                {
                    scr_menu_main_action_execute(
                        _menu,
                        _button.action
                    );
                }
                else
                {
                    scr_menu_main_message_set(
                        _menu,
                        _button.status,
                        c_gray
                    );
                }

                return true;
            }
        }


        var _highlighted =
            i == _menu.selected;


        _button.animation =
            lerp(
                _button.animation,
                _highlighted ? 1 : 0,
                0.18
            );
    }


    // ========================================================================
    // KEYBOARD INPUT
    // ========================================================================

    if (
        keyboard_check_pressed(vk_down)
        || keyboard_check_pressed(ord("S"))
    )
    {
        scr_menu_main_selection_move(
            _menu,
            1
        );
    }


    if (
        keyboard_check_pressed(vk_up)
        || keyboard_check_pressed(ord("W"))
    )
    {
        scr_menu_main_selection_move(
            _menu,
            -1
        );
    }


    if (
        keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space)
    )
    {
        var _selected_button =
            _menu.buttons[_menu.selected];


        if (_selected_button.enabled)
        {
            scr_menu_main_action_execute(
                _menu,
                _selected_button.action
            );
        }
    }


    return true;
}


/// @description Draws the animated main-menu background.

function scr_menu_main_background_draw(_menu)
{
    var _width =
        display_get_gui_width();

    var _height =
        display_get_gui_height();

    var _tick =
        global.vtd.tick;


    draw_clear(
        make_color_rgb(
            1,
            7,
            10
        )
    );


    // ========================================================================
    // SUBTLE MOVING DATA POINTS
    // ========================================================================

    draw_set_color(
        make_color_rgb(
            0,
            110,
            125
        )
    );

    draw_set_alpha(0.3);


    for (var i = 0; i < 42; ++i)
    {
        var _x =
            (
                (i * 173)
                + (_tick * (0.05 + ((i mod 4) * 0.02)))
            )
            mod _width;

        var _y =
            (
                (i * 97)
                + sin((_tick * 0.4) + i) * 12
            )
            mod _height;


        draw_circle(
            _x,
            _y,
            1 + (i mod 2),
            false
        );
    }


    // ========================================================================
    // PERSPECTIVE GRID
    // ========================================================================

    var _horizon =
        _height * 0.58;

    var _center_x =
        _width * 0.69;


    draw_set_alpha(0.12);


    for (var i = -12; i <= 12; ++i)
    {
        draw_line(
            _center_x,
            _horizon,
            _center_x + (i * 105),
            _height
        );
    }


    for (var i = 0; i < 9; ++i)
    {
        var _progress =
            i / 8;

        var _grid_y =
            _horizon
            + power(_progress, 1.8)
            * (_height - _horizon);


        draw_line(
            0,
            _grid_y,
            _width,
            _grid_y
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the animated CPU hologram.

function scr_menu_main_hologram_draw(_menu)
{
    var _width =
        display_get_gui_width();

    var _height =
        display_get_gui_height();

    var _x =
        _width * 0.72;

    var _y =
        _height * 0.48;

    var _tick =
        global.vtd.tick;

    var _cyan =
        make_color_rgb(
            0,
            220,
            240
        );

    var _pulse =
        0.55
        + sin(_tick * 3) * 0.12;


    // ========================================================================
    // SCANNING RINGS
    // ========================================================================

    draw_set_color(_cyan);


    for (var i = 0; i < 5; ++i)
    {
        var _radius =
            92
            + (i * 34)
            + sin((_tick * 1.2) + (i * 20)) * 3;

        draw_set_alpha(
            0.08
            + ((4 - i) * 0.025)
        );

        draw_circle(
            _x,
            _y,
            _radius,
            true
        );
    }


    // Rotating scanner lines.

    draw_set_alpha(0.22);


    for (var i = 0; i < 4; ++i)
    {
        var _angle =
            (_tick * 0.35)
            + (i * 90);

        draw_line(
            _x,
            _y,
            _x + lengthdir_x(235, _angle),
            _y + lengthdir_y(235, _angle)
        );
    }


    // ========================================================================
    // VECTOR CPU BASE
    // ========================================================================

    draw_set_alpha(_pulse);
    draw_set_color(_cyan);


    // Main tower.

    draw_rectangle(
        _x - 34,
        _y - 80,
        _x + 34,
        _y + 50,
        true
    );

    draw_rectangle(
        _x - 24,
        _y - 108,
        _x + 24,
        _y - 80,
        true
    );

    draw_line_width(
        _x,
        _y - 108,
        _x,
        _y - 150,
        2
    );

    draw_circle(
        _x,
        _y - 156,
        4 + sin(_tick * 4),
        false
    );


    // Central core.

    draw_rectangle(
        _x - 15,
        _y - 35,
        _x + 15,
        _y + 4,
        true
    );

    draw_circle(
        _x,
        _y - 16,
        7,
        true
    );


    // Fortress wings.

    draw_line_width(
        _x - 34,
        _y + 20,
        _x - 145,
        _y + 84,
        2
    );

    draw_line_width(
        _x + 34,
        _y + 20,
        _x + 145,
        _y + 84,
        2
    );

    draw_rectangle(
        _x - 165,
        _y + 68,
        _x - 112,
        _y + 116,
        true
    );

    draw_rectangle(
        _x + 112,
        _y + 68,
        _x + 165,
        _y + 116,
        true
    );

    draw_line(
        _x - 165,
        _y + 116,
        _x + 165,
        _y + 116
    );


    // Holographic vertical scan.

    var _scan_y =
        _y - 160
        + (
            (_tick * 1.3)
            mod 285
        );

    draw_set_alpha(0.4);

    draw_line_width(
        _x - 185,
        _scan_y,
        _x + 185,
        _scan_y,
        2
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}


/// @description Draws one main-menu button.

function scr_menu_main_button_draw(_button, _selected)
{
    var _bounds =
        _button.bounds;

    var _cyan =
        make_color_rgb(
            0,
            220,
            240
        );

    var _color =
        _button.enabled
        ? _cyan
        : make_color_rgb(45, 75, 80);


    draw_set_color(c_black);
    draw_set_alpha(0.72);

    draw_rectangle(
        _bounds.left,
        _bounds.top,
        _bounds.right,
        _bounds.bottom,
        false
    );


    if (_selected)
    {
        draw_set_color(_cyan);
        draw_set_alpha(0.08 + (_button.animation * 0.14));

        draw_rectangle(
            _bounds.left,
            _bounds.top,
            _bounds.right,
            _bounds.bottom,
            false
        );
    }


    draw_set_alpha(
        _button.enabled
        ? 0.75
        : 0.25
    );

    draw_set_color(_color);

    draw_line(
        _bounds.left,
        _bounds.bottom,
        _bounds.right,
        _bounds.bottom
    );


    if (_selected)
    {
        draw_set_alpha(1);

        draw_line_width(
            _bounds.left,
            _bounds.top,
            _bounds.left,
            _bounds.bottom,
            3
        );

        draw_triangle(
            _bounds.left + 14,
            (_bounds.top + _bounds.bottom) * 0.5,
            _bounds.left + 5,
            ((_bounds.top + _bounds.bottom) * 0.5) - 6,
            _bounds.left + 5,
            ((_bounds.top + _bounds.bottom) * 0.5) + 6,
            false
        );
    }


    draw_set_alpha(
        _button.enabled
        ? 1
        : 0.38
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_text(
        _bounds.left + 32,
        (_bounds.top + _bounds.bottom) * 0.5,
        _button.label
    );


    if (_button.status != "")
    {
        draw_set_halign(fa_right);

        draw_text(
            _bounds.right - 14,
            (_bounds.top + _bounds.bottom) * 0.5,
            _button.status
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}


/// @description Draws the complete main-menu interface.

function scr_menu_main_draw(_menu)
{
    if (!is_struct(_menu))
        return false;


    var _width =
        display_get_gui_width();

    var _height =
        display_get_gui_height();

    var _cyan =
        make_color_rgb(
            0,
            220,
            240
        );


    scr_menu_main_background_draw(_menu);
    scr_menu_main_hologram_draw(_menu);


    // ========================================================================
    // OUTER FRAME
    // ========================================================================

    draw_set_color(_cyan);
    draw_set_alpha(0.65);

    draw_rectangle(
        18,
        18,
        _width - 18,
        _height - 18,
        true
    );

    draw_line(
        46,
        64,
        _width - 46,
        64
    );


    // ========================================================================
    // TITLE
    // ========================================================================

    draw_set_alpha(_menu.intro);
    draw_set_color(_cyan);

    draw_text_transformed(
        70,
        92,
        "VECTOR TD",
        2.6,
        2.6,
        0
    );

    draw_text_transformed(
        74,
        154,
        "TOWER DEFENSE",
        1.1,
        1.1,
        0
    );


    draw_set_alpha(0.55);

    draw_line(
        72,
        188,
        382,
        188
    );


    // ========================================================================
    // BUTTONS
    // ========================================================================

    for (
        var i = 0;
        i < array_length(_menu.buttons);
        ++i
    )
    {
        scr_menu_main_button_draw(
            _menu.buttons[i],
            i == _menu.selected
        );
    }


    // ========================================================================
    // MESSAGE
    // ========================================================================

    if (
        _menu.message.timer > 0
        && _menu.message.text != ""
    )
    {
        draw_set_color(
            _menu.message.color
        );

        draw_set_alpha(
            min(
                1,
                _menu.message.timer / 20
            )
        );

        draw_text(
            74,
            _height - 88,
            _menu.message.text
        );
    }


    // ========================================================================
    // FOOTER
    // ========================================================================

    draw_set_alpha(0.7);
    draw_set_color(_cyan);

    draw_text(
        46,
        _height - 47,
        "WELCOME, COMMANDER."
    );


    draw_set_halign(fa_right);

    draw_text(
        _width - 46,
        _height - 47,
        "DEVELOPMENT BUILD"
    );


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);


    // ========================================================================
    // TRANSITION FADE
    // ========================================================================

    if (_menu.transition.active)
    {
        draw_set_alpha(
            _menu.transition.alpha
        );

        draw_set_color(c_black);

        draw_rectangle(
            0,
            0,
            _width,
            _height,
            false
        );

        draw_set_alpha(1);
        draw_set_color(c_white);
    }


    return true;
}