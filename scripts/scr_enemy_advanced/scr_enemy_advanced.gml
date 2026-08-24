
/// @description Initializes optional advanced enemy runtime systems.

function scr_enemy_advanced_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _data =
        _enemy.enemy_data;

    var _initial_angle =
        _enemy.visual.draw_angle;


    // ========================================================================
    // INDEPENDENT HULL / TURRET ROTATION
    // ========================================================================

    _enemy.visual.hull_angle =
        _initial_angle;

    _enemy.visual.turret_angle =
        _initial_angle;


    // ========================================================================
	// OPTIONAL PLAYER TARGETING
	// ========================================================================

	var _player_data =
	{
	    enabled: false,

	    acquire_range: 0,
	    forget_range_multiplier: 1.3,
	    acquire_chance: 0,

	    require_line_of_sight: true,
	    require_reachable: true
	};


	if (
	    variable_struct_exists(_data.targeting, "player")
	    && is_struct(_data.targeting.player)
	)
	{
	    var _source =
	        _data.targeting.player;

	    var _names =
	        variable_struct_get_names(
	            _source
	        );

	    for (var i = 0; i < array_length(_names); ++i)
	    {
	        variable_struct_set(
	            _player_data,
	            _names[i],
	            variable_struct_get(
	                _source,
	                _names[i]
	            )
	        );
	    }
	}


	_enemy.targeting.player =
	{
	    data: _player_data,
	    active: false,

	    roll:
	    {
	        strategic_target:
	            _enemy.targeting.strategic,

	        completed: false,
	        succeeded: false
	    },

	    follow_repath:
	    {
	        interval_minimum: 0.25,
	        interval_maximum: 0.45,

	        minimum_distance: 32,

	        remaining:
	            random_range(
	                0.25,
	                0.45
	            ),

	        target_x: _enemy.x,
	        target_y: _enemy.y
	    }
	};


	// ========================================================================
	// STRATEGIC BUILDING RETARGETING
	// ========================================================================

	var _strategic_data =
	{
	    enabled: false,

	    interval_minimum: 0.75,
	    interval_maximum: 1.5,

	    minimum_distance_advantage: 64,
	    switch_ratio: 0.85
	};


	if (
	    variable_struct_exists(_data.targeting, "strategic_retarget")
	    && is_struct(_data.targeting.strategic_retarget)
	)
	{
	    var _source =
	        _data.targeting.strategic_retarget;

	    var _names =
	        variable_struct_get_names(
	            _source
	        );

	    for (var i = 0; i < array_length(_names); ++i)
	    {
	        variable_struct_set(
	            _strategic_data,
	            _names[i],
	            variable_struct_get(
	                _source,
	                _names[i]
	            )
	        );
	    }
	}


	_enemy.targeting.strategic_retarget =
	{
	    data: _strategic_data,

	    // Different enemies begin their scans on different frames.

	    remaining:
	        random_range(
	            _strategic_data.interval_minimum,
	            _strategic_data.interval_maximum
	        )
	};


    // ========================================================================
    // COMBAT MOVEMENT
    // ========================================================================

    var _combat_data =
    {
        type:
            EnemyCombatMovement.STATIONARY,

        preferred_range:
            _enemy.attack.range * 0.8,

        minimum_range:
            _enemy.attack.range * 0.55,

        maximum_range:
            _enemy.attack.range,

        anchor_radius: 0,

        speed_multiplier: 1,

        hull_turn_speed: 2,
        turret_turn_speed: 6,

        reposition:
        {
            enabled: false,
            chance: 0,

            interval_minimum: 3,
            interval_maximum: 4,

            distance_minimum: 0,
            distance_maximum: 0,

            candidate_attempts: 4,
            arrival_tolerance: 5,

            require_line_of_sight: false
        }
    };


    if (
        variable_struct_exists(
            _data,
            "combat_movement"
        )
        && is_struct(_data.combat_movement)
    )
    {
        var _source =
            _data.combat_movement;

        var _names =
            variable_struct_get_names(
                _source
            );


        for (
            var i = 0;
            i < array_length(_names);
            ++i
        )
        {
            var _name =
                _names[i];

            if (_name == "reposition")
                continue;

            variable_struct_set(
                _combat_data,
                _name,
                variable_struct_get(
                    _source,
                    _name
                )
            );
        }


        if (
            variable_struct_exists(
                _source,
                "reposition"
            )
            && is_struct(_source.reposition)
        )
        {
            var _reposition_names =
                variable_struct_get_names(
                    _source.reposition
                );


            for (
                var i = 0;
                i < array_length(
                    _reposition_names
                );
                ++i
            )
            {
                var _name =
                    _reposition_names[i];

                variable_struct_set(
                    _combat_data.reposition,
                    _name,
                    variable_struct_get(
                        _source.reposition,
                        _name
                    )
                );
            }
        }
    }


    _enemy.combat_movement =
    {
        data: _combat_data,

        anchor:
        {
            x: _enemy.x,
            y: _enemy.y,

            valid: false,
            target: noone,

            navigation_revision:
                -1
        },

        destination:
        {
            x: _enemy.x,
            y: _enemy.y,
            active: false
        },

        reposition:
        {
            remaining:
                random_range(
                    _combat_data
                        .reposition
                        .interval_minimum,

                    _combat_data
                        .reposition
                        .interval_maximum
                )
        }
    };


    return true;
}