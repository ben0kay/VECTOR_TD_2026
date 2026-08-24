/// @description Releases one Transporter's configured enemy cargo.

function scr_enemy_transport_release(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !scr_enemy_has_ability(
            _enemy,
            EnemyAbility.TRANSPORT_ENEMIES
        )
    )
    {
        return false;
    }

    var _transport =
        _enemy.ability_runtime.transport;

    if (!is_struct(_transport))
        return false;

    if (_transport.triggered)
        return false;

    _transport.triggered = true;


    // ========================================================================
    // COUNT COMPLETE CARGO
    // ========================================================================

    var _total_cargo = 0;

    for (var i = 0; i < array_length(_transport.cargo); ++i)
    {
        var _cargo = _transport.cargo[i];

        _total_cargo +=
            irandom_range(
                max(0, floor(_cargo.count_min)),
                max(0, floor(_cargo.count_max))
            );
    }

    if (_total_cargo <= 0)
        return true;


    // ========================================================================
    // RELEASE CARGO
    // ========================================================================

    var _released = 0;

    for (var i = 0; i < array_length(_transport.cargo); ++i)
    {
        var _cargo = _transport.cargo[i];

        var _count =
            irandom_range(
                max(0, floor(_cargo.count_min)),
                max(0, floor(_cargo.count_max))
            );

        var _child_modifiers = [];

        if (_cargo.inherit_modifiers)
        {
            _child_modifiers =
                scr_enemy_modifiers_copy(
                    _enemy.modifiers
                );
        }


        for (var j = 0; j < _count; ++j)
        {
            var _angle =
                (_released / max(1, _total_cargo)) * 360;

            var _distance =
                random_range(
                    _transport.spawn_radius * 0.45,
                    _transport.spawn_radius
                );

            var _spawn_x =
                clamp(
                    _enemy.x
                    + lengthdir_x(_distance, _angle),
                    32,
                    room_width - 32
                );

            var _spawn_y =
                clamp(
                    _enemy.y
                    + lengthdir_y(_distance, _angle),
                    32,
                    room_height - 32
                );


            // If the surrounding position is obstructed, release the child
            // at the Transporter's valid current position instead.

            if (
                scr_world_moving_circle_solid(
                    _enemy.x,
                    _enemy.y,
                    _spawn_x,
                    _spawn_y,
                    8
                )
            )
            {
                _spawn_x = _enemy.x;
                _spawn_y = _enemy.y;
            }


            scr_enemy_spawn(
                _cargo.enemy_key,
                _spawn_x,
                _spawn_y,
                _angle,
                _child_modifiers
            );

            _released++;
        }
    }


    scr_effect_shockwave_create(
        _enemy.x,
        _enemy.y,
        _transport.spawn_radius + 20,
        _enemy.visual.color
    );


    // FUTURE:
    // opening transport panels
    // cargo launch particles
    // configurable release-on-arrival
    // mixed cargo formations
    // cargo capacity affected by modifiers


    return true;
}

/// @description Approaches and then orbits an enemy's strategic target.

function scr_enemy_orbit_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _target =
        _enemy.targeting.target;

    if (!instance_exists(_target))
        return false;

    var _orbit =
        _enemy.ability_runtime.orbit;

    if (!is_struct(_orbit))
        return false;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _distance =
        point_distance(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );

    var _entry_distance =
        _orbit.radius
        + _orbit.entry_tolerance;


    // ========================================================================
    // APPROACH
    // ========================================================================

    if (
        !_orbit.active
        && _distance > _entry_distance
    )
    {
        _enemy.EnemyState =
            EnemyState.MOVING;

        var _direction =
            point_direction(
                _enemy.x,
                _enemy.y,
                _target.x,
                _target.y
            );

        _enemy.x +=
            lengthdir_x(
                _enemy.movement.speed,
                _direction
            );

        _enemy.y +=
            lengthdir_y(
                _enemy.movement.speed,
                _direction
            );

        _enemy.x =
            clamp(
                _enemy.x,
                _enemy.visual.radius,
                room_width - _enemy.visual.radius
            );

        _enemy.y =
            clamp(
                _enemy.y,
                _enemy.visual.radius,
                room_height - _enemy.visual.radius
            );

        return true;
    }


    // ========================================================================
    // ENTER ORBIT
    // ========================================================================

    if (!_orbit.active)
    {
        _orbit.active = true;

        _orbit.angle =
            point_direction(
                _target.x,
                _target.y,
                _enemy.x,
                _enemy.y
            );
    }


    // ========================================================================
    // ORBIT
    // ========================================================================

    _enemy.EnemyState =
        EnemyState.ATTACKING;

    _orbit.angle +=
        _orbit.angular_speed
        / _fps;

    _orbit.angle =
        _orbit.angle mod 360;


    var _orbit_x =
        _target.x
        + lengthdir_x(
            _orbit.radius,
            _orbit.angle
        );

    var _orbit_y =
        _target.y
        + lengthdir_y(
            _orbit.radius,
            _orbit.angle
        );


    var _move_direction =
        point_direction(
            _enemy.x,
            _enemy.y,
            _orbit_x,
            _orbit_y
        );

    var _move_distance =
        min(
            _enemy.movement.speed,
            point_distance(
                _enemy.x,
                _enemy.y,
                _orbit_x,
                _orbit_y
            )
        );


    _enemy.x +=
        lengthdir_x(
            _move_distance,
            _move_direction
        );

    _enemy.y +=
        lengthdir_y(
            _move_distance,
            _move_direction
        );


    _enemy.x =
        clamp(
            _enemy.x,
            _enemy.visual.radius,
            room_width - _enemy.visual.radius
        );

    _enemy.y =
        clamp(
            _enemy.y,
            _enemy.visual.radius,
            room_height - _enemy.visual.radius
        );


    // Gunships face inward while firing, similar to the original enemy.

    _enemy.visual.draw_angle =
        point_direction(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );


    if (_enemy.attack.cooldown.remaining <= 0)
        scr_enemy_attack(_enemy);


    return true;
}

