/// @description Creates the level debug-menu runtime.

function scr_debug_menu_create()
{
    return
    {
        open: false,

        width: 760,
        height: 620,

        margin: 22,
        header_height: 54,
        control_height: 42,

        columns: 2,
        button_height: 48,
        button_gap: 8,

        scroll_row: 0,

        spawn_count: 1,
        shielded: false,

        color: c_aqua,
        danger_color: c_red
    };
}


/// @description Returns the centered debug-menu rectangle.

function scr_debug_menu_rectangle_get(_hud)
{
    var _menu = _hud.hud.debug_menu;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _width =
        min(
            _menu.width,
            _gui_width - 64
        );

    var _height =
        min(
            _menu.height,
            _gui_height - 64
        );


    return
    {
        left: (_gui_width - _width) * 0.5,
        top: (_gui_height - _height) * 0.5,
        right: (_gui_width + _width) * 0.5,
        bottom: (_gui_height + _height) * 0.5,

        width: _width,
        height: _height
    };
}


/// @description Returns whether the GUI pointer is inside a rectangle.

function scr_debug_menu_pointer_inside(
    _left,
    _top,
    _right,
    _bottom
)
{
    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);


    return point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _left,
        _top,
        _right,
        _bottom
    );
}


/// @description Spawns the selected number of one enemy.

function scr_debug_menu_enemy_spawn(
    _hud,
    _enemy_key
)
{
    if (!instance_exists(_hud))
        return false;


    var _menu =
        _hud.hud.debug_menu;

    var _modifiers = [];


    if (_menu.shielded)
    {
        array_push(
            _modifiers,
            EnemyModifier.SHIELDED
        );
    }


    repeat (_menu.spawn_count)
    {
        scr_enemy_spawn_edge(
            _enemy_key,
            _modifiers
        );
    }


    return true;
}


/// @description Processes debug-menu input and enemy buttons.

