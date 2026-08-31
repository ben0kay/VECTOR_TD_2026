/// @description Applies one attack area to valid enemies.

function scr_attack_area_apply(
    _source,
    _source_type,
    _damage_type,
    _target_layer,
    _world_x,
    _world_y,
    _direction,
    _damage,
    _area
)
{
    if (!is_struct(_area))
        return 0;


    switch (_area.shape)
    {
        case AttackAreaShape.POINT:
        {
            // Point attacks should normally use scr_enemy_damage directly.
            return 0;
        }


        case AttackAreaShape.CIRCLE:
        {
            return scr_attack_area_circle_apply(
                _source,
                _source_type,
                _damage_type,
                _target_layer,
                _world_x,
                _world_y,
                _damage,
                _area
            );
        }


        case AttackAreaShape.CAPSULE:
		{
		    return scr_attack_area_capsule_apply(
		        _source, _source_type, _damage_type, _target_layer,
		        _world_x, _world_y, _direction, _damage, _area
		    );
		}

		case AttackAreaShape.LINE:
		case AttackAreaShape.CONE:
		    return 0;
        }
}



/// @description Applies circular damage with optional distance falloff.

function scr_attack_area_circle_apply(
    _source,
    _source_type,
    _damage_type,
    _target_layer,
    _world_x,
    _world_y,
    _damage,
    _area
)
{
    var _radius =
        max(
            0,
            _area.radius
        );

    if (_radius <= 0)
        return 0;


    var _falloff_enabled = false;
    var _minimum_multiplier = 1;
    var _falloff_exponent = 1;


    if (
        variable_struct_exists(_area, "falloff")
        && is_struct(_area.falloff)
    )
    {
        var _falloff = _area.falloff;

        if (variable_struct_exists(_falloff, "enabled"))
            _falloff_enabled = _falloff.enabled;

        if (variable_struct_exists(_falloff, "minimum_multiplier"))
        {
            _minimum_multiplier =
                clamp(
                    _falloff.minimum_multiplier,
                    0,
                    1
                );
        }

        if (variable_struct_exists(_falloff, "exponent"))
        {
            _falloff_exponent =
                max(
                    0.01,
                    _falloff.exponent
                );
        }
    }


    var _hit_count = 0;
    var _enemy_count = instance_number(o_enemy);


    for (var i = 0; i < _enemy_count; ++i)
    {
        var _enemy = instance_find(o_enemy, i);

        if (!instance_exists(_enemy))
            continue;

        if (_enemy.EnemyState == EnemyState.DEAD)
            continue;

        if (
            _enemy.movement.layer
            != _target_layer
        )
        {
            continue;
        }


        var _distance =
            point_distance(
                _world_x,
                _world_y,
                _enemy.x,
                _enemy.y
            );

        if (
            _distance
            > _radius + _enemy.visual.radius
        )
        {
            continue;
        }


        var _damage_multiplier = 1;


        if (_falloff_enabled)
        {
            var _distance_ratio =
                clamp(
                    _distance / _radius,
                    0,
                    1
                );

            _damage_multiplier =
                lerp(
                    1,
                    _minimum_multiplier,
                    power(
                        _distance_ratio,
                        _falloff_exponent
                    )
                );
        }


        var _packet =
            scr_damage_create(
                _damage * _damage_multiplier,
                _source,
                _source_type,
                _damage_type
            );


        if (scr_enemy_damage(_enemy, _packet))
            _hit_count++;
    }


    return _hit_count;
}

/// @description Returns squared distance between a point and line segment.

function scr_attack_area_point_segment_distance_squared(_px, _py, _x1, _y1, _x2, _y2)
{
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _length_squared = (_dx * _dx) + (_dy * _dy);

    if (_length_squared <= 0)
        return sqr(_px - _x1) + sqr(_py - _y1);

    var _position = clamp(
        (((_px - _x1) * _dx) + ((_py - _y1) * _dy)) / _length_squared,
        0,
        1
    );

    var _closest_x = _x1 + (_dx * _position);
    var _closest_y = _y1 + (_dy * _position);

    return sqr(_px - _closest_x) + sqr(_py - _closest_y);
}


/// @description Returns whether a segment crosses an expanded rectangle.

