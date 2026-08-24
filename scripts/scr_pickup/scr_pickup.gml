/// @description Creates one physical resource pickup.

function scr_pickup_create(
    _world_x,
    _world_y,
    _resource_key,
    _amount
)
{
    if (!is_string(_resource_key))
        return noone;

    if (_resource_key == "")
        return noone;

    if (_amount <= 0)
        return noone;


    return instance_create_layer(
        _world_x,
        _world_y,
        "Effects_Ground",
        o_pickup,
        {
            pickup_resource_key: _resource_key,
            pickup_amount: _amount
        }
    );
}


/// @description Initializes one physical pickup.

function scr_pickup_initialize(_pickup)
{
    if (!instance_exists(_pickup))
        return false;

    if (!variable_instance_exists(_pickup, "pickup_resource_key"))
        return false;

    if (!variable_instance_exists(_pickup, "pickup_amount"))
        return false;


    var _resource_data =
        scr_resource_data_get(
            _pickup.pickup_resource_key
        );

    if (!scr_resource_data_valid(_resource_data))
        return false;


    _pickup.identity =
    {
        resource_key:
            _pickup.pickup_resource_key
    };


    _pickup.value =
    {
        amount:
            max(0, _pickup.pickup_amount)
    };


    _pickup.collection =
    {
        collected: false,

        magnet_range: 128,
        collection_range: 22,
        magnet_strength: 0.09
    };


    _pickup.life =
    {
        remaining_seconds: 20,
        flash_seconds: 4
    };


    _pickup.visual =
    {
        color: _resource_data.visual.color,
        radius: 2,

        hover_time:
            random(360),

        rotation:
            random(360)
    };


    return true;
}


/// @description Awards and removes one collected pickup.

function scr_pickup_collect(
    _pickup,
    _collector
)
{
    if (!instance_exists(_pickup))
        return false;

    if (_pickup.collection.collected)
        return false;


    var _accepted =
        scr_resource_amount_add(
            _pickup.identity.resource_key,
            _pickup.value.amount
        );


    if (_accepted <= 0)
        return false;


    _pickup.collection.collected = true;


    scr_hud_resource_gain_push(
        _pickup.identity.resource_key,
        _accepted
    );


    // FUTURE:
    // collection sound
    // collection beam
    // floating world text
    // player pickup statistics
    // automatic credit-magnet buildings


    instance_destroy(_pickup);

    return true;
}


/// @description Updates attraction, collection and expiration.

function scr_pickup_update(_pickup)
{
    if (!instance_exists(_pickup))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    _pickup.life.remaining_seconds =
        max(
            0,
            _pickup.life.remaining_seconds
            - _delta
        );


    if (_pickup.life.remaining_seconds <= 0)
    {
        instance_destroy(_pickup);
        return true;
    }


    _pickup.visual.hover_time +=
        5;

    _pickup.visual.rotation +=
        2;


    var _player =
        global.vtd_level.entities.player;


    if (!instance_exists(_player))
        return true;

    if (_player.PlayerState == PlayerState.DEAD)
        return true;


    var _distance =
        point_distance(
            _pickup.x,
            _pickup.y,
            _player.x,
            _player.y
        );


    if (_distance <= _pickup.collection.collection_range)
    {
        scr_pickup_collect(
            _pickup,
            _player
        );

        return true;
    }


    if (_distance <= _pickup.collection.magnet_range)
    {
        _pickup.x =
            lerp(
                _pickup.x,
                _player.x,
                _pickup.collection.magnet_strength
            );

        _pickup.y =
            lerp(
                _pickup.y,
                _player.y,
                _pickup.collection.magnet_strength
            );
    }


    return true;
}


/// @description Draws one primitive vector pickup.

function scr_pickup_draw(_pickup)
{
    if (!instance_exists(_pickup))
        return false;


    var _life =
        _pickup.life;

    var _alpha = 1;


    if (
        _life.remaining_seconds
        <= _life.flash_seconds
    )
    {
        _alpha =
            (
                floor(global.vtd.tick / 5)
                mod 2
            )
            ? 0.25
            : 1;
    }


    var _draw_y =
        _pickup.y
        + sin(_pickup.visual.hover_time)
        * 1;

    var _radius =
        _pickup.visual.radius;

    var _angle =
        _pickup.visual.rotation;


    draw_set_alpha(_alpha);
    draw_set_color(_pickup.visual.color);


    for (var i = 0; i < 4; ++i)
    {
        var _first_angle =
            _angle
            + (i * 90);

        var _second_angle =
            _angle
            + ((i + 1) * 90);

        draw_line_width(
            _pickup.x
                + lengthdir_x(
                    _radius,
                    _first_angle
                ),

            _draw_y
                + lengthdir_y(
                    _radius,
                    _first_angle
                ),

            _pickup.x
                + lengthdir_x(
                    _radius,
                    _second_angle
                ),

            _draw_y
                + lengthdir_y(
                    _radius,
                    _second_angle
                ),

            2
        );
    }


    draw_circle(
        _pickup.x,
        _draw_y,
        3,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}