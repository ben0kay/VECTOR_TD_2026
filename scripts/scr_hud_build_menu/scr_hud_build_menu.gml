/// @description Creates one reusable vector HUD button.

function scr_hud_button_create(
    _key,
    _label,
    _subtitle = ""
)
{
    return
    {
        key: _key,
        label: _label,
        subtitle: _subtitle,

        bounds:
        {
            x: 0,
            y: 0,
            width: 120,
            height: 40
        },

        enabled: true,
        selected: false,
        hovered: false,
        pressed: false,

        accent_color: c_aqua,
        background_color: c_black,

        data: undefined
    };
}


/// @description Updates one button's GUI-space bounds.

function scr_hud_button_bounds_set(
    _button,
    _x,
    _y,
    _width,
    _height
)
{
    if (!is_struct(_button))
        return false;

    _button.bounds.x = _x;
    _button.bounds.y = _y;
    _button.bounds.width = _width;
    _button.bounds.height = _height;

    return true;
}


/// @description Returns whether a GUI position overlaps a button.

function scr_hud_button_contains(
    _button,
    _gui_x,
    _gui_y
)
{
    if (!is_struct(_button))
        return false;

    var _bounds = _button.bounds;

    return (
        _gui_x >= _bounds.x
        && _gui_x <= _bounds.x + _bounds.width
        && _gui_y >= _bounds.y
        && _gui_y <= _bounds.y + _bounds.height
    );
}


/// @description Updates button hover and press state.

function scr_hud_button_update(_button)
{
    if (!is_struct(_button))
        return false;


    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);

    _button.hovered =
        _button.enabled
        && scr_hud_button_contains(
            _button,
            _mouse_x,
            _mouse_y
        );

    _button.pressed =
        _button.hovered
        && mouse_check_button_pressed(mb_left);


    return _button.pressed;
}


/// @description Draws one reusable vector HUD button.

