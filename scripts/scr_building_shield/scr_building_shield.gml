/// @description Returns whether one building has an active field shield.

function scr_building_shield_active(_building)
{
    if (!instance_exists(_building))
        return false;

    if (!variable_struct_exists(_building.vitals, "shield"))
        return false;

    if (!is_struct(_building.vitals.shield))
        return false;


    var _shield =
        _building.vitals.shield;


    return (
        _shield.enabled
        && _shield.maximum > 0
        && instance_exists(_shield.source)
        && _shield.field_remaining_seconds > 0
    );
}


/// @description Updates passive shield timers on one building.

function scr_building_shield_update(_building)
{
    if (!instance_exists(_building))
        return false;

    if (!variable_struct_exists(_building.vitals, "shield"))
        return true;


    var _shield =
        _building.vitals.shield;

    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _shield.hit_flash =
        max(
            0,
            _shield.hit_flash
            - (_delta * 4)
        );


    _shield.regeneration_delay_remaining =
        max(
            0,
            _shield.regeneration_delay_remaining
            - _delta
        );


    if (_shield.enabled)
    {
        _shield.field_remaining_seconds =
            max(
                0,
                _shield.field_remaining_seconds
                - _delta
            );


        if (
            _shield.field_remaining_seconds <= 0
            || !instance_exists(_shield.source)
        )
        {
            // The generator stopped refreshing this field.

            _shield.enabled = false;
            _shield.current = 0;
            _shield.source = noone;
            _shield.field_remaining_seconds = 0;
        }
    }


    return true;
}


/// @description Connects one building to an operational Shield Generator.

function scr_building_shield_connect(
    _building,
    _generator,
    _linger_seconds,
    _regeneration_delay_seconds,
    _color
)
{
    if (!instance_exists(_building))
        return false;

    if (!instance_exists(_generator))
        return false;


    var _shield =
        _building.vitals.shield;


    if (_shield.maximum <= 0)
        return false;


    _shield.enabled = true;
    _shield.source = _generator;

    _shield.field_remaining_seconds =
        max(
            _shield.field_remaining_seconds,
            _linger_seconds
        );

    _shield.regeneration_delay_seconds =
        max(
            0,
            _regeneration_delay_seconds
        );

    _shield.color =
        _color;


    return true;
}


/// @description Draws one building's active field and shield bar.

function scr_building_shield_draw(_building)
{
    if (!scr_building_shield_active(_building))
        return false;


    var _shield =
        _building.vitals.shield;

    var _cell_size =
        global.vtd_level.map.cell_size;

    var _half_width =
        (
            _building.footprint.width_cells
            * _cell_size
        )
        * 0.5;

    var _half_height =
        (
            _building.footprint.height_cells
            * _cell_size
        )
        * 0.5;

    var _left =
        _building.x - _half_width;

    var _right =
        _building.x + _half_width;

    var _top =
        _building.y - _half_height;

    var _bottom =
        _building.y + _half_height;

    var _ratio =
        clamp(
            _shield.current
            / max(1, _shield.maximum),
            0,
            1
        );

    var _pulse =
        0.12
        + (_shield.hit_flash * 0.35);


    // Subtle field outline around the structure.

    draw_set_color(_shield.color);
    draw_set_alpha(_pulse);

    draw_rectangle(
        _left - 3,
        _top - 3,
        _right + 3,
        _bottom + 3,
        true
    );


    // Shield bar above the existing health bar.

    draw_set_alpha(0.65);
    draw_set_color(c_dkgray);

    draw_rectangle(
        _left,
        _top - 15,
        _right,
        _top - 11,
        false
    );


    draw_set_alpha(1);
    draw_set_color(_shield.color);

    draw_rectangle(
        _left,
        _top - 15,
        _left
        + ((_right - _left) * _ratio),
        _top - 11,
        false
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}