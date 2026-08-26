/// @description Initializes the active level's spatial collision grid.

function scr_spatial_collision_initialize()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(
        global.vtd_level,
        "spatial_collision"
    ))
    {
        return false;
    }


    var _spatial =
        global.vtd_level.spatial_collision;

    var _settings =
        _spatial.settings;

    var _runtime =
        _spatial.runtime;


    if (_runtime.ready)
        return true;


    var _cell_size =
        max(
            32,
            round(_settings.cell_size)
        );

    _settings.cell_size =
        _cell_size;


    _runtime.columns =
        ceil(
            global.vtd_level.map.width
            / _cell_size
        );

    _runtime.rows =
        ceil(
            global.vtd_level.map.height
            / _cell_size
        );

    _runtime.enemy_grid =
        ds_grid_create(
            _runtime.columns,
            _runtime.rows
        );


    ds_grid_clear(
        _runtime.enemy_grid,
        undefined
    );


    _runtime.maximum_enemy_radius =
        max(
            1,
            _settings.initial_enemy_radius
        );

    _runtime.ready =
        true;


    show_debug_message(
        "SPATIAL COLLISION INITIALIZED - "
        + string(_runtime.columns)
        + " x "
        + string(_runtime.rows)
        + " @ "
        + string(_cell_size)
        + "px"
    );


    return true;
}

/// @description Releases the active level's spatial collision grid.

function scr_spatial_collision_cleanup()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (!variable_struct_exists(
        global.vtd_level,
        "spatial_collision"
    ))
    {
        return true;
    }


    var _runtime =
        global.vtd_level
            .spatial_collision
            .runtime;


    if (
        _runtime.ready
        && ds_exists(
            _runtime.enemy_grid,
            ds_type_grid
        )
    )
    {
        ds_grid_destroy(
            _runtime.enemy_grid
        );
    }


    _runtime.enemy_grid =
        -1;

    _runtime.columns =
        0;

    _runtime.rows =
        0;

    _runtime.ready =
        false;


    return true;
}

/// @description Returns the spatial sector containing a world position.

function scr_spatial_collision_cell_get(
    _world_x,
    _world_y
)
{
    var _spatial =
        global.vtd_level.spatial_collision;

    var _settings =
        _spatial.settings;

    var _runtime =
        _spatial.runtime;


    return
    {
        x:
            clamp(
                floor(
                    _world_x
                    / _settings.cell_size
                ),
                0,
                _runtime.columns - 1
            ),

        y:
            clamp(
                floor(
                    _world_y
                    / _settings.cell_size
                ),
                0,
                _runtime.rows - 1
            )
    };
}

/// @description Removes an enemy from its current spatial sector.

function scr_spatial_enemy_unregister(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(
        _enemy,
        "spatial_registration"
    ))
    {
        return true;
    }


    var _registration =
        _enemy.spatial_registration;

    if (!_registration.registered)
        return true;


    if (
        !variable_global_exists("vtd_level")
        || !is_struct(global.vtd_level)
        || !variable_struct_exists(
            global.vtd_level,
            "spatial_collision"
        )
    )
    {
        _registration.registered = false;
        _registration.cell_x = -1;
        _registration.cell_y = -1;

        return true;
    }


    var _runtime =
        global.vtd_level
            .spatial_collision
            .runtime;


    if (!_runtime.ready)
    {
        _registration.registered = false;
        _registration.cell_x = -1;
        _registration.cell_y = -1;

        return true;
    }


    var _bucket =
        ds_grid_get(
            _runtime.enemy_grid,
            _registration.cell_x,
            _registration.cell_y
        );


    if (is_array(_bucket))
    {
        for (
            var i = array_length(_bucket) - 1;
            i >= 0;
            --i
        )
        {
            if (_bucket[i] == _enemy)
            {
                array_delete(
                    _bucket,
                    i,
                    1
                );

                break;
            }
        }


        ds_grid_set(
            _runtime.enemy_grid,
            _registration.cell_x,
            _registration.cell_y,
            _bucket
        );
    }


    _registration.registered =
        false;

    _registration.cell_x =
        -1;

    _registration.cell_y =
        -1;


    return true;
}

/// @description Registers or relocates an enemy in the spatial grid.

function scr_spatial_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    if (!scr_spatial_collision_initialize())
        return false;


    if (!variable_instance_exists(
        _enemy,
        "spatial_registration"
    ))
    {
        _enemy.spatial_registration =
        {
            registered: false,
            cell_x: -1,
            cell_y: -1
        };
    }


    var _spatial =
        global.vtd_level.spatial_collision;

    var _runtime =
        _spatial.runtime;

    var _registration =
        _enemy.spatial_registration;

    var _cell =
        scr_spatial_collision_cell_get(
            _enemy.x,
            _enemy.y
        );


    // Most frames end here. No bucket editing is required while the enemy
    // remains inside its current sector.

    if (
        _registration.registered
        && _registration.cell_x == _cell.x
        && _registration.cell_y == _cell.y
    )
    {
        return true;
    }


    if (_registration.registered)
    {
        scr_spatial_enemy_unregister(
            _enemy
        );
    }


    var _bucket =
        ds_grid_get(
            _runtime.enemy_grid,
            _cell.x,
            _cell.y
        );


    if (!is_array(_bucket))
        _bucket = [];


    array_push(
        _bucket,
        _enemy
    );


    ds_grid_set(
        _runtime.enemy_grid,
        _cell.x,
        _cell.y,
        _bucket
    );


    _registration.registered =
        true;

    _registration.cell_x =
        _cell.x;

    _registration.cell_y =
        _cell.y;


    _runtime.maximum_enemy_radius =
        max(
            _runtime.maximum_enemy_radius,
            _enemy.visual.radius
        );


    return true;
}

