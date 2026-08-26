/// @description Tower projectile creation, collision, impact, and drawing.

/// @description Creates one configured tower projectile.

function scr_projectile_tower_create(
    _owner,
    _world_x,
    _world_y,
    _draw_angle,
    _damage,
    _damage_type,
    _projectile_data,
    _target_layer,
    _target = noone
)
{
    if (!instance_exists(_owner))
        return noone;

    if (!is_struct(_projectile_data))
        return noone;


    var _effect = undefined;
    var _movement = ProjectileMovement.STRAIGHT;
    var _turn_speed = 0;

    if (variable_struct_exists(_projectile_data, "effect"))
        _effect = _projectile_data.effect;

    if (variable_struct_exists(_projectile_data, "movement"))
        _movement = _projectile_data.movement;

    if (variable_struct_exists(_projectile_data, "turn_speed"))
        _turn_speed = _projectile_data.turn_speed;


    var _target_x =
        _world_x
        + lengthdir_x(
            256,
            _draw_angle
        );

    var _target_y =
        _world_y
        + lengthdir_y(
            256,
            _draw_angle
        );

    if (instance_exists(_target))
    {
        _target_x = _target.x;
        _target_y = _target.y;
    }


    return instance_create_layer(
        _world_x,
        _world_y,
        scr_layer_projectile_get(
    _target_layer
),
        o_projectile_tower,
        {
            projectile_owner: _owner,
            projectile_target: _target,
            projectile_target_x: _target_x,
            projectile_target_y: _target_y,

            projectile_damage: _damage,
            projectile_damage_type: _damage_type,
            projectile_speed: _projectile_data.speed,
            projectile_turn_speed: _turn_speed,
            projectile_movement: _movement,

            projectile_lifetime: _projectile_data.lifetime_seconds,
            projectile_radius: _projectile_data.radius,
            projectile_color: _projectile_data.color,
            projectile_angle: _draw_angle,

            projectile_impact: _projectile_data.impact,
            projectile_damage_radius: _projectile_data.damage_radius,
            projectile_target_layer: _target_layer,
            projectile_effect: _effect
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
        target: _projectile.projectile_target,

        damage: _projectile.projectile_damage,
        damage_type: _projectile.projectile_damage_type,
        impact: _projectile.projectile_impact,
        damage_radius: _projectile.projectile_damage_radius,
        target_layer: _projectile.projectile_target_layer,
        effect: _projectile.projectile_effect
    };


    _projectile.movement =
    {
        type: _projectile.projectile_movement,
        speed: _projectile.projectile_speed,
        turn_speed: _projectile.projectile_turn_speed,

        destination:
        {
            x: _projectile.projectile_target_x,
            y: _projectile.projectile_target_y
        }
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

/// @description Finds the earliest valid enemy crossed by a tower projectile.

function scr_projectile_tower_enemy_find(
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
        _projectile.visual.radius,
        _projectile.combat.target_layer
    );
}


/// @description Resolves one tower projectile impact.

function scr_projectile_tower_impact(
    _projectile,
    _direct_target
)
{
    if (!instance_exists(_projectile))
        return false;


    var _combat =
        _projectile.combat;

    var _impact_x =
        _projectile.x;

    var _impact_y =
        _projectile.y;

    var _impact_color =
        _projectile.visual.color;


    // A direct target gives us a more accurate impact position.

    if (instance_exists(_direct_target))
    {
        _impact_x =
            _direct_target.x;

        _impact_y =
            _direct_target.y;
    }


    switch (_combat.impact)
    {
        case ProjectileImpact.DIRECT:
        {
            if (!instance_exists(_direct_target))
                return false;


            scr_enemy_damage(
                _direct_target,
                scr_damage_create(
                    _combat.damage,
                    _combat.owner,
                    DamageSource.TOWER,
                    _combat.damage_type
                )
            );


            switch (_combat.damage_type)
            {
                case DamageType.LASER:
                {
                    scr_particles_laser_impact(
                        _impact_x,
                        _impact_y,
                        _impact_color
                    );
                }
                break;


                case DamageType.KINETIC:
                {
                    scr_particles_impact(
                        _impact_x,
                        _impact_y,
                        _impact_color,
                        3
                    );
                }
                break;


                case DamageType.EXPLOSIVE:
                {
                    scr_particles_explosion(
                        _impact_x,
                        _impact_y,
                        _impact_color,
                        0.6
                    );
                }
                break;
            }
        }
        break;


        case ProjectileImpact.EXPLOSIVE:
        {
            var _area =
            {
                shape:
                    AttackAreaShape.CIRCLE,

                radius:
                    _combat.damage_radius,

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
                _impact_color,
                _combat.target_layer
            );


            scr_particles_explosion(
                _projectile.x,
                _projectile.y,
                _impact_color,
                clamp(
                    _combat.damage_radius / 96,
                    0.75,
                    2
                )
            );
        }
        break;
    }


    // ========================================================================
    // OPTIONAL STATUS EFFECT
    // ========================================================================

    if (is_struct(_combat.effect))
    {
        var _effect_radius =
            0;

        if (
            variable_struct_exists(
                _combat.effect,
                "radius"
            )
        )
        {
            _effect_radius =
                _combat.effect.radius;
        }


        if (_effect_radius > 0)
        {
            scr_enemy_effect_area_apply(
                _projectile.x,
                _projectile.y,
                _effect_radius,
                _combat.target_layer,
                _combat.effect,
                _combat.owner
            );


            scr_effect_shockwave_create(
                _projectile.x,
                _projectile.y,
                _effect_radius,
                _impact_color,
                _combat.target_layer
            );
        }
        else if (instance_exists(_direct_target))
        {
            scr_enemy_effect_apply(
                _direct_target,
                _combat.effect,
                _combat.owner
            );
        }
    }


    return true;
}

/// @description Moves one tower projectile and resolves its impact.

function scr_projectile_tower_update(_projectile)
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


    // Homing projectiles turn toward their target.
    // Target-position projectiles aim at their stored destination.

    scr_projectile_tower_direction_update(
        _projectile
    );


    var _start_x =
        _projectile.x;

    var _start_y =
        _projectile.y;


    // ========================================================================
    // FIXED TARGET-POSITION PROJECTILE
    // ========================================================================
    //
    // Mortar shells travel toward their original destination and do not
    // collide with unrelated enemies along the way.

    if (
        _projectile.movement.type
        == ProjectileMovement.TARGET_POSITION
    )
    {
        var _destination_x =
            _projectile.movement.destination.x;

        var _destination_y =
            _projectile.movement.destination.y;

        var _destination_distance =
            point_distance(
                _start_x,
                _start_y,
                _destination_x,
                _destination_y
            );


        if (
            _destination_distance
            <= _projectile.movement.speed
        )
        {
            _projectile.x =
                _destination_x;

            _projectile.y =
                _destination_y;


            scr_projectile_tower_impact(
                _projectile,
                noone
            );


            instance_destroy(
                _projectile
            );

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


    // ========================================================================
    // STRAIGHT / HOMING PROJECTILE
    // ========================================================================

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


    var _enemy_hit =
        scr_projectile_tower_enemy_find(
            _projectile,
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );


    if (is_struct(_enemy_hit))
    {
        var _enemy =
            _enemy_hit.enemy;


        if (instance_exists(_enemy))
        {
            // Preserve your existing impact behavior by resolving the
            // projectile at the direct target's position.

            _projectile.x =
                _enemy.x;

            _projectile.y =
                _enemy.y;


            scr_projectile_tower_impact(
                _projectile,
                _enemy
            );
        }


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

/// @description Updates one tower projectile's direction and destination.

function scr_projectile_tower_direction_update(_projectile)
{
    if (!instance_exists(_projectile))
        return false;


    var _movement =
        _projectile.movement;


    switch (_movement.type)
    {
        case ProjectileMovement.STRAIGHT:
        {
            // Existing direction remains unchanged.
        }
        break;


        case ProjectileMovement.TARGET_POSITION:
        {
            _projectile.visual.draw_angle =
                point_direction(
                    _projectile.x,
                    _projectile.y,
                    _movement.destination.x,
                    _movement.destination.y
                );
        }
        break;


        case ProjectileMovement.HOMING:
        {
            var _target =
                _projectile.combat.target;

            if (!instance_exists(_target))
            {
                // If the target dies, continue along the last direction.

                return true;
            }


            _movement.destination.x =
                _target.x;

            _movement.destination.y =
                _target.y;


            var _desired_angle =
                point_direction(
                    _projectile.x,
                    _projectile.y,
                    _target.x,
                    _target.y
                );

            var _angle_difference =
                angle_difference(
                    _desired_angle,
                    _projectile.visual.draw_angle
                );


            _projectile.visual.draw_angle +=
                clamp(
                    _angle_difference,
                    -_movement.turn_speed,
                    _movement.turn_speed
                );
        }
        break;
    }


    return true;
}