function scr_attack_area_segment_rectangle_overlap(
    _x1, _y1, _x2, _y2,
    _left, _top, _right, _bottom,
    _radius
)
{
    _left -= _radius;
    _top -= _radius;
    _right += _radius;
    _bottom += _radius;

    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _minimum = 0;
    var _maximum = 1;

    if (abs(_dx) < 0.0001)
    {
        if (_x1 < _left || _x1 > _right)
            return false;
    }
    else
    {
        var _a = (_left - _x1) / _dx;
        var _b = (_right - _x1) / _dx;

        _minimum = max(_minimum, min(_a, _b));
        _maximum = min(_maximum, max(_a, _b));

        if (_minimum > _maximum)
            return false;
    }

    if (abs(_dy) < 0.0001)
    {
        if (_y1 < _top || _y1 > _bottom)
            return false;
    }
    else
    {
        var _a = (_top - _y1) / _dy;
        var _b = (_bottom - _y1) / _dy;

        _minimum = max(_minimum, min(_a, _b));
        _maximum = min(_maximum, max(_a, _b));

        if (_minimum > _maximum)
            return false;
    }

    return true;
}


/// @description Returns whether one entity intersects a capsule.

function scr_attack_area_capsule_target_overlap(
    _target,
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _radius
)
{
    if (!instance_exists(_target))
        return false;

    var _is_building =
        _target.object_index == o_building_par
        || object_is_ancestor(_target.object_index, o_building_par);

    if (_is_building || _target.object_index == o_cpu)
    {
        var _cell_size = global.vtd_level.map.cell_size;
        var _half_width = _target.footprint.width_cells * _cell_size * 0.5;
        var _half_height = _target.footprint.height_cells * _cell_size * 0.5;

        return scr_attack_area_segment_rectangle_overlap(
            _start_x, _start_y, _end_x, _end_y,
            _target.x - _half_width,
            _target.y - _half_height,
            _target.x + _half_width,
            _target.y + _half_height,
            _radius
        );
    }

    var _target_radius = _target.visual.radius + _radius;

    return scr_attack_area_point_segment_distance_squared(
        _target.x, _target.y,
        _start_x, _start_y,
        _end_x, _end_y
    ) <= sqr(_target_radius);
}


/// @description Applies capsule damage to all valid entities along a segment.

function scr_attack_area_capsule_apply(
    _source,
    _source_type,
    _damage_type,
    _target_layer,
    _world_x,
    _world_y,
    _direction,
    _damage,
    _area
)
{
    var _radius = max(0, _area.radius);
    var _length = max(0, _area.length);

    if (_radius <= 0 || _length <= 0 || _damage <= 0)
        return 0;

    var _end_x = _world_x + lengthdir_x(_length, _direction);
    var _end_y = _world_y + lengthdir_y(_length, _direction);
    var _hit_count = 0;


    // ENEMY BEAM: damage player, CPU and buildings.

    if (_source_type == DamageSource.ENEMY)
    {
        var _player = global.vtd_level.entities.player;
        var _cpu = global.vtd_level.entities.cpu;

        if (
            scr_attack_area_capsule_target_overlap(
                _player, _world_x, _world_y, _end_x, _end_y, _radius
            )
            && scr_enemy_damage_target(
                _source, _player, _damage, _damage_type
            )
        )
        {
            _hit_count++;
        }

        if (
            scr_attack_area_capsule_target_overlap(
                _cpu, _world_x, _world_y, _end_x, _end_y, _radius
            )
            && scr_enemy_damage_target(
                _source, _cpu, _damage, _damage_type
            )
        )
        {
            _hit_count++;
        }

        var _building_count = instance_number(o_building_par);

        for (var i = 0; i < _building_count; ++i)
        {
            var _building = instance_find(o_building_par, i);

            if (!scr_enemy_building_target_valid(_building))
                continue;

            if (
                scr_attack_area_capsule_target_overlap(
                    _building,
                    _world_x, _world_y,
                    _end_x, _end_y,
                    _radius
                )
                && scr_enemy_damage_target(
                    _source, _building, _damage, _damage_type
                )
            )
            {
                _hit_count++;
            }
        }

        return _hit_count;
    }


    // PLAYER/TOWER CAPSULE: damage enemies.

    var _enemy_count = instance_number(o_enemy);

    for (var i = 0; i < _enemy_count; ++i)
    {
        var _enemy = instance_find(o_enemy, i);

        if (!instance_exists(_enemy))
            continue;

        if (_enemy.EnemyState == EnemyState.DEAD)
            continue;

        if (_enemy.movement.layer != _target_layer)
            continue;

        if (
            !scr_attack_area_capsule_target_overlap(
                _enemy,
                _world_x, _world_y,
                _end_x, _end_y,
                _radius
            )
        )
        {
            continue;
        }

        var _packet = scr_damage_create(
            _damage,
            _source,
            _source_type,
            _damage_type
        );

        if (scr_enemy_damage(_enemy, _packet))
            _hit_count++;
    }

    return _hit_count;
}