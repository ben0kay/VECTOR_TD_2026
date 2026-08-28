/// @description Creates the movable level minimap dock.
function scr_hud_minimap_create()
{
    return
    {
        visible: true,

        x: 16,
        y: 108,

        width: 260,
        height: 250,

        header_height: 30,
        padding: 10,

        range: 1600,
        range_minimum: 600,
        range_maximum: 2500,
        zoom_factor: 1.25,

        dragging: false,
        drag_offset_x: 0,
        drag_offset_y: 0,

        color: c_aqua,
        background_alpha: 0.88,
		
		static_terrain:
        {
            surface: -1,
            dirty: true,
            scale: 0,
            width: 0,
            height: 0
        },

		radar:
        {
            sweep_angle: 0,
            previous_sweep_angle: 0,

            sweep_degrees_per_second: 90
        },
		
        controls:
        {
            zoom_in:
            {
                x: 0,
                y: 0,
                width: 26,
                height: 22
            },

            zoom_out:
            {
                x: 0,
                y: 0,
                width: 26,
                height: 22
            },

            hide:
            {
                x: 0,
                y: 0,
                width: 26,
                height: 22
            }
        }
    };
}


/// @description Returns whether a GUI point is inside one HUD rectangle.
function scr_hud_minimap_bounds_contains(
    _bounds,
    _x,
    _y
)
{
    return
        _x >= _bounds.x
        && _x <= _bounds.x + _bounds.width
        && _y >= _bounds.y
        && _y <= _bounds.y + _bounds.height;
}


/// @description Updates one minimap control's GUI bounds.
function scr_hud_minimap_control_bounds_set(
    _control,
    _x,
    _y,
    _width,
    _height
)
{
    _control.x = _x;
    _control.y = _y;
    _control.width = _width;
    _control.height = _height;

    return true;
}


/// @description Returns whether the GUI pointer is inside the visible minimap.
function scr_hud_minimap_pointer_over(_hud)
{
    if (!instance_exists(_hud)) return false;

    var _map =
        _hud.hud.minimap;

    if (!_map.visible) return false;

    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);

    return
        _mouse_x >= _map.x
        && _mouse_x <= _map.x + _map.width
        && _mouse_y >= _map.y
        && _mouse_y <= _map.y + _map.height;
}


/// @description Draws one compact minimap marker.
function scr_hud_minimap_marker_draw(
    _x,
    _y,
    _color,
    _radius = 3
)
{
    draw_set_alpha(1);
    draw_set_color(_color);

    draw_circle(
        _x,
        _y,
        _radius,
        false
    );

    return true;
}


/// @description Draws one vector minimap control.
function scr_hud_minimap_control_draw(
    _control,
    _label,
    _color
)
{
    var _hovered =
        scr_hud_minimap_bounds_contains(
            _control,
            device_mouse_x_to_gui(0),
            device_mouse_y_to_gui(0)
        );

    draw_set_alpha(
        _hovered
        ? 0.34
        : 0.16
    );

    draw_set_color(c_black);

    draw_rectangle(
        _control.x,
        _control.y,
        _control.x + _control.width,
        _control.y + _control.height,
        false
    );

    draw_set_alpha(1);
    draw_set_color(_color);

    draw_rectangle(
        _control.x,
        _control.y,
        _control.x + _control.width,
        _control.y + _control.height,
        true
    );

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(
        _control.x + (_control.width * 0.5),
        _control.y + (_control.height * 0.5),
        _label
    );

    return true;
}


