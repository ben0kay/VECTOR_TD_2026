/// @description Creates one primitive shockwave on the appropriate effects layer.

function scr_effect_shockwave_create(
    _world_x,
    _world_y,
    _radius,
    _color,
    _movement_layer = EnemyMovementLayer.GROUND
)
{
    return instance_create_layer(
        _world_x,
        _world_y,

        scr_layer_effect_get(
            _movement_layer
        ),

        o_effect,
        {
            effect_type: EffectType.SHOCKWAVE,
            effect_duration: 0.35,
            effect_color: _color,
            effect_radius_start: 6,
            effect_radius_end: max(6, _radius)
        }
    );
}

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


    // ========================================================================
    // COMMON EFFECT RUNTIME
    // ========================================================================

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
            _effect.effect_radius_end,

        death:
            undefined,

        construction:
            undefined
    };


    // ========================================================================
    // TYPE-SPECIFIC RUNTIME
    // ========================================================================

    switch (_effect.effect.type)
    {
        case EffectType.CONSTRUCTION_COMPLETE:
        {
            if (
                !variable_instance_exists(
                    _effect,
                    "effect_footprint_width"
                )
            )
            {
                return false;
            }

            if (
                !variable_instance_exists(
                    _effect,
                    "effect_footprint_height"
                )
            )
            {
                return false;
            }

            _effect.effect.construction =
            {
                width:
                    _effect.effect_footprint_width,

                height:
                    _effect.effect_footprint_height
            };
        }
        break;


        case EffectType.ENEMY_DEATH:
        {
            if (
                !variable_instance_exists(
                    _effect,
                    "effect_enemy_radius"
                )
            )
            {
                return false;
            }

            if (
                !variable_instance_exists(
                    _effect,
                    "effect_ghost_sides"
                )
            )
            {
                return false;
            }

            if (
                !variable_instance_exists(
                    _effect,
                    "effect_fragment_count"
                )
            )
            {
                return false;
            }

            if (
                !variable_instance_exists(
                    _effect,
                    "effect_spark_count"
                )
            )
            {
                return false;
            }


            var _fragments =
                [];

            var _total_count =
                _effect.effect_fragment_count
                + _effect.effect_spark_count;

            for (
                var i = 0;
                i < _total_count;
                ++i
            )
            {
                var _is_spark =
                    i
                    >= _effect.effect_fragment_count;

                var _speed =
                    _is_spark
                    ? random_range(
                        _effect.effect_enemy_radius * 4.5,
                        _effect.effect_enemy_radius * 7.0
                    )
                    : random_range(
                        _effect.effect_enemy_radius * 2.3,
                        _effect.effect_enemy_radius * 4.4
                    );

                array_push(
                    _fragments,
                    {
                        spark:
                            _is_spark,

                        x:
                            _effect.x,

                        y:
                            _effect.y,

                        angle:
                            random(360),

                        speed:
                            _speed,

                        deceleration:
                            _speed
                            * random_range(
                                1.5,
                                2.3
                            ),

                        rotation:
                            random(360),

                        rotation_speed:
                            random_range(
                                -540,
                                540
                            ),

                        size:
                            _is_spark
                            ? random_range(2, 4)
                            : clamp(
                                _effect.effect_enemy_radius
                                * random_range(
                                    0.12,
                                    0.26
                                ),
                                2,
                                8
                            ),

                        age:
                            0,

                        duration:
                            _is_spark
                            ? random_range(0.22, 0.42)
                            : random_range(0.35, 0.65),

                        sides:
                            irandom_range(3, 4)
                    }
                );
            }


            _effect.effect.death =
            {
                radius:
                    _effect.effect_enemy_radius,

                ghost_sides:
                    _effect.effect_ghost_sides,

                fragments:
                    _fragments
            };
        }
        break;
    }


    return true;
}


/// @description Updates the debris owned by one enemy-death effect.