function scr_hud_button_draw(_button)
{
    if (!is_struct(_button))
        return false;


    var _bounds = _button.bounds;

    var _left = _bounds.x;
    var _top = _bounds.y;
    var _right = _left + _bounds.width;
    var _bottom = _top + _bounds.height;

    var _color =
        _button.enabled
        ? _button.accent_color
        : c_dkgray;

    var _background_alpha = 0.72;

    if (_button.hovered)
        _background_alpha = 0.9;

    if (_button.selected)
        _background_alpha = 0.96;


    // ========================================================================
    // BACKGROUND
    // ========================================================================

    draw_set_alpha(_background_alpha);
    draw_set_color(_button.background_color);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    // ========================================================================
    // VECTOR BORDER
    // ========================================================================

    draw_set_alpha(
        _button.enabled
        ? 1
        : 0.5
    );

    draw_set_color(_color);

    var _corner = 7;

    draw_line(_left + _corner, _top, _right - _corner, _top);
    draw_line(_right - _corner, _top, _right, _top + _corner);
    draw_line(_right, _top + _corner, _right, _bottom - _corner);
    draw_line(_right, _bottom - _corner, _right - _corner, _bottom);

    draw_line(_right - _corner, _bottom, _left + _corner, _bottom);
    draw_line(_left + _corner, _bottom, _left, _bottom - _corner);
    draw_line(_left, _bottom - _corner, _left, _top + _corner);
    draw_line(_left, _top + _corner, _left + _corner, _top);


    if (_button.selected)
    {
        draw_line_width(
            _left + 10,
            _bottom - 4,
            _right - 10,
            _bottom - 4,
            2
        );
    }


    // ========================================================================
    // TEXT
    // ========================================================================

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(
        _button.enabled
        ? c_white
        : c_gray
    );

    var _text_y =
        _button.subtitle == ""
        ? (_top + _bottom) * 0.5
        : _top + (_bounds.height * 0.40);

    draw_text(
        (_left + _right) * 0.5,
        _text_y,
        _button.label
    );


    if (_button.subtitle != "")
    {
        draw_set_color(_color);

        draw_text(
            (_left + _right) * 0.5,
            _top + (_bounds.height * 0.72),
            _button.subtitle
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}

/// @description Returns a building's build-menu category.

function scr_hud_build_category_get(_building_data)
{
    if (!is_struct(_building_data))
        return BuildMenuCategory.AUXILIARY;


    switch (_building_data.identity.type)
    {
        case BuildingType.WALL:
        case BuildingType.TOWER:
            return BuildMenuCategory.DEFENSE;

        case BuildingType.MINER:
            return BuildMenuCategory.EXTRACTION;

        case BuildingType.STORAGE:
            return BuildMenuCategory.STORAGE;

        case BuildingType.POWER_GENERATOR:
        case BuildingType.POWER_NODE:
            return BuildMenuCategory.POWER;

        case BuildingType.REFINERY:
            return BuildMenuCategory.PRODUCTION;

        case BuildingType.SUPPORT:
            return BuildMenuCategory.SUPPORT;
    }


    return BuildMenuCategory.AUXILIARY;
}


/// @description Returns readable category text.

function scr_hud_build_category_name(_category)
{
    switch (_category)
    {
        case BuildMenuCategory.DEFENSE:
            return "DEFENSE";

        case BuildMenuCategory.EXTRACTION:
            return "EXTRACTION";

        case BuildMenuCategory.STORAGE:
            return "STORAGE";

        case BuildMenuCategory.POWER:
            return "POWER";

        case BuildMenuCategory.PRODUCTION:
            return "PRODUCTION";

        case BuildMenuCategory.SUPPORT:
            return "SUPPORT";

        case BuildMenuCategory.AUXILIARY:
            return "AUXILIARY";
    }


    return "UNKNOWN";
}


/// @description Returns a short role label for a building card.

function scr_hud_building_role_text(_data)
{
    if (!is_struct(_data))
        return "";


    switch (_data.identity.type)
    {
        case BuildingType.WALL:
            return "BARRIER";

        case BuildingType.MINER:
            return "EXTRACTOR";

        case BuildingType.STORAGE:
            return "STORAGE";

        case BuildingType.POWER_GENERATOR:
            return "GENERATOR";

        case BuildingType.POWER_NODE:
            return "NETWORK";

        case BuildingType.REFINERY:
            return "PRODUCTION";

        case BuildingType.SUPPORT:
            return "SUPPORT";

        case BuildingType.TOWER:
        {
            switch (_data.tower.target_layer)
            {
                case EnemyMovementLayer.GROUND:
                    return "GROUND";

                case EnemyMovementLayer.FLYING:
                    return "ANTI-AIR";

                case EnemyMovementLayer.UNDERGROUND:
                    return "UNDERGROUND";
            }

            return "DEFENSE";
        }
    }


    return "";
}


/// @description Creates the reusable bottom build-menu runtime.

function scr_hud_build_menu_create()
{
    var _categories =
    [
        BuildMenuCategory.DEFENSE,
        BuildMenuCategory.EXTRACTION,
        BuildMenuCategory.STORAGE,
        BuildMenuCategory.POWER,
        BuildMenuCategory.PRODUCTION,
        BuildMenuCategory.SUPPORT
    ];

    var _category_buttons = [];


    for (var i = 0; i < array_length(_categories); ++i)
    {
        var _category = _categories[i];

        var _button =
            scr_hud_button_create(
                _category,
                scr_hud_build_category_name(_category)
            );

        _button.data = _category;

        array_push(
            _category_buttons,
            _button
        );
    }


    var _scroll_positions =
        array_create(7, 0);


    return
    {
        open: false,
        progress: 0,
        animation_speed: 0.16,

        category: BuildMenuCategory.DEFENSE,

        category_buttons: _category_buttons,
        building_buttons: [],

        scroll_positions: _scroll_positions,
        scroll_index: 0,

        build_button:
            scr_hud_button_create(
                "build",
                "BUILD",
                "B"
            ),

        left_button:
            scr_hud_button_create(
                "left",
                "<"
            ),

        right_button:
            scr_hud_button_create(
                "right",
                ">"
            ),

        layout:
{
    card_width: 142,
    card_height: 136,
    card_gap: 8,

    strip_left: 0,
    strip_top: 0,
    strip_width: 0,
    strip_height: 0,

    visible_count: 1
}
    };
}


/// @description Rebuilds the card list for the selected category.

function scr_hud_build_menu_cards_rebuild(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;
    var _buttons = [];

    var _building_keys =
        variable_struct_get_names(
            global.vtd.data.buildings
        );


    for (var i = 0; i < array_length(_building_keys); ++i)
    {
        var _key = _building_keys[i];

        var _data =
            scr_building_data_get(_key);

        if (!scr_building_data_valid(_data))
            continue;

        if (
            scr_hud_build_category_get(_data)
            != _menu.category
        )
        {
            continue;
        }


        var _button =
            scr_hud_button_create(
                _key,
                _data.identity.name,
                scr_hud_building_role_text(_data)
            );

        _button.data = _key;
        _button.accent_color = _data.visual.color;

        array_push(
            _buttons,
            _button
        );
    }


    _menu.building_buttons = _buttons;

    _menu.scroll_index = clamp(
        _menu.scroll_positions[_menu.category],
        0,
        max(
            0,
            array_length(_buttons) - 1
        )
    );


    return true;
}


/// @description Opens or closes the bottom build tray.

function scr_hud_build_menu_toggle(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;

    _menu.open = !_menu.open;


    if (_menu.open)
    {
        var _controller =
            global.vtd_level.entities.build_controller;

        if (
            instance_exists(_controller)
            && global.BuildState == BuildState.PLACING
        )
        {
            scr_build_mode_cancel(_controller);
        }


        scr_hud_build_menu_cards_rebuild(_hud);
    }


    return true;
}


/// @description Closes the bottom build tray.

function scr_hud_build_menu_close(_hud)
{
    if (!instance_exists(_hud))
        return false;

    _hud.hud.build_menu.open = false;

    return true;
}


/// @description Returns whether the pointer belongs to the level HUD.

function scr_hud_pointer_blocks_world()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(global.vtd_level.entities, "hud"))
        return false;

    var _hud = global.vtd_level.entities.hud;

    if (!instance_exists(_hud))
        return false;

    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _tray_top =
        _gui_height - _hud.hud.bottom.height;

    var _inspector_left =
        _gui_width - _hud.hud.bottom.inspector_width;

    var _inspector_top =
        _gui_height - _hud.hud.bottom.inspector_height;

    var _inside_tray =
        _mouse_y >= _tray_top;

    var _inside_inspector =
        _mouse_x >= _inspector_left
        && _mouse_y >= _inspector_top;

    return _inside_tray || _inside_inspector;
}

