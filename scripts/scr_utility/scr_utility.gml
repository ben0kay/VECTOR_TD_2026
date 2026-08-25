/// @description Active data-driven utility-building behaviour.

/// @description Initializes one utility building.

function scr_utility_initialize(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _data =
        _utility.building_data;


    if (
        !variable_struct_exists(_data, "utility")
        || !is_struct(_data.utility)
    )
    {
        return false;
    }


    var _source =
        _data.utility;


    _utility.UtilityType =
        _source.type;


    _utility.utility =
    {
        range:
            max(0, _source.range),

        interval:
        {
            duration:
                max(
                    0.05,
                    _source.interval_seconds
                ),

            remaining:
                random_range(
                    0,
                    max(
                        0.05,
                        _source.interval_seconds
                    )
                )
        },

        amount:
            max(0, _source.amount),

        target:
            noone,

        feedback:
        {
            remaining: 0,
            duration: 0.3
        },

        magnet:
        {
            resource_key:
                "resource_credits",

            claimed_last:
                0
        },

        radar:
        {
            reveal_seconds: 0,
            sweep_angle: 0,
            sweep_degrees_per_second: 0,

            detected_last: 0,

            color:
                c_aqua,

            pulse:
            {
                active: false,
                progress: 0,
                duration: 0.65
            }
        }
    };


    // ========================================================================
    // CREDIT MAGNET
    // ========================================================================

    if (variable_struct_exists(_source, "resource_key"))
    {
        _utility.utility.magnet.resource_key =
            _source.resource_key;
    }


    // ========================================================================
    // RADAR
    // ========================================================================

    if (
        _utility.UtilityType == UtilityType.RADAR
        && variable_struct_exists(_source, "radar")
        && is_struct(_source.radar)
    )
    {
        var _radar_data =
            _source.radar;

        var _radar =
            _utility.utility.radar;


        _radar.reveal_seconds =
            max(
                0.1,
                _radar_data.reveal_seconds
            );

        _radar.sweep_degrees_per_second =
            _radar_data.sweep_degrees_per_second;

        _radar.pulse.duration =
            max(
                0.1,
                _radar_data.pulse_duration_seconds
            );

        _radar.color =
            _radar_data.color;
    }


    return true;
}

/// @description Processes the configured utility behaviour.

function scr_utility_update(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _runtime =
        _utility.utility;

    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    // ========================================================================
    // RADAR VISUAL RUNTIME
    // ========================================================================

    if (_utility.UtilityType == UtilityType.RADAR)
    {
        var _radar =
            _runtime.radar;


        _radar.sweep_angle =
            (
                _radar.sweep_angle
                + (
                    _radar.sweep_degrees_per_second
                    * _delta
                )
            )
            mod 360;


        if (_radar.pulse.active)
        {
            _radar.pulse.progress +=
                _delta
                / max(
                    0.01,
                    _radar.pulse.duration
                );


            if (_radar.pulse.progress >= 1)
            {
                _radar.pulse.progress = 1;
                _radar.pulse.active = false;
            }
        }
    }


    // ========================================================================
    // GENERAL TIMERS
    // ========================================================================

    _runtime.interval.remaining =
        max(
            0,
            _runtime.interval.remaining
            - _delta
        );

    _runtime.feedback.remaining =
        max(
            0,
            _runtime.feedback.remaining
            - _delta
        );


    if (_runtime.interval.remaining > 0)
        return true;


    // ========================================================================
    // UTILITY ACTION
    // ========================================================================

    switch (_utility.UtilityType)
    {
        case UtilityType.CREDIT_MAGNET:
            scr_utility_credit_magnet_update(_utility);
        break;


        case UtilityType.REPAIRER:
            scr_utility_repairer_update(_utility);
        break;


        case UtilityType.CREDIT_UPLINK:
            scr_utility_credit_uplink_update(_utility);
        break;


        case UtilityType.RADAR:
            scr_utility_radar_update(_utility);
        break;
    }


    _runtime.interval.remaining =
        _runtime.interval.duration;


    return true;
}


