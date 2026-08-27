/// @description Commander-profile boot screen and slot selection.


/// ============================================================================
/// RUNTIME
/// ============================================================================

function scr_boot_create()
{
    var _slots = [];

    for (
        var i = 1;
        i <= scr_profile_slot_count_get();
        ++i
    )
    {
        array_push(
            _slots,
            scr_profile_slot_summary_get(i)
        );
    }

    return
    {
        selected: 0,
        hovered: -1,

        slots: _slots,

        input:
        {
            active: false,
            slot: 0,
            text: "",
            maximum_length: 18
        },

        message:
        {
            text: "",
            color: c_aqua,
            remaining: 0
        },

        layout:
        {
            width: 1100,
            height: 700,

            card_width: 1012,
            card_height: 142,
            card_gap: 18,

            left: 0,
            top: 0,

            cards: []
        }
    };
}


/// @description Rebuilds boot-screen card positions for the GUI resolution.
function scr_boot_layout_update(_boot)
{
    if (!is_struct(_boot))
        return false;

    var _layout =
        _boot.layout;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    _layout.left =
        floor(
            (_gui_width - _layout.width)
            * 0.5
        );

    _layout.top =
        floor(
            (_gui_height - _layout.height)
            * 0.5
        );

    _layout.cards = [];

    var _cards_left =
        _layout.left
        + 44;

    var _cards_top =
        _layout.top
        + 186;

    for (
        var i = 0;
        i < array_length(_boot.slots);
        ++i
    )
    {
        array_push(
            _layout.cards,
            {
                left:
                    _cards_left,

                top:
                    _cards_top
                    + (
                        i
                        * (
                            _layout.card_height
                            + _layout.card_gap
                        )
                    ),

                right:
                    _cards_left
                    + _layout.card_width,

                bottom:
                    _cards_top
                    + (
                        i
                        * (
                            _layout.card_height
                            + _layout.card_gap
                        )
                    )
                    + _layout.card_height
            }
        );
    }

    return true;
}


/// @description Returns whether a GUI point is inside one profile card.
function scr_boot_card_contains(
    _card,
    _gui_x,
    _gui_y
)
{
    return
        _gui_x >= _card.left
        && _gui_x <= _card.right
        && _gui_y >= _card.top
        && _gui_y <= _card.bottom;
}


/// @description Shows one short boot-screen status message.
function scr_boot_message_set(
    _boot,
    _text,
    _color = c_aqua
)
{
    _boot.message.text =
        _text;

    _boot.message.color =
        _color;

    _boot.message.remaining =
        180;

    return true;
}


/// ============================================================================
/// SLOT ACTIONS
/// ============================================================================

/// @description Refreshes one slot summary after creating/loading data.
function scr_boot_slots_refresh(_boot)
{
    if (!is_struct(_boot))
        return false;

    var _slots = [];

    for (
        var i = 1;
        i <= scr_profile_slot_count_get();
        ++i
    )
    {
        array_push(
            _slots,
            scr_profile_slot_summary_get(i)
        );
    }

    _boot.slots = _slots;

    return true;
}


/// @description Leaves boot after a valid profile becomes active.
function scr_boot_main_menu_enter(_boot)
{
    if (!is_struct(global.vtd.profile))
        return false;

    global.GameState =
        GameState.MENU;

    room_goto(r_main_menu);

    return true;
}


/// @description Begins commander-name entry for one empty slot.
function scr_boot_name_input_begin(
    _boot,
    _slot
)
{
    _boot.input.active = true;
    _boot.input.slot = _slot;
    _boot.input.text = "";

    keyboard_string = "";

    return true;
}


/// @description Activates a selected profile slot.
function scr_boot_slot_activate(
    _boot,
    _index
)
{
    if (
        _index < 0
        || _index >= array_length(_boot.slots)
    )
    {
        return false;
    }

    var _slot =
        _boot.slots[_index];

    if (
        variable_struct_exists(
            _slot,
            "corrupted"
        )
        && _slot.corrupted
    )
    {
        return scr_boot_message_set(
            _boot,
            "PROFILE DATA IS INVALID.",
            c_red
        );
    }

    if (!_slot.occupied)
    {
        return scr_boot_name_input_begin(
            _boot,
            _slot.slot
        );
    }

    if (
        !scr_profile_load(
            _slot.slot
        )
    )
    {
        return scr_boot_message_set(
            _boot,
            "PROFILE LOAD FAILED.",
            c_red
        );
    }

    return scr_boot_main_menu_enter(
        _boot
    );
}