/// @description Changes the selected build category.

function scr_hud_build_menu_category_set(
    _hud,
    _category
)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;

    _menu.scroll_positions[_menu.category] =
        _menu.scroll_index;

    _menu.category = _category;

    _menu.scroll_index =
        _menu.scroll_positions[_category];

    scr_hud_build_menu_cards_rebuild(_hud);

    return true;
}


/// @description Scrolls the active building-card strip.

function scr_hud_build_menu_scroll(_hud, _amount)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;

    var _maximum = max(
        0,
        array_length(_menu.building_buttons)
        - _menu.layout.visible_count
    );

    _menu.scroll_index = clamp(
        _menu.scroll_index + _amount,
        0,
        _maximum
    );

    _menu.scroll_positions[_menu.category] =
        _menu.scroll_index;


    return true;
}


/// @description Processes bottom build-menu input and layout.

function scr_hud_build_menu_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _bottom_top =
        _gui_height - _hud.hud.bottom.height;

    var _inspector_left =
        _gui_width - _hud.hud.bottom.inspector_width;

    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);


    // ========================================================================
    // BUILD BUTTON
    // ========================================================================

    scr_hud_button_bounds_set(
        _menu.build_button,
        16,
        _bottom_top + 12,
        90,
        40
    );


    if (
        keyboard_check_pressed(ord("B"))
        || scr_hud_button_update(_menu.build_button)
    )
    {
        scr_hud_build_menu_toggle(_hud);
    }


    _menu.progress = lerp(
        _menu.progress,
        _menu.open ? 1 : 0,
        _menu.animation_speed
    );


    if (!_menu.open && _menu.progress < 0.02)
        return true;


    // ========================================================================
    // CATEGORY BUTTONS
    // ========================================================================

    var _category_x = 118;
    var _category_width = 108;
    var _category_gap = 6;


    for (
        var i = 0;
        i < array_length(_menu.category_buttons);
        ++i
    )
    {
        var _button =
            _menu.category_buttons[i];

        scr_hud_button_bounds_set(
            _button,
            _category_x
                + (i * (_category_width + _category_gap)),
            _bottom_top + 12,
            _category_width,
            40
        );

        _button.selected =
            _button.data == _menu.category;


        if (scr_hud_button_update(_button))
        {
            scr_hud_build_menu_category_set(
                _hud,
                _button.data
            );
        }
    }


    // ========================================================================
    // CARD STRIP
    // ========================================================================

    var _arrow_width = 34;
    var _strip_left = 16 + _arrow_width + 8;
    var _strip_right = _inspector_left - _arrow_width - 24;

    var _strip_top = _bottom_top + 68;
    var _strip_width = max(1, _strip_right - _strip_left);

    var _card_step =
        _menu.layout.card_width
        + _menu.layout.card_gap;

    var _visible_count =
        max(
            1,
            floor(
                (_strip_width + _menu.layout.card_gap)
                / _card_step
            )
        );


    _menu.layout.strip_left = _strip_left;
    _menu.layout.strip_top = _strip_top;
    _menu.layout.strip_width = _strip_width;
    _menu.layout.strip_height = _menu.layout.card_height;
    _menu.layout.visible_count = _visible_count;


    scr_hud_button_bounds_set(
        _menu.left_button,
        16,
        _strip_top,
        _arrow_width,
        _menu.layout.card_height
    );

    scr_hud_button_bounds_set(
        _menu.right_button,
        _strip_right + 8,
        _strip_top,
        _arrow_width,
        _menu.layout.card_height
    );


    var _button_count =
        array_length(_menu.building_buttons);

    var _maximum_scroll =
        max(
            0,
            _button_count - _visible_count
        );


    _menu.left_button.enabled =
        _menu.scroll_index > 0;

    _menu.right_button.enabled =
        _menu.scroll_index < _maximum_scroll;


    if (scr_hud_button_update(_menu.left_button))
        scr_hud_build_menu_scroll(_hud, -1);

    if (scr_hud_button_update(_menu.right_button))
        scr_hud_build_menu_scroll(_hud, 1);


    var _inside_strip =
        (
            _mouse_x >= _strip_left
            && _mouse_x <= _strip_right
            && _mouse_y >= _strip_top
            && _mouse_y
                <= _strip_top + _menu.layout.card_height
        );


    if (_inside_strip)
    {
        if (mouse_wheel_up())
            scr_hud_build_menu_scroll(_hud, -1);

        if (mouse_wheel_down())
            scr_hud_build_menu_scroll(_hud, 1);
    }


    // ========================================================================
    // VISIBLE BUILDING CARDS
    // ========================================================================

    for (var i = 0; i < _button_count; ++i)
    {
        var _button =
            _menu.building_buttons[i];

        var _visible_slot =
            i - _menu.scroll_index;

        var _visible =
            _visible_slot >= 0
            && _visible_slot < _visible_count;


        if (!_visible)
        {
            _button.hovered = false;
            _button.pressed = false;
            continue;
        }


        scr_hud_button_bounds_set(
            _button,
            _strip_left + (_visible_slot * _card_step),
            _strip_top,
            _menu.layout.card_width,
            _menu.layout.card_height
        );


        if (scr_hud_button_update(_button))
        {
            var _controller =
                global.vtd_level.entities.build_controller;

            if (
                instance_exists(_controller)
                && scr_build_mode_begin(
                    _controller,
                    _button.data
                )
            )
            {
                scr_hud_build_menu_close(_hud);
                _hud.hud.selection.target = noone;
            }
        }
    }


    if (
        _menu.open
        && mouse_check_button_pressed(mb_right)
        && !scr_hud_pointer_blocks_world()
    )
    {
        scr_hud_build_menu_close(_hud);
    }


    return true;
}


