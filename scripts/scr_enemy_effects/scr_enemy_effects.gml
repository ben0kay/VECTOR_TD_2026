/// @description Returns whether an enemy currently has one effect.

function scr_enemy_effect_active(_enemy, _effect)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "effects"))
        return false;

    if (!is_struct(_enemy.effects))
        return false;


    switch (_effect)
    {
        case EnemyEffect.SLOW:
            return _enemy.effects.slow.active;

        case EnemyEffect.STASIS:
            return _enemy.effects.stasis.active;

        case EnemyEffect.DAMAGE_OVER_TIME:
            return _enemy.effects.damage_over_time.active;
    }


    return false;
}

/// @description Applies or refreshes one data-driven enemy effect.

function scr_enemy_effect_apply(_enemy, _effect_data, _source = noone)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_effect_data))
        return false;

    if (!variable_struct_exists(_effect_data, "type"))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;


    switch (_effect_data.type)
    {
        case EnemyEffect.SLOW:
        {
            var _slow = _enemy.effects.slow;
            var _multiplier = clamp(_effect_data.multiplier, 0.05, 1);
            var _duration = _effect_data.duration_seconds;

            if (!_slow.active || _multiplier < _slow.multiplier)
                _slow.multiplier = _multiplier;

            _slow.active = true;
            _slow.source = _source;

            if (_slow.remaining_seconds < 0 || _duration < 0)
                _slow.remaining_seconds = -1;
            else
                _slow.remaining_seconds = max(_slow.remaining_seconds, _duration);
        }
        break;


        case EnemyEffect.STASIS:
        {
            var _stasis = _enemy.effects.stasis;

            _stasis.active = true;
            _stasis.source = _source;

            _stasis.remaining_seconds =
                max(
                    _stasis.remaining_seconds,
                    _effect_data.duration_seconds
                );
        }
        break;


        case EnemyEffect.DAMAGE_OVER_TIME:
        {
            var _dot = _enemy.effects.damage_over_time;

            // Existing equal or stronger disruption remains in control.

            if (
                _dot.active
                && _dot.damage >= _effect_data.damage
            )
            {
                return false;
            }

            _dot.active = true;
            _dot.damage = _effect_data.damage;
            _dot.interval_seconds = max(0.05, _effect_data.interval_seconds);
            _dot.interval_remaining = _dot.interval_seconds;
            _dot.remaining_seconds = _effect_data.duration_seconds;
            _dot.damage_type = _effect_data.damage_type;
            _dot.source = _source;
        }
        break;
    }


    return true;
}


/// @description Applies one effect to enemies inside a circular area.

function scr_enemy_effect_area_apply(
    _world_x,
    _world_y,
    _radius,
    _target_layer,
    _effect_data,
    _source = noone
)
{
    if (_radius <= 0)
        return false;


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

        if (_enemy.movement.layer != _target_layer)
            continue;

        if (
            point_distance(
                _world_x,
                _world_y,
                _enemy.x,
                _enemy.y
            )
            > _radius + _enemy.visual.radius
        )
        {
            continue;
        }


        scr_enemy_effect_apply(
            _enemy,
            _effect_data,
            _source
        );
    }


    return true;
}

/// @description Updates active effects and calculates effective movement speed.

function scr_enemy_effects_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_enemy.effects))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    // ========================================================================
    // SLOW
    // ========================================================================

    var _slow = _enemy.effects.slow;

    if (_slow.active && _slow.remaining_seconds >= 0)
    {
        _slow.remaining_seconds =
            max(
                0,
                _slow.remaining_seconds - _delta
            );

        if (_slow.remaining_seconds <= 0)
        {
            _slow.active = false;
            _slow.multiplier = 1;
            _slow.source = noone;
        }
    }


    // ========================================================================
    // STASIS
    // ========================================================================

    var _stasis = _enemy.effects.stasis;

    if (_stasis.active)
    {
        _stasis.remaining_seconds =
            max(
                0,
                _stasis.remaining_seconds - _delta
            );

        if (_stasis.remaining_seconds <= 0)
        {
            _stasis.active = false;
            _stasis.source = noone;
        }
    }


    // ========================================================================
    // DAMAGE OVER TIME
    // ========================================================================

    var _dot = _enemy.effects.damage_over_time;

    if (_dot.active)
    {
        // Only count down non-permanent effects.

        if (_dot.remaining_seconds >= 0)
        {
            _dot.remaining_seconds =
                max(
                    0,
                    _dot.remaining_seconds - _delta
                );
        }


        _dot.interval_remaining -=
            _delta;


        if (_dot.interval_remaining <= 0)
        {
            _dot.interval_remaining =
                _dot.interval_seconds;

            scr_enemy_damage(
                _enemy,
                scr_damage_create(
                    _dot.damage,
                    _dot.source,
                    DamageSource.TOWER,
                    _dot.damage_type
                )
            );

            if (!instance_exists(_enemy))
                return true;
        }


        if (
            _dot.remaining_seconds == 0
        )
        {
            _dot.active = false;
            _dot.source = noone;
        }
    }


    // ========================================================================
    // EFFECTIVE MOVEMENT SPEED
    // ========================================================================

    var _speed_multiplier = 1;

    if (_slow.active)
        _speed_multiplier *= _slow.multiplier;

    if (_stasis.active)
        _speed_multiplier = 0;


    _enemy.movement.speed =
        _enemy.movement.speed_base
        * _speed_multiplier;


    return true;
}


/// @description Draws active enemy status-effect visuals.

