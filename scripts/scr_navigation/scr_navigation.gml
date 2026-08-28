/// @description Original-style native mp_grid enemy navigation.


/// @description Returns the navigation grid used by an enemy.

function scr_navigation_enemy_grid_get(_enemy)
{
    if (!instance_exists(_enemy))
        return -1;

    if (!is_struct(global.vtd_level))
        return -1;

    if (!global.vtd_level.navigation.ready)
        return -1;


    switch (_enemy.movement.layer)
    {
        case EnemyMovementLayer.GROUND:
        {
            if (
                scr_enemy_has_ability(
                    _enemy,
                    EnemyAbility.PHASING
                )
            )
            {
                // Phasers ignore buildings but still respect terrain.
                return global.vtd_level.navigation.grid_breach;
            }

            return global.vtd_level.navigation.grid_ground;
        }


        case EnemyMovementLayer.FLYING:
        {
            // Flyers ignore buildings and natural terrain.
            return global.vtd_level.navigation.grid_flying;
        }


        case EnemyMovementLayer.UNDERGROUND:
        {
            // Underground rules can receive their own grid later.
            // For now they ignore buildings but respect terrain.
            return global.vtd_level.navigation.grid_breach;
        }
    }


    return -1;
}


/// @description Requests a staggered enemy path calculation.

function scr_navigation_enemy_repath_request(
    _enemy,
    _immediate = false
)
{
    if (!instance_exists(_enemy))
        return false;


    var _outside_view =
        _enemy.performance
            .visibility
            .outside_view;


    _enemy.navigation.lazy.outside_view =
        _outside_view;


    var _lazy_factor =
        _outside_view
        ? _enemy.navigation.lazy.factor
        : 1;


    _enemy.navigation.needs_path =
        true;


    if (_immediate)
    {
        // Immediate requests are still staggered slightly so a large spawn
        // group cannot calculate every initial path on the same frame.

        _enemy.navigation.repath_timer =
            (real(_enemy.id) mod 6)
            * min(2, _lazy_factor);
    }
    else
    {
        _enemy.navigation.repath_timer =
            irandom_range(15, 30)
            * _lazy_factor;
    }


    return true;
}


/// @description Stops an enemy's current native path.

function scr_navigation_enemy_stop(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    with (_enemy)
    {
        path_end();
    }


    return true;
}


/// @description Calculates a path or schedules delayed breach analysis.

function scr_navigation_enemy_path_build(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_enemy.targeting.target))
        return false;

    var _grid =
        scr_navigation_enemy_grid_get(_enemy);

    if (_grid < 0)
        return false;


    var _path = _enemy.navigation.path_id;
    var _target = _enemy.targeting.target;

    var _path_found =
        scr_navigation_path_to_target(
            _enemy,
            _target,
            _grid,
            _path
        );


    if (!_path_found)
    {
        _enemy.navigation.reachable = false;
		
		        if (
            scr_enemy_order_active(_enemy)
            && _enemy.targeting.target
                == _enemy.order.target
        )
        {
            scr_enemy_order_fallback(
                _enemy
            );

            return false;
        }
		
        _enemy.navigation.needs_path = false;

        _enemy.navigation.revision_seen =
            global.vtd_level.navigation.revision;

        path_clear_points(_path);


        // Do not perform the expensive breach route on this same frame.
        // Each blocked enemy receives a different delayed breach check.

        if (
            _enemy.navigation.blocked_action
            == EnemyBlockedAction.BREACH
            && _enemy.targeting.target
                == _enemy.targeting.strategic
        )
        {
            var _outside_multiplier =
                _enemy.navigation.lazy.outside_view
                ? 2
                : 1;

            _enemy.navigation.lazy.breach_pending = true;

            _enemy.navigation.lazy.breach_timer =
                (
                    irandom_range(6, 18)
                    + (real(_enemy.id) mod 12)
                )
                * _outside_multiplier;
        }


        return false;
    }


    _enemy.navigation.reachable = true;
    _enemy.navigation.needs_path = false;

    _enemy.navigation.revision_seen =
        global.vtd_level.navigation.revision;

    _enemy.navigation.lazy.breach_pending = false;
    _enemy.navigation.lazy.breach_timer = 0;
    _enemy.navigation.lazy.breach_attempts = 0;


    with (_enemy)
    {
        path_start(
            navigation.path_id,
            movement.speed,
            path_action_stop,
            true
        );
    }


    return true;
}

/// @description Updates staggered native navigation and breach retries.

