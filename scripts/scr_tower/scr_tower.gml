/// @description Generic data-driven tower targeting, firing, and drawing.

/// @description Creates one tower's consumable magazine runtime.

function scr_tower_consumables_create(_data)
{
    var _runtime = [];

    if (!is_struct(_data))
        return _runtime;

    if (!variable_struct_exists(_data, "consumables"))
        return _runtime;

    if (!is_array(_data.consumables))
        return _runtime;


    for (var i = 0; i < array_length(_data.consumables); ++i)
    {
        var _entry = _data.consumables[i];

        if (!is_struct(_entry))
            continue;

        if (!variable_struct_exists(_entry, "resource_key"))
            continue;

        var _maximum = max(0, _entry.maximum);
        var _starting = clamp(_entry.starting, 0, _maximum);

        array_push(_runtime,
        {
            resource_key: _entry.resource_key,

            current: _starting,
            maximum: _maximum,

            amount_per_attack: max(0, _entry.amount_per_attack),
            request_threshold: clamp(_entry.request_threshold, 0, 1),
            delivery_amount: max(1, _entry.delivery_amount),

            delivery_requested: false
        });
    }


    return _runtime;
}

/// @description Returns one tower consumable entry.

function scr_tower_consumable_get(_tower, _resource_key)
{
    if (!instance_exists(_tower))
        return undefined;

    if (!variable_instance_exists(_tower, "consumables"))
        return undefined;

    if (!is_array(_tower.consumables))
        return undefined;


    for (var i = 0; i < array_length(_tower.consumables); ++i)
    {
        var _entry = _tower.consumables[i];

        if (_entry.resource_key == _resource_key)
            return _entry;
    }


    return undefined;
}

/// @description Initializes one tower after its building parent.

function scr_tower_initialize(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.building_data))
        return false;

    if (!variable_struct_exists(_tower.building_data, "tower"))
        return false;


    var _data = _tower.building_data.tower;
    var _weapon_data = _data.weapon;


    // ========================================================================
    // VISUALS
    // ========================================================================

    _tower.visual.turret_color =
        _tower.building_data.visual.turret_color;

    _tower.visual.draw_angle = 0;
    _tower.visual.draw_function = scr_tower_visual_ground;
	_tower.visual.recoil = scr_tower_recoil_runtime_create(_tower.building_data.visual);

    if (variable_struct_exists(_data, "draw_function"))
        _tower.visual.draw_function = _data.draw_function;

	
	// ========================================================================
	// AIMING
	// ========================================================================

	var _turn_speed_degrees_per_second =
	    360;

	var _fire_angle_tolerance_degrees =
	    3;

	if (
	    variable_struct_exists(
	        _data,
	        "turn_speed_degrees_per_second"
	    )
	)
	{
	    _turn_speed_degrees_per_second =
	        max(
	            0,
	            _data.turn_speed_degrees_per_second
	        );
	}

	if (
	    variable_struct_exists(
	        _data,
	        "fire_angle_tolerance_degrees"
	    )
	)
	{
	    _fire_angle_tolerance_degrees =
	        max(
	            0,
	            _data.fire_angle_tolerance_degrees
	        );
	}

    // ========================================================================
    // TARGETING
    // ========================================================================

    var _requires_line_of_sight = true;
    var _target_filter = TowerTargetFilter.ANY;

    if (variable_struct_exists(_data, "requires_line_of_sight"))
        _requires_line_of_sight = _data.requires_line_of_sight;

    if (variable_struct_exists(_data, "target_filter"))
        _target_filter = _data.target_filter;


    _tower.targeting =
    {
        target: noone,
        mode: _data.target_mode,
        layer: _data.target_layer,
        filter: _target_filter,
        requires_line_of_sight: _requires_line_of_sight,
        aim:
        {
            turn_speed_degrees_per_second:
                _turn_speed_degrees_per_second,

            fire_angle_tolerance_degrees:
                _fire_angle_tolerance_degrees,

            aligned: true
        }
		
    };


    // ========================================================================
    // WEAPON
    // ========================================================================

    var _projectile = undefined;
    var _beam = undefined;
    var _hitscan = undefined;

    if (variable_struct_exists(_weapon_data, "projectile"))
        _projectile = _weapon_data.projectile;

    if (variable_struct_exists(_weapon_data, "beam"))
        _beam = _weapon_data.beam;

    if (variable_struct_exists(_weapon_data, "hitscan"))
        _hitscan = _weapon_data.hitscan;

	var _critical_chance = 0;
    var _critical_multiplier = 1;

    if (
        variable_struct_exists(
            _weapon_data,
            "critical"
        )
        && is_struct(_weapon_data.critical)
    )
    {
        _critical_chance =
            _weapon_data.critical.chance;

        _critical_multiplier =
            _weapon_data.critical.multiplier;
    }

    _tower.combat =
    {
        stats:
        scr_stats_runtime_create(
            {
                range:
                    _data.range,

                weapon_damage:
                    _weapon_data.damage,

                weapon_cooldown_seconds:
                    _weapon_data.cooldown_seconds,

                critical_chance:
                    _critical_chance,

                critical_multiplier:
                    _critical_multiplier
            }
        ),

        range: _data.range,

        weapon:
        {
            type: _weapon_data.type,
            damage_type: _weapon_data.damage_type,
            damage: _weapon_data.damage,
			
			critical:
				{
				    chance:
				        _critical_chance,

				    multiplier:
				        _critical_multiplier
				},

            cooldown:
            {
                duration: _weapon_data.cooldown_seconds,
                remaining: 0
            },

            muzzle:
            {
                mode: _weapon_data.muzzle.mode,
                distance: _weapon_data.muzzle.distance,
                spacing: _weapon_data.muzzle.spacing,
                side: 1
            },

            projectile: _projectile,
            beam: _beam,
            hitscan: _hitscan,

            trace:
            {
                active: false,
                remaining: 0,

                start_x: _tower.x,
                start_y: _tower.y,
                end_x: _tower.x,
                end_y: _tower.y,

                color_outer: c_white,
                color_core: c_white,
                width: 1
            }
        }
    };


    // ========================================================================
    // CONSUMABLE MAGAZINES
    // ========================================================================

    _tower.consumables =
        scr_tower_consumables_create(
            _data
        );


    // ========================================================================
    // INDIVIDUAL TOWER PROGRESSION
    // ========================================================================

    _tower.progression =
    {
        kills: 0,
        experience: 0,
        rank: 1,
        maximum_rank: 10,

        next_experience:
            scr_tower_rank_experience_required(2),

        bonus:
        {
            damage_per_rank: 0.01,
            range_per_rank: 0.005,
            cooldown_per_rank: 0.005
        }
    };


    scr_upgrade_tower_combat_stats_apply(_tower);

    return true;
}