/// @description Draws the horizontally scrollable build menu.

function scr_hud_build_menu_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _menu = _hud.hud.build_menu;

    // BUILD remains visible while the tray is closed.

    scr_hud_button_draw(_menu.build_button);

    if (_menu.progress < 0.05)
        return true;

    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    var _bottom_top =
        _gui_height - _hud.hud.bottom.height;

    var _inspector_left =
        _gui_width - _hud.hud.bottom.inspector_width;

    // Animated separator.

    draw_set_alpha(_menu.progress);
    draw_set_color(c_aqua);

    draw_line(
        118,
        _bottom_top + 58,
        lerp(118, _inspector_left - 18, _menu.progress),
        _bottom_top + 58
    );

    // Category buttons.

    for (var i = 0; i < array_length(_menu.category_buttons); ++i)
        scr_hud_button_draw(_menu.category_buttons[i]);

    // Scroll arrows.

    scr_hud_button_draw(_menu.left_button);
    scr_hud_button_draw(_menu.right_button);

    // Visible building cards.

    var _start = _menu.scroll_index;

    var _end = min(
        array_length(_menu.building_buttons),
        _start + _menu.layout.visible_count
    );

    for (var i = _start; i < _end; ++i)
        scr_hud_build_card_draw(_menu.building_buttons[i]);

    if (array_length(_menu.building_buttons) <= 0)
    {
        draw_set_color(c_gray);
        draw_set_halign(fa_center);

        draw_text(
            _menu.layout.strip_left
                + (_menu.layout.strip_width * 0.5),
            _menu.layout.strip_top + 54,
            "NO BUILDINGS REGISTERED"
        );

        draw_set_halign(fa_left);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Updates the building preview selected by card hover.

function scr_hud_build_menu_hover_update(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _menu = _hud.hud.build_menu;

    if (!variable_struct_exists(_menu, "hovered_key"))
        _menu.hovered_key = "";

    _menu.hovered_key = "";


    if (!_menu.open)
        return true;


    for (
        var i = 0;
        i < array_length(_menu.building_buttons);
        ++i
    )
    {
        var _button =
            _menu.building_buttons[i];

        if (_button.hovered)
        {
            _menu.hovered_key =
                _button.data;

            break;
        }
    }


    return true;
}

/// @description Returns one optional building-description field.

function scr_hud_building_description_get(
    _building_data,
    _field,
    _fallback
)
{
    if (!is_struct(_building_data))
        return _fallback;

    if (!is_struct(_building_data.identity))
        return _fallback;

    if (
        !variable_struct_exists(
            _building_data.identity,
            _field
        )
    )
    {
        return _fallback;
    }


    return variable_struct_get(
        _building_data.identity,
        _field
    );
}

/// @description Draws a vector preview for one building definition.

function scr_hud_building_preview_draw(
    _building_data,
    _center_x,
    _center_y,
    _size
)
{
    if (!is_struct(_building_data))
        return false;


    var _color =
        _building_data.visual.color;

    var _half_size =
        _size * 0.5;


    // ========================================================================
    // PREVIEW FRAME
    // ========================================================================

    draw_set_color(c_dkgray);

    draw_rectangle(
        _center_x - _half_size,
        _center_y - _half_size,
        _center_x + _half_size,
        _center_y + _half_size,
        false
    );

    draw_set_color(_color);

    draw_rectangle(
        _center_x - _half_size + 5,
        _center_y - _half_size + 5,
        _center_x + _half_size - 5,
        _center_y + _half_size - 5,
        true
    );


    // ========================================================================
    // CATEGORY-SPECIFIC VECTOR
    // ========================================================================

    switch (_building_data.identity.type)
    {
        case BuildingType.TOWER:
        {
            var _preview =
            {
                id: 0,
                x: _center_x,
                y: _center_y,

                visual:
                {
                    draw_angle: 315,
                    turret_color:
                        _building_data.visual.turret_color
                }
            };


            if (
                variable_struct_exists(
                    _building_data.tower,
                    "draw_function"
                )
            )
            {
                _building_data.tower
                    .draw_function(_preview);
            }
        }
        break;


        case BuildingType.WALL:
        {
            draw_set_color(_color);

            draw_rectangle(
                _center_x - 24,
                _center_y - 24,
                _center_x + 24,
                _center_y + 24,
                false
            );

            draw_line(
                _center_x - 24,
                _center_y,
                _center_x + 24,
                _center_y
            );

            draw_line(
                _center_x,
                _center_y - 24,
                _center_x,
                _center_y + 24
            );
        }
        break;


        case BuildingType.MINER:
        {
            draw_set_color(_color);

            draw_circle(
                _center_x,
                _center_y,
                22,
                false
            );

            draw_line_width(
                _center_x - 20,
                _center_y - 20,
                _center_x + 20,
                _center_y + 20,
                3
            );

            draw_line_width(
                _center_x + 20,
                _center_y - 20,
                _center_x - 20,
                _center_y + 20,
                3
            );

            draw_circle(
                _center_x,
                _center_y,
                6,
                true
            );
        }
        break;


        case BuildingType.STORAGE:
        {
            draw_set_color(_color);

            draw_rectangle(
                _center_x - 26,
                _center_y - 22,
                _center_x + 26,
                _center_y + 22,
                false
            );

            draw_rectangle(
                _center_x - 19,
                _center_y - 15,
                _center_x + 19,
                _center_y + 15,
                true
            );

            draw_line(
                _center_x - 26,
                _center_y - 7,
                _center_x + 26,
                _center_y - 7
            );

            draw_line(
                _center_x - 26,
                _center_y + 7,
                _center_x + 26,
                _center_y + 7
            );
        }
        break;
    }


    draw_set_color(c_white);

    return true;
}

/// @description Draws the hovered building inside the tall build inspector.

function scr_hud_build_preview_inspector_draw(
    _hud,
    _left,
    _top,
    _right,
    _bottom
)
{
    if (!instance_exists(_hud))
        return false;

    var _menu = _hud.hud.build_menu;
    var _building_key = _menu.hovered_key;

    draw_set_color(c_aqua);
    draw_text(_left + 16, _top + 12, "STRUCTURE DATABASE");

    draw_set_color(c_dkgray);

    draw_line(
        _left + 16,
        _top + 36,
        _right - 16,
        _top + 36
    );

    if (_building_key == "")
    {
        draw_set_color(c_gray);

        draw_text(
            _left + 16,
            _top + 54,
            "Hover over a building card for information."
        );

        draw_set_color(c_white);
        return true;
    }

    var _data = scr_building_data_get(_building_key);

    if (!scr_building_data_valid(_data))
        return false;

    // ========================================================================
    // BUILDING NAME
    // ========================================================================

    draw_set_color(_data.visual.color);

    draw_text(
        _left + 16,
        _top + 48,
        string_upper(_data.identity.name)
    );

    draw_set_color(c_gray);

    draw_text(
        _left + 16,
        _top + 68,
        scr_hud_building_role_text(_data)
    );

    // ========================================================================
    // PREVIEW
    // ========================================================================

    var _preview_left = _left + 16;
    var _preview_top = _top + 94;
    var _preview_size = 112;

    scr_hud_building_preview_draw(
        _data,
        _preview_left + (_preview_size * 0.5),
        _preview_top + (_preview_size * 0.5),
        _preview_size
    );

    // ========================================================================
    // DESCRIPTION
    // ========================================================================

    var _description_left =
        _preview_left + _preview_size + 18;

    var _description_width =
        max(100, _right - _description_left - 16);

    draw_set_color(c_aqua);
    draw_text(_description_left, _preview_top, "DESCRIPTION");

    draw_set_color(c_white);

    draw_text(
        _description_left,
        _preview_top + 20,
        scr_hud_building_description_get(
            _data,
            "description_short",
            scr_hud_building_role_text(_data)
        )
    );

    draw_set_color(c_gray);

    draw_text_ext(
        _description_left,
        _preview_top + 42,
        scr_hud_building_description_get(
            _data,
            "description_long",
            "No detailed description has been supplied."
        ),
        16,
        _description_width
    );

    // ========================================================================
    // STATISTICS
    // ========================================================================

    var _section_y = _top + 220;

    draw_set_color(c_aqua);
    draw_text(_left + 16, _section_y, "STATS");

    draw_set_color(c_white);

    draw_text(
        _left + 16,
        _section_y + 20,
        "HEALTH  " + string(_data.vitals.hp_maximum)
    );

    var _stat_x = _left + 132;

    switch (_data.identity.type)
    {
        case BuildingType.TOWER:
        {
            draw_text(
                _stat_x,
                _section_y + 20,
                "RANGE  " + string(_data.tower.range)
            );

            draw_text(
                _stat_x + 116,
                _section_y + 20,
                "DAMAGE  " + string(_data.tower.weapon.damage)
            );

            draw_text(
                _stat_x + 244,
                _section_y + 20,
                "RATE  "
                + string(_data.tower.weapon.cooldown_seconds)
                + "s"
            );
        }
        break;

        case BuildingType.MINER:
        {
            draw_text(
                _stat_x,
                _section_y + 20,
                "RATE  "
                + string(_data.miner.extraction_rate_per_second)
                + "/s"
            );

            draw_text(
                _stat_x + 150,
                _section_y + 20,
                "HOPPER  " + string(_data.miner.hopper_capacity)
            );
        }
        break;

        case BuildingType.STORAGE:
        {
            draw_text(
                _stat_x,
                _section_y + 20,
                "CAPACITY  " + string(_data.storage.capacity)
            );
        }
        break;
    }

    // ========================================================================
    // COST
    // ========================================================================

    var _cost_y = _bottom - 34;

    draw_set_color(c_aqua);
    draw_text(_left + 16, _cost_y, "COST");

    scr_hud_building_cost_draw(
        _data,
        _left + 72,
        _cost_y,
        _right - (_left + 88),
        false
    );

    draw_set_color(c_white);
    return true;
}

/// @description Returns the configured resource cost for one building.

function scr_hud_building_cost_get(_data)
{
    if (!is_struct(_data))
        return [];

    if (!variable_struct_exists(_data, "economy"))
        return [];

    if (!is_struct(_data.economy))
        return [];

    if (!variable_struct_exists(_data.economy, "cost"))
        return [];

    if (!is_array(_data.economy.cost))
        return [];

    return _data.economy.cost;
}

/// @description Draws a reusable horizontal multi-resource cost list.

function scr_hud_building_cost_draw(
    _data,
    _x,
    _y,
    _maximum_width,
    _compact = false
)
{
    var _cost = scr_hud_building_cost_get(_data);

    if (array_length(_cost) <= 0)
    {
        draw_set_color(c_lime);
        draw_text(_x, _y, "FREE");
        draw_set_color(c_white);
        return true;
    }

    var _draw_x = _x;
    var _right = _x + _maximum_width;

    for (var i = 0; i < array_length(_cost); ++i)
    {
        var _entry = _cost[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "resource_key"))
            continue;

        if (!variable_struct_exists(_entry, "amount"))
            continue;

        var _resource_data =
            scr_resource_data_get(_entry.resource_key);

        var _resource_name = "?";
        var _resource_color = c_white;

        if (scr_resource_data_valid(_resource_data))
        {
            _resource_name = _resource_data.identity.name;
            _resource_color = _resource_data.visual.color;
        }

        var _text =
            _compact
            ? string(_entry.amount)
            : _resource_name + "  " + string(_entry.amount);

        var _entry_width =
            14 + string_width(_text) + 18;

        if (_draw_x + _entry_width > _right)
            break;

        // Small vector resource diamond.

        draw_set_color(_resource_color);

        draw_line(
            _draw_x,
            _y + 6,
            _draw_x + 5,
            _y + 1
        );

        draw_line(
            _draw_x + 5,
            _y + 1,
            _draw_x + 10,
            _y + 6
        );

        draw_line(
            _draw_x + 10,
            _y + 6,
            _draw_x + 5,
            _y + 11
        );

        draw_line(
            _draw_x + 5,
            _y + 11,
            _draw_x,
            _y + 6
        );

        draw_text(_draw_x + 14, _y, _text);

        _draw_x += _entry_width;
    }

    draw_set_color(c_white);
    return true;
}

