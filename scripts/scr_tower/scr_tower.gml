/// @description Generic data-driven tower targeting, firing, and drawing.


/// @description Initializes one tower after its building parent.

function scr_tower_initialize(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.building_data))
        return false;

    if (!variable_struct_exists(_tower.building_data, "tower"))
        return false;


    var _data = _tower.building_data.tower;

    _tower.visual.turret_color =
        _tower.building_data.visual.turret_color;

    _tower.visual.draw_angle = 0;
    _tower.visual.draw_function = scr_tower_visual_ground;


    if (variable_struct_exists(_data, "draw_function"))
    {
        _tower.visual.draw_function =
            _data.draw_function;
    }


    var _requires_line_of_sight = true;

    if (variable_struct_exists(_data, "requires_line_of_sight"))
    {
        _requires_line_of_sight =
            _data.requires_line_of_sight;
    }


    _tower.targeting =
    {
        target: noone,
        mode: _data.target_mode,
        layer: _data.target_layer,

        requires_line_of_sight:
            _requires_line_of_sight
    };


    _tower.combat =
    {
        kills: 0,
        range: _data.range,

        weapon:
        {
            damage: _data.weapon.damage,

            cooldown:
            {
                duration: _data.weapon.cooldown_seconds,
                remaining: 0
            },

            projectile:
            {
                speed: _data.weapon.projectile.speed,

                lifetime_seconds:
                    _data.weapon.projectile.lifetime_seconds,

                radius: _data.weapon.projectile.radius,
                color: _data.weapon.projectile.color,
                impact: _data.weapon.projectile.impact,

                damage_radius:
                    _data.weapon.projectile.damage_radius
            }
        }
    };


    return true;
}


/// @description Returns whether an enemy is visible and targetable.

function scr_tower_target_valid(_tower, _enemy)
{
    if (!instance_exists(_tower))
        return false;

    if (!instance_exists(_enemy))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (
        _enemy.movement.layer
        != _tower.targeting.layer
    )
    {
        return false;
    }

    if (!scr_fog_position_visible(_enemy.x, _enemy.y))
        return false;


    if (
        point_distance(
            _tower.x,
            _tower.y,
            _enemy.x,
            _enemy.y
        )
        > _tower.combat.range
            + _enemy.visual.radius
    )
    {
        return false;
    }


    if (
        _tower.targeting.requires_line_of_sight
        && scr_world_line_blocked_by_dead(
            _tower.x,
            _tower.y,
            _enemy.x,
            _enemy.y
        )
    )
    {
        return false;
    }


    return true;
}


/// @description Acquires an enemy using the tower's targeting mode.

function scr_tower_target_acquire(_tower)
{
    if (!instance_exists(_tower))
        return noone;


    var _best_enemy =
        noone;

    var _best_score =
        infinity;


    if (
        _tower.targeting.mode
        == TowerTargetMode.FURTHEST
        || _tower.targeting.mode
        == TowerTargetMode.HIGHEST_HP
    )
    {
        _best_score =
            -infinity;
    }


    var _enemy_count =
        instance_number(
            o_enemy
        );


    for (
        var i = 0;
        i < _enemy_count;
        ++i
    )
    {
        var _enemy =
            instance_find(
                o_enemy,
                i
            );


        if (
            !scr_tower_target_valid(
                _tower,
                _enemy
            )
        )
        {
            continue;
        }


        var _score =
            0;


        switch (_tower.targeting.mode)
        {
            case TowerTargetMode.CLOSEST:
            case TowerTargetMode.FURTHEST:
            {
                _score =
                    point_distance(
                        _tower.x,
                        _tower.y,
                        _enemy.x,
                        _enemy.y
                    );
            }
            break;


            case TowerTargetMode.LOWEST_HP:
            case TowerTargetMode.HIGHEST_HP:
            {
                _score =
                    _enemy.vitals.hp.current;
            }
            break;
        }


        var _better =
            false;


        switch (_tower.targeting.mode)
        {
            case TowerTargetMode.CLOSEST:
            case TowerTargetMode.LOWEST_HP:
            {
                _better =
                    _score < _best_score;
            }
            break;


            case TowerTargetMode.FURTHEST:
            case TowerTargetMode.HIGHEST_HP:
            {
                _better =
                    _score > _best_score;
            }
            break;
        }


        if (_better)
        {
            _best_score =
                _score;

            _best_enemy =
                _enemy;
        }
    }


    return _best_enemy;
}


/// @description Fires one tower projectile.

function scr_tower_fire(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!instance_exists(_tower.targeting.target))
        return false;


    var _angle = _tower.visual.draw_angle;
    var _muzzle_distance = 36;

    var _projectile =
        scr_projectile_tower_create(
            _tower,

            _tower.x
            + lengthdir_x(
                _muzzle_distance,
                _angle
            ),

            _tower.y
            + lengthdir_y(
                _muzzle_distance,
                _angle
            ),

            _angle,
            _tower.combat.weapon.damage,
            _tower.combat.weapon.projectile,
            _tower.targeting.layer
        );


    if (!instance_exists(_projectile))
        return false;


    _tower.combat.weapon.cooldown.remaining =
        _tower.combat.weapon.cooldown.duration;


    // FUTURE:
    // alternate anti-air barrels
    // muzzle particles
    // firing sound
    // recoil
    // firing power demand


    return true;
}


/// @description Updates one tower.

function scr_tower_update(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (
        _tower.BuildingState
        != BuildingState.ACTIVE
    )
    {
        return true;
    }


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _tower.combat.weapon
        .cooldown.remaining =
        max(
            0,
            _tower.combat.weapon
                .cooldown.remaining
            - (1 / _fps)
        );


    if (
        !scr_tower_target_valid(
            _tower,
            _tower.targeting.target
        )
    )
    {
        _tower.targeting.target =
            noone;
    }


    // Target searches are staggered between tower instances.

    if (
        !instance_exists(
            _tower.targeting.target
        )
        && IFRAMES_5
    )
    {
        _tower.targeting.target =
            scr_tower_target_acquire(
                _tower
            );
    }


    if (!instance_exists(
        _tower.targeting.target
    ))
    {
        return true;
    }


    _tower.visual.draw_angle =
        point_direction(
            _tower.x,
            _tower.y,
            _tower.targeting.target.x,
            _tower.targeting.target.y
        );


    if (
        _tower.combat.weapon
            .cooldown.remaining
        <= 0
    )
    {
        scr_tower_fire(
            _tower
        );
    }


    return true;
}