function scr_debug_menu_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu =
        _hud.hud.debug_menu;


    // F1 is the only permanent debug-menu hotkey.

    if (keyboard_check_pressed(vk_f1))
    {
        _menu.open = !_menu.open;

        if (_menu.open)
        {
            _hud.hud.selection.target = noone;

            if (
                variable_struct_exists(
                    global.vtd_level.entities,
                    "build_controller"
                )
            )
            {
                var _build_controller =
                    global.vtd_level.entities.build_controller;

                if (instance_exists(_build_controller))
                {
                    scr_build_mode_cancel(
                        _build_controller
                    );
                }
            }
        }

        return true;
    }


    if (!_menu.open)
        return true;


    if (keyboard_check_pressed(vk_escape))
    {
        _menu.open = false;
        return true;
    }


    var _rectangle =
        scr_debug_menu_rectangle_get(_hud);

    var _margin =
        _menu.margin;

    var _content_left =
        _rectangle.left + _margin;

    var _content_right =
        _rectangle.right - _margin;

    var _control_top =
        _rectangle.top + _menu.header_height;

    var _control_bottom =
        _control_top + _menu.control_height;

    var _control_gap = 8;

    var _control_width =
        (
            _content_right
            - _content_left
            - (_control_gap * 3)
        )
        / 4;


    // ========================================================================
    // CLOSE BUTTON
    // ========================================================================

    var _close_size = 30;

    if (
        mouse_check_button_pressed(mb_left)
        && scr_debug_menu_pointer_inside(
            _rectangle.right - _margin - _close_size,
            _rectangle.top + 12,
            _rectangle.right - _margin,
            _rectangle.top + 12 + _close_size
        )
    )
    {
        _menu.open = false;
        return true;
    }


    // ========================================================================
    // CONTROL BUTTONS
    // ========================================================================

    if (mouse_check_button_pressed(mb_left))
    {
        var _button_left =
            _content_left;


        // Spawn count.

        if (
            scr_debug_menu_pointer_inside(
                _button_left,
                _control_top,
                _button_left + _control_width,
                _control_bottom
            )
        )
        {
            switch (_menu.spawn_count)
            {
                case 1:
                    _menu.spawn_count = 5;
                break;

                case 5:
                    _menu.spawn_count = 10;
                break;

                case 10:
                    _menu.spawn_count = 25;
                break;

                default:
                    _menu.spawn_count = 1;
                break;
            }

            return true;
        }


        // Shield modifier.

        _button_left +=
            _control_width + _control_gap;

        if (
            scr_debug_menu_pointer_inside(
                _button_left,
                _control_top,
                _button_left + _control_width,
                _control_bottom
            )
        )
        {
            _menu.shielded =
                !_menu.shielded;

            return true;
        }


        // CPU damage.

        _button_left +=
            _control_width + _control_gap;

        if (
            scr_debug_menu_pointer_inside(
                _button_left,
                _control_top,
                _button_left + _control_width,
                _control_bottom
            )
        )
        {
            var _cpu =
                global.vtd_level.entities.cpu;

            if (instance_exists(_cpu))
                scr_cpu_damage(_cpu, 100);

            return true;
        }


        // Restart room.

        _button_left +=
            _control_width + _control_gap;

        if (
            scr_debug_menu_pointer_inside(
                _button_left,
                _control_top,
                _button_left + _control_width,
                _control_bottom
            )
        )
        {
            room_restart();
            return true;
        }
    }


    // ========================================================================
    // ENEMY LIST
    // ========================================================================

    var _enemy_keys =
        variable_struct_get_names(
            global.vtd.data.enemies
        );

    var _list_top =
        _control_bottom + 28;

    var _list_bottom =
        _rectangle.bottom - 48;

    var _column_gap =
        _menu.button_gap;

    var _button_width =
        (
            _content_right
            - _content_left
            - _column_gap
        )
        / _menu.columns;

    var _row_height =
        _menu.button_height
        + _menu.button_gap;

    var _visible_rows =
        max(
            1,
            floor(
                (_list_bottom - _list_top)
                / _row_height
            )
        );

    var _total_rows =
        ceil(
            array_length(_enemy_keys)
            / _menu.columns
        );

    var _maximum_scroll =
        max(
            0,
            _total_rows - _visible_rows
        );


    if (mouse_wheel_down())
        _menu.scroll_row++;

    if (mouse_wheel_up())
        _menu.scroll_row--;


    _menu.scroll_row = clamp(
        _menu.scroll_row,
        0,
        _maximum_scroll
    );


    if (!mouse_check_button_pressed(mb_left))
        return true;


    for (
        var i = 0;
        i < array_length(_enemy_keys);
        ++i
    )
    {
        var _row =
            floor(i / _menu.columns);

        var _column =
            i mod _menu.columns;

        var _visible_row =
            _row - _menu.scroll_row;


        if (
            _visible_row < 0
            || _visible_row >= _visible_rows
        )
        {
            continue;
        }


        var _left =
            _content_left
            + (
                _column
                * (
                    _button_width
                    + _column_gap
                )
            );

        var _top =
            _list_top
            + (_visible_row * _row_height);

        var _right =
            _left + _button_width;

        var _bottom =
            _top + _menu.button_height;


        if (
            scr_debug_menu_pointer_inside(
                _left,
                _top,
                _right,
                _bottom
            )
        )
        {
            scr_debug_menu_enemy_spawn(
                _hud,
                _enemy_keys[i]
            );

            return true;
        }
    }


    return true;
}


/// @description Draws one reusable debug-menu button.

function scr_debug_menu_button_draw(
    _left,
    _top,
    _right,
    _bottom,
    _text,
    _color,
    _active = false
)
{
    var _hovered =
        scr_debug_menu_pointer_inside(
            _left,
            _top,
            _right,
            _bottom
        );


    draw_set_color(c_black);

    draw_set_alpha(
        _hovered
        ? 0.95
        : 0.82
    );

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_alpha(
        _active
        ? 0.16
        : 0.06
    );

    draw_set_color(_color);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_alpha(1);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        true
    );


    if (_hovered)
    {
        draw_line(
            _left + 8,
            _bottom - 4,
            _right - 8,
            _bottom - 4
        );
    }


    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(
        _active
        ? c_white
        : _color
    );

    draw_text(
        (_left + _right) * 0.5,
        (_top + _bottom) * 0.5,
        _text
    );


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    return true;
}


/// @description Draws the complete enemy debug interface.