function scr_navigation_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_enemy.targeting.target))
    {
        scr_navigation_enemy_stop(_enemy);
        return false;
    }


    var _lazy =
        _enemy.navigation.lazy;


    // Performance data is guaranteed during enemy initialization.

    _lazy.outside_view =
        _enemy.performance
            .visibility
            .outside_view;


    // A building or obstacle changed. Every enemy notices the revision,
    // but the expensive mp_grid_path calculation receives a random delay.

    if (
        _enemy.navigation.revision_seen
        != global.vtd_level.navigation.revision
        && !_enemy.navigation.needs_path
        && !_lazy.breach_pending
    )
    {
        scr_navigation_enemy_repath_request(
            _enemy,
            false
        );
    }


    // A normal route failed. Breach analysis remains staggered.

    if (_lazy.breach_pending)
    {
        _lazy.breach_timer--;


        if (_lazy.breach_timer <= 0)
        {
            _lazy.breach_pending =
                false;

            _lazy.breach_attempts++;


            var _breach_started =
                scr_navigation_enemy_breach_begin(
                    _enemy
                );


            if (!_breach_started)
            {
                var _retry_factor =
                    _lazy.outside_view
                    ? _lazy.factor
                    : 1;


                _lazy.breach_pending =
                    true;

                _lazy.breach_timer =
                    irandom_range(
                        30,
                        60
                    )
                    * _retry_factor;
            }
        }
    }


    if (_enemy.navigation.needs_path)
    {
        _enemy.navigation.repath_timer--;


        if (_enemy.navigation.repath_timer <= 0)
        {
            return scr_navigation_enemy_path_build(
                _enemy
            );
        }
    }


    // Native path movement must remain active every frame.

    _enemy.path_speed =
        _enemy.movement.speed;


    // Visual direction is handled once by
    // scr_enemy_visual_direction_update() while visible.

    return true;
}
/// @description Returns possible approach positions around a building.

function scr_navigation_building_approach_positions(
    _enemy,
    _building
)
{
    var _positions =
        [];


    if (!instance_exists(_enemy))
        return _positions;

    if (!instance_exists(_building))
        return _positions;

    if (!is_struct(_building.footprint))
        return _positions;


    var _origin =
        _building.footprint.origin;

    var _width =
        _building.footprint.width_cells;

    var _height =
        _building.footprint.height_cells;


    var _left =
        _origin.x - 1;

    var _right =
        _origin.x + _width;

    var _top =
        _origin.y - 1;

    var _bottom =
        _origin.y + _height;


    for (
        var _cell_y = _top;
        _cell_y <= _bottom;
        ++_cell_y
    )
    {
        for (
            var _cell_x = _left;
            _cell_x <= _right;
            ++_cell_x
        )
        {
            var _inside_building =
                (
                    _cell_x >= _origin.x
                    && _cell_x
                        < _origin.x + _width
                    && _cell_y >= _origin.y
                    && _cell_y
                        < _origin.y + _height
                );


            if (_inside_building)
                continue;


            if (
                !scr_building_cell_inside_map(
                    _cell_x,
                    _cell_y
                )
            )
            {
                continue;
            }


            if (
                mp_grid_get_cell(
                    global.vtd_level.navigation
                        .grid_ground,
                    _cell_x,
                    _cell_y
                )
                != 0
            )
            {
                continue;
            }


            var _position =
                scr_building_cell_to_position(
                    _cell_x,
                    _cell_y
                );


            array_push(
                _positions,
                {
                    x:
                        _position.x,

                    y:
                        _position.y,

                    distance:
                        point_distance(
                            _enemy.x,
                            _enemy.y,
                            _position.x,
                            _position.y
                        )
                }
            );
        }
    }


    // Sort nearest approach cells first.

    for (
        var i = 1;
        i < array_length(_positions);
        ++i
    )
    {
        var _entry =
            _positions[i];

        var j =
            i - 1;


        while (
            j >= 0
            && _positions[j].distance
                > _entry.distance
        )
        {
            _positions[j + 1] =
                _positions[j];

            j--;
        }


        _positions[j + 1] =
            _entry;
    }


    return _positions;
}


/// @description Builds a path to an ordinary target or adjacent building cell.

function scr_navigation_path_to_target(
    _enemy,
    _target,
    _grid,
    _path
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;


    // Buildings occupy blocked grid cells, so enemies must path to an
    // accessible neighboring cell rather than the building centre.

    if (
        _target.object_index
        == o_building_par
        || object_is_ancestor(
            _target.object_index,
            o_building_par
        )
    )
    {
        var _positions =
            scr_navigation_building_approach_positions(
                _enemy,
                _target
            );


        for (
            var i = 0;
            i < array_length(_positions);
            ++i
        )
        {
            var _position =
                _positions[i];


            path_clear_points(
                _path
            );


            if (
                mp_grid_path(
                    _grid,
                    _path,
                    _enemy.x,
                    _enemy.y,
                    _position.x,
                    _position.y,
                    true
                )
            )
            {
                return true;
            }
        }


        path_clear_points(
            _path
        );

        return false;
    }


    path_clear_points(
        _path
    );


    return mp_grid_path(
        _grid,
        _path,
        _enemy.x,
        _enemy.y,
        _target.x,
        _target.y,
        true
    );
}