/// @description Turns one tower toward its target using the shortest angle path.
function scr_tower_aim_update(
    _tower,
    _target_x,
    _target_y
)
{
    if (!instance_exists(_tower))
        return false;

    var _aim =
        _tower.targeting.aim;

    var _target_angle =
        point_direction(
            _tower.x,
            _tower.y,
            _target_x,
            _target_y
        );

    var _current_angle =
        _tower.visual.draw_angle;

    // Produces a shortest-path signed difference from -180 to 180.
    // This prevents a turret at 359 degrees from rotating almost a
    // complete circle to reach a target at 1 degree.

    var _angle_difference =
        (
            (
                _target_angle
                - _current_angle
                + 540
            )
            mod 360
        )
        - 180;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _turn_step =
        _aim.turn_speed_degrees_per_second
        / _fps;

    _tower.visual.draw_angle =
        (
            _current_angle
            + clamp(
                _angle_difference,
                -_turn_step,
                _turn_step
            )
            + 360
        )
        mod 360;

    _aim.aligned =
        abs(
            (
                (
                    _target_angle
                    - _tower.visual.draw_angle
                    + 540
                )
                mod 360
            )
            - 180
        )
        <= _aim.fire_angle_tolerance_degrees;

    return true;
}

/// @description Updates one active tower's cooldown, target, aim, and firing.

function scr_tower_update(_tower)
{
    if (!instance_exists(_tower))
        return false;


    scr_tower_recoil_update(
        _tower
    );


    if (
        _tower.BuildingState
        != BuildingState.ACTIVE
    )
    {
        return true;
    }


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    var _weapon =
        _tower.combat.weapon;


    // ========================================================================
    // WEAPON TIMERS
    // ========================================================================

    _weapon.cooldown.remaining =
        max(
            0,
            _weapon.cooldown.remaining
            - (1 / _fps)
        );


    if (_weapon.trace.active)
    {
        _weapon.trace.remaining =
            max(
                0,
                _weapon.trace.remaining
                - (1 / _fps)
            );


        if (_weapon.trace.remaining <= 0)
        {
            _weapon.trace.active =
                false;
        }
    }


    // ========================================================================
    // CHEAP TARGET SAFETY
    // ========================================================================
    //
    // Instance existence remains every frame because aiming and firing
    // dereference the target immediately afterwards.
    //
    // Expensive validity checks are staggered separately.

    if (
        !instance_exists(
            _tower.targeting.target
        )
    )
    {
        _tower.targeting.target =
            noone;
    }


    // ========================================================================
    // PERIODIC CURRENT-TARGET VALIDATION
    // ========================================================================
    //
    // Full validation includes stealth, fog, range, LOS and target filters.
    // There is no need to perform all of that every Step.

    if (
        instance_exists(
            _tower.targeting.target
        )
        && IFRAMES_5
    )
    {
        if (
            !scr_tower_target_valid(
                _tower,
                _tower.targeting.target
            )
        )
        {
            _tower.targeting.target =
                noone;
        }
    }


    // ========================================================================
    // PERIODIC TARGET ACQUISITION / RECONSIDERATION
    // ========================================================================
    //
    // Every tower gets an opportunity approximately every 10 frames to
    // acquire a target or replace its current target with a better one.
    //
    // IFRAMES_10 is staggered by instance id.

    if (IFRAMES_10)
    {
        var _candidate =
            scr_tower_target_acquire(
                _tower
            );


        if (instance_exists(_candidate))
        {
            _tower.targeting.target =
                _candidate;
        }
    }


    // ========================================================================
    // NO TARGET
    // ========================================================================

    if (
        !instance_exists(
            _tower.targeting.target
        )
    )
    {
        _tower.targeting.aim.aligned =
            false;

        return true;
    }


    // ========================================================================
    // AIM
    // ========================================================================

    if (
        !scr_tower_aim_update(
            _tower,
            _tower.targeting.target.x,
            _tower.targeting.target.y
        )
    )
    {
        return false;
    }


    // ========================================================================
    // FIRE
    // ========================================================================

    if (
        _tower.targeting.aim.aligned
        && _weapon.cooldown.remaining <= 0
    )
    {
        scr_tower_fire(
            _tower
        );
    }


    return true;
}

