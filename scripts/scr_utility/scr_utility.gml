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
                max(0.05, _source.interval_seconds),

            remaining:
                random_range(
                    0,
                    max(0.05, _source.interval_seconds)
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
        }
    };


    if (
        variable_struct_exists(
            _source,
            "resource_key"
        )
    )
    {
        _utility.utility.magnet.resource_key =
            _source.resource_key;
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


    _runtime.interval.remaining =
        max(
            0,
            _runtime.interval.remaining - _delta
        );

    _runtime.feedback.remaining =
        max(
            0,
            _runtime.feedback.remaining - _delta
        );


    if (_runtime.interval.remaining > 0)
        return true;


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


/// @description Repairs the most damaged nearby structure.

function scr_utility_repairer_update(_utility)
{
    var _runtime =
        _utility.utility;

    var _target =
        noone;

    var _lowest_integrity =
        1;

    var _building_count =
        instance_number(o_building_par);


    for (var i = 0; i < _building_count; ++i)
    {
        var _building =
            instance_find(o_building_par, i);

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


    if (!instance_exists(_target))
    {
        _runtime.target = noone;
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


    _runtime.target =
        _target;

    _runtime.feedback.remaining =
        _runtime.feedback.duration;


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
            scr_utility_credit_magnet_draw(_utility);
        break;

        case UtilityType.REPAIRER:
            scr_utility_repairer_draw(_utility);
        break;

        case UtilityType.CREDIT_UPLINK:
            scr_utility_credit_uplink_draw(_utility);
        break;
    }


    return true;
}


/// @description Draws the Credit Magnet's vector assembly.

function scr_utility_credit_magnet_draw(_utility)
{
    var _pulse =
        0.75
        + sin(
            global.vtd.tick * 5
            + real(_utility.id)
        ) * 0.2;

    var _color =
        make_color_rgb(
            190,
            70,
            255
        );


    draw_set_color(_color);

    draw_circle(
        _utility.x,
        _utility.y,
        17,
        false
    );

    scr_draw_arc(
    _utility.x - 9,
    _utility.y,
    9,
    90,
    270
	);

	scr_draw_arc(
	    _utility.x + 9,
	    _utility.y,
	    9,
	    270,
	    90
	);


    draw_line_width(
        _utility.x - 9,
        _utility.y + 9,
        _utility.x - 9,
        _utility.y + 20,
        3
    );

    draw_line_width(
        _utility.x + 9,
        _utility.y + 9,
        _utility.x + 9,
        _utility.y + 20,
        3
    );


    draw_set_alpha(_pulse);
    draw_circle(
        _utility.x,
        _utility.y,
        5,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @description Draws the Restoration Array and its active repair beam.

function scr_utility_repairer_draw(_utility)
{
    var _runtime =
        _utility.utility;

    var _color =
        make_color_rgb(
            80,
            255,
            150
        );


    draw_set_color(_color);

    draw_circle(
        _utility.x,
        _utility.y,
        16,
        false
    );

    draw_line_width(
        _utility.x - 11,
        _utility.y,
        _utility.x + 11,
        _utility.y,
        4
    );

    draw_line_width(
        _utility.x,
        _utility.y - 11,
        _utility.x,
        _utility.y + 11,
        4
    );


    if (
        _runtime.feedback.remaining > 0
        && instance_exists(_runtime.target)
    )
    {
        var _alpha =
            _runtime.feedback.remaining
            / max(
                0.001,
                _runtime.feedback.duration
            );

        draw_set_alpha(_alpha);

        draw_line_width(
            _utility.x,
            _utility.y,
            _runtime.target.x,
            _runtime.target.y,
            2
        );

        draw_circle(
            _runtime.target.x,
            _runtime.target.y,
            10 + ((1 - _alpha) * 14),
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @description Draws the passive Credit Uplink.

function scr_utility_credit_uplink_draw(_utility)
{
    var _runtime =
        _utility.utility;

    var _pulse =
        0.6
        + sin(
            global.vtd.tick * 4
            + real(_utility.id)
        ) * 0.25;


    draw_set_color(c_yellow);

    draw_rectangle(
        _utility.x - 17,
        _utility.y - 12,
        _utility.x + 17,
        _utility.y + 12,
        true
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x,
        _utility.y + 12
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x - 9,
        _utility.y - 29
    );

    draw_line(
        _utility.x,
        _utility.y - 20,
        _utility.x + 9,
        _utility.y - 29
    );


    draw_set_alpha(_pulse);

    draw_circle(
        _utility.x,
        _utility.y,
        6,
        true
    );


    if (_runtime.feedback.remaining > 0)
    {
        var _radius =
            12
            + (
                1
                - _runtime.feedback.remaining
                / max(
                    0.001,
                    _runtime.feedback.duration
                )
            ) * 18;

        draw_circle(
            _utility.x,
            _utility.y,
            _radius,
            false
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
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