/// @description Claims nearby matching pickups for one Credit Magnet pulse.

function scr_utility_credit_magnet_update(_utility)
{
    var _runtime =
        _utility.utility;

    var _pickup_count =
        instance_number(o_pickup);

    var _eligible = [];


    for (var i = 0; i < _pickup_count; ++i)
    {
        var _pickup =
            instance_find(o_pickup, i);

        if (!instance_exists(_pickup))
            continue;

        if (_pickup.collection.collected)
            continue;

        if (
            _pickup.identity.resource_key
            != _runtime.magnet.resource_key
        )
        {
            continue;
        }


        var _attractor =
            _pickup.collection.attractor;

        if (
            instance_exists(_attractor)
            && _attractor != _utility
        )
        {
            continue;
        }


        if (
            point_distance(
                _utility.x,
                _utility.y,
                _pickup.x,
                _pickup.y
            )
            > _runtime.range
        )
        {
            continue;
        }


        array_push(
            _eligible,
            _pickup
        );
    }


    if (array_length(_eligible) <= 0)
        return false;


    if (!scr_energy_activity_consume(_utility))
        return false;


    for (var i = 0; i < array_length(_eligible); ++i)
    {
        var _pickup =
            _eligible[i];

        if (!instance_exists(_pickup))
            continue;

        _pickup.collection.attractor =
            _utility;

        _pickup.life.remaining_seconds =
            max(
                _pickup.life.remaining_seconds,
                10
            );
    }


    _runtime.magnet.claimed_last =
        array_length(_eligible);

    _runtime.feedback.remaining =
        _runtime.feedback.duration;


    scr_effect_shockwave_create(
        _utility.x,
        _utility.y,
        _runtime.range,
        make_color_rgb(190, 70, 255),
        EnemyMovementLayer.GROUND
    );


    return true;
}


/// @description Repairs the most damaged nearby structure, including the CPU.

function scr_utility_repairer_update(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _runtime =
        _utility.utility;

    var _target =
        noone;

    var _lowest_integrity =
        1;


    // ========================================================================
    // BUILDING TARGETS
    // ========================================================================

    var _building_count =
        instance_number(o_building_par);


    for (var i = 0; i < _building_count; ++i)
    {
        var _building =
            instance_find(
                o_building_par,
                i
            );

        if (!instance_exists(_building))
            continue;

        if (_building == _utility)
            continue;

        if (_building.BuildingState == BuildingState.DESTROYED)
            continue;

        if (_building.BuildingState == BuildingState.CONSTRUCTING)
            continue;


        var _hp =
            _building.vitals.hp;

        if (_hp.current >= _hp.maximum)
            continue;

        if (
            point_distance(
                _utility.x,
                _utility.y,
                _building.x,
                _building.y
            )
            > _runtime.range
        )
        {
            continue;
        }


        var _integrity =
            _hp.current
            / max(1, _hp.maximum);


        if (_integrity < _lowest_integrity)
        {
            _target =
                _building;

            _lowest_integrity =
                _integrity;
        }
    }


    // ========================================================================
    // CPU TARGET
    // ========================================================================

    var _cpu =
        global.vtd_level.entities.cpu;


    if (instance_exists(_cpu))
    {
        var _cpu_hp =
            _cpu.vitals.hp;

        var _cpu_in_range =
            point_distance(
                _utility.x,
                _utility.y,
                _cpu.x,
                _cpu.y
            )
            <= _runtime.range;


        if (
            _cpu_in_range
            && _cpu_hp.current > 0
            && _cpu_hp.current < _cpu_hp.maximum
        )
        {
            var _cpu_integrity =
                _cpu_hp.current
                / max(1, _cpu_hp.maximum);


            if (_cpu_integrity < _lowest_integrity)
            {
                _target =
                    _cpu;

                _lowest_integrity =
                    _cpu_integrity;
            }
        }
    }


    // ========================================================================
    // REPAIR
    // ========================================================================

    if (!instance_exists(_target))
    {
        _runtime.target =
            noone;

        return false;
    }


    if (!scr_energy_activity_consume(_utility))
        return false;


    _target.vitals.hp.current =
        min(
            _target.vitals.hp.maximum,
            _target.vitals.hp.current
            + _runtime.amount
        );


    // Cache the target for the temporary repair beam.

    _runtime.target =
        _target;

    _runtime.feedback.remaining =
        _runtime.feedback.duration;


    // Subtle repair particles appear only on a successful repair pulse.

    scr_particles_repair(
        _utility.x,
        _utility.y,
        _target.x,
        _target.y
    );


    return true;
}


