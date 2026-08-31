/// @description Original-style native mp_grid enemy navigation.


/// @description Returns the navigation grid used by an enemy.

function scr_navigation_enemy_grid_get(_enemy)
{
    if (!instance_exists(_enemy))
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
            irandom_range(20, 45)
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

    var _grid = scr_navigation_enemy_grid_get(_enemy);

    if (_grid < 0)
        return false;

    var _path = _enemy.navigation.path_id;
    var _target = _enemy.targeting.target;
    var _flank = _enemy.navigation.flank;
    var _path_found = false;

    // Player pursuit and explicit orders permanently cancel the initial flank.

    if (
        _flank.active
        && (
            _enemy.targeting.player.active
            || _enemy.order.type != EnemyOrder.NONE
        )
    )
    {
        _flank.active = false;
    }

    // Try the initial flank coordinate first.

    if (_flank.active)
    {
        var _flank_open =
            mp_grid_get_cell(
                _grid,
                _flank.cell_x,
                _flank.cell_y
            ) == 0;

        if (_flank_open)
        {
            path_clear_points(_path);

            _path_found =
                mp_grid_path(
                    _grid,
                    _path,
                    _enemy.x,
                    _enemy.y,
                    _flank.x,
                    _flank.y,
                    true
                );
        }

        // A blocked or unreachable flank falls back to normal navigation.

        if (!_path_found)
            _flank.active = false;
    }

    if (!_path_found)
    {
        _path_found =
            scr_navigation_path_to_target(
                _enemy,
                _target,
                _grid,
                _path
            );
    }

    if (!_path_found)
    {
        _enemy.navigation.reachable = false;

        if (
            scr_enemy_order_active(_enemy)
            && _enemy.targeting.target == _enemy.order.target
        )
        {
            scr_enemy_order_fallback(_enemy);
            return false;
        }

        _enemy.navigation.needs_path = false;
        _enemy.navigation.revision_seen =
            global.vtd_level.navigation.revision;

        path_clear_points(_path);

        if (
            _enemy.navigation.blocked_action == EnemyBlockedAction.BREACH
            && _enemy.targeting.target == _enemy.targeting.strategic
        )
        {
            var _outside_multiplier =
                _enemy.navigation.lazy.outside_view ? 2 : 1;

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

function scr_navigation_enemy_update(_enemy)
{
    // Native GameMaker path movement continues automatically.
    _enemy.path_speed = _enemy.movement.speed;

    var _nav = _enemy.navigation;
    var _lazy = _nav.lazy;
    var _revision = global.vtd_level.navigation.revision;
	
	var _flank = _nav.flank;

	if (
	    _flank.active
	    && _enemy.path_index == -1
	    && !_nav.needs_path
	)
	{
	    var _dx = _flank.x - _enemy.x;
	    var _dy = _flank.y - _enemy.y;
	    var _arrival_distance =
	        global.vtd_level.map.cell_size;

	    if (
	        (_dx * _dx) + (_dy * _dy)
	        <= _arrival_distance * _arrival_distance
	    )
	    {
	        _flank.active = false;
	        scr_navigation_enemy_repath_request(_enemy, true);

	        return true;
	    }

	    // Path stopped before reaching the flank point.

	    scr_navigation_enemy_repath_request(_enemy, true);
	    return true;
	}


    // ------------------------------------------------------------------------
	// REMEMBERED DEAD BUILDING
	// ------------------------------------------------------------------------

	var _remembering_building =
	    _enemy.targeting.target_type == EnemyTarget.BUILDING
	    && !_enemy.targeting.player.active
	    && _enemy.order.type == EnemyOrder.NONE
	    && !instance_exists(_enemy.targeting.strategic)
	    && _enemy.path_index != -1;

	if (_remembering_building)
	{
	    var _dx = _enemy.targeting.target_x - _enemy.x;
	    var _dy = _enemy.targeting.target_y - _enemy.y;

	    var _notice_range = max(
	        _enemy.targeting.range_sight,
	        _enemy.attack.range
	    );

	    if (
	        (_dx * _dx) + (_dy * _dy)
	        > _notice_range * _notice_range
	    )
	    {
	        _nav.revision_seen = _revision;
	        _nav.needs_path = false;

	        _lazy.breach_pending = false;
	        _lazy.breach_timer = 0;

	        return true;
	    }
	}


    // ------------------------------------------------------------------------
    // FAST PATH
    // ------------------------------------------------------------------------

    if (!_nav.needs_path
        && !_lazy.breach_pending
        && _nav.revision_seen == _revision)
    {
        return true;
    }


    _lazy.outside_view = _enemy.performance.visibility.outside_view;


    // ------------------------------------------------------------------------
    // NAVIGATION GRID CHANGED
    // ------------------------------------------------------------------------

    if (_nav.revision_seen != _revision
        && !_nav.needs_path
        && !_lazy.breach_pending)
    {
        scr_navigation_enemy_repath_request(_enemy, false);
    }


    // ------------------------------------------------------------------------
	// BREACH RETRY
	// ------------------------------------------------------------------------

	if (_lazy.breach_pending)
	{
	    _lazy.breach_timer--;

	    if (_lazy.breach_timer <= 0)
	    {
	        _lazy.breach_timer = 0;

	        if (!scr_navigation_path_budget_claim())
	            return true;

	        _lazy.breach_pending = false;
	        _lazy.breach_attempts++;

	        if (!scr_navigation_enemy_breach_begin(_enemy))
	        {
	            var _factor =
	                _lazy.outside_view
	                ? _lazy.factor
	                : 1;

	            _lazy.breach_pending = true;
	            _lazy.breach_timer =
	                irandom_range(30, 60) * _factor;
	        }
	    }
	}


    // ------------------------------------------------------------------------
    // PATH REQUEST
    // ------------------------------------------------------------------------

    if (_nav.needs_path)
	{
	    _nav.repath_timer--;

	    if (_nav.repath_timer <= 0)
	    {
	        _nav.repath_timer = 0;

	        if (!scr_navigation_path_budget_claim())
	            return true;

	        return scr_navigation_enemy_path_build(_enemy);
	    }
	}

    return true;
}

function scr_navigation_target_approach_positions(_enemy, _target)
{
    var _positions = [];

    var _origin = _target.footprint.origin;
    var _width = _target.footprint.width_cells;
    var _height = _target.footprint.height_cells;

    var _left = _origin.x - 1;
    var _right = _origin.x + _width;
    var _top = _origin.y - 1;
    var _bottom = _origin.y + _height;

    for (var _cell_y = _top; _cell_y <= _bottom; ++_cell_y)
    {
        for (var _cell_x = _left; _cell_x <= _right; ++_cell_x)
        {
            var _inside =
                _cell_x >= _origin.x
                && _cell_x < _origin.x + _width
                && _cell_y >= _origin.y
                && _cell_y < _origin.y + _height;

            if (_inside)
                continue;

            if (!scr_building_cell_inside_map(_cell_x, _cell_y))
                continue;

            if (mp_grid_get_cell(
                global.vtd_level.navigation.grid_ground,
                _cell_x,
                _cell_y
            ) != 0)
            {
                continue;
            }

            var _position =
                scr_building_cell_to_position(_cell_x, _cell_y);

            array_push(
                _positions,
                {
                    x: _position.x,
                    y: _position.y,
                    distance: point_distance(
                        _enemy.x,
                        _enemy.y,
                        _position.x,
                        _position.y
                    )
                }
            );
        }
    }

    // Nearest approach cells first.
    for (var i = 1; i < array_length(_positions); ++i)
    {
        var _entry = _positions[i];
        var j = i - 1;

        while (j >= 0 && _positions[j].distance > _entry.distance)
        {
            _positions[j + 1] = _positions[j];
            j--;
        }

        _positions[j + 1] = _entry;
    }

    return _positions;
}


function scr_navigation_path_to_target(_enemy, _target, _grid, _path)
{
    if (!instance_exists(_target))
        return false;

    // Any footprint target — CPU or building — is approached from outside.
    if (variable_instance_exists(_target, "footprint"))
    {
        var _positions =
            scr_navigation_target_approach_positions(_enemy, _target);

        for (var i = 0; i < array_length(_positions); ++i)
        {
            var _position = _positions[i];

            path_clear_points(_path);

            if (mp_grid_path(
                _grid,
                _path,
                _enemy.x,
                _enemy.y,
                _position.x,
                _position.y,
                true
            ))
            {
                return true;
            }
        }

        path_clear_points(_path);
        return false;
    }

    // Player / other point targets.
    path_clear_points(_path);

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

/// @description Finds open route-point cells around one desired world position.

function scr_navigation_flanking_zone_build(
    _world_x,
    _world_y,
    _count,
    _search_radius
)
{
    var _points = [];
    var _cell_size = global.vtd_level.map.cell_size;
    var _columns = global.vtd_level.map.columns;
    var _rows = global.vtd_level.map.rows;
    var _grid = global.vtd_level.navigation.grid_ground;

    var _center_x = clamp(floor(_world_x / _cell_size), 1, _columns - 2);
    var _center_y = clamp(floor(_world_y / _cell_size), 1, _rows - 2);

    for (var _radius = 0; _radius <= _search_radius; ++_radius)
    {
        for (var _offset_y = -_radius; _offset_y <= _radius; ++_offset_y)
        {
            for (var _offset_x = -_radius; _offset_x <= _radius; ++_offset_x)
            {
                if (
                    _radius > 0
                    && abs(_offset_x) != _radius
                    && abs(_offset_y) != _radius
                )
                {
                    continue;
                }

                var _cell_x = _center_x + _offset_x;
                var _cell_y = _center_y + _offset_y;

                if (!scr_building_cell_inside_map(_cell_x, _cell_y))
                    continue;

                if (mp_grid_get_cell(_grid, _cell_x, _cell_y) != 0)
                    continue;

                var _position =
                    scr_building_cell_to_position(_cell_x, _cell_y);

                array_push(
                    _points,
                    {
                        x: _position.x,
                        y: _position.y,
                        cell_x: _cell_x,
                        cell_y: _cell_y
                    }
                );

                if (array_length(_points) >= _count)
                    return _points;
            }
        }
    }

    return _points;
}


/// @description Creates optional shared flank-route zones for the level.

function scr_navigation_flanking_initialize(_world_data)
{
    global.vtd_level.navigation.flanking =
    {
        enabled: false,
        chance: 0,

        top_left: [],
        top_right: [],
        bottom_left: [],
        bottom_right: []
    };

    if (!variable_struct_exists(_world_data, "navigation"))
        return true;

    var _navigation_data = _world_data.navigation;

    if (
        !is_struct(_navigation_data)
        || !variable_struct_exists(_navigation_data, "flanking")
        || !is_struct(_navigation_data.flanking)
    )
    {
        return true;
    }

    var _data = _navigation_data.flanking;

    if (
        !variable_struct_exists(_data, "enabled")
        || !_data.enabled
    )
    {
        return true;
    }

    var _cpu = global.vtd_level.entities.cpu;

    if (!instance_exists(_cpu))
        return false;

    var _chance = variable_struct_exists(_data, "chance")
        ? clamp(_data.chance, 0, 1)
        : 0.20;

    var _distance_ratio = variable_struct_exists(_data, "distance_ratio")
        ? clamp(_data.distance_ratio, 0.05, 0.40)
        : 0.22;

    var _candidate_count = variable_struct_exists(_data, "candidates_per_corner")
        ? max(1, floor(_data.candidates_per_corner))
        : 6;

    var _search_radius = variable_struct_exists(_data, "search_radius_cells")
        ? max(1, floor(_data.search_radius_cells))
        : 8;

    var _distance =
        min(
            global.vtd_level.map.width,
            global.vtd_level.map.height
        )
        * _distance_ratio;

    var _runtime = global.vtd_level.navigation.flanking;

    _runtime.chance = _chance;

    _runtime.top_left =
        scr_navigation_flanking_zone_build(
            _cpu.x - _distance,
            _cpu.y - _distance,
            _candidate_count,
            _search_radius
        );

    _runtime.top_right =
        scr_navigation_flanking_zone_build(
            _cpu.x + _distance,
            _cpu.y - _distance,
            _candidate_count,
            _search_radius
        );

    _runtime.bottom_left =
        scr_navigation_flanking_zone_build(
            _cpu.x - _distance,
            _cpu.y + _distance,
            _candidate_count,
            _search_radius
        );

    _runtime.bottom_right =
        scr_navigation_flanking_zone_build(
            _cpu.x + _distance,
            _cpu.y + _distance,
            _candidate_count,
            _search_radius
        );

    _runtime.enabled = true;

    return true;
}


/// @description Assigns one optional initial flank point to an enemy.

function scr_navigation_enemy_flank_assign(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _flank = _enemy.navigation.flank;
    var _level_flanking = global.vtd_level.navigation.flanking;

    if (
        !is_struct(_level_flanking)
        || !_level_flanking.enabled
        || _enemy.movement.brainless
        || _enemy.movement.layer != EnemyMovementLayer.GROUND
        || random(1) >= _level_flanking.chance
    )
    {
        return true;
    }

    var _cpu = global.vtd_level.entities.cpu;

    if (!instance_exists(_cpu))
        return true;

    var _left = _enemy.x < _cpu.x;
    var _top = _enemy.y < _cpu.y;
    var _zone;

    if (_left)
        _zone = _top
            ? _level_flanking.top_left
            : _level_flanking.bottom_left;
    else
        _zone = _top
            ? _level_flanking.top_right
            : _level_flanking.bottom_right;

    var _count = array_length(_zone);

    if (_count <= 0)
        return true;

    var _start = irandom(_count - 1);
    var _grid = global.vtd_level.navigation.grid_ground;

    for (var i = 0; i < _count; ++i)
    {
        var _point = _zone[(_start + i) mod _count];

        if (
            mp_grid_get_cell(
                _grid,
                _point.cell_x,
                _point.cell_y
            ) != 0
        )
        {
            continue;
        }

        _flank.active = true;
        _flank.x = _point.x;
        _flank.y = _point.y;
        _flank.cell_x = _point.cell_x;
        _flank.cell_y = _point.cell_y;

        return true;
    }

    return true;
}

/// @description Claims one enemy path calculation for the current frame.

function scr_navigation_path_budget_claim()
{
    var _budget =
        global.vtd_level.navigation.path_budget;

    var _frame =
        global.vtd.tick;

    if (_budget.frame != _frame)
    {
        _budget.frame = _frame;
        _budget.used = 0;
    }

    if (_budget.used >= _budget.maximum)
        return false;

    _budget.used++;

    return true;
}