/// @description Returns whether a tower has enough consumables to attack.

function scr_tower_consumables_can_fire(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_array(_tower.consumables))
        return true;


    for (var i = 0; i < array_length(_tower.consumables); ++i)
    {
        var _entry = _tower.consumables[i];

        if (_entry.current < _entry.amount_per_attack)
            return false;
    }


    return true;
}

/// @description Consumes one attack's required tower ammunition.

function scr_tower_consumables_consume(_tower)
{
    if (!scr_tower_consumables_can_fire(_tower))
        return false;


    for (var i = 0; i < array_length(_tower.consumables); ++i)
    {
        var _entry = _tower.consumables[i];

        _entry.current =
            max(
                0,
                _entry.current - _entry.amount_per_attack
            );
    }


    return true;
}

/// @description Refunds one failed attack's tower ammunition.

function scr_tower_consumables_refund(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_array(_tower.consumables))
        return true;


    for (var i = 0; i < array_length(_tower.consumables); ++i)
    {
        var _entry = _tower.consumables[i];

        _entry.current =
            min(
                _entry.maximum,
                _entry.current + _entry.amount_per_attack
            );
    }


    return true;
}

/// @description Adds delivered ammunition to one tower magazine.

function scr_tower_consumable_receive(
    _tower,
    _resource_key,
    _amount
)
{
    var _entry =
        scr_tower_consumable_get(
            _tower,
            _resource_key
        );

    if (!is_struct(_entry))
        return 0;


    var _accepted =
        min(
            max(0, _amount),
            _entry.maximum - _entry.current
        );

    _entry.current += _accepted;


    if (_entry.current >= _entry.maximum)
        _entry.delivery_requested = false;


    return _accepted;
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


function scr_tower_target_valid(_tower, _enemy)
{
    if (!instance_exists(_tower) || !instance_exists(_enemy))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (scr_enemy_stealth_cloaked(_enemy))
        return false;

    if (_enemy.movement.layer != _tower.targeting.layer)
        return false;

    if (!scr_fog_position_visible(_enemy.x, _enemy.y))
        return false;

    var _range = _tower.combat.range + _enemy.visual.radius;
    var _dx = _enemy.x - _tower.x;
    var _dy = _enemy.y - _tower.y;

    if ((_dx * _dx) + (_dy * _dy) > _range * _range)
        return false;

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

    switch (_tower.targeting.filter)
    {
        case TowerTargetFilter.NOT_SLOWED:
            return !scr_enemy_effect_active(_enemy, EnemyEffect.SLOW);

        case TowerTargetFilter.NOT_STASIS:
            return !scr_enemy_effect_active(_enemy, EnemyEffect.STASIS);

        case TowerTargetFilter.NOT_DISRUPTED:
            return !scr_enemy_effect_active(
                _enemy,
                EnemyEffect.DAMAGE_OVER_TIME
            );
    }

    return true;
}

/// @description Acquires the best valid enemy currently inside tower range.

function scr_tower_target_acquire(_tower)
{
    if (!instance_exists(_tower))
        return noone;


    // ========================================================================
    // LOCAL RANGE QUERY
    // ========================================================================
    //
    // Only enemies intersecting the tower's actual weapon range are gathered.
    // This replaces scanning every o_enemy instance in the room.

    var _enemy_list =
        ds_list_create();


    var _distance_sorted =
        _tower.targeting.mode
        == TowerTargetMode.CLOSEST
        || _tower.targeting.mode
        == TowerTargetMode.FURTHEST;


    collision_circle_list(
        _tower.x,
        _tower.y,
        _tower.combat.range,
        o_enemy,
        false,
        true,
        _enemy_list,
        _distance_sorted
    );


    var _count =
        ds_list_size(
            _enemy_list
        );


    if (_count <= 0)
    {
        ds_list_destroy(
            _enemy_list
        );

        return noone;
    }


    // ========================================================================
    // CLOSEST
    // ========================================================================
    //
    // The collision list is already distance sorted.
    // Stop immediately at the first valid enemy.

    if (
        _tower.targeting.mode
        == TowerTargetMode.CLOSEST
    )
    {
        for (
            var i = 0;
            i < _count;
            ++i
        )
        {
            var _enemy =
                _enemy_list[| i];


            if (
                !scr_tower_target_valid(
                    _tower,
                    _enemy
                )
            )
            {
                continue;
            }


            ds_list_destroy(
                _enemy_list
            );

            return _enemy;
        }


        ds_list_destroy(
            _enemy_list
        );

        return noone;
    }


    // ========================================================================
    // FURTHEST
    // ========================================================================
    //
    // Sorted closest -> furthest, so inspect backwards and stop at the
    // first valid enemy.

    if (
        _tower.targeting.mode
        == TowerTargetMode.FURTHEST
    )
    {
        for (
            var i = _count - 1;
            i >= 0;
            --i
        )
        {
            var _enemy =
                _enemy_list[| i];


            if (
                !scr_tower_target_valid(
                    _tower,
                    _enemy
                )
            )
            {
                continue;
            }


            ds_list_destroy(
                _enemy_list
            );

            return _enemy;
        }


        ds_list_destroy(
            _enemy_list
        );

        return noone;
    }


    // ========================================================================
    // HP-BASED TARGETING
    // ========================================================================

    var _best_enemy =
        noone;


    var _best_score =
        _tower.targeting.mode
        == TowerTargetMode.LOWEST_HP
        ? infinity
        : -infinity;


    for (
        var i = 0;
        i < _count;
        ++i
    )
    {
        var _enemy =
            _enemy_list[| i];


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
            _enemy.vitals.hp.current;


        switch (_tower.targeting.mode)
        {
            case TowerTargetMode.LOWEST_HP:
            {
                if (_score < _best_score)
                {
                    _best_score =
                        _score;

                    _best_enemy =
                        _enemy;
                }
            }
            break;


            case TowerTargetMode.HIGHEST_HP:
            {
                if (_score > _best_score)
                {
                    _best_score =
                        _score;

                    _best_enemy =
                        _enemy;
                }
            }
            break;
        }
    }


    ds_list_destroy(
        _enemy_list
    );


    return _best_enemy;
}

/// @description Fires one tower weapon after paying ammunition and energy.

function scr_tower_fire(_tower)
{
    if (!instance_exists(_tower))
        return false;


    var _target = _tower.targeting.target;

    if (!instance_exists(_target))
        return false;


    // Towers without configured consumables pass this automatically.

    if (!scr_tower_consumables_can_fire(_tower))
        return false;


    // The shot waits until the private energy buffer is ready.

    if (!scr_energy_activity_consume(_tower))
        return false;


    if (!scr_tower_consumables_consume(_tower))
    {
        _tower.energy.buffer.current =
            min(
                _tower.energy.buffer.maximum,
                _tower.energy.buffer.current
                + _tower.energy.demand.activity_cost
            );

        return false;
    }


    var _weapon = _tower.combat.weapon;
	var _damage =
        scr_damage_create(
            _weapon.damage,
            _tower,
            DamageSource.TOWER,
            _weapon.damage_type
        );

    scr_damage_critical_roll(
        _damage,
        _weapon.critical.chance,
        _weapon.critical.multiplier
    );
    var _muzzle = scr_tower_muzzle_position_get(_tower);
    var _fired = false;

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
					_damage,
                    _weapon.projectile,
                    _tower.targeting.layer,
                    _target
                );

            _fired = instance_exists(_projectile);
        }
        break;


        case TowerWeaponType.HITSCAN:
        {

            scr_enemy_damage(_target, _damage);

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

            scr_enemy_damage(_target, _damage);

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
            // Emit laser heat and ember particles along this trace.
        }
        break;
		
		case TowerWeaponType.SHOCKWAVE:
		{
		    var _area =
		    {
		        shape: AttackAreaShape.CIRCLE,
		        radius: _tower.combat.range,
		        falloff: _weapon.shockwave.falloff
		    };

		    var _hit_count = scr_attack_area_apply(
		        _tower, DamageSource.TOWER, _weapon.damage_type,
		        _tower.targeting.layer, _tower.x, _tower.y,
		        0, _damage.amount, _area
		    );

		    if (_hit_count > 0)
		    {
		        scr_effect_shockwave_create(
		            _tower.x, _tower.y, _tower.combat.range,
		            _weapon.shockwave.color,
		            _tower.targeting.layer
		        );

		        _fired = true;
		    }
		}
		break;
    }


    if (!_fired)
    {
        // Refund both transactions when the attack could not be created.

        _tower.energy.buffer.current =
            min(
                _tower.energy.buffer.maximum,
                _tower.energy.buffer.current
                + _tower.energy.demand.activity_cost
            );

        scr_tower_consumables_refund(_tower);

        return false;
    }


    _weapon.cooldown.remaining =
        _weapon.cooldown.duration;

    scr_tower_muzzle_advance(_tower);
	scr_tower_recoil_fire(_tower);


    if (!instance_exists(_tower.targeting.target))
        _tower.targeting.target = noone;


    // FUTURE:
    // dry-fire feedback
    // ammunition delivery requests
    // firing sounds
    // recoil
    // muzzle flashes
    // heat
    // overclock consumption multipliers


    return true;
}

