/// @description Queues one Transporter's configured enemy cargo for staggered release.
function scr_enemy_transport_release(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _transport =
        _enemy.ability_runtime.transport;


    if (_transport.triggered)
        return false;

    _transport.triggered = true;
	
	// A flying transporter cannot release ground cargo while directly
// above permanent terrain. Its children would spawn trapped inside it.

	if (_enemy.movement.layer == EnemyMovementLayer.FLYING
	    && scr_world_circle_solid(
	        _enemy.x,
	        _enemy.y,
	        8
	    ))
	{
	    return true;
	}


    // ========================================================================
    // COMPLETE THE CARGO ROLLS ONCE
    // ========================================================================
    //
    // The stored result is used both for the total formation spacing and for
    // the actual release queue. This avoids rolling each cargo amount twice.

    var _cargo_count =
        array_length(
            _transport.cargo
        );

    var _cargo_counts =
        array_create(
            _cargo_count,
            0
        );

    var _total_cargo = 0;

    for (var i = 0; i < _cargo_count; ++i)
    {
        var _cargo =
            _transport.cargo[i];

        var _count =
            irandom_range(
                max(
                    0,
                    floor(_cargo.count_min)
                ),

                max(
                    0,
                    floor(_cargo.count_max)
                )
            );

        _cargo_counts[i] =
            _count;

        _total_cargo +=
            _count;
    }

    if (_total_cargo <= 0)
        return true;


    // ========================================================================
    // GET / CREATE THE LEVEL RUNTIME QUEUE
    // ========================================================================

    if (
        !variable_struct_exists(
            global.vtd_level,
            "transport_release_queue"
        )
    )
    {
        global.vtd_level.transport_release_queue =
            [];
    }

    var _queue =
        global.vtd_level.transport_release_queue;

    var _current_frame =
        global.vtd_level.time.frames;

    // Kept here deliberately: this is universal ability behaviour, not
    // transporter definition data. One child releases every 3 frames.
    var _release_interval_frames =
        3;

    var _released = 0;


    // ========================================================================
    // QUEUE CARGO
    // ========================================================================

    for (var i = 0; i < _cargo_count; ++i)
    {
        var _cargo =
            _transport.cargo[i];

        var _count =
            _cargo_counts[i];

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
                (_released / _total_cargo)
                * 360;

            var _distance =
                random_range(
                    _transport.spawn_radius * 0.45,
                    _transport.spawn_radius
                );

            var _spawn_x =
                clamp(
                    _enemy.x
                    + lengthdir_x(
                        _distance,
                        _angle
                    ),

                    32,
                    room_width - 32
                );

            var _spawn_y =
                clamp(
                    _enemy.y
                    + lengthdir_y(
                        _distance,
                        _angle
                    ),

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
                _spawn_x =
                    _enemy.x;

                _spawn_y =
                    _enemy.y;
            }


            array_push(
                _queue,
                {
                    release_frame:
                        _current_frame
                        + (
                            _released
                            * _release_interval_frames
                        ),

                    enemy_key:
                        _cargo.enemy_key,

                    x:
                        _spawn_x,

                    y:
                        _spawn_y,

                    angle:
                        _angle,

                    modifiers:
                        _child_modifiers,

                    major_wave_number:
                        _enemy.major_wave_number
                }
            );

            _released++;
        }
    }

    global.vtd_level.transport_release_queue =
        _queue;


    // The carrier's destruction effect still happens immediately.

    scr_effect_shockwave_create(
        _enemy.x,
        _enemy.y,
        _transport.spawn_radius + 20,
        _enemy.visual.color,
        _enemy.movement.layer
    );

    return true;
}

/// @description Releases transport cargo whose scheduled frame has arrived.
function scr_enemy_transport_release_queue_update()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (
        !variable_struct_exists(
            global.vtd_level,
            "transport_release_queue"
        )
    )
    {
        return true;
    }

    var _queue =
        global.vtd_level.transport_release_queue;

    if (array_length(_queue) <= 0)
        return true;

    var _current_frame =
        global.vtd_level.time.frames;

    for (
        var i = array_length(_queue) - 1;
        i >= 0;
        --i
    )
    {
        var _release =
            _queue[i];

        if (
            _release.release_frame
            > _current_frame
        )
        {
            continue;
        }

        scr_enemy_spawn(
    _release.enemy_key,
    _release.x,
    _release.y,
    _release.x,
    _release.y,
    _release.angle,
    _release.modifiers,
    _release.major_wave_number
);

        array_delete(
            _queue,
            i,
            1
        );
    }

    global.vtd_level.transport_release_queue =
        _queue;

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
		    _enemy.modifiers,
		    _enemy.major_wave_number
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

