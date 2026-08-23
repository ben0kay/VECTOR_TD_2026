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
    var _weapon_data = _data.weapon;


    // ========================================================================
    // VISUALS
    // ========================================================================

    _tower.visual.turret_color =
        _tower.building_data.visual.turret_color;

    _tower.visual.draw_angle = 0;
    _tower.visual.draw_function = scr_tower_visual_ground;

    if (variable_struct_exists(_data, "draw_function"))
        _tower.visual.draw_function = _data.draw_function;


    // ========================================================================
    // TARGETING
    // ========================================================================

    var _requires_line_of_sight = true;

    if (variable_struct_exists(_data, "requires_line_of_sight"))
        _requires_line_of_sight = _data.requires_line_of_sight;

    _tower.targeting =
    {
        target: noone,
        mode: _data.target_mode,
        layer: _data.target_layer,
        requires_line_of_sight: _requires_line_of_sight
    };


    // ========================================================================
    // WEAPON
    // ========================================================================

    var _projectile = undefined;
    var _beam = undefined;
    var _hitscan = undefined;

    if (variable_struct_exists(_weapon_data, "projectile"))
        _projectile = _weapon_data.projectile;

    if (variable_struct_exists(_weapon_data, "beam"))
        _beam = _weapon_data.beam;

    if (variable_struct_exists(_weapon_data, "hitscan"))
        _hitscan = _weapon_data.hitscan;

    _tower.combat =
    {
        base:
        {
            range: _data.range,
            damage: _weapon_data.damage,
            cooldown_seconds: _weapon_data.cooldown_seconds
        },

        range: _data.range,

        weapon:
        {
            type: _weapon_data.type,
            damage_type: _weapon_data.damage_type,
            damage: _weapon_data.damage,

            cooldown:
            {
                duration: _weapon_data.cooldown_seconds,
                remaining: 0
            },

            muzzle:
            {
                mode: _weapon_data.muzzle.mode,
                distance: _weapon_data.muzzle.distance,
                spacing: _weapon_data.muzzle.spacing,
                side: 1
            },

            projectile: _projectile,
            beam: _beam,
            hitscan: _hitscan,

            trace:
            {
                active: false,
                remaining: 0,
                start_x: _tower.x,
                start_y: _tower.y,
                end_x: _tower.x,
                end_y: _tower.y,
                color_outer: c_white,
                color_core: c_white,
                width: 1
            }
        }
    };


    // ========================================================================
    // INDIVIDUAL TOWER PROGRESSION
    // ========================================================================

    _tower.progression =
    {
        kills: 0,
        experience: 0,
        rank: 1,
        maximum_rank: 10,

        next_experience:
            scr_tower_rank_experience_required(2),

        bonus:
        {
            damage_per_rank: 0.01,
            range_per_rank: 0.005,
            cooldown_per_rank: 0.005
        }
    };

    scr_tower_progression_stats_apply(_tower);

    return true;
}

/// @description Returns the active muzzle position for one tower shot.

function scr_tower_muzzle_position_get(_tower)
{
    var _weapon = _tower.combat.weapon;
    var _angle = _tower.visual.draw_angle;
    var _side_offset = 0;

    if (_weapon.muzzle.mode == TowerMuzzleMode.ALTERNATING)
    {
        _side_offset =
            _weapon.muzzle.spacing
            * _weapon.muzzle.side;
    }

    return
    {
        x:
            _tower.x
            + lengthdir_x(_weapon.muzzle.distance, _angle)
            + lengthdir_x(_side_offset, _angle + 90),

        y:
            _tower.y
            + lengthdir_y(_weapon.muzzle.distance, _angle)
            + lengthdir_y(_side_offset, _angle + 90)
    };
}


/// @description Switches an alternating weapon to its other muzzle.

function scr_tower_muzzle_advance(_tower)
{
    if (
        _tower.combat.weapon.muzzle.mode
        == TowerMuzzleMode.ALTERNATING
    )
    {
        _tower.combat.weapon.muzzle.side *= -1;
    }

    return true;
}


/// @description Stores a temporary beam or hitscan visual.