/// @description Updates minimap controls, dragging, visibility and notification position.
function scr_hud_minimap_update(_hud)
{
    if (!instance_exists(_hud)) return false;

    var _map =
        _hud.hud.minimap;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _minimum_y =
        _hud.hud.top.height + 12;

    // M toggles the dock even after it has been hidden.
    if (
        keyboard_check_pressed(
            ord("M")
        )
    )
    {
        _map.visible =
            !_map.visible;

        _map.dragging =
            false;
    }

    // Keep the notification feed below the dock while it is visible.
    if (_map.visible)
    {
        _hud.hud.notifications.target_x =
            _map.x + 8;

        _hud.hud.notifications.start_y =
            _map.y
            + _map.height
            + 28;
    }
    else
    {
        _hud.hud.notifications.target_x =
            24;

        _hud.hud.notifications.start_y =
            _hud.hud.top.height
            + 30;
    }

    if (!_map.visible) return true;
	
	scr_hud_minimap_radar_update(_hud);

    // ========================================================================
    // CONTROL BOUNDS
    // ========================================================================

    var _control_y =
        _map.y + 4;

    var _hide_x =
        _map.x
        + _map.width
        - 4
        - _map.controls.hide.width;

    var _zoom_out_x =
        _hide_x
        - 4
        - _map.controls.zoom_out.width;

    var _zoom_in_x =
        _zoom_out_x
        - 4
        - _map.controls.zoom_in.width;

    scr_hud_minimap_control_bounds_set(
        _map.controls.zoom_in,
        _zoom_in_x,
        _control_y,
        _map.controls.zoom_in.width,
        _map.controls.zoom_in.height
    );

    scr_hud_minimap_control_bounds_set(
        _map.controls.zoom_out,
        _zoom_out_x,
        _control_y,
        _map.controls.zoom_out.width,
        _map.controls.zoom_out.height
    );

    scr_hud_minimap_control_bounds_set(
        _map.controls.hide,
        _hide_x,
        _control_y,
        _map.controls.hide.width,
        _map.controls.hide.height
    );

    var _mouse_x =
        device_mouse_x_to_gui(0);

    var _mouse_y =
        device_mouse_y_to_gui(0);

    // ========================================================================
    // BUTTONS
    // ========================================================================

    if (mouse_check_button_pressed(mb_left))
    {
        if (
            scr_hud_minimap_bounds_contains(
                _map.controls.zoom_in,
                _mouse_x,
                _mouse_y
            )
        )
        {
            _map.range =
                clamp(
                    _map.range
                    / _map.zoom_factor,

                    _map.range_minimum,
                    _map.range_maximum
                );
				
			_map.static_terrain.dirty = true;

            return true;
        }

        if (
            scr_hud_minimap_bounds_contains(
                _map.controls.zoom_out,
                _mouse_x,
                _mouse_y
            )
        )
        {
            _map.range =
                clamp(
                    _map.range
                    * _map.zoom_factor,

                    _map.range_minimum,
                    _map.range_maximum
                );
				
				_map.static_terrain.dirty = true;

            return true;
        }

        if (
            scr_hud_minimap_bounds_contains(
                _map.controls.hide,
                _mouse_x,
                _mouse_y
            )
        )
        {
            _map.visible =
                false;

            _map.dragging =
                false;

            return true;
        }
    }

    // ========================================================================
    // DRAGGING
    // ========================================================================

    var _title_bar_left =
        _map.x;

    var _title_bar_right =
        _map.controls.zoom_in.x - 6;

    var _pointer_in_title_bar =
        _mouse_x >= _title_bar_left
        && _mouse_x <= _title_bar_right
        && _mouse_y >= _map.y
        && _mouse_y <= _map.y + _map.header_height;

    if (
        mouse_check_button_pressed(mb_left)
        && _pointer_in_title_bar
    )
    {
        _map.dragging =
            true;

        _map.drag_offset_x =
            _mouse_x - _map.x;

        _map.drag_offset_y =
            _mouse_y - _map.y;
    }

    if (
        _map.dragging
        && mouse_check_button(mb_left)
    )
    {
        _map.x =
            clamp(
                _mouse_x - _map.drag_offset_x,
                8,
                _gui_width - _map.width - 8
            );
			

        _map.y =
            clamp(
                _mouse_y - _map.drag_offset_y,
                _minimum_y,
                _gui_height
                - _hud.hud.bottom.height
                - _map.height
                - 8
            );
    }

    if (
        _map.dragging
        && !mouse_check_button(mb_left)
    )
    {
        _map.dragging =
            false;
    }

    return true;
}