/// @description Confirms creation of a newly named profile.
function scr_boot_name_input_confirm(_boot)
{
    var _name =
        string_trim(
            _boot.input.text
        );

    if (string_length(_name) <= 0)
    {
        return scr_boot_message_set(
            _boot,
            "COMMANDER NAME REQUIRED.",
            c_yellow
        );
    }

    if (
        !scr_profile_new(
            _boot.input.slot,
            _name
        )
    )
    {
        return scr_boot_message_set(
            _boot,
            "PROFILE CREATION FAILED.",
            c_red
        );
    }

    _boot.input.active = false;

    scr_boot_slots_refresh(_boot);

    return scr_boot_main_menu_enter(
        _boot
    );
}


/// ============================================================================
/// INPUT
/// ============================================================================

/// @description Updates the commander-name input modal.
function scr_boot_name_input_update(_boot)
{
    var _input =
        _boot.input;

    var _text =
        keyboard_string;

    if (
        string_length(_text)
        > _input.maximum_length
    )
    {
        _text =
            string_copy(
                _text,
                1,
                _input.maximum_length
            );

        keyboard_string =
            _text;
    }

    _input.text =
        _text;

    if (keyboard_check_pressed(vk_escape))
    {
        _input.active = false;
        _input.text = "";
        keyboard_string = "";

        return true;
    }

    if (keyboard_check_pressed(vk_enter))
    {
        return scr_boot_name_input_confirm(
            _boot
        );
    }

    return true;
}


/// @description Updates profile-slot selection and input.
function scr_boot_update(_boot_object)
{
    if (!instance_exists(_boot_object))
        return false;

    var _boot =
        _boot_object.boot;

    scr_boot_layout_update(_boot);


    if (_boot.message.remaining > 0)
    {
        _boot.message.remaining =
            max(
                0,
                _boot.message.remaining - 1
            );
    }


    if (_boot.input.active)
    {
        return scr_boot_name_input_update(
            _boot
        );
    }


    var _gui_x =
        device_mouse_x_to_gui(0);

    var _gui_y =
        device_mouse_y_to_gui(0);

    _boot.hovered = -1;

    for (
        var i = 0;
        i < array_length(_boot.layout.cards);
        ++i
    )
    {
        if (
            scr_boot_card_contains(
                _boot.layout.cards[i],
                _gui_x,
                _gui_y
            )
        )
        {
            _boot.hovered = i;
            _boot.selected = i;
            break;
        }
    }


    if (keyboard_check_pressed(vk_up))
    {
        _boot.selected =
            max(
                0,
                _boot.selected - 1
            );
    }

    if (keyboard_check_pressed(vk_down))
    {
        _boot.selected =
            min(
                array_length(_boot.slots) - 1,
                _boot.selected + 1
            );
    }


    if (
        mouse_check_button_pressed(mb_left)
        && _boot.hovered >= 0
    )
    {
        return scr_boot_slot_activate(
            _boot,
            _boot.hovered
        );
    }

    if (keyboard_check_pressed(vk_enter))
    {
        return scr_boot_slot_activate(
            _boot,
            _boot.selected
        );
    }

    return true;
}


/// ============================================================================
/// DRAWING
/// ============================================================================

/// @description Draws one clipped vector-tech frame.
function scr_boot_frame_draw(
    _left,
    _top,
    _right,
    _bottom,
    _color,
    _alpha = 1
)
{
    var _cut = 14;

    draw_set_alpha(_alpha);
    draw_set_color(_color);

    draw_line(
        _left + _cut,
        _top,
        _right - _cut,
        _top
    );

    draw_line(
        _right - _cut,
        _top,
        _right,
        _top + _cut
    );

    draw_line(
        _right,
        _top + _cut,
        _right,
        _bottom - _cut
    );

    draw_line(
        _right,
        _bottom - _cut,
        _right - _cut,
        _bottom
    );

    draw_line(
        _right - _cut,
        _bottom,
        _left + _cut,
        _bottom
    );

    draw_line(
        _left + _cut,
        _bottom,
        _left,
        _bottom - _cut
    );

    draw_line(
        _left,
        _bottom - _cut,
        _left,
        _top + _cut
    );

    draw_line(
        _left,
        _top + _cut,
        _left + _cut,
        _top
    );

    // Small technical accents.
    draw_line(
        _left + 24,
        _top + 8,
        _left + 94,
        _top + 8
    );

    draw_line(
        _right - 94,
        _bottom - 8,
        _right - 24,
        _bottom - 8
    );

    return true;
}


