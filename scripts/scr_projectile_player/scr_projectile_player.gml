/// @description Player projectile creation, collision, and drawing.


/// @description Creates one player projectile.

function scr_projectile_player_create(
    _owner,
    _world_x,
    _world_y,
    _draw_angle,
    _damage,
    _projectile_data
)
{
    if (!instance_exists(_owner))
        return noone;

    if (!is_struct(_projectile_data))
        return noone;


    return instance_create_layer(
        _world_x,
        _world_y,
        "Projectiles_Ground",
        o_projectile_player,
        {
            owner:
                _owner,

            projectile_damage:
                _damage,

            projectile_speed:
                _projectile_data.speed,

            projectile_lifetime:
                _projectile_data
                    .lifetime_seconds,

            projectile_radius:
                _projectile_data.radius,

            projectile_color:
                _projectile_data.color,

            projectile_angle:
                _draw_angle
        }
    );
}


/// @description Initializes one player projectile.

function scr_projectile_player_initialize(
    _projectile
)
{
    if (!instance_exists(_projectile))
        return false;


    var _required_variables =
    [
        "owner",
        "projectile_damage",
        "projectile_speed",
        "projectile_lifetime",
        "projectile_radius",
        "projectile_color",
        "projectile_angle"
    ];


    for (
        var i = 0;
        i < array_length(
            _required_variables
        );
        ++i
    )
    {
        if (
            !variable_instance_exists(
                _projectile,
                _required_variables[i]
            )
        )
        {
            return false;
        }
    }


    _projectile.combat =
    {
        owner:
            _projectile.owner,

        damage:
            _projectile.projectile_damage
    };


    _projectile.movement =
    {
        speed:
            _projectile.projectile_speed
    };


    _projectile.life =
    {
        remaining:
            _projectile.projectile_lifetime
    };


    _projectile.visual =
    {
        draw_angle:
            _projectile.projectile_angle,

        radius:
            _projectile.projectile_radius,

        color:
            _projectile.projectile_color
    };


    return true;
}


/// @description Returns the squared distance from a point to a line segment.

function scr_point_segment_distance_squared(
    _point_x,
    _point_y,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    var _segment_x =
        _end_x - _start_x;

    var _segment_y =
        _end_y - _start_y;

    var _length_squared =
        (_segment_x * _segment_x)
        + (_segment_y * _segment_y);


    if (_length_squared <= 0)
    {
        var _difference_x =
            _point_x - _start_x;

        var _difference_y =
            _point_y - _start_y;


        return (
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y)
        );
    }


    var _amount =
        (
            ((_point_x - _start_x) * _segment_x)
            + ((_point_y - _start_y) * _segment_y)
        )
        / _length_squared;


    _amount =
        clamp(
            _amount,
            0,
            1
        );


    var _closest_x =
        _start_x
        + (_segment_x * _amount);

    var _closest_y =
        _start_y
        + (_segment_y * _amount);


    var _distance_x =
        _point_x - _closest_x;

    var _distance_y =
        _point_y - _closest_y;


    return (
        (_distance_x * _distance_x)
        + (_distance_y * _distance_y)
    );
}


/// @description Finds an enemy crossed by one projectile movement segment.

function scr_projectile_player_enemy_find(
    _projectile,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    if (!instance_exists(_projectile))
        return noone;


    var _enemy_count =
        instance_number(
            o_enemy
        );

    var _closest_enemy =
        noone;

    var _closest_distance =
        infinity;


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

        if (
            _enemy.EnemyState
            == EnemyState.DEAD
        )
        {
            continue;
        }


        var _collision_radius =
            _projectile.visual.radius
            + _enemy.visual.radius;

        var _distance_squared =
            scr_point_segment_distance_squared(
                _enemy.x,
                _enemy.y,
                _start_x,
                _start_y,
                _end_x,
                _end_y
            );


        if (
            _distance_squared
            > _collision_radius
                * _collision_radius
        )
        {
            continue;
        }


        var _travel_distance =
            point_distance(
                _start_x,
                _start_y,
                _enemy.x,
                _enemy.y
            );


        if (
            _travel_distance
            < _closest_distance
        )
        {
            _closest_distance =
                _travel_distance;

            _closest_enemy =
                _enemy;
        }
    }


    return _closest_enemy;
}

/// @description Updates one player projectile with ordered solid collision.

function scr_projectile_player_update(_projectile)
{
    if (!instance_exists(_projectile))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _projectile.life.remaining =
        max(
            0,
            _projectile.life.remaining
            - (1 / _fps)
        );


    if (_projectile.life.remaining <= 0)
    {
        instance_destroy(_projectile);
        return true;
    }


    var _start_x =
        _projectile.x;

    var _start_y =
        _projectile.y;

    var _end_x =
        _start_x
        + lengthdir_x(
            _projectile.movement.speed,
            _projectile.visual.draw_angle
        );

    var _end_y =
        _start_y
        + lengthdir_y(
            _projectile.movement.speed,
            _projectile.visual.draw_angle
        );


    var _distance =
        point_distance(
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );

    var _steps =
        max(
            1,
            ceil(
                _distance
                / max(1, _projectile.visual.radius)
            )
        );


    var _previous_x = _start_x;
    var _previous_y = _start_y;


    for (var i = 1; i <= _steps; ++i)
    {
        var _progress =
            i / _steps;

        var _check_x =
            lerp(
                _start_x,
                _end_x,
                _progress
            );

        var _check_y =
            lerp(
                _start_y,
                _end_y,
                _progress
            );


        // Ordinary buildings, CPU and terrain block player shots.
        // Basic walls intentionally allow player projectiles through.

        if (
            scr_world_circle_gameplay_solid(
                _check_x,
                _check_y,
                _projectile.visual.radius,
                false
            )
        )
        {
            // FUTURE:
            // solid impact sparks
            // terrain hit particles
            // ricochet weapons

            instance_destroy(_projectile);
            return true;
        }


        var _enemy =
            scr_projectile_player_enemy_find(
                _projectile,
                _previous_x,
                _previous_y,
                _check_x,
                _check_y
            );


        if (instance_exists(_enemy))
        {
            var _damage =
                scr_damage_create(
                    _projectile.combat.damage,
                    _projectile.combat.owner,
                    DamageSource.PLAYER
                );


            scr_enemy_damage(
                _enemy,
                _damage
            );


            // FUTURE:
            // enemy impact effect
            // piercing projectiles
            // explosive player weapons

            instance_destroy(_projectile);
            return true;
        }


        _previous_x = _check_x;
        _previous_y = _check_y;
    }


    _projectile.x = _end_x;
    _projectile.y = _end_y;


    return true;
}

/// @description Draws one player projectile.

function scr_projectile_player_draw(
    _projectile
)
{
    if (!instance_exists(_projectile))
        return false;


    var _visual =
        _projectile.visual;


    var _trail_x =
        _projectile.x
        - lengthdir_x(
            12,
            _visual.draw_angle
        );

    var _trail_y =
        _projectile.y
        - lengthdir_y(
            12,
            _visual.draw_angle
        );


    draw_set_color(
        _visual.color
    );

    draw_line_width(
        _trail_x,
        _trail_y,
        _projectile.x,
        _projectile.y,
        3
    );

    draw_circle(
        _projectile.x,
        _projectile.y,
        _visual.radius,
        false
    );


    draw_set_color(
        c_white
    );


    return true;
}