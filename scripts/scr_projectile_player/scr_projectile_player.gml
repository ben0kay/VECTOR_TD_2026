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


    // ========================================================================
    // COLLISION MASK
    // ========================================================================

    _projectile.mask_index =
        s_collision_circle;

    var _collision_scale =
        _projectile.visual.radius
        / 16;

    _projectile.image_xscale =
        _collision_scale;

    _projectile.image_yscale =
        _collision_scale;


    return true;
}


/// @description Updates one player projectile.

function scr_projectile_player_update(_projectile)
{
    if (!instance_exists(_projectile))
        return false;

    var _fps = max(1, game_get_speed(gamespeed_fps));

    _projectile.life.remaining =
        max(0, _projectile.life.remaining - (1 / _fps));

    if (_projectile.life.remaining <= 0)
    {
        instance_destroy(_projectile);
        return true;
    }

    _projectile.x +=
        lengthdir_x(
            _projectile.movement.speed,
            _projectile.visual.draw_angle
        );

    _projectile.y +=
        lengthdir_y(
            _projectile.movement.speed,
            _projectile.visual.draw_angle
        );

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