function scr_effect_enemy_death_update(
    _effect,
    _delta
)
{
    if (!instance_exists(_effect))
        return false;


    var _death =
        _effect.effect.death;

    var _fragments =
        _death.fragments;

    for (
        var i = 0;
        i < array_length(_fragments);
        ++i
    )
    {
        var _fragment =
            _fragments[i];

        if (
            _fragment.age
            >= _fragment.duration
        )
        {
            continue;
        }

        _fragment.age =
            min(
                _fragment.duration,
                _fragment.age + _delta
            );

        _fragment.x +=
            lengthdir_x(
                _fragment.speed * _delta,
                _fragment.angle
            );

        _fragment.y +=
            lengthdir_y(
                _fragment.speed * _delta,
                _fragment.angle
            );

        _fragment.speed =
            max(
                0,
                _fragment.speed
                - (
                    _fragment.deceleration
                    * _delta
                )
            );

        _fragment.rotation +=
            _fragment.rotation_speed
            * _delta;

        _fragments[i] =
            _fragment;
    }

    _death.fragments =
        _fragments;

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

    var _delta =
        1 / _fps;


    if (
        _effect.effect.type
        == EffectType.ENEMY_DEATH
    )
    {
        scr_effect_enemy_death_update(
            _effect,
            _delta
        );
    }


    _effect.effect.age +=
        _delta;


    if (
        _effect.effect.age
        >= _effect.effect.duration
    )
    {
        instance_destroy(_effect);
        return false;
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

/// @description Draws one vector enemy-death flash, ghost, ring, and debris burst.

function scr_effect_draw_enemy_death(_effect)
{
    if (!instance_exists(_effect))
        return false;


    var _data =
        _effect.effect;

    var _death =
        _data.death;

    var _progress =
        clamp(
            _data.age
            / _data.duration,
            0,
            1
        );


    // ========================================================================
    // WHITE GHOST / INITIAL FLASH
    // ========================================================================

    var _ghost_progress =
        clamp(
            _progress / 0.25,
            0,
            1
        );

    var _ghost_radius =
        lerp(
            _death.radius * 0.70,
            _death.radius * 1.20,
            _ghost_progress
        );

    var _ghost_alpha =
        (1 - _ghost_progress)
        * 0.95;

    draw_set_color(c_white);
    draw_set_alpha(_ghost_alpha);

    draw_circle(
        _effect.x,
        _effect.y,
        max(
            2,
            _death.radius * 0.38
        ),
        false
    );

    scr_enemy_visual_helper_polygon(
        _effect.x,
        _effect.y,
        _ghost_radius,
        _death.ghost_sides,
        _progress * 80,
        2
    );


    // ========================================================================
    // COLOURED EXPANDING RING
    // ========================================================================

    var _ring_radius =
        lerp(
            _data.radius_start,
            _data.radius_end,
            _progress
        );

    draw_set_color(_data.color);
    draw_set_alpha(
        (1 - _progress)
        * 0.85
    );

    draw_circle(
        _effect.x,
        _effect.y,
        _ring_radius,
        true
    );


    // ========================================================================
    // COLOURED FRAGMENTS / SPARKS
    // ========================================================================

    var _fragments =
        _death.fragments;

    for (
        var i = 0;
        i < array_length(_fragments);
        ++i
    )
    {
        var _fragment =
            _fragments[i];

        var _fragment_progress =
            clamp(
                _fragment.age
                / _fragment.duration,
                0,
                1
            );

        if (_fragment_progress >= 1)
            continue;

        draw_set_alpha(
            (1 - _fragment_progress)
            * 0.95
        );

        if (_fragment.spark)
        {
            draw_line_width(
                _fragment.x,
                _fragment.y,

                _fragment.x
                - lengthdir_x(
                    _fragment.size * 3,
                    _fragment.angle
                ),

                _fragment.y
                - lengthdir_y(
                    _fragment.size * 3,
                    _fragment.angle
                ),

                1
            );

            continue;
        }

        scr_enemy_visual_helper_polygon(
            _fragment.x,
            _fragment.y,
            _fragment.size,
            _fragment.sides,
            _fragment.rotation,
            1
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

/// @description Draws a building-sized activation flash when construction completes.

function scr_effect_draw_construction_complete(_effect)
{
    if (!instance_exists(_effect))
        return false;


    var _data =
        _effect.effect;

    var _construction =
        _data.construction;

    var _progress =
        clamp(
            _data.age
            / _data.duration,
            0,
            1
        );

    var _flash_progress =
        clamp(
            _progress / 0.20,
            0,
            1
        );

    var _flash_alpha =
        (1 - _flash_progress)
        * 0.42;

    var _expand =
        lerp(
            0,
            14,
            _progress
        );

    var _half_width =
        (_construction.width * 0.5)
        + _expand;

    var _half_height =
        (_construction.height * 0.5)
        + _expand;

    var _left =
        _effect.x - _half_width;

    var _right =
        _effect.x + _half_width;

    var _top =
        _effect.y - _half_height;

    var _bottom =
        _effect.y + _half_height;


    // Brief whole-footprint system-online flash.

    draw_set_color(c_white);
    draw_set_alpha(_flash_alpha);

    draw_rectangle(
        _effect.x
        - (_construction.width * 0.5),

        _effect.y
        - (_construction.height * 0.5),

        _effect.x
        + (_construction.width * 0.5),

        _effect.y
        + (_construction.height * 0.5),

        false
    );


    // Main coloured outline expanding away from the completed building.

    draw_set_color(_data.color);
    draw_set_alpha(
        (1 - _progress)
        * 0.95
    );

    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        true
    );


    // Short bright corner braces make the activation easier to notice.

    draw_set_alpha(
        (1 - _progress)
        * 0.85
    );

    var _brace_length =
        lerp(
            12,
            3,
            _progress
        );

    draw_line_width(
        _left,
        _top,
        _left + _brace_length,
        _top,
        2
    );

    draw_line_width(
        _left,
        _top,
        _left,
        _top + _brace_length,
        2
    );

    draw_line_width(
        _right,
        _top,
        _right - _brace_length,
        _top,
        2
    );

    draw_line_width(
        _right,
        _top,
        _right,
        _top + _brace_length,
        2
    );

    draw_line_width(
        _left,
        _bottom,
        _left + _brace_length,
        _bottom,
        2
    );

    draw_line_width(
        _left,
        _bottom,
        _left,
        _bottom - _brace_length,
        2
    );

    draw_line_width(
        _right,
        _bottom,
        _right - _brace_length,
        _bottom,
        2
    );

    draw_line_width(
        _right,
        _bottom,
        _right,
        _bottom - _brace_length,
        2
    );


    // One final expanding circular energy ring.

    var _ring_radius =
        lerp(
            8,
            max(
                _construction.width,
                _construction.height
            )
            * 0.90,
            _progress
        );

    draw_set_alpha(
        (1 - _progress)
        * 0.55
    );

    draw_circle(
        _effect.x,
        _effect.y,
        _ring_radius,
        true
    );


    draw_set_alpha(1);
    draw_set_color(c_white);

    return true;
}

function scr_effect_draw(_effect)
{
    if (!instance_exists(_effect))
        return false;


    switch (_effect.effect.type)
    {
        case EffectType.SHOCKWAVE:
            return scr_effect_draw_shockwave(_effect);
			
		case EffectType.CONSTRUCTION_COMPLETE:
            return scr_effect_draw_construction_complete(_effect);

		case EffectType.ENEMY_DEATH:
            return scr_effect_draw_enemy_death(_effect);
			
        case EffectType.IMPACT_FLASH:
        case EffectType.BEAM_IMPACT:
        {
            // FUTURE EFFECTS
        }
        break;
    }


    return true;
}

/// @description Creates one data-driven vector death effect from an enemy.

function scr_effect_enemy_death_create(_enemy)
{
    if (!instance_exists(_enemy))
        return noone;


    var _radius =
        max(
            6,
            _enemy.visual.radius
        );

    var _fragment_count =
        clamp(
            round(
                2
                + (_radius * 0.16)
            ),
            3,
            8
        );

    var _spark_count =
        clamp(
            round(
                1
                + (_radius * 0.10)
            ),
            2,
            6
        );

    var _ghost_sides =
        6;

    if (_radius <= 14)
    {
        _ghost_sides = 4;
    }
    else if (_radius >= 28)
    {
        _ghost_sides = 8;
    }


    return instance_create_layer(
        _enemy.x,
        _enemy.y,

        scr_layer_effect_get(
            _enemy.movement.layer
        ),

        o_effect,
        {
            effect_type:
                EffectType.ENEMY_DEATH,

            effect_duration:
                clamp(
                    0.38
                    + (_radius * 0.012),
                    0.45,
                    0.80
                ),

            effect_color:
                _enemy.visual.color,

            effect_radius_start:
                max(
                    4,
                    _radius * 0.55
                ),

            effect_radius_end:
                _radius * 1.90,

            effect_enemy_radius:
                _radius,

            effect_ghost_sides:
                _ghost_sides,

            effect_fragment_count:
                _fragment_count,

            effect_spark_count:
                _spark_count
        }
    );
}

/// @description Creates one footprint-sized construction-completion activation effect.

function scr_effect_construction_complete_create(_building)
{
    if (!instance_exists(_building))
        return noone;


    var _cell_size =
        global.vtd_level.map.cell_size;

    var _width =
        _building.footprint.width_cells
        * _cell_size;

    var _height =
        _building.footprint.height_cells
        * _cell_size;


    return instance_create_layer(
        _building.x,
        _building.y,
        "Effects_Ground",
        o_effect,
        {
            effect_type:
                EffectType.CONSTRUCTION_COMPLETE,

            effect_duration:
                0.55,

            effect_color:
                _building.visual.color,

            effect_radius_start:
                0,

            effect_radius_end:
                max(
                    _width,
                    _height
                ),

            effect_footprint_width:
                _width,

            effect_footprint_height:
                _height
        }
    );
}