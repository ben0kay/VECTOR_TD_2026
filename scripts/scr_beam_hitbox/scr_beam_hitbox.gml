/// @description Creates one reusable invisible beam hitbox.

function scr_beam_hitbox_create(
    _owner,
    _source_type,
    _damage_type,
    _damage_per_second,
    _radius,
    _target_layer
)
{
    if (!instance_exists(_owner))
        return noone;

    var _beam =
        instance_create_layer(
            _owner.x,
            _owner.y,
            "Instances",
            o_beam_hitbox
        );

    _beam.owner = _owner;
    _beam.source_type = _source_type;
    _beam.damage_type = _damage_type;
    _beam.damage_per_second = _damage_per_second;
    _beam.radius = max(1, _radius);
    _beam.target_layer = _target_layer;

    return _beam;
}


/// @description Positions one beam hitbox between two world positions.

function scr_beam_hitbox_geometry_set(
    _beam,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    if (!instance_exists(_beam))
        return false;

    var _length =
        point_distance(
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );

    if (_length <= 0)
    {
        _beam.active = false;
        _beam.image_xscale = 0;
        return false;
    }

    _beam.x = (_start_x + _end_x) * 0.5;
    _beam.y = (_start_y + _end_y) * 0.5;

    _beam.image_angle =
        point_direction(
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );

    _beam.image_xscale =
        _length
        / sprite_get_width(s_collision_square);

    _beam.image_yscale =
        (_beam.radius * 2)
        / sprite_get_height(s_collision_square);

    _beam.active = true;

    return true;
}


/// @description Removes one reusable beam hitbox.

function scr_beam_hitbox_remove(_beam)
{
    if (instance_exists(_beam))
        instance_destroy(_beam);

    return noone;
}


/// @description Applies an enemy beam hit to a player-side entity.

function scr_beam_hitbox_player_side_damage(_beam, _target)
{
    if (!instance_exists(_beam) || !instance_exists(_target))
        return false;

    if (!_beam.active)
        return false;

    if (_beam.source_type != DamageSource.ENEMY)
        return false;

    return scr_enemy_damage_target(
        _beam.owner,
        _target,
        _beam.damage_per_step,
        _beam.damage_type
    );
}


/// @description Applies a player or tower beam hit to one enemy.

function scr_beam_hitbox_enemy_damage(_beam, _enemy)
{
    if (!instance_exists(_beam) || !instance_exists(_enemy))
        return false;

    if (!_beam.active)
        return false;

    if (_beam.source_type == DamageSource.ENEMY)
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (_enemy.movement.layer != _beam.target_layer)
        return false;

    return scr_enemy_damage(
        _enemy,
        scr_damage_create(
            _beam.damage_per_step,
            _beam.owner,
            _beam.source_type,
            _beam.damage_type
        )
    );
}