/// @description Generates one fixed passive-credit payment.

function scr_utility_credit_uplink_update(_utility)
{
    var _runtime =
        _utility.utility;


    if (!scr_energy_activity_consume(_utility))
        return false;


    var _accepted =
        scr_resource_amount_add(
            "resource_credits",
            _runtime.amount
        );


    if (_accepted <= 0)
        return false;


    global.vtd_level.combat.credits_earned +=
        _accepted;


    scr_hud_resource_gain_push(
        "resource_credits",
        _accepted
    );


    _runtime.feedback.remaining =
        _runtime.feedback.duration;


    return true;
}

/// @description Draws the configured utility assembly.

function scr_utility_draw(_utility)
{
    if (!instance_exists(_utility))
        return false;


    switch (_utility.UtilityType)
    {
        case UtilityType.CREDIT_MAGNET:
            return scr_utility_credit_magnet_draw(_utility);


        case UtilityType.REPAIRER:
            return scr_utility_repairer_draw(_utility);


        case UtilityType.CREDIT_UPLINK:
            return scr_utility_credit_uplink_draw(_utility);


        case UtilityType.RADAR:
            return scr_utility_radar_draw(_utility);
    }


    return false;
}

/// @description Emits one powered scan and reveals nearby cloaked enemies.

function scr_utility_radar_update(_utility)
{
    if (!instance_exists(_utility))
        return false;


    var _runtime =
        _utility.utility;

    var _radar =
        _runtime.radar;


    // Every scan consumes activity energy, even if no cloaked enemy is found.

    if (!scr_energy_activity_consume(_utility))
        return false;


    _radar.detected_last = 0;


    var _enemy_count =
        instance_number(o_enemy);


    for (var i = 0; i < _enemy_count; ++i)
    {
        var _enemy =
            instance_find(
                o_enemy,
                i
            );


        if (!instance_exists(_enemy))
            continue;

        if (_enemy.EnemyState == EnemyState.DEAD)
            continue;

        if (!scr_enemy_stealth_available(_enemy))
            continue;


        if (
            point_distance(
                _utility.x,
                _utility.y,
                _enemy.x,
                _enemy.y
            )
            > _runtime.range
            + _enemy.visual.radius
        )
        {
            continue;
        }


        if (
            scr_enemy_stealth_reveal(
                _enemy,
                _radar.reveal_seconds
            )
        )
        {
            _radar.detected_last++;
        }
    }


    // Restart the expanding visual scan ring.

    _radar.pulse.active = true;
    _radar.pulse.progress = 0;

    _runtime.feedback.remaining =
        _runtime.feedback.duration;


    // FUTURE:
    // radar scan particles
    // scan sound
    // fog-of-war exploration
    // underground detection
    // enemy classification upgrades
    // radar jamming


    return true;
}

/// @description Clears references owned by one utility building.

function scr_utility_cleanup(_utility)
{
    if (!instance_exists(_utility))
        return false;


    // Release pickups claimed by a destroyed Credit Magnet.

    if (_utility.UtilityType == UtilityType.CREDIT_MAGNET)
    {
        var _pickup_count =
            instance_number(o_pickup);

        for (var i = 0; i < _pickup_count; ++i)
        {
            var _pickup =
                instance_find(o_pickup, i);

            if (
                instance_exists(_pickup)
                && _pickup.collection.attractor
                    == _utility
            )
            {
                _pickup.collection.attractor =
                    noone;
            }
        }
    }


    return true;
}