function scr_enemy_effects_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _effects =
        _enemy.effects;


    // ========================================================================
    // NOTHING ACTIVE
    // ========================================================================
    //
    // Every enemy owns the effects runtime.
    // If nothing is active, leave immediately.

    if (
        !_effects.slow.active
        && !_effects.stasis.active
        && !_effects.damage_over_time.active
    )
    {
        return true;
    }


    var _x =
        _enemy.x;

    var _y =
        _enemy.y;

    var _radius =
        _enemy.visual.radius;


    // ========================================================================
    // CRYO SLOW
    // ========================================================================

    if (_effects.slow.active)
    {
        var _cryo_radius =
            _radius + 4;

        var _spin =
            (
                global.vtd.tick * 1.5
                + real(_enemy.id)
            )
            mod 360;


        draw_set_alpha(0.75);
        draw_set_color(c_aqua);


        // Four separated curved sections create a rotating frozen outline.

        for (var section = 0; section < 4; ++section)
        {
            var _section_start =
                _spin
                + (section * 90);

            var _section_end =
                _section_start + 48;

            var _previous_x =
                _x
                + lengthdir_x(
                    _cryo_radius,
                    _section_start
                );

            var _previous_y =
                _y
                + lengthdir_y(
                    _cryo_radius,
                    _section_start
                );


            for (
                var _angle = _section_start + 8;
                _angle <= _section_end;
                _angle += 8
            )
            {
                var _next_x =
                    _x
                    + lengthdir_x(
                        _cryo_radius,
                        _angle
                    );

                var _next_y =
                    _y
                    + lengthdir_y(
                        _cryo_radius,
                        _angle
                    );


                draw_line(
                    _previous_x,
                    _previous_y,
                    _next_x,
                    _next_y
                );


                _previous_x =
                    _next_x;

                _previous_y =
                    _next_y;
            }
        }


        // Small outward ice marks.

        for (var i = 0; i < 4; ++i)
        {
            var _mark_angle =
                _spin
                + 24
                + (i * 90);


            draw_line(
                _x
                + lengthdir_x(
                    _cryo_radius - 2,
                    _mark_angle
                ),

                _y
                + lengthdir_y(
                    _cryo_radius - 2,
                    _mark_angle
                ),

                _x
                + lengthdir_x(
                    _cryo_radius + 3,
                    _mark_angle
                ),

                _y
                + lengthdir_y(
                    _cryo_radius + 3,
                    _mark_angle
                )
            );
        }
    }


    // ========================================================================
    // STASIS
    // ========================================================================

    if (_effects.stasis.active)
    {
        var _stasis_radius =
            _radius + 7;

        var _pulse =
            0.65
            + dsin(
                global.vtd.tick * 8
                + real(_enemy.id)
            )
            * 0.2;


        draw_set_alpha(_pulse);

        draw_set_color(
            make_color_rgb(
                120,
                170,
                255
            )
        );


        draw_circle(
            _x,
            _y,
            _stasis_radius,
            true
        );


        // Horizontal and vertical containment lines.

        draw_line(
            _x - _radius,
            _y,
            _x + _radius,
            _y
        );

        draw_line(
            _x,
            _y - _radius,
            _x,
            _y + _radius
        );


        // Diamond-shaped inner lock.

        var _inner_radius =
            _radius * 0.55;


        draw_line(
            _x,
            _y - _inner_radius,
            _x + _inner_radius,
            _y
        );

        draw_line(
            _x + _inner_radius,
            _y,
            _x,
            _y + _inner_radius
        );

        draw_line(
            _x,
            _y + _inner_radius,
            _x - _inner_radius,
            _y
        );

        draw_line(
            _x - _inner_radius,
            _y,
            _x,
            _y - _inner_radius
        );
    }


    // ========================================================================
    // DISRUPTION / DAMAGE OVER TIME
    // ========================================================================

    if (_effects.damage_over_time.active)
    {
        var _dot_radius =
            _radius + 5;

        var _dot_spin =
            (
                global.vtd.tick * -3
                + real(_enemy.id)
            )
            mod 360;

        var _dot_pulse =
            0.55
            + dsin(
                global.vtd.tick * 7
                + real(_enemy.id)
            )
            * 0.25;


        draw_set_alpha(_dot_pulse);

        draw_set_color(
            make_color_rgb(
                190,
                70,
                255
            )
        );


        // Rotating electrical disruption marks.

        for (var i = 0; i < 3; ++i)
        {
            var _angle =
                _dot_spin
                + (i * 120);

            var _middle_angle =
                _angle + 18;

            var _end_angle =
                _angle + 34;


            var _middle_x =
                _x
                + lengthdir_x(
                    _dot_radius + 3,
                    _middle_angle
                );

            var _middle_y =
                _y
                + lengthdir_y(
                    _dot_radius + 3,
                    _middle_angle
                );


            draw_line(
                _x
                + lengthdir_x(
                    _dot_radius - 3,
                    _angle
                ),

                _y
                + lengthdir_y(
                    _dot_radius - 3,
                    _angle
                ),

                _middle_x,
                _middle_y
            );


            draw_line(
                _middle_x,
                _middle_y,

                _x
                + lengthdir_x(
                    _dot_radius - 2,
                    _end_angle
                ),

                _y
                + lengthdir_y(
                    _dot_radius - 2,
                    _end_angle
                )
            );
        }
    }


    // ========================================================================
    // RESTORE DRAWING STATE
    // ========================================================================

    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}