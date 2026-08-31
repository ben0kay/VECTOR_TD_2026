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
	        return 0;

	    case AttackAreaShape.CIRCLE:
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

	    case AttackAreaShape.CAPSULE:
	    case AttackAreaShape.LINE:
	    case AttackAreaShape.CONE:
	        return 0;
	}

	return 0;
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