/// @description Creates one tower recoil runtime from optional tower data.
function scr_tower_recoil_runtime_create(_tower_data)
{
    var _kick_distance = 2;
    var _recovery_speed = 28;

    if (
        is_struct(_tower_data)
        && variable_struct_exists(
            _tower_data,
            "recoil"
        )
        && is_struct(_tower_data.recoil)
    )
    {
        var _data =
            _tower_data.recoil;

        if (
            variable_struct_exists(
                _data,
                "kick_distance"
            )
        )
        {
            _kick_distance =
                max(
                    0,
                    _data.kick_distance
                );
        }

        if (
            variable_struct_exists(
                _data,
                "recovery_speed"
            )
        )
        {
            _recovery_speed =
                max(
                    0,
                    _data.recovery_speed
                );
        }
    }

    return
    {
        distance: 0,

        kick_distance:
            _kick_distance,

        recovery_speed:
            _recovery_speed
    };
}


/// @description Triggers visual recoil after a successful tower shot.
function scr_tower_recoil_fire(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.visual.recoil))
        return false;

    var _recoil =
        _tower.visual.recoil;

    _recoil.distance =
        max(
            _recoil.distance,
            _recoil.kick_distance
        );

    return true;
}


/// @description Returns recoil smoothly toward its resting position.
function scr_tower_recoil_update(_tower)
{
    if (!instance_exists(_tower))
        return false;

    if (!is_struct(_tower.visual.recoil))
        return false;

    var _recoil =
        _tower.visual.recoil;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    _recoil.distance =
        max(
            0,
            _recoil.distance
            - (
                _recoil.recovery_speed
                / _fps
            )
        );

    return true;
}


/// @description Returns the backward visual offset for the current turret angle.
function scr_tower_recoil_offset_get(_tower)
{
    if (!instance_exists(_tower))
        return { x: 0, y: 0 };

    if (!is_struct(_tower.visual.recoil))
        return { x: 0, y: 0 };

    var _distance =
        _tower.visual.recoil.distance;

    var _angle =
        _tower.visual.draw_angle;

    return
    {
        x:
            lengthdir_x(
                -_distance,
                _angle
            ),

        y:
            lengthdir_y(
                -_distance,
                _angle
            )
    };
}

