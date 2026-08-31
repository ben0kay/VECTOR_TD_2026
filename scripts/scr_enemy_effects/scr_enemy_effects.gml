/// @description Returns the baked slow-effect sprite.

function scr_enemy_effect_slow_baked()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _radius = 20;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    for (var section = 0; section < 4; ++section)
    {
        var _start = section * 90;
        var _end = _start + 48;
        var _previous_x = _centre + lengthdir_x(_radius, _start);
        var _previous_y = _centre + lengthdir_y(_radius, _start);

        for (var _angle = _start + 8; _angle <= _end; _angle += 8)
        {
            var _next_x = _centre + lengthdir_x(_radius, _angle);
            var _next_y = _centre + lengthdir_y(_radius, _angle);

            draw_line(_previous_x, _previous_y, _next_x, _next_y);

            _previous_x = _next_x;
            _previous_y = _next_y;
        }

        var _mark_angle = _start + 24;

        draw_line(
            _centre + lengthdir_x(_radius - 2, _mark_angle),
            _centre + lengthdir_y(_radius - 2, _mark_angle),
            _centre + lengthdir_x(_radius + 3, _mark_angle),
            _centre + lengthdir_y(_radius + 3, _mark_angle)
        );
    }

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    return _sprite;
}


/// @description Returns the baked stasis-effect sprite.

function scr_enemy_effect_stasis_baked()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _radius = 16;
    var _outer = 23;
    var _inner = _radius * 0.55;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    draw_circle(_centre, _centre, _outer, true);

    draw_line(_centre - _radius, _centre, _centre + _radius, _centre);
    draw_line(_centre, _centre - _radius, _centre, _centre + _radius);

    draw_line(_centre, _centre - _inner, _centre + _inner, _centre);
    draw_line(_centre + _inner, _centre, _centre, _centre + _inner);
    draw_line(_centre, _centre + _inner, _centre - _inner, _centre);
    draw_line(_centre - _inner, _centre, _centre, _centre - _inner);

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    return _sprite;
}


/// @description Returns the baked disruption-effect sprite.

function scr_enemy_effect_disruption_baked()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _radius = 21;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    for (var i = 0; i < 3; ++i)
    {
        var _angle = i * 120;
        var _middle_angle = _angle + 18;
        var _end_angle = _angle + 34;

        var _middle_x = _centre + lengthdir_x(_radius + 3, _middle_angle);
        var _middle_y = _centre + lengthdir_y(_radius + 3, _middle_angle);

        draw_line(
            _centre + lengthdir_x(_radius - 3, _angle),
            _centre + lengthdir_y(_radius - 3, _angle),
            _middle_x,
            _middle_y
        );

        draw_line(
            _middle_x,
            _middle_y,
            _centre + lengthdir_x(_radius - 2, _end_angle),
            _centre + lengthdir_y(_radius - 2, _end_angle)
        );
    }

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    return _sprite;
}

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

/// @description Returns the baked natural-shield energy fill.

function scr_enemy_shield_fill_baked()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    draw_circle(_centre, _centre, 23, false);

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    return _sprite;
}


/// @description Returns one baked natural-shield segment level.

function scr_enemy_shield_natural_baked(_segments)
{
    static _sprites = array_create(8, -1);

    _segments = clamp(round(_segments), 1, 8);

    var _index = _segments - 1;
    var _sprite = _sprites[_index];

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _radius = 23;
    var _segment_radius = 26;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    draw_circle(_centre, _centre, _radius, true);

    for (var i = 0; i < _segments; ++i)
    {
        var _angle = i * 45;

        draw_line(
            _centre + lengthdir_x(_segment_radius, _angle - 12),
            _centre + lengthdir_y(_segment_radius, _angle - 12),
            _centre + lengthdir_x(_segment_radius, _angle + 12),
            _centre + lengthdir_y(_segment_radius, _angle + 12)
        );
    }

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    _sprites[_index] = _sprite;

    return _sprite;
}


/// @description Returns the baked support-shield boundary.

function scr_enemy_shield_support_baked()
{
    static _sprite = -1;

    if (sprite_exists(_sprite))
        return _sprite;

    var _size = 64;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    draw_set_color(c_white);
    draw_set_alpha(1);

    draw_circle(_centre, _centre, 28, true);

    surface_reset_target();

    _sprite = sprite_create_from_surface(
        _surface, 0, 0, _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);

    return _sprite;
}

/// @description Draws an enemy's baked natural and support shields.