/// @description Returns total experience required to enter a tower rank.

function scr_tower_rank_experience_required(_rank)
{
    switch (_rank)
    {
        case 1:  return 0;
        case 2:  return 10;
        case 3:  return 25;
        case 4:  return 45;
        case 5:  return 70;
        case 6:  return 100;
        case 7:  return 140;
        case 8:  return 190;
        case 9:  return 250;
        case 10: return 325;
    }


    return infinity;
}


/// @description Applies finalized tower combat stats to active combat runtime.
function scr_tower_combat_stats_apply(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.combat))
        return false;

    if (!is_struct(_tower.combat.stats))
        return false;

    if (
        !scr_stats_recalculate(
            _tower.combat.stats
        )
    )
    {
        return false;
    }


    var _stats =
        _tower.combat.stats;


    _tower.combat.range =
        scr_stats_final_get(
            _stats,
            "range",
            0
        );

    _tower.combat.weapon.damage =
        scr_stats_final_get(
            _stats,
            "weapon_damage",
            0
        );

    _tower.combat.weapon.cooldown.duration =
        scr_stats_final_get(
            _stats,
            "weapon_cooldown_seconds",
            0.01
        );
		
		  _tower.combat.weapon.critical.chance =
        scr_stats_final_get(
            _stats,
            "critical_chance",
            0
        );

    _tower.combat.weapon.critical.multiplier =
        scr_stats_final_get(
            _stats,
            "critical_multiplier",
            1
        );

    return true;
}

/// @description Rebuilds local veteran/foundation modifiers and applies combat stats.
function scr_tower_progression_stats_apply(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "progression"))
        return false;

    if (!is_struct(_tower.combat.stats))
        return false;


    var _veteran_levels =
        max(
            0,
            _tower.progression.rank - 1
        );

    var _damage_multiplier =
        1
        + (
            _veteran_levels
            * _tower.progression.bonus.damage_per_rank
        );

    var _range_multiplier =
        1
        + (
            _veteran_levels
            * _tower.progression.bonus.range_per_rank
        );

    var _cooldown_multiplier =
        max(
            0.5,
            1
            - (
                _veteran_levels
                * _tower.progression.bonus.cooldown_per_rank
            )
        );


    // The old foundation effect accelerated cooldown countdown directly.
    // Dividing its duration by that multiplier gives the same fire rate,
    // while keeping all combat results in the stat pipeline.

    var _foundation_fire_rate =
        1;

    if (
        variable_struct_exists(
            _tower.foundation,
            "tower_fire_rate_multiplier"
        )
    )
    {
        _foundation_fire_rate =
            max(
                0.01,
                _tower.foundation
                    .tower_fire_rate_multiplier
            );
    }


    var _local =
        _tower.combat.stats.local.multiplier;

    _local.weapon_damage =
        _damage_multiplier;

    _local.range =
        _range_multiplier;

    _local.weapon_cooldown_seconds =
        _cooldown_multiplier
        / _foundation_fire_rate;


    return scr_tower_combat_stats_apply(
        _tower
    );
}

/// @description Grants experience and processes tower rank promotions.

function scr_tower_experience_add(_tower, _amount)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "progression"))
        return false;

    if (_amount <= 0)
        return true;


    var _progression =
        _tower.progression;

    _progression.experience += _amount;


    while (_progression.rank < _progression.maximum_rank)
    {
        var _next_rank =
            _progression.rank + 1;

        var _requirement =
            scr_tower_rank_experience_required(
                _next_rank
            );

        if (_progression.experience < _requirement)
            break;


        _progression.rank =
            _next_rank;

        scr_tower_progression_stats_apply(
            _tower
        );


        scr_hud_alert_push(
            HudAlertType.SUCCESS,
            "TOWER PROMOTED",
            string_upper(_tower.identity.name)
            + " REACHED RANK "
            + string(_progression.rank),
            2.5
        );


        show_debug_message(
            "TOWER RANK UP: "
            + _tower.identity.name
            + " | RANK "
            + string(_progression.rank)
        );
    }


    _progression.next_experience =
        scr_tower_rank_experience_required(
            min(
                _progression.maximum_rank,
                _progression.rank + 1
            )
        );


    return true;
}