/// @description Releases evenly spaced brainless children from a splitter.

function scr_enemy_split(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !scr_enemy_has_ability(
            _enemy,
            EnemyAbility.SPLIT_ON_DEATH
        )
    )
    {
        return false;
    }

    if (!is_struct(_enemy.ability_runtime.split))
        return false;


    var _split =
        _enemy.ability_runtime.split;

    if (_split.triggered)
        return false;


    _split.triggered = true;


    var _count =
        max(
            1,
            floor(_split.count)
        );

    var _angle_step =
        360 / _count;

    var _base_angle =
        random(360)
        + _split.angle_offset;


    for (var i = 0; i < _count; ++i)
    {
        var _angle =
            _base_angle
            + (i * _angle_step);

        var _spawn_x =
            _enemy.x
            + lengthdir_x(
                _split.spawn_distance,
                _angle
            );

        var _spawn_y =
            _enemy.y
            + lengthdir_y(
                _split.spawn_distance,
                _angle
            );


        scr_enemy_spawn(
            _split.enemy_key,
            _spawn_x,
            _spawn_y,
            _angle,

            // Children inherit composable spawn modifiers.

            _enemy.modifiers
        );
    }


    // FUTURE:
    // split particles
    // split sound
    // modifier inheritance exceptions
    // several possible child enemy keys


    return true;
}

/// @description Detonates one enemy and damages every valid nearby target.

function scr_enemy_explode(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!scr_enemy_has_ability(_enemy, EnemyAbility.EXPLODE_ON_DEATH))
        return false;

    if (!is_struct(_enemy.ability_runtime.explosion))
        return false;


    var _explosion = _enemy.ability_runtime.explosion;

    if (_explosion.triggered)
        return false;


    _explosion.triggered = true;

    var _world_x = _enemy.x;
    var _world_y = _enemy.y;
    var _damage = scr_damage_create(
        _explosion.damage,
        _enemy,
        DamageSource.ENEMY
    );


    // ========================================================================
    // CPU
    // ========================================================================

    var _cpu = global.vtd_level.entities.cpu;

    if (
        instance_exists(_cpu)
        && scr_enemy_explosion_target_distance(_world_x, _world_y, _cpu)
        <= _explosion.radius
    )
    {
        scr_cpu_damage(_cpu, _damage.amount);
    }


    // ========================================================================
    // PLAYER
    // ========================================================================

    var _player = global.vtd_level.entities.player;

    if (
        instance_exists(_player)
        && scr_enemy_explosion_target_distance(_world_x, _world_y, _player)
        <= _explosion.radius
    )
    {
        scr_player_damage(_player, _damage);
    }


    // ========================================================================
    // BUILDINGS
    // ========================================================================

    var _building_count = instance_number(o_building_par);

    for (var i = _building_count - 1; i >= 0; --i)
    {
        var _building = instance_find(o_building_par, i);

        if (!scr_enemy_building_target_valid(_building))
            continue;

        if (
            scr_enemy_explosion_target_distance(
                _world_x,
                _world_y,
                _building
            )
            > _explosion.radius
        )
        {
            continue;
        }


        scr_building_damage(_building, _damage);
    }


    // Temporary vector feedback until scr_particle is implemented.

    show_debug_message(
        "ENEMY EXPLOSION: "
        + _enemy.identity.name
        + " | DAMAGE "
        + string(_explosion.damage)
        + " | RADIUS "
        + string(_explosion.radius)
    );


    // FUTURE:
    // scr_particle_explosion_create(...)
    // camera shake
    // sound
    // damage falloff
    // knockback
    // shield interaction


    return true;
}