/// @description Draws one profile-slot card.
function scr_boot_slot_draw(
    _slot,
    _card,
    _selected,
    _hovered
)
{
    var _color =
        _selected || _hovered
        ? c_aqua
        : make_color_rgb(
            55,
            145,
            160
        );

    draw_set_alpha(
        _selected || _hovered
        ? 0.18
        : 0.08
    );

    draw_set_color(c_black);

    draw_rectangle(
        _card.left,
        _card.top,
        _card.right,
        _card.bottom,
        false
    );

    scr_boot_frame_draw(
        _card.left,
        _card.top,
        _card.right,
        _card.bottom,
        _color,
        1
    );


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(_color);

    draw_text(
        _card.left + 34,
        _card.top + 22,
        "COMMANDER SLOT "
        + string(_slot.slot)
    );


    if (_slot.occupied)
    {
        draw_set_color(c_white);

        draw_text(
            _card.left + 34,
            _card.top + 54,
            _slot.commander_name
        );

        draw_set_color(c_ltgray);

        draw_text(
            _card.left + 34,
            _card.top + 88,
            "CAMPAIGN PROFILE // READY"
        );

        draw_set_halign(fa_right);

        draw_set_color(
            _selected || _hovered
            ? c_aqua
            : c_gray
        );

        draw_text(
            _card.right - 34,
            _card.top + 58,
            _selected || _hovered
            ? "ENTER PROFILE"
            : "SELECT"
        );
    }
    else
    {
        draw_set_color(c_gray);

        draw_text(
            _card.left + 34,
            _card.top + 58,
            "UNASSIGNED COMMANDER RECORD"
        );

        draw_set_halign(fa_right);

        draw_set_color(
            _selected || _hovered
            ? c_aqua
            : c_gray
        );

        draw_text(
            _card.right - 34,
            _card.top + 58,
            _selected || _hovered
            ? "CREATE PROFILE"
            : "EMPTY"
        );
    }

    return true;
}


/// @description Draws the commander-name input modal.
function scr_boot_name_input_draw(_boot)
{
    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _width = 680;
    var _height = 280;

    var _left =
        floor(
            (_gui_width - _width)
            * 0.5
        );

    var _top =
        floor(
            (_gui_height - _height)
            * 0.5
        );

    var _right =
        _left + _width;

    var _bottom =
        _top + _height;


    draw_set_alpha(0.70);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );

    draw_set_alpha(0.96);
    draw_set_color(c_black);

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );

    scr_boot_frame_draw(
        _left,
        _top,
        _right,
        _bottom,
        c_aqua,
        1
    );


    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_aqua);

    draw_text(
        (_left + _right) * 0.5,
        _top + 34,
        "INITIALIZE COMMANDER PROFILE"
    );

    draw_set_color(c_ltgray);

    draw_text(
        (_left + _right) * 0.5,
        _top + 76,
        "ENTER COMMANDER NAME"
    );


    var _cursor =
        current_time mod 900 < 450
        ? "|"
        : "";

    draw_set_color(c_white);

    draw_text(
        (_left + _right) * 0.5,
        _top + 126,
        _boot.input.text
        + _cursor
    );

    draw_set_color(c_gray);

    draw_text(
        (_left + _right) * 0.5,
        _top + 208,
        "ENTER // CONFIRM     ESC // CANCEL"
    );

    return true;
}


/// @description Draws the complete profile boot interface.
function scr_boot_draw(_boot_object)
{
    if (!instance_exists(_boot_object))
        return false;

    var _boot =
        _boot_object.boot;

    scr_boot_layout_update(_boot);


    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _layout =
        _boot.layout;

    var _left =
        _layout.left;

    var _top =
        _layout.top;

    var _right =
        _left + _layout.width;

    var _bottom =
        _top + _layout.height;


    draw_set_alpha(1);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );

    scr_boot_frame_draw(
        _left,
        _top,
        _right,
        _bottom,
        c_aqua,
        1
    );


    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_aqua);

    draw_text(
        (_left + _right) * 0.5,
        _top + 38,
        "VECTOR TD // COMMANDER TERMINAL"
    );

    draw_set_color(c_ltgray);

    draw_text(
        (_left + _right) * 0.5,
        _top + 82,
        "SELECT OR INITIALIZE A COMMANDER PROFILE"
    );

    draw_set_color(
        make_color_rgb(
            45,
            150,
            165
        )
    );

    draw_line_width(
        _left + 44,
        _top + 142,
        _right - 44,
        _top + 142,
        2
    );


    for (
        var i = 0;
        i < array_length(_boot.slots);
        ++i
    )
    {
        scr_boot_slot_draw(
            _boot.slots[i],
            _layout.cards[i],
            i == _boot.selected,
            i == _boot.hovered
        );
    }


    if (_boot.message.remaining > 0)
    {
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);

        draw_set_color(_boot.message.color);

        draw_text(
            (_left + _right) * 0.5,
            _bottom - 30,
            _boot.message.text
        );
    }


    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_set_color(c_gray);

    draw_text(
        (_left + _right) * 0.5,
        _bottom - 62,
        "UP / DOWN + ENTER  //  SELECT COMMANDER"
    );


    if (_boot.input.active)
    {
        scr_boot_name_input_draw(_boot);
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}