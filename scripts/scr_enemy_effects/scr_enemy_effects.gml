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
            var _slow =
                _enemy.effects.slow;

            var _multiplier =
                clamp(
                    _effect_data.multiplier,
                    0.05,
                    1
                );

            var _duration =
                _effect_data.duration_seconds;


            // The strongest slow wins. Repeated weaker shots cannot make
            // the enemy progressively slower.

            if (
                !_slow.active
                || _multiplier < _slow.multiplier
            )
            {
                _slow.multiplier =
                    _multiplier;
            }


            _slow.active = true;
            _slow.source = _source;


            if (
                _slow.remaining_seconds < 0
                || _duration < 0
            )
            {
                // Negative duration means the effect lasts permanently.

                _slow.remaining_seconds = -1;
            }
            else
            {
                _slow.remaining_seconds =
                    max(
                        _slow.remaining_seconds,
                        _duration
                    );
            }
        }
        break;


        case EnemyEffect.STASIS:
        {
            var _stasis =
                _enemy.effects.stasis;

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
            var _dot =
                _enemy.effects.damage_over_time;

            _dot.active = true;
            _dot.damage = _effect_data.damage;
            _dot.interval_seconds = _effect_data.interval_seconds;
            _dot.interval_remaining = 0;
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


/// @description Updates one enemy's active effects and effective speed.

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

    var _slow =
        _enemy.effects.slow;

    if (
        _slow.active
        && _slow.remaining_seconds >= 0
    )
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

    var _stasis =
        _enemy.effects.stasis;

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

    var _dot =
        _enemy.effects.damage_over_time;

    if (_dot.active)
    {
        _dot.remaining_seconds =
            max(
                0,
                _dot.remaining_seconds - _delta
            );

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


        if (_dot.remaining_seconds <= 0)
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


/// @description Draws temporary vector feedback for active enemy effects.

function scr_enemy_effects_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_enemy.effects))
        return false;


    var _radius =
        _enemy.visual.radius;


    if (_enemy.effects.slow.active)
    {
        draw_set_alpha(0.7);
        draw_set_color(c_aqua);

        draw_arc(
            _enemy.x,
            _enemy.y,
            _radius + 3,
            25,
            155
        );

        draw_arc(
            _enemy.x,
            _enemy.y,
            _radius + 3,
            205,
            335
        );
    }


    if (_enemy.effects.stasis.active)
    {
        var _pulse =
            0.65
            + dsin(
                global.vtd.tick * 8
                + real(_enemy.id)
            ) * 0.2;

        draw_set_alpha(_pulse);
        draw_set_color(make_color_rgb(120, 170, 255));

        draw_circle(
            _enemy.x,
            _enemy.y,
            _radius + 6,
            true
        );

        draw_line(
            _enemy.x - _radius,
            _enemy.y,
            _enemy.x + _radius,
            _enemy.y
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}