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

function scr_point_istance_squared(
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

/// @description Finds an enemy crossed by one player-projectile segment.

function scr_projectile_player_enemy_find(
    _projectile,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    if (!instance_exists(_projectile))
        return undefined;


    return scr_spatial_enemy_segment_find(
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        _projectile.visual.radius
    );
}

/// @description Updates one player projectile with spatial swept collision.

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


    // One spatial query for the complete movement segment.

    var _enemy_hit =
        scr_projectile_player_enemy_find(
            _projectile,
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );

    var _enemy_hit_amount =
        infinity;


    if (is_struct(_enemy_hit))
    {
        _enemy_hit_amount =
            _enemy_hit.amount;
    }


    // Solid collision remains stepped because walls intentionally allow
    // player projectiles through while other gameplay solids stop them.

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
                / max(
                    1,
                    _projectile.visual.radius
                )
            )
        );


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
            // terrain impact particles
            // ricochet weapons
            // destructible terrain

            instance_destroy(_projectile);
            return true;
        }


        if (
            is_struct(_enemy_hit)
            && _enemy_hit_amount <= _progress
        )
        {
            var _enemy =
                _enemy_hit.enemy;


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
            }


            // FUTURE:
            // enemy impact particles
            // piercing ammunition
            // explosive player weapons

            instance_destroy(_projectile);
            return true;
        }
    }


    _projectile.x =
        _end_x;

    _projectile.y =
        _end_y;


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