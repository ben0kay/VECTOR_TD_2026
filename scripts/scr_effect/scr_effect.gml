/// @description Creates one primitive vector shockwave effect.

function scr_effect_shockwave_create(
    _world_x,
    _world_y,
    _radius,
    _color
)
{
    return instance_create_layer(
        _world_x,
        _world_y,
        "Instances",
        o_effect,
        {
            effect_type:
                EffectType.SHOCKWAVE,

            effect_duration:
                0.35,

            effect_color:
                _color,

            effect_radius_start:
                6,

            effect_radius_end:
                max(6, _radius)
        }
    );
}

/// @description Initializes one temporary primitive effect.

function scr_effect_initialize(_effect)
{
    if (!instance_exists(_effect))
        return false;


    if (!variable_instance_exists(_effect, "effect_type"))
        return false;

    if (!variable_instance_exists(_effect, "effect_duration"))
        return false;

    if (!variable_instance_exists(_effect, "effect_color"))
        return false;

    if (!variable_instance_exists(_effect, "effect_radius_start"))
        return false;

    if (!variable_instance_exists(_effect, "effect_radius_end"))
        return false;


    _effect.effect =
    {
        type:
            _effect.effect_type,

        age:
            0,

        duration:
            max(
                0.01,
                _effect.effect_duration
            ),

        color:
            _effect.effect_color,

        radius_start:
            _effect.effect_radius_start,

        radius_end:
            _effect.effect_radius_end
    };


    return true;
}

/// @description Updates one temporary primitive effect.

function scr_effect_update(_effect)
{
    if (!instance_exists(_effect))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _effect.effect.age +=
        1 / _fps;


    if (
        _effect.effect.age
        >= _effect.effect.duration
    )
    {
        instance_destroy(_effect);
    }


    return true;
}

/// @description Draws one expanding primitive shockwave.

function scr_effect_draw_shockwave(_effect)
{
    if (!instance_exists(_effect))
        return false;


    var _data =
        _effect.effect;

    var _progress =
        clamp(
            _data.age
            / _data.duration,
            0,
            1
        );

    var _radius =
        lerp(
            _data.radius_start,
            _data.radius_end,
            _progress
        );

    var _alpha =
        1 - _progress;


    // Main expanding ring.

    draw_set_color(
        _data.color
    );

    draw_set_alpha(
        _alpha * 0.9
    );

    draw_circle(
        _effect.x,
        _effect.y,
        _radius,
        true
    );


    // Secondary ring trails behind the first.

    draw_set_alpha(
        _alpha * 0.4
    );

    draw_circle(
        _effect.x,
        _effect.y,
        max(1, _radius - 7),
        true
    );


    // Short radial impact marks.

    draw_set_alpha(
        _alpha * 0.7
    );

    for (var i = 0; i < 8; ++i)
    {
        var _angle =
            (i * 45)
            + (real(_effect.id) mod 45);

        draw_line(
            _effect.x
                + lengthdir_x(_radius - 4, _angle),

            _effect.y
                + lengthdir_y(_radius - 4, _angle),

            _effect.x
                + lengthdir_x(_radius + 7, _angle),

            _effect.y
                + lengthdir_y(_radius + 7, _angle)
        );
    }


    // FUTURE PARTICLE HOOKS:
    //
    // scr_particle_burst_create(...)
    // scr_particle_sparks_create(...)
    // scr_particle_debris_create(...)
    //
    // Particle sprites can be added here without changing attack damage.


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws one generic temporary effect.

function scr_effect_draw(_effect)
{
    if (!instance_exists(_effect))
        return false;


    switch (_effect.effect.type)
    {
        case EffectType.SHOCKWAVE:
            return scr_effect_draw_shockwave(_effect);

        case EffectType.IMPACT_FLASH:
        case EffectType.BEAM_IMPACT:
        {
            // FUTURE EFFECTS
        }
        break;
    }


    return true;
}