/// @description Frees the minimap cached static-terrain surface.
function scr_hud_minimap_static_terrain_destroy(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _terrain =
        _hud.hud.minimap.static_terrain;

    if (surface_exists(_terrain.surface))
    {
        surface_free(_terrain.surface);
    }

    _terrain.surface =
        -1;

    _terrain.dirty =
        true;

    _terrain.scale =
        0;

    _terrain.width =
        0;

    _terrain.height =
        0;

    return true;
}


/// @description Rebuilds the static dead-terrain minimap surface.
function scr_hud_minimap_static_terrain_rebuild(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _map =
        _hud.hud.minimap;

    var _terrain =
        _map.static_terrain;

    var _map_width =
        _map.width
        - (_map.padding * 2);

    var _map_height =
        _map.height
        - _map.header_height
        - (_map.padding * 2);

    var _scale =
        min(
            _map_width,
            _map_height
        )
        / (_map.range * 2);

    var _surface_width =
        max(
            1,
            ceil(
                global.vtd_level.map.width
                * _scale
            )
        );

    var _surface_height =
        max(
            1,
            ceil(
                global.vtd_level.map.height
                * _scale
            )
        );

    var _surface_valid =
        surface_exists(_terrain.surface)
        && _terrain.width == _surface_width
        && _terrain.height == _surface_height;

    if (!_surface_valid)
    {
        if (surface_exists(_terrain.surface))
        {
            surface_free(_terrain.surface);
        }

        _terrain.surface =
            surface_create(
                _surface_width,
                _surface_height
            );

        _terrain.width =
            _surface_width;

        _terrain.height =
            _surface_height;
    }

    if (!surface_exists(_terrain.surface))
        return false;


    surface_set_target(_terrain.surface);

    draw_clear_alpha(
        c_black,
        0
    );

    draw_set_alpha(0.8);
    draw_set_color(
        make_color_rgb(
            55,
            65,
            70
        )
    );

    var _dead_cell_count =
        instance_number(o_dead_cell);

    for (
        var i = 0;
        i < _dead_cell_count;
        ++i
    )
    {
        var _dead_cell =
            instance_find(
                o_dead_cell,
                i
            );

        if (!instance_exists(_dead_cell))
            continue;

        var _x =
            floor(
                _dead_cell.x
                * _scale
            );

        var _y =
            floor(
                _dead_cell.y
                * _scale
            );

        draw_rectangle(
            _x - 2,
            _y - 2,
            _x + 2,
            _y + 2,
            false
        );
    }

    surface_reset_target();

    _terrain.scale =
        _scale;

    _terrain.dirty =
        false;

    return true;
}


/// @description Draws the visible player-centred crop of cached static terrain.
function scr_hud_minimap_static_terrain_draw(
    _hud,
    _player,
    _map_left,
    _map_top,
    _map_width,
    _map_height
)
{
    if (!instance_exists(_hud))
        return false;

    if (!instance_exists(_player))
        return false;

    var _map =
        _hud.hud.minimap;

    var _terrain =
        _map.static_terrain;

    if (
        _terrain.dirty
        || !surface_exists(_terrain.surface)
    )
    {
        if (
            !scr_hud_minimap_static_terrain_rebuild(
                _hud
            )
        )
        {
            return false;
        }
    }

    var _source_x =
        floor(
            (_player.x * _terrain.scale)
            - (_map_width * 0.5)
        );

    var _source_y =
        floor(
            (_player.y * _terrain.scale)
            - (_map_height * 0.5)
        );

    var _source_left =
        clamp(
            _source_x,
            0,
            _terrain.width
        );

    var _source_top =
        clamp(
            _source_y,
            0,
            _terrain.height
        );

    var _source_right =
        clamp(
            _source_x + _map_width,
            0,
            _terrain.width
        );

    var _source_bottom =
        clamp(
            _source_y + _map_height,
            0,
            _terrain.height
        );

    var _source_width =
        _source_right
        - _source_left;

    var _source_height =
        _source_bottom
        - _source_top;

    if (
        _source_width <= 0
        || _source_height <= 0
    )
    {
        return true;
    }

    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_surface_part(
        _terrain.surface,

        _source_left,
        _source_top,
        _source_width,
        _source_height,

        _map_left
        + (_source_left - _source_x),

        _map_top
        + (_source_top - _source_y)
    );

    return true;
}