/// @description Draws one building card inside the horizontal build tray.

function scr_hud_build_card_draw(_button)
{
    if (!is_struct(_button))
        return false;

    var _data = scr_building_data_get(_button.data);

    if (!scr_building_data_valid(_data))
        return false;

    var _bounds = _button.bounds;

    var _left = _bounds.x;
    var _top = _bounds.y;
    var _right = _left + _bounds.width;
    var _bottom = _top + _bounds.height;

    var _color =
        _button.enabled
        ? _button.accent_color
        : c_dkgray;

    var _background_alpha =
        _button.hovered ? 0.94 : 0.78;

    // Card background.

    draw_set_alpha(_background_alpha);
    draw_set_color(c_black);
    draw_rectangle(_left, _top, _right, _bottom, false);

    // Angled vector border.

    draw_set_alpha(_button.enabled ? 1 : 0.45);
    draw_set_color(_color);

    var _corner = 7;

    draw_line(_left + _corner, _top, _right - _corner, _top);
    draw_line(_right - _corner, _top, _right, _top + _corner);
    draw_line(_right, _top + _corner, _right, _bottom - _corner);
    draw_line(_right, _bottom - _corner, _right - _corner, _bottom);

    draw_line(_right - _corner, _bottom, _left + _corner, _bottom);
    draw_line(_left + _corner, _bottom, _left, _bottom - _corner);
    draw_line(_left, _bottom - _corner, _left, _top + _corner);
    draw_line(_left, _top + _corner, _left + _corner, _top);

    // Name at the top.

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    draw_text(
        (_left + _right) * 0.5,
        _top + 8,
        string_upper(_data.identity.name)
    );

    // Compact vector preview.

    scr_hud_building_preview_draw(
        _data,
        (_left + _right) * 0.5,
        _top + 60,
        58
    );

    // Building role.

    draw_set_color(_color);

    draw_text(
        (_left + _right) * 0.5,
        _top + 93,
        scr_hud_building_role_text(_data)
    );

    // Cost line.

    draw_set_halign(fa_left);

    scr_hud_building_cost_draw(
        _data,
        _left + 10,
        _bottom - 21,
        _bounds.width - 20,
        true
    );

    if (_button.hovered)
    {
        draw_set_color(c_white);

        draw_line(
            _left + 12,
            _bottom - 3,
            _right - 12,
            _bottom - 3
        );
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}