function scr_debug_menu_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu =
        _hud.hud.debug_menu;

    if (!_menu.open)
        return true;


    var _rectangle =
        scr_debug_menu_rectangle_get(_hud);

    var _margin =
        _menu.margin;


    // Darken the game beneath the debug interface.

    draw_set_alpha(0.58);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        display_get_gui_width(),
        display_get_gui_height(),
        false
    );


    // Main vector panel.

    draw_set_alpha(0.96);
    draw_set_color(c_black);

    draw_rectangle(
        _rectangle.left,
        _rectangle.top,
        _rectangle.right,
        _rectangle.bottom,
        false
    );


    draw_set_alpha(1);
    draw_set_color(_menu.color);

    draw_rectangle(
        _rectangle.left,
        _rectangle.top,
        _rectangle.right,
        _rectangle.bottom,
        true
    );

    draw_line(
        _rectangle.left + _margin,
        _rectangle.top + _menu.header_height - 8,
        _rectangle.right - _margin,
        _rectangle.top + _menu.header_height - 8
    );


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_text(
        _rectangle.left + _margin,
        _rectangle.top + 15,
        "ENEMY DEBUG DATABASE"
    );


    // Close button.

    scr_debug_menu_button_draw(
        _rectangle.right - _margin - 30,
        _rectangle.top + 12,
        _rectangle.right - _margin,
        _rectangle.top + 42,
        "X",
        _menu.color,
        false
    );


    // ========================================================================
    // CONTROLS
    // ========================================================================

    var _content_left =
        _rectangle.left + _margin;

    var _content_right =
        _rectangle.right - _margin;

    var _control_top =
        _rectangle.top + _menu.header_height;

    var _control_bottom =
        _control_top + _menu.control_height;

    var _control_gap = 8;

    var _control_width =
        (
            _content_right
            - _content_left
            - (_control_gap * 3)
        )
        / 4;

    var _button_left =
        _content_left;


    scr_debug_menu_button_draw(
        _button_left,
        _control_top,
        _button_left + _control_width,
        _control_bottom,
        "SPAWN x" + string(_menu.spawn_count),
        _menu.color,
        false
    );


    _button_left +=
        _control_width + _control_gap;

    scr_debug_menu_button_draw(
        _button_left,
        _control_top,
        _button_left + _control_width,
        _control_bottom,
        "SHIELDED: "
        + (
            _menu.shielded
            ? "YES"
            : "NO"
        ),
        c_yellow,
        _menu.shielded
    );


    _button_left +=
        _control_width + _control_gap;

    scr_debug_menu_button_draw(
        _button_left,
        _control_top,
        _button_left + _control_width,
        _control_bottom,
        "DAMAGE CPU",
        c_orange,
        false
    );


    _button_left +=
        _control_width + _control_gap;

    scr_debug_menu_button_draw(
        _button_left,
        _control_top,
        _button_left + _control_width,
        _control_bottom,
        "RESTART ROOM",
        _menu.danger_color,
        false
    );


    // ========================================================================
    // ENEMY DATABASE
    // ========================================================================

    var _enemy_keys =
        variable_struct_get_names(
            global.vtd.data.enemies
        );

    var _list_top =
        _control_bottom + 28;

    var _list_bottom =
        _rectangle.bottom - 48;

    var _column_gap =
        _menu.button_gap;

    var _button_width =
        (
            _content_right
            - _content_left
            - _column_gap
        )
        / _menu.columns;

    var _row_height =
        _menu.button_height
        + _menu.button_gap;

    var _visible_rows =
        max(
            1,
            floor(
                (_list_bottom - _list_top)
                / _row_height
            )
        );


    draw_set_color(c_white);

    draw_text(
        _content_left,
        _control_bottom + 7,
        "CLICK AN ENEMY TO SPAWN"
    );


    for (
        var i = 0;
        i < array_length(_enemy_keys);
        ++i
    )
    {
        var _row =
            floor(i / _menu.columns);

        var _column =
            i mod _menu.columns;

        var _visible_row =
            _row - _menu.scroll_row;


        if (
            _visible_row < 0
            || _visible_row >= _visible_rows
        )
        {
            continue;
        }


        var _key =
            _enemy_keys[i];

        var _data =
            variable_struct_get(
                global.vtd.data.enemies,
                _key
            );

        var _left =
            _content_left
            + (
                _column
                * (
                    _button_width
                    + _column_gap
                )
            );

        var _top =
            _list_top
            + (_visible_row * _row_height);


        scr_debug_menu_button_draw(
            _left,
            _top,
            _left + _button_width,
            _top + _menu.button_height,
            _data.identity.name
            + "  [" + _key + "]",
            _data.visual.color,
            false
        );
    }


    draw_set_color(c_white);

    draw_text(
        _content_left,
        _rectangle.bottom - 28,
        "F1 / ESC: CLOSE     MOUSE WHEEL: SCROLL"
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}