/// @description Finds the first building crossed by a breach-grid route.

function scr_navigation_enemy_breach_target_find(
    _enemy
)
{
    if (!instance_exists(_enemy))
        return noone;

    if (!instance_exists(
        _enemy.targeting.strategic
    ))
    {
        return noone;
    }


    var _path =
        _enemy.navigation.path_id;

    var _target =
        _enemy.targeting.strategic;

    var _breach_grid =
        global.vtd_level.navigation
            .grid_breach;


    path_clear_points(
        _path
    );


    if (
        !mp_grid_path(
            _breach_grid,
            _path,
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y,
            true
        )
    )
    {
        path_clear_points(
            _path
        );

        return noone;
    }


    var _point_count =
        path_get_number(
            _path
        );

    var _cell_size =
        global.vtd_level.map.cell_size;

    var _sample_distance =
        max(
            4,
            _cell_size * 0.4
        );


    var _previous_x =
        _enemy.x;

    var _previous_y =
        _enemy.y;


    // Sample every path segment rather than checking only path points.
    // Native paths may contain long straight segments crossing several cells.

    for (
        var i = 0;
        i < _point_count;
        ++i
    )
    {
        var _point_x =
            path_get_point_x(
                _path,
                i
            );

        var _point_y =
            path_get_point_y(
                _path,
                i
            );


        var _segment_length =
            point_distance(
                _previous_x,
                _previous_y,
                _point_x,
                _point_y
            );

        var _samples =
            max(
                1,
                ceil(
                    _segment_length
                    / _sample_distance
                )
            );


        for (
            var j = 0;
            j <= _samples;
            ++j
        )
        {
            var _amount =
                j / _samples;

            var _sample_x =
                lerp(
                    _previous_x,
                    _point_x,
                    _amount
                );

            var _sample_y =
                lerp(
                    _previous_y,
                    _point_y,
                    _amount
                );


            var _cell =
                scr_building_position_to_cell(
                    _sample_x,
                    _sample_y
                );


            var _building =
                scr_building_at_cell(
                    _cell.x,
                    _cell.y
                );


            if (instance_exists(_building))
            {
                path_clear_points(
                    _path
                );

                return _building;
            }
        }


        _previous_x =
            _point_x;

        _previous_y =
            _point_y;
    }


    path_clear_points(
        _path
    );


    return noone;
}


/// @description Assigns the first blocking building as a temporary target.

function scr_navigation_enemy_breach_begin(
    _enemy
)
{
    if (!instance_exists(_enemy))
        return false;


    var _building =
        scr_navigation_enemy_breach_target_find(
            _enemy
        );


    if (!instance_exists(_building))
        return false;


    _enemy.targeting.breach =
        _building;

    _enemy.targeting.target =
        _building;


    scr_navigation_enemy_repath_request(
        _enemy,
        true
    );


    show_debug_message(
        "ENEMY BREACH TARGET: "
        + _building.identity.name
    );


    return true;
}

/// @description Refreshes one navigation cell from terrain and buildings.

function scr_navigation_cell_refresh(_cell_x, _cell_y)
{
    if (!scr_world_cell_inside(_cell_x, _cell_y))
        return false;

    if (!global.vtd_level.navigation.ready)
        return false;


    var _terrain_blocked =
        !scr_world_cell_buildable(
            _cell_x,
            _cell_y
        );

    var _building =
        scr_building_at_cell(
            _cell_x,
            _cell_y
        );

    var _building_blocked =
        instance_exists(_building);


    // Ground navigation includes terrain and buildings.

    if (_terrain_blocked || _building_blocked)
    {
        mp_grid_add_cell(
            global.vtd_level.navigation.grid_ground,
            _cell_x,
            _cell_y
        );
    }
    else
    {
        mp_grid_clear_cell(
            global.vtd_level.navigation.grid_ground,
            _cell_x,
            _cell_y
        );
    }


    // The breach grid ignores buildings but never ignores terrain.

    if (_terrain_blocked)
    {
        mp_grid_add_cell(
            global.vtd_level.navigation.grid_breach,
            _cell_x,
            _cell_y
        );
    }
    else
    {
        mp_grid_clear_cell(
            global.vtd_level.navigation.grid_breach,
            _cell_x,
            _cell_y
        );
    }


    return true;
}


/// @description Deletes the native path owned by an enemy.

function scr_navigation_enemy_cleanup(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    scr_navigation_enemy_stop(
        _enemy
    );


    if (
        _enemy.navigation.path_id >= 0
        && path_exists(
            _enemy.navigation.path_id
        )
    )
    {
        path_delete(
            _enemy.navigation.path_id
        );
    }


    _enemy.navigation.path_id =
        -1;


    return true;
}