/// @description Applies a temporary support shield to one enemy.

function scr_enemy_support_shield_apply(
    _enemy,
    _source,
    _capacity,
    _recharge,
    _duration,
    _color
)
{
    if (!instance_exists(_enemy))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (!variable_struct_exists(_enemy.vitals, "shield"))
        return false;

    var _shield = _enemy.vitals.shield;

    if (!is_struct(_shield.support))
        return false;

    var _support = _shield.support;
    var _new_capacity = max(1, _capacity);


    // A stronger generator may replace the existing support shield source.

    if (
        !_support.enabled
        || !instance_exists(_support.source)
        || _new_capacity > _support.maximum
        || _support.source == _source
    )
    {
        _support.source = _source;
        _support.maximum = _new_capacity;
        _support.color = _color;
    }


    _support.enabled = true;

    _support.current =
        min(
            _support.maximum,
            _support.current
            + max(0, _recharge)
        );

    _support.remaining_seconds =
        max(
            _support.remaining_seconds,
            _duration
        );


    return true;
}

/// @description Pulses temporary shields to nearby allied enemies.

function scr_enemy_shield_generator_pulse(_generator)
{
    if (!instance_exists(_generator))
        return false;

    var _support =
        _generator.ability_runtime.support_shield;

    if (!is_struct(_support))
        return false;


    var _enemy_count =
        instance_number(o_enemy);

    for (var i = 0; i < _enemy_count; ++i)
    {
        var _target =
            instance_find(
                o_enemy,
                i
            );

        if (!instance_exists(_target))
            continue;

        if (_target == _generator)
            continue;

        if (_target.EnemyState == EnemyState.DEAD)
            continue;


        // The support generator is intended to protect ordinary assault
        // enemies rather than equally large support or siege units.

        if (
            _target.visual.radius
            > _support.maximum_target_radius
        )
        {
            continue;
        }


        if (
            point_distance(
                _generator.x,
                _generator.y,
                _target.x,
                _target.y
            )
            > _support.field_radius
        )
        {
            continue;
        }


        scr_enemy_support_shield_apply(
            _target,
            _generator,
            _support.shield_capacity,
            _support.recharge_per_pulse,
            _support.linger_seconds,
            _support.color
        );
    }


    scr_effect_shockwave_create(
        _generator.x,
        _generator.y,
        _support.field_radius,
        _support.color
    );


    // FUTURE:
    // pulse particles
    // shield-transfer beams
    // sound effects
    // support strength modifiers
    // several shield generator tiers


    return true;
}

/// @description Moves a Shield Generator into support range of the closest building.

function scr_enemy_shield_generator_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _support =
        _enemy.ability_runtime.support_shield;

    if (!is_struct(_support))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _support.pulse_remaining =
        max(
            0,
            _support.pulse_remaining
            - (1 / _fps)
        );


    // Always use the closest living building. If none remain, the CPU
    // becomes the final objective.

    if (
        !instance_exists(
            _enemy.targeting.strategic
        )
    )
    {
        _enemy.targeting.strategic =
            scr_enemy_closest_building_get(
                _enemy
            );

        if (
            !instance_exists(
                _enemy.targeting.strategic
            )
        )
        {
            _enemy.targeting.strategic =
                global.vtd_level.entities.cpu;
        }

        _enemy.targeting.target =
            _enemy.targeting.strategic;

        scr_navigation_enemy_repath_request(
            _enemy,
            true
        );
    }


    var _target =
        _enemy.targeting.strategic;

    if (!instance_exists(_target))
    {
        scr_navigation_enemy_stop(_enemy);
        return true;
    }


    var _edge_distance =
        scr_enemy_target_edge_distance(
            _enemy,
            _target
        );


    // Move until the generator reaches its long support distance.

    if (_edge_distance > _support.standoff_range)
    {
        _enemy.EnemyState =
            EnemyState.MOVING;

        _enemy.targeting.target =
            _target;

        scr_navigation_enemy_update(
            _enemy
        );

        return true;
    }


    // Hold position and protect nearby assault enemies.

    scr_navigation_enemy_stop(
        _enemy
    );

    _enemy.EnemyState =
        EnemyState.ATTACKING;

    _enemy.visual.draw_angle =
        point_direction(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );


    if (_support.pulse_remaining <= 0)
    {
        scr_enemy_shield_generator_pulse(
            _enemy
        );

        _support.pulse_remaining =
            _support.pulse_seconds;
    }


    return true;
}