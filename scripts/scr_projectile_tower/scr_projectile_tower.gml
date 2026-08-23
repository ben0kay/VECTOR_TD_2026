/// @description Tower projectile creation, collision, impact, and drawing.

/// @description Creates one layer-restricted tower projectile.

function scr_projectile_tower_create(
    _owner,
    _world_x,
    _world_y,
    _draw_angle,
    _damage,
    _damage_type,
    _projectile_data,
    _target_layer
)
{
    if (!instance_exists(_owner))
        return noone;

    if (!is_struct(_projectile_data))
        return noone;

    return instance_create_layer(
        _world_x,
        _world_y,
        "Instances",
        o_projectile_tower,
        {
            projectile_owner: _owner,
            projectile_damage: _damage,
            projectile_damage_type: _damage_type,
            projectile_speed: _projectile_data.speed,
            projectile_lifetime: _projectile_data.lifetime_seconds,
            projectile_radius: _projectile_data.radius,
            projectile_color: _projectile_data.color,
            projectile_angle: _draw_angle,
            projectile_impact: _projectile_data.impact,
            projectile_damage_radius: _projectile_data.damage_radius,
            projectile_target_layer: _target_layer
        }
    );
}

/// @description Initializes one tower projectile.

function scr_projectile_tower_initialize(_projectile)
{
    if (!instance_exists(_projectile))
        return false;

    _projectile.combat =
    {
        owner: _projectile.projectile_owner,
        damage: _projectile.projectile_damage,
        damage_type: _projectile.projectile_damage_type,
        impact: _projectile.projectile_impact,
        damage_radius: _projectile.projectile_damage_radius,
        target_layer: _projectile.projectile_target_layer
    };

    _projectile.movement =
    {
        speed: _projectile.projectile_speed
    };

    _projectile.life =
    {
        remaining: _projectile.projectile_lifetime
    };

    _projectile.visual =
    {
        draw_angle: _projectile.projectile_angle,
        radius: _projectile.projectile_radius,
        color: _projectile.projectile_color
    };

    return true;
}

/// @description Finds the closest valid enemy crossed by a projectile segment.

function scr_projectile_tower_enemy_find(
    _projectile,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    var _result = noone;
    var _best_distance = infinity;
    var _count = instance_number(o_enemy);


    for (var i = 0; i < _count; ++i)
    {
        var _enemy = instance_find(o_enemy, i);

        if (!instance_exists(_enemy))
            continue;

        if (_enemy.EnemyState == EnemyState.DEAD)
            continue;

        if (
            _enemy.movement.layer
            != _projectile.combat.target_layer
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
            > _collision_radius * _collision_radius
        )
        {
            continue;
        }


        var _distance =
            point_distance(
                _start_x,
                _start_y,
                _enemy.x,
                _enemy.y
            );


        if (_distance < _best_distance)
        {
            _best_distance = _distance;
            _result = _enemy;
        }
    }


    return _result;
}


/// @description Applies direct or circular damage at a projectile impact.

function scr_projectile_tower_impact(_projectile, _direct_target)
{
    if (!instance_exists(_projectile))
        return false;

    var _combat = _projectile.combat;


    switch (_combat.impact)
    {
        case ProjectileImpact.DIRECT:
        {
            if (!instance_exists(_direct_target))
                return false;

            var _damage =
                scr_damage_create(
                    _combat.damage,
                    _combat.owner,
                    DamageSource.TOWER,
                    _combat.damage_type
                );

            scr_enemy_damage(_direct_target, _damage);
        }
        break;


        case ProjectileImpact.EXPLOSIVE:
        {
            var _area =
            {
                shape: AttackAreaShape.CIRCLE,
                radius: _combat.damage_radius,

                falloff:
                {
                    enabled: true,
                    minimum_multiplier: 0.35,
                    exponent: 1
                }
            };

            scr_attack_area_apply(
                _combat.owner,
                DamageSource.TOWER,
                _combat.damage_type,
                _combat.target_layer,
                _projectile.x,
                _projectile.y,
                _projectile.visual.draw_angle,
                _combat.damage,
                _area
            );

            scr_effect_shockwave_create(
                _projectile.x,
                _projectile.y,
                _combat.damage_radius,
                _projectile.visual.color
            );


            // FUTURE:
            // explosion particles
            // debris
            // sound
            // camera shake
        }
        break;
    }

    return true;
}

/// @description Updates one tower projectile.

function scr_projectile_tower_update(
    _projectile
)
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
        instance_destroy(
            _projectile
        );

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


    var _enemy =
        scr_projectile_tower_enemy_find(
            _projectile,
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );


    if (instance_exists(_enemy))
    {
        // Move to the impact point before applying radius damage.

        _projectile.x =
            _enemy.x;

        _projectile.y =
            _enemy.y;


        scr_projectile_tower_impact(
            _projectile,
            _enemy
        );


        instance_destroy(
            _projectile
        );

        return true;
    }


    _projectile.x =
        _end_x;

    _projectile.y =
        _end_y;


    return true;
}


/// @description Draws one tower projectile.

function scr_projectile_tower_draw(
    _projectile
)
{
    if (!instance_exists(_projectile))
        return false;


    var _visual =
        _projectile.visual;


    draw_set_color(
        _visual.color
    );


    draw_line_width(
        _projectile.x
            - lengthdir_x(
                10,
                _visual.draw_angle
            ),

        _projectile.y
            - lengthdir_y(
                10,
                _visual.draw_angle
            ),

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