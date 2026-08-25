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

    if (variable_struct_exists(_data, "draw_function"))
        _tower.visual.draw_function = _data.draw_function;


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
        requires_line_of_sight: _requires_line_of_sight
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


    _tower.combat =
    {
        base:
        {
            range: _data.range,
            damage: _weapon_data.damage,
            cooldown_seconds: _weapon_data.cooldown_seconds
        },

        range: _data.range,

        weapon:
        {
            type: _weapon_data.type,
            damage_type: _weapon_data.damage_type,
            damage: _weapon_data.damage,

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


    scr_tower_progression_stats_apply(_tower);

    return true;
}



function scr_tower_update(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (_tower.BuildingState != BuildingState.ACTIVE)
        return true;

    var _fps = max(1, game_get_speed(gamespeed_fps));
    var _weapon = _tower.combat.weapon;


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
	        _tower.foundation
	            .tower_fire_rate_multiplier;
	}


	_weapon.cooldown.remaining =
	    max(
	        0,
	        _weapon.cooldown.remaining
	        - (
	            (1 / _fps)
	            * _foundation_fire_rate
	        )
	    );


    if (_weapon.trace.active)
    {
        _weapon.trace.remaining =
            max(
                0,
                _weapon.trace.remaining - (1 / _fps)
            );

        if (_weapon.trace.remaining <= 0)
            _weapon.trace.active = false;
    }


    if (!scr_tower_target_valid(_tower, _tower.targeting.target))
        _tower.targeting.target = noone;


    // Searches remain staggered between tower instances.

    if (
        !instance_exists(_tower.targeting.target)
        && IFRAMES_5
    )
    {
        _tower.targeting.target =
            scr_tower_target_acquire(_tower);
    }


    if (!instance_exists(_tower.targeting.target))
        return true;


    _tower.visual.draw_angle =
        point_direction(
            _tower.x,
            _tower.y,
            _tower.targeting.target.x,
            _tower.targeting.target.y
        );


    if (_weapon.cooldown.remaining <= 0)
        scr_tower_fire(_tower);


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

/// @description Recalculates one tower's small veteran stat bonuses.

function scr_tower_progression_stats_apply(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "progression"))
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


    _tower.combat.weapon.damage =
        _tower.combat.base.damage
        * _damage_multiplier;

    _tower.combat.range =
        _tower.combat.base.range
        * _range_multiplier;

    _tower.combat.weapon.cooldown.duration =
        _tower.combat.base.cooldown_seconds
        * _cooldown_multiplier;


    return true;
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