/// @description Hostile projectile creation, collision, damage, and drawing.


/// @description Creates one hostile projectile on its owner's visual layer.

function scr_projectile_enemy_create(
    _owner,
    _world_x,
    _world_y,
    _draw_angle,
    _damage,
    _projectile_data
)
{
    if (!instance_exists(_owner))
        return noone;

    if (!is_struct(_projectile_data))
        return noone;


    return instance_create_layer(
        _world_x,
        _world_y,

        scr_layer_projectile_get(
            _owner.movement.layer
        ),

        o_projectile_enemy,
        {
            projectile_owner: _owner,
            projectile_damage: _damage,
            projectile_speed: _projectile_data.speed,
            projectile_lifetime: _projectile_data.lifetime_seconds,
            projectile_radius: _projectile_data.radius,
            projectile_color: _projectile_data.color,
            projectile_angle: _draw_angle
        }
    );
}


/// @description Initializes one hostile projectile runtime.

function scr_projectile_enemy_initialize(_projectile)
{
    if (!instance_exists(_projectile))
        return false;


    _projectile.combat =
    {
        owner: _projectile.projectile_owner,
        damage: _projectile.projectile_damage
    };


    _projectile.movement =
    {
        speed: _projectile.projectile_speed
    };


    _projectile.life =
    {
        remaining: _projectile.projectile_lifetime
    };


    _projectile.visual =
    {
        draw_angle: _projectile.projectile_angle,
        radius: _projectile.projectile_radius,
        color: _projectile.projectile_color
    };


    return true;
}


/// @description Returns an approximate collision radius for a hostile target.

function scr_projectile_enemy_target_radius(_target)
{
    if (!instance_exists(_target))
        return 0;


    if (_target.object_index == o_cpu)
        return _target.visual.radius;


    if (_target.object_index == o_player)
        return _target.visual.radius;


    if (
        _target.object_index == o_building_par
        || object_is_ancestor(_target.object_index, o_building_par)
    )
    {
        var _cell_size = global.vtd_level.map.cell_size;
        var _width = _target.footprint.width_cells * _cell_size;
        var _height = _target.footprint.height_cells * _cell_size;

        return point_distance(0, 0, _width * 0.5, _height * 0.5);
    }


    return 0;
}


/// @description Considers one instance as the possible first projectile hit.

function scr_projectile_enemy_hit_consider(
    _projectile,
    _target,
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _result
)
{
    if (!instance_exists(_target))
        return _result;


    var _target_radius = scr_projectile_enemy_target_radius(_target);
    var _collision_radius = _target_radius + _projectile.visual.radius;

    var _distance_squared = scr_point_segment_distance_squared(
        _target.x,
        _target.y,
        _start_x,
        _start_y,
        _end_x,
        _end_y
    );


    if (_distance_squared > _collision_radius * _collision_radius)
        return _result;


    var _travel_distance = point_distance(
        _start_x,
        _start_y,
        _target.x,
        _target.y
    );


    if (_travel_distance < _result.distance)
    {
        _result.target = _target;
        _result.distance = _travel_distance;
    }


    return _result;
}


/// @description Finds the first CPU, player, or building crossed by a projectile.

function scr_projectile_enemy_hit_find(
    _projectile,
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    var _result =
    {
        target: noone,
        distance: infinity
    };


    _result = scr_projectile_enemy_hit_consider(
        _projectile,
        global.vtd_level.entities.cpu,
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        _result
    );


    _result = scr_projectile_enemy_hit_consider(
        _projectile,
        global.vtd_level.entities.player,
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        _result
    );


    var _building_count = instance_number(o_building_par);

    for (var i = 0; i < _building_count; ++i)
    {
        var _building = instance_find(o_building_par, i);

        if (!scr_enemy_building_target_valid(_building))
            continue;

        _result = scr_projectile_enemy_hit_consider(
            _projectile,
            _building,
            _start_x,
            _start_y,
            _end_x,
            _end_y,
            _result
        );
    }


    return _result.target;
}


/// @description Applies projectile damage according to the impacted object type.

function scr_projectile_enemy_damage_target(_projectile, _target)
{
    if (!instance_exists(_projectile))
        return false;

    if (!instance_exists(_target))
        return false;


    var _damage = scr_damage_create(
        _projectile.combat.damage,
        _projectile.combat.owner,
        DamageSource.ENEMY
    );


    if (_target.object_index == o_cpu)
        return scr_cpu_damage(_target, _damage.amount);


    if (_target.object_index == o_player)
        return scr_player_damage(_target, _damage);


    if (
        _target.object_index == o_building_par
        || object_is_ancestor(_target.object_index, o_building_par)
    )
    {
        return scr_building_damage(_target, _damage);
    }


    return false;
}


/// @description Moves one hostile projectile and resolves its first impact.

function scr_projectile_enemy_update(_projectile)
{
    if (!instance_exists(_projectile))
        return false;


    var _fps = max(1, game_get_speed(gamespeed_fps));

    _projectile.life.remaining = max(
        0,
        _projectile.life.remaining - (1 / _fps)
    );


    if (_projectile.life.remaining <= 0)
    {
        instance_destroy(_projectile);
        return true;
    }


    var _start_x = _projectile.x;
    var _start_y = _projectile.y;

    var _end_x = _start_x + lengthdir_x(
        _projectile.movement.speed,
        _projectile.visual.draw_angle
    );

    var _end_y = _start_y + lengthdir_y(
        _projectile.movement.speed,
        _projectile.visual.draw_angle
    );


    var _target = scr_projectile_enemy_hit_find(
        _projectile,
        _start_x,
        _start_y,
        _end_x,
        _end_y
    );


    if (instance_exists(_target))
    {
        scr_projectile_enemy_damage_target(_projectile, _target);

        // FUTURE:
        // impact particles
        // shield effects
        // projectile sounds

        instance_destroy(_projectile);
        return true;
    }


    _projectile.x = _end_x;
    _projectile.y = _end_y;

    return true;
}


/// @description Draws one hostile vector projectile.

function scr_projectile_enemy_draw(_projectile)
{
    if (!instance_exists(_projectile))
        return false;


    var _visual = _projectile.visual;

    var _trail_x = _projectile.x - lengthdir_x(12, _visual.draw_angle);
    var _trail_y = _projectile.y - lengthdir_y(12, _visual.draw_angle);


    draw_set_color(_visual.color);
    draw_line_width(_trail_x, _trail_y, _projectile.x, _projectile.y, 3);
    draw_circle(_projectile.x, _projectile.y, _visual.radius, false);
    draw_set_color(c_white);


    return true;
}