function scr_enemy_shield_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _shield = _enemy.vitals.shield;
    var _support = _shield.support;

    var _natural_active =
        _shield.enabled
        && _shield.current > 0
        && _shield.maximum > 0;

    var _support_active =
        _support.enabled
        && _support.current > 0
        && _support.maximum > 0;

    if (!_natural_active && !_support_active)
        return true;

    var _x = _enemy.x;
    var _y = _enemy.y;
    var _base_radius = _enemy.visual.radius;
    var _phase = real(_enemy.id);


    // NATURAL SHIELD

    if (_natural_active)
    {
        var _ratio = clamp(_shield.current / _shield.maximum, 0, 1);
        var _radius = _base_radius + 7 + dsin(global.vtd.tick * 3 + _phase);
        var _scale = _radius / 23;
        var _segments = max(1, ceil(_ratio * 8));

        var _fill_sprite = scr_enemy_shield_fill_baked();
        var _shield_sprite = scr_enemy_shield_natural_baked(_segments);

        if (sprite_exists(_fill_sprite))
        {
            draw_sprite_ext(
                _fill_sprite, 0, _x, _y,
                _scale, _scale, 0,
                _shield.color,
                0.035 + (_shield.hit_flash * 0.05)
            );
        }

        if (sprite_exists(_shield_sprite))
        {
            draw_sprite_ext(
                _shield_sprite, 0, _x, _y,
                _scale, _scale, 0,
                _shield.color,
                clamp(
                    0.35
                    + (_ratio * 0.25)
                    + (_shield.hit_flash * 0.35),
                    0,
                    1
                )
            );
        }
    }


    // TEMPORARY SUPPORT SHIELD

    if (_support_active)
    {
        var _ratio = clamp(_support.current / _support.maximum, 0, 1);
        var _radius = _base_radius + 12 + dsin(global.vtd.tick * 5 + _phase);
        var _scale = _radius / 28;
        var _sprite = scr_enemy_shield_support_baked();

        if (sprite_exists(_sprite))
        {
            draw_sprite_ext(
                _sprite, 0, _x, _y,
                _scale, _scale, 0,
                _support.color,
                clamp(
                    0.3
                    + (_ratio * 0.25)
                    + (_support.hit_flash * 0.35),
                    0,
                    1
                )
            );
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);

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


    var _enemy_list =
        ds_list_create();


    collision_circle_list(
        _world_x,
        _world_y,
        _radius,
        o_enemy,
        false,
        true,
        _enemy_list,
        false
    );


    var _count =
        ds_list_size(
            _enemy_list
        );


    for (
        var i = 0;
        i < _count;
        ++i
    )
    {
        var _enemy =
            _enemy_list[| i];


        if (
            _enemy.EnemyState
            == EnemyState.DEAD
        )
        {
            continue;
        }


        if (
            _enemy.movement.layer
            != _target_layer
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


    ds_list_destroy(
        _enemy_list
    );


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


/// @description Draws an enemy's baked status effects.

function scr_enemy_effects_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _effects = _enemy.effects;

    if (
        !_effects.slow.active
        && !_effects.stasis.active
        && !_effects.damage_over_time.active
    )
    {
        return true;
    }

    var _x = _enemy.x;
    var _y = _enemy.y;
    var _radius = _enemy.visual.radius;
    var _phase = real(_enemy.id);


    // CRYO SLOW

    if (_effects.slow.active)
    {
        var _sprite = scr_enemy_effect_slow_baked();

        if (sprite_exists(_sprite))
        {
            var _scale = (_radius + 4) / 20;

            draw_sprite_ext(
                _sprite, 0, _x, _y,
                _scale, _scale,
                global.vtd.tick * 1.5 + _phase,
                c_aqua, 0.75
            );
        }
    }


    // STASIS

    if (_effects.stasis.active)
    {
        var _sprite = scr_enemy_effect_stasis_baked();

        if (sprite_exists(_sprite))
        {
            var _scale = (_radius + 7) / 23;
            var _alpha = 0.65 + dsin(global.vtd.tick * 8 + _phase) * 0.2;

            draw_sprite_ext(
                _sprite, 0, _x, _y,
                _scale, _scale,
                0,
                make_color_rgb(120, 170, 255),
                _alpha
            );
        }
    }


    // DISRUPTION / DAMAGE OVER TIME

    if (_effects.damage_over_time.active)
    {
        var _sprite = scr_enemy_effect_disruption_baked();

        if (sprite_exists(_sprite))
        {
            var _scale = (_radius + 5) / 21;
            var _alpha = 0.55 + dsin(global.vtd.tick * 7 + _phase) * 0.25;

            draw_sprite_ext(
                _sprite, 0, _x, _y,
                _scale, _scale,
                global.vtd.tick * -3 + _phase,
                make_color_rgb(190, 70, 255),
                _alpha
            );
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