/// @description Returns the earliest segment amount intersecting a circle.

function scr_spatial_segment_circle_hit_amount(
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _circle_x,
    _circle_y,
    _circle_radius
)
{
    var _segment_x =
        _end_x - _start_x;

    var _segment_y =
        _end_y - _start_y;

    var _length_squared =
        (_segment_x * _segment_x)
        + (_segment_y * _segment_y);


    var _difference_x =
        _start_x - _circle_x;

    var _difference_y =
        _start_y - _circle_y;

    var _radius_squared =
        _circle_radius
        * _circle_radius;


    if (
        (
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y)
        )
        <= _radius_squared
    )
    {
        return 0;
    }


    if (_length_squared <= 0)
        return infinity;


    var _b =
        2
        * (
            (_difference_x * _segment_x)
            + (_difference_y * _segment_y)
        );

    var _c =
        (
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y)
        )
        - _radius_squared;

    var _discriminant =
        (_b * _b)
        - (4 * _length_squared * _c);


    if (_discriminant < 0)
        return infinity;


    var _amount =
        (
            -_b
            - sqrt(_discriminant)
        )
        / (2 * _length_squared);


    if (_amount < 0 || _amount > 1)
        return infinity;


    return _amount;
}

/// @description Finds the earliest nearby enemy crossed by a segment.

function scr_spatial_enemy_segment_find(
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _projectile_radius,
    _target_layer = undefined
)
{
    if (!scr_spatial_collision_initialize())
        return undefined;


    var _spatial =
        global.vtd_level.spatial_collision;

    var _settings =
        _spatial.settings;

    var _runtime =
        _spatial.runtime;


    var _padding =
        _projectile_radius
        + _runtime.maximum_enemy_radius
        + _settings.query_padding;


    var _segment_left =
        min(_start_x, _end_x);

    var _segment_right =
        max(_start_x, _end_x);

    var _segment_top =
        min(_start_y, _end_y);

    var _segment_bottom =
        max(_start_y, _end_y);


    var _cell_left =
        clamp(
            floor(
                (_segment_left - _padding)
                / _settings.cell_size
            ),
            0,
            _runtime.columns - 1
        );

    var _cell_right =
        clamp(
            floor(
                (_segment_right + _padding)
                / _settings.cell_size
            ),
            0,
            _runtime.columns - 1
        );

    var _cell_top =
        clamp(
            floor(
                (_segment_top - _padding)
                / _settings.cell_size
            ),
            0,
            _runtime.rows - 1
        );

    var _cell_bottom =
        clamp(
            floor(
                (_segment_bottom + _padding)
                / _settings.cell_size
            ),
            0,
            _runtime.rows - 1
        );


    var _filter_layer =
        !is_undefined(_target_layer);

    var _closest_enemy =
        noone;

    var _closest_amount =
        infinity;


    for (
        var _cell_x = _cell_left;
        _cell_x <= _cell_right;
        ++_cell_x
    )
    {
        for (
            var _cell_y = _cell_top;
            _cell_y <= _cell_bottom;
            ++_cell_y
        )
        {
            var _bucket =
                ds_grid_get(
                    _runtime.enemy_grid,
                    _cell_x,
                    _cell_y
                );


            if (!is_array(_bucket))
                continue;


            for (
                var i = 0;
                i < array_length(_bucket);
                ++i
            )
            {
                var _enemy =
                    _bucket[i];


                if (!instance_exists(_enemy))
                    continue;

                if (_enemy.EnemyState == EnemyState.DEAD)
                    continue;


                if (
                    _filter_layer
                    && _enemy.movement.layer
                        != _target_layer
                )
                {
                    continue;
                }


                var _collision_radius =
                    _projectile_radius
                    + _enemy.visual.radius;


                // Cheap rectangle rejection before exact collision.

                if (
                    _enemy.x
                    < _segment_left
                        - _collision_radius
                    || _enemy.x
                    > _segment_right
                        + _collision_radius
                    || _enemy.y
                    < _segment_top
                        - _collision_radius
                    || _enemy.y
                    > _segment_bottom
                        + _collision_radius
                )
                {
                    continue;
                }


                var _amount =
                    scr_spatial_segment_circle_hit_amount(
                        _start_x,
                        _start_y,
                        _end_x,
                        _end_y,
                        _enemy.x,
                        _enemy.y,
                        _collision_radius
                    );


                if (_amount < _closest_amount)
                {
                    _closest_amount =
                        _amount;

                    _closest_enemy =
                        _enemy;
                }
            }
        }
    }


    if (!instance_exists(_closest_enemy))
        return undefined;


    return
    {
        enemy: _closest_enemy,
        amount: _closest_amount
    };
}