/// @description Draws the player-centred tactical minimap dock.
function scr_hud_minimap_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;


    var _map =
        _hud.hud.minimap;

    if (!_map.visible)
        return true;


    var _left =
        _map.x;

    var _top =
        _map.y;

    var _right =
        _map.x + _map.width;

    var _bottom =
        _map.y + _map.height;


    var _map_left =
        _left + _map.padding;

    var _map_top =
        _top
        + _map.header_height
        + _map.padding;

    var _map_right =
        _right - _map.padding;

    var _map_bottom =
        _bottom - _map.padding;


    var _map_width =
        _map_right - _map_left;

    var _map_height =
        _map_bottom - _map_top;


    var _center_x =
        _map_left
        + (_map_width * 0.5);

    var _center_y =
        _map_top
        + (_map_height * 0.5);


    // Calculate these once for every marker this frame.

    var _map_scale =
        min(
            _map_width,
            _map_height
        )
        / (_map.range * 2);

    var _range_squared =
        _map.range * _map.range;


    // ========================================================================
    // PANEL
    // ========================================================================

    draw_set_alpha(
        _map.background_alpha
    );

    draw_set_color(
        c_black
    );


    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_alpha(1);

    draw_set_color(
        _map.color
    );


    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        true
    );


    draw_line(
        _left,
        _top + _map.header_height,
        _right,
        _top + _map.header_height
    );


    var _corner =
        10;


    draw_line(
        _left,
        _top + _corner,
        _left + _corner,
        _top
    );

    draw_line(
        _right - _corner,
        _top,
        _right,
        _top + _corner
    );

    draw_line(
        _left,
        _bottom - _corner,
        _left + _corner,
        _bottom
    );

    draw_line(
        _right - _corner,
        _bottom,
        _right,
        _bottom - _corner
    );


    // ========================================================================
    // TITLE / CONTROLS
    // ========================================================================

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_middle
    );

    draw_set_color(
        _map.color
    );


    draw_text(
        _left + 10,
        _top + (_map.header_height * 0.5),
        "MINIMAP"
    );


    scr_hud_minimap_control_draw(
        _map.controls.zoom_in,
        "+",
        _map.color
    );

    scr_hud_minimap_control_draw(
        _map.controls.zoom_out,
        "-",
        _map.color
    );

    scr_hud_minimap_control_draw(
        _map.controls.hide,
        "X",
        c_gray
    );


    // ========================================================================
    // MAP BACKGROUND / GRID
    // ========================================================================

    draw_set_alpha(
        0.22
    );

    draw_set_color(
        c_dkgray
    );


    draw_rectangle(
        _map_left,
        _map_top,
        _map_right,
        _map_bottom,
        false
    );


    var _grid_divisions =
        4;


    for (
        var i = 1;
        i < _grid_divisions;
        ++i
    )
    {
        var _grid_x =
            _map_left
            + (
                (_map_width / _grid_divisions)
                * i
            );

        var _grid_y =
            _map_top
            + (
                (_map_height / _grid_divisions)
                * i
            );


        draw_line(
            _grid_x,
            _map_top,
            _grid_x,
            _map_bottom
        );


        draw_line(
            _map_left,
            _grid_y,
            _map_right,
            _grid_y
        );
    }


    draw_set_alpha(
        0.4
    );

    draw_set_color(
        _map.color
    );


    draw_circle(
        _center_x,
        _center_y,
        min(
            _map_width,
            _map_height
        ) * 0.5,
        true
    );


    draw_set_alpha(1);

    draw_set_color(
        _map.color
    );


    draw_rectangle(
        _map_left,
        _map_top,
        _map_right,
        _map_bottom,
        true
    );


    // ========================================================================
    // WORLD MARKERS
    // ========================================================================

    var _player =
        global.vtd_level.entities.player;


    if (instance_exists(_player))
    {
        scr_hud_minimap_static_terrain_draw(
            _hud,
            _player,
            _map_left,
            _map_top,
            _map_width,
            _map_height
        );


        // ====================================================================
        // BUILDINGS
        // ====================================================================

        var _building_count =
            instance_number(
                o_building_par
            );


        for (
            var i = 0;
            i < _building_count;
            ++i
        )
        {
            var _building =
                instance_find(
                    o_building_par,
                    i
                );


            if (!instance_exists(_building))
                continue;


            if (
                _building.BuildingState
                == BuildingState.DESTROYED
            )
            {
                continue;
            }


            var _building_dx =
                _building.x
                - _player.x;

            var _building_dy =
                _building.y
                - _player.y;

            var _building_distance_squared =
                (_building_dx * _building_dx)
                + (_building_dy * _building_dy);


            if (
                _building_distance_squared
                > _range_squared
            )
            {
                continue;
            }


            // Direct world-to-minimap conversion.
            // No temporary { x, y } struct is created.

            var _building_map_x =
                _center_x
                + (
                    _building_dx
                    * _map_scale
                );

            var _building_map_y =
                _center_y
                + (
                    _building_dy
                    * _map_scale
                );


            draw_set_alpha(1);

            draw_set_color(
                c_lime
            );


            draw_rectangle(
                _building_map_x - 3,
                _building_map_y - 3,
                _building_map_x + 3,
                _building_map_y + 3,
                false
            );


            draw_set_alpha(
                0.5
            );

            draw_set_color(
                c_aqua
            );


            draw_rectangle(
                _building_map_x - 4,
                _building_map_y - 4,
                _building_map_x + 4,
                _building_map_y + 4,
                true
            );
        }


        // ====================================================================
        // ENEMIES / RADAR CONTACTS
        // ====================================================================

        var _enemy_count =
            instance_number(
                o_enemy
            );

        var _radar =
            _map.radar;


        var _fps =
            max(
                1,
                game_get_speed(
                    gamespeed_fps
                )
            );

        var _delta_seconds =
            1 / _fps;


        for (
            var i = 0;
            i < _enemy_count;
            ++i
        )
        {
            var _enemy =
                instance_find(
                    o_enemy,
                    i
                );


            if (!instance_exists(_enemy))
                continue;


            var _enemy_minimap =
                _enemy.minimap;


            _enemy_minimap.contact_remaining =
                max(
                    0,
                    _enemy_minimap.contact_remaining
                    - _delta_seconds
                );


            var _enemy_dx =
                _enemy.x
                - _player.x;

            var _enemy_dy =
                _enemy.y
                - _player.y;

            var _enemy_distance_squared =
                (_enemy_dx * _enemy_dx)
                + (_enemy_dy * _enemy_dy);


            if (
                _enemy_distance_squared
                > _range_squared
            )
            {
                continue;
            }


            var _enemy_angle =
                point_direction(
                    _player.x,
                    _player.y,
                    _enemy.x,
                    _enemy.y
                );


            if (
                scr_hud_minimap_radar_sweep_crossed(
                    _radar.previous_sweep_angle,
                    _radar.sweep_angle,
                    _enemy_angle
                )
            )
            {
                _enemy_minimap.contact_remaining =
                    _enemy_minimap.fade_time;
            }


            if (
                _enemy_minimap.contact_remaining
                <= 0
            )
            {
                continue;
            }


            // Direct world-to-minimap conversion.
            // No temporary { x, y } struct is created.

            var _enemy_map_x =
                _center_x
                + (
                    _enemy_dx
                    * _map_scale
                );

            var _enemy_map_y =
                _center_y
                + (
                    _enemy_dy
                    * _map_scale
                );


            var _fade_alpha =
                clamp(
                    _enemy_minimap.contact_remaining
                    / _enemy_minimap.fade_time,
                    0,
                    1
                );


            var _dot_size =
                _enemy_minimap.size;


            draw_set_color(
                _enemy.visual.color
            );


            draw_set_alpha(
                0.08
                * _fade_alpha
            );


            draw_circle(
                _enemy_map_x,
                _enemy_map_y,
                _dot_size * 4.67,
                false
            );


            draw_set_alpha(
                0.18
                * _fade_alpha
            );


            draw_circle(
                _enemy_map_x,
                _enemy_map_y,
                _dot_size * 3.33,
                false
            );


            draw_set_alpha(
                0.45
                * _fade_alpha
            );


            draw_circle(
                _enemy_map_x,
                _enemy_map_y,
                _dot_size * 2,
                false
            );


            draw_set_alpha(
                _fade_alpha
            );


            draw_circle(
                _enemy_map_x,
                _enemy_map_y,
                _dot_size,
                false
            );
        }


        // ====================================================================
        // RADAR SWEEP LINE
        // ====================================================================

        var _sweep_radius =
            min(
                _map_width,
                _map_height
            )
            * 0.5;


        draw_set_alpha(
            0.72
        );

        draw_set_color(
            _map.color
        );


        draw_line_width(
            _center_x,
            _center_y,

            _center_x
            + lengthdir_x(
                _sweep_radius,
                _radar.sweep_angle
            ),

            _center_y
            + lengthdir_y(
                _sweep_radius,
                _radar.sweep_angle
            ),

            2
        );


        // ====================================================================
        // PLAYER
        // ====================================================================

        draw_set_alpha(
            0.18
        );

        draw_set_color(
            c_aqua
        );


        draw_rectangle(
            _center_x - 8,
            _center_y - 8,
            _center_x + 8,
            _center_y + 8,
            false
        );


        draw_set_alpha(1);

        draw_set_color(
            c_aqua
        );


        draw_rectangle(
            _center_x - 4,
            _center_y - 4,
            _center_x + 4,
            _center_y + 4,
            false
        );


        draw_set_color(
            c_white
        );


        draw_rectangle(
            _center_x - 5,
            _center_y - 5,
            _center_x + 5,
            _center_y + 5,
            true
        );
    }
    else
    {
        draw_set_halign(
            fa_center
        );

        draw_set_valign(
            fa_middle
        );

        draw_set_color(
            c_red
        );


        draw_text(
            _center_x,
            _center_y,
            "PLAYER OFFLINE"
        );
    }


    // ========================================================================
    // RANGE LABEL
    // ========================================================================

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_bottom
    );

    draw_set_color(
        c_gray
    );


    draw_text(
        _map_left + 4,
        _map_bottom - 4,
        "RANGE "
        + string(
            floor(
                _map.range
            )
        )
    );


    draw_set_alpha(1);

    draw_set_color(
        c_white
    );

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_top
    );


    return true;
}

/// @description Advances the minimap enemy-contact radar sweep.
function scr_hud_minimap_radar_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    var _radar =
        _hud.hud.minimap.radar;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    _radar.previous_sweep_angle =
        _radar.sweep_angle;

    _radar.sweep_angle =
        (
            _radar.sweep_angle
            + (
                _radar.sweep_degrees_per_second
                / _fps
            )
        )
        mod 360;

    return true;
}


/// @description Returns whether a clockwise radar sweep crossed one angle.
function scr_hud_minimap_radar_sweep_crossed(
    _start_angle,
    _end_angle,
    _target_angle
)
{
    var _travelled =
        (
            _end_angle
            - _start_angle
            + 360
        )
        mod 360;

    var _target_offset =
        (
            _target_angle
            - _start_angle
            + 360
        )
        mod 360;

    return _target_offset <= _travelled;
}