function scr_tower_trace_set(
    _tower,
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _color_outer,
    _color_core,
    _width,
    _duration
)
{
    var _trace = _tower.combat.weapon.trace;

    _trace.active = true;
    _trace.remaining = max(0.01, _duration);
    _trace.start_x = _start_x;
    _trace.start_y = _start_y;
    _trace.end_x = _end_x;
    _trace.end_y = _end_y;
    _trace.color_outer = _color_outer;
    _trace.color_core = _color_core;
    _trace.width = max(1, _width);

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


/// @description Fires one tower weapon using its configured weapon type.

function scr_tower_fire(_tower)
{
    if (!instance_exists(_tower))
        return false;

    var _target = _tower.targeting.target;

    if (!instance_exists(_target))
        return false;


    var _weapon = _tower.combat.weapon;
    var _muzzle = scr_tower_muzzle_position_get(_tower);
    var _fired = false;


    // Store the impact position before damage is applied.
    // Hitscan and beam damage may immediately destroy the target.

    var _target_x = _target.x;
    var _target_y = _target.y;


    switch (_weapon.type)
    {
        case TowerWeaponType.PROJECTILE:
        {
            var _projectile =
                scr_projectile_tower_create(
                    _tower,
                    _muzzle.x,
                    _muzzle.y,
                    _tower.visual.draw_angle,
                    _weapon.damage,
                    _weapon.damage_type,
                    _weapon.projectile,
                    _tower.targeting.layer
                );

            _fired =
                instance_exists(_projectile);
        }
        break;


        case TowerWeaponType.HITSCAN:
        {
            var _damage =
                scr_damage_create(
                    _weapon.damage,
                    _tower,
                    DamageSource.TOWER,
                    _weapon.damage_type
                );


            scr_enemy_damage(
                _target,
                _damage
            );


            // Use the stored position because the shot may have killed
            // and destroyed its target immediately.

            scr_tower_trace_set(
                _tower,
                _muzzle.x,
                _muzzle.y,
                _target_x,
                _target_y,
                _weapon.hitscan.color,
                c_white,
                _weapon.hitscan.width,
                _weapon.hitscan.visual_seconds
            );


            _fired = true;
        }
        break;


        case TowerWeaponType.BEAM:
        {
            var _damage =
                scr_damage_create(
                    _weapon.damage,
                    _tower,
                    DamageSource.TOWER,
                    _weapon.damage_type
                );


            scr_enemy_damage(
                _target,
                _damage
            );


            // Beam endpoint also uses the position captured before damage.

            scr_tower_trace_set(
                _tower,
                _muzzle.x,
                _muzzle.y,
                _target_x,
                _target_y,
                _weapon.beam.color_outer,
                _weapon.beam.color_core,
                _weapon.beam.width,
                _weapon.beam.visual_seconds
            );


            _fired = true;


            // FUTURE PARTICLE HOOK:
            // Ember particles can be distributed between the stored
            // muzzle and impact positions.
        }
        break;
    }


    if (!_fired)
        return false;


    _weapon.cooldown.remaining =
        _weapon.cooldown.duration;


    scr_tower_muzzle_advance(
        _tower
    );


    // Clear the reference if this shot destroyed its target.

    if (!instance_exists(_tower.targeting.target))
        _tower.targeting.target = noone;


    // FUTURE:
    // firing sounds
    // recoil
    // muzzle flashes
    // firing power demand
    // heat generation


    return true;
}
/// @description Updates targeting, firing and temporary weapon visuals.

function scr_tower_update(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (_tower.BuildingState != BuildingState.ACTIVE)
        return true;

    var _fps = max(1, game_get_speed(gamespeed_fps));
    var _weapon = _tower.combat.weapon;


    _weapon.cooldown.remaining =
        max(
            0,
            _weapon.cooldown.remaining - (1 / _fps)
        );


    if (_weapon.trace.active)
    {
        _weapon.trace.remaining =
            max(
                0,
                _weapon.trace.remaining - (1 / _fps)
            );

        if (_weapon.trace.remaining <= 0)
            _weapon.trace.active = false;
    }


    if (!scr_tower_target_valid(_tower, _tower.targeting.target))
        _tower.targeting.target = noone;


    // Searches remain staggered between tower instances.

    if (
        !instance_exists(_tower.targeting.target)
        && IFRAMES_5
    )
    {
        _tower.targeting.target =
            scr_tower_target_acquire(_tower);
    }


    if (!instance_exists(_tower.targeting.target))
        return true;


    _tower.visual.draw_angle =
        point_direction(
            _tower.x,
            _tower.y,
            _tower.targeting.target.x,
            _tower.targeting.target.y
        );


    if (_weapon.cooldown.remaining <= 0)
        scr_tower_fire(_tower);


    return true;
}

/// @description Returns total experience required to enter a tower rank.

function scr_tower_rank_experience_required(_rank)
{
    switch (_rank)
    {
        case 1:  return 0;
        case 2:  return 10;
        case 3:  return 25;
        case 4:  return 45;
        case 5:  return 70;
        case 6:  return 100;
        case 7:  return 140;
        case 8:  return 190;
        case 9:  return 250;
        case 10: return 325;
    }


    return infinity;
}

/// @description Recalculates one tower's small veteran stat bonuses.

function scr_tower_progression_stats_apply(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "progression"))
        return false;


    var _veteran_levels =
        max(
            0,
            _tower.progression.rank - 1
        );


    var _damage_multiplier =
        1
        + (
            _veteran_levels
            * _tower.progression.bonus.damage_per_rank
        );

    var _range_multiplier =
        1
        + (
            _veteran_levels
            * _tower.progression.bonus.range_per_rank
        );

    var _cooldown_multiplier =
        max(
            0.5,
            1
            - (
                _veteran_levels
                * _tower.progression.bonus.cooldown_per_rank
            )
        );


    _tower.combat.weapon.damage =
        _tower.combat.base.damage
        * _damage_multiplier;

    _tower.combat.range =
        _tower.combat.base.range
        * _range_multiplier;

    _tower.combat.weapon.cooldown.duration =
        _tower.combat.base.cooldown_seconds
        * _cooldown_multiplier;


    return true;
}

/// @description Grants experience and processes tower rank promotions.

function scr_tower_experience_add(_tower, _amount)
{
    if (!instance_exists(_tower))
        return false;

    if (!variable_instance_exists(_tower, "progression"))
        return false;

    if (_amount <= 0)
        return true;


    var _progression =
        _tower.progression;

    _progression.experience += _amount;


    while (_progression.rank < _progression.maximum_rank)
    {
        var _next_rank =
            _progression.rank + 1;

        var _requirement =
            scr_tower_rank_experience_required(
                _next_rank
            );

        if (_progression.experience < _requirement)
            break;


        _progression.rank =
            _next_rank;

        scr_tower_progression_stats_apply(
            _tower
        );


        scr_hud_alert_push(
            HudAlertType.SUCCESS,
            "TOWER PROMOTED",
            string_upper(_tower.identity.name)
            + " REACHED RANK "
            + string(_progression.rank),
            2.5
        );


        show_debug_message(
            "TOWER RANK UP: "
            + _tower.identity.name
            + " | RANK "
            + string(_progression.rank)
        );
    }


    _progression.next_experience =
        scr_tower_rank_experience_required(
            min(
                _progression.maximum_rank,
                _progression.rank + 1
            )
        );


    return true;
}