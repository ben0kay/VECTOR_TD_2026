/// @description Generic data-driven enemy behaviour.


/// @description Returns whether an enemy currently has an ability.

function scr_enemy_has_ability(
    _enemy,
    _ability
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_array(_enemy.abilities))
        return false;


    for (
        var i = 0;
        i < array_length(_enemy.abilities);
        ++i
    )
    {
        if (_enemy.abilities[i] == _ability)
            return true;
    }


    return false;
}


/// @description Acquires the enemy's intended target.

function scr_enemy_target_acquire(_enemy)
{
    if (!instance_exists(_enemy))
        return noone;


    switch (_enemy.targeting.target_type)
    {
        case EnemyTarget.CPU:
        {
            return global.vtd_level
                .entities.cpu;
        }


        case EnemyTarget.BUILDING:
        {
            // FUTURE:
            // Find nearby or weighted building candidates.

            return noone;
        }


        case EnemyTarget.PLAYER:
        {
            return global.vtd_level
                .entities.player;
        }
    }


    return noone;
}


/// @description Initializes one generic enemy.

function scr_enemy_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    if (
        !variable_instance_exists(
            _enemy,
            "enemy_key"
        )
    )
    {
        show_debug_message(
            "ENEMY ERROR - enemy_key was not supplied."
        );

        return false;
    }


    var _data =
        scr_enemy_data_get(
            _enemy.enemy_key
        );


    if (!scr_enemy_data_valid(_data))
    {
        show_debug_message(
            "ENEMY ERROR - invalid definition: "
            + string(_enemy.enemy_key)
        );

        return false;
    }


    _enemy.enemy_data =
        _data;


    // ========================================================================
    // STATE
    // ========================================================================

    _enemy.EnemyState =
        EnemyState.SPAWNING;


    // ========================================================================
    // IDENTITY
    // ========================================================================

    _enemy.identity =
    {
        key:
            _data.identity.key,

        name:
            _data.identity.name
    };


    // ========================================================================
    // VISUAL
    // ========================================================================

    _enemy.visual =
    {
        draw_angle:
            0,

        radius:
            _data.visual.radius,

        color:
            _data.visual.color
    };


    // ========================================================================
    // VITALS
    // ========================================================================

    _enemy.vitals =
    {
        hp:
        {
            current:
                _data.vitals.hp_maximum,

            maximum:
                _data.vitals.hp_maximum
        }
    };


    // ========================================================================
    // MOVEMENT
    // ========================================================================

    _enemy.movement =
    {
        speed:
            _data.movement.speed,

        layer:
            _data.movement.layer
    };


    // ========================================================================
    // TARGETING
    // ========================================================================

    _enemy.targeting =
    {
        target:
            noone,

        strategic:
            noone,

        breach:
            noone,

        target_type:
            _data.targeting.target_type
    };


    // ========================================================================
    // NAVIGATION
    // ========================================================================

    _enemy.navigation =
    {
        path_id:
            path_add(),

        needs_path:
            true,

        repath_timer:
            real(_enemy.id) mod 4,

        revision_seen:
            -1,

        reachable:
            true,

        blocked_action:
            _data.navigation.blocked_action
    };


    // ========================================================================
    // ATTACK
    // ========================================================================

    _enemy.attack =
    {
        type:
            _data.attack.type,

        damage:
            _data.attack.damage,

        range:
            _data.attack.range,

        cooldown:
        {
            duration:
                _data.attack.cooldown_seconds,

            remaining:
                0
        }
    };


    // ========================================================================
    // ABILITIES
    // ========================================================================

    _enemy.abilities =
        [];


    for (
        var i = 0;
        i < array_length(_data.abilities);
        ++i
    )
    {
        array_push(
            _enemy.abilities,
            _data.abilities[i]
        );
    }


    // ========================================================================
    // INITIAL TARGET
    // ========================================================================

    _enemy.targeting.strategic =
        scr_enemy_target_acquire(
            _enemy
        );

    _enemy.targeting.target =
        _enemy.targeting.strategic;


    show_debug_message(
        "ENEMY CREATED: "
        + _enemy.identity.name
    );


    return true;
}

/// @description Returns the distance between an enemy and its target edges.

function scr_enemy_target_edge_distance(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return infinity;

    if (!instance_exists(_target))
        return infinity;


    // ========================================================================
    // BUILDING RECTANGLE
    // ========================================================================

    if (
        _target.object_index
        == o_building_par
        || object_is_ancestor(
            _target.object_index,
            o_building_par
        )
    )
    {
        var _cell_size =
            global.vtd_level.map.cell_size;

        var _half_width =
            (
                _target.footprint.width_cells
                * _cell_size
            )
            * 0.5;

        var _half_height =
            (
                _target.footprint.height_cells
                * _cell_size
            )
            * 0.5;


        // Find the closest point anywhere on the building rectangle.

        var _closest_x =
            clamp(
                _enemy.x,
                _target.x - _half_width,
                _target.x + _half_width
            );

        var _closest_y =
            clamp(
                _enemy.y,
                _target.y - _half_height,
                _target.y + _half_height
            );


        var _distance_to_rectangle =
            point_distance(
                _enemy.x,
                _enemy.y,
                _closest_x,
                _closest_y
            );


        // A small interaction tolerance allows enemies standing in diagonal
        // neighboring grid cells to attack the building.
        //
        // Without this tolerance, a 16-pixel enemy beside a 32-pixel wall can
        // finish its path approximately 2.6 pixels outside its attack range.

        var _interaction_tolerance =
            _cell_size * 0.25;


        return max(
            0,
            _distance_to_rectangle
            - _enemy.visual.radius
            - _interaction_tolerance
        );
    }


    // ========================================================================
    // CIRCULAR TARGET
    // ========================================================================

    var _target_radius =
        0;


    if (
        variable_instance_exists(
            _target,
            "visual"
        )
        && is_struct(_target.visual)
        && variable_struct_exists(
            _target.visual,
            "radius"
        )
    )
    {
        _target_radius =
            _target.visual.radius;
    }


    return max(
        0,
        point_distance(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        )
        - _enemy.visual.radius
        - _target_radius
    );
}


/// @description Executes one enemy attack.

function scr_enemy_attack(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _target =
        _enemy.targeting.target;


    if (!instance_exists(_target))
        return false;


    var _damage =
        scr_damage_create(
            _enemy.attack.damage,
            _enemy,
            DamageSource.ENEMY
        );

    var _damage_applied =
        false;


    switch (_enemy.attack.type)
    {
        case EnemyAttack.CONTACT:
        {
            if (_target.object_index == o_cpu)
            {
                _damage_applied =
                    scr_cpu_damage(
                        _target,
                        _enemy.attack.damage
                    );
            }
            else if (
                _target.object_index
                    == o_building_par
                || object_is_ancestor(
                    _target.object_index,
                    o_building_par
                )
            )
            {
                _damage_applied =
                    scr_building_damage(
                        _target,
                        _damage
                    );
            }
        }
        break;


        case EnemyAttack.PROJECTILE:
        {
            // FUTURE:
            // Create a data-driven enemy projectile.
        }
        break;
    }


    if (!_damage_applied)
        return false;


    _enemy.attack.cooldown.remaining =
        _enemy.attack.cooldown.duration;


    return true;
}


/// @description Updates one generic enemy.

function scr_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _enemy.attack.cooldown.remaining =
        max(
            0,
            _enemy.attack.cooldown.remaining
            - (1 / _fps)
        );


    // ========================================================================
    // TARGET RECOVERY
    // ========================================================================

    if (!instance_exists(
        _enemy.targeting.strategic
    ))
    {
        _enemy.targeting.strategic =
            scr_enemy_target_acquire(
                _enemy
            );
    }


    if (!instance_exists(
        _enemy.targeting.breach
    ))
    {
        _enemy.targeting.breach =
            noone;
    }


    if (!instance_exists(
        _enemy.targeting.target
    ))
    {
        // If the temporary breach target was destroyed, return to the
        // original strategic objective.

        if (instance_exists(
            _enemy.targeting.strategic
        ))
        {
            _enemy.targeting.target =
                _enemy.targeting.strategic;
        }
        else
        {
            _enemy.targeting.target =
                scr_enemy_target_acquire(
                    _enemy
                );

            _enemy.targeting.strategic =
                _enemy.targeting.target;
        }


        if (!instance_exists(
            _enemy.targeting.target
        ))
        {
            scr_navigation_enemy_stop(
                _enemy
            );

            return true;
        }


        scr_navigation_enemy_repath_request(
            _enemy,
            true
        );
    }


    var _target =
        _enemy.targeting.target;

    var _edge_distance =
        scr_enemy_target_edge_distance(
            _enemy,
            _target
        );


    switch (_enemy.EnemyState)
    {
        case EnemyState.SPAWNING:
        {
            _enemy.EnemyState =
                EnemyState.MOVING;


            scr_navigation_enemy_repath_request(
                _enemy,
                true
            );
        }
        break;


        case EnemyState.MOVING:
        {
            if (
                _edge_distance
                <= _enemy.attack.range
            )
            {
                scr_navigation_enemy_stop(
                    _enemy
                );

                _enemy.EnemyState =
                    EnemyState.ATTACKING;

                break;
            }


            scr_navigation_enemy_update(
                _enemy
            );
        }
        break;


        case EnemyState.ATTACKING:
        {
            _enemy.visual.draw_angle =
                point_direction(
                    _enemy.x,
                    _enemy.y,
                    _target.x,
                    _target.y
                );


            if (
                _edge_distance
                > _enemy.attack.range
            )
            {
                _enemy.EnemyState =
                    EnemyState.MOVING;


                scr_navigation_enemy_repath_request(
                    _enemy,
                    true
                );

                break;
            }


            if (
                _enemy.attack.cooldown.remaining
                <= 0
            )
            {
                scr_enemy_attack(
                    _enemy
                );
            }
        }
        break;


        case EnemyState.STUNNED:
        {
            scr_navigation_enemy_stop(
                _enemy
            );


            // FUTURE:
            // Timed status-effect recovery.
        }
        break;


        case EnemyState.DEAD:
        {
            scr_navigation_enemy_stop(
                _enemy
            );
        }
        break;
    }


    return true;
}

/// @description Spawns one data-driven enemy.

function scr_enemy_spawn(
    _enemy_key,
    _world_x,
    _world_y
)
{
    var _data =
        scr_enemy_data_get(
            _enemy_key
        );

    if (!scr_enemy_data_valid(_data))
        return noone;


    return instance_create_layer(
        _world_x,
        _world_y,
        "Instances",
        o_enemy,
        {
            enemy_key:
                _enemy_key
        }
    );
}


/// @description Spawns a test enemy from a random map edge.

function scr_enemy_spawn_test()
{
    var _margin =
        64;

    var _spawn_x =
        _margin;

    var _spawn_y =
        _margin;


    switch (irandom(3))
    {
        case 0:
        {
            _spawn_x =
                random_range(
                    _margin,
                    room_width - _margin
                );

            _spawn_y =
                _margin;
        }
        break;


        case 1:
        {
            _spawn_x =
                room_width - _margin;

            _spawn_y =
                random_range(
                    _margin,
                    room_height - _margin
                );
        }
        break;


        case 2:
        {
            _spawn_x =
                random_range(
                    _margin,
                    room_width - _margin
                );

            _spawn_y =
                room_height - _margin;
        }
        break;


        case 3:
        {
            _spawn_x =
                _margin;

            _spawn_y =
                random_range(
                    _margin,
                    room_height - _margin
                );
        }
        break;
    }


    return scr_enemy_spawn(
        "enemy_weak",
        _spawn_x,
        _spawn_y
    );
}


/// @description Draws one vector-style enemy.

function scr_enemy_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _radius =
        _enemy.visual.radius;

    var _angle =
        _enemy.visual.draw_angle;


    var _front_x =
        _enemy.x
        + lengthdir_x(
            _radius,
            _angle
        );

    var _front_y =
        _enemy.y
        + lengthdir_y(
            _radius,
            _angle
        );

    var _back_left_x =
        _enemy.x
        + lengthdir_x(
            _radius * 0.8,
            _angle + 140
        );

    var _back_left_y =
        _enemy.y
        + lengthdir_y(
            _radius * 0.8,
            _angle + 140
        );

    var _back_right_x =
        _enemy.x
        + lengthdir_x(
            _radius * 0.8,
            _angle - 140
        );

    var _back_right_y =
        _enemy.y
        + lengthdir_y(
            _radius * 0.8,
            _angle - 140
        );


    draw_set_color(
        _enemy.visual.color
    );

    draw_triangle(
        _front_x,
        _front_y,
        _back_left_x,
        _back_left_y,
        _back_right_x,
        _back_right_y,
        false
    );


    // ========================================================================
    // HEALTH BAR
    // ========================================================================

    var _hp_percent =
        clamp(
            _enemy.vitals.hp.current
            / _enemy.vitals.hp.maximum,
            0,
            1
        );

    var _bar_width =
        _radius * 2;

    var _bar_left =
        _enemy.x - _radius;

    var _bar_top =
        _enemy.y - _radius - 8;


    draw_set_color(
        c_dkgray
    );

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left + _bar_width,
        _bar_top + 3,
        false
    );


    draw_set_color(
        c_red
    );

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left
            + (_bar_width * _hp_percent),
        _bar_top + 3,
        false
    );
	
	if (instance_exists(
    _enemy.targeting.breach
))
{
    draw_set_color(
        c_orange
    );

    draw_text(
        _enemy.x - 24,
        _enemy.y
            + _enemy.visual.radius
            + 6,
        "BREACH"
    );
}


    draw_set_color(
        c_white
    );


    return true;
}


/// @description Applies damage to one enemy.

function scr_enemy_damage(
    _enemy,
    _damage
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_damage))
        return false;

    if (
        _enemy.EnemyState
        == EnemyState.DEAD
    )
    {
        return false;
    }

    if (_damage.amount <= 0)
        return false;


    _enemy.vitals.hp.current =
        max(
            0,
            _enemy.vitals.hp.current
            - _damage.amount
        );


    if (_enemy.vitals.hp.current <= 0)
    {
        return scr_enemy_die(
            _enemy,
            _damage
        );
    }


    return true;
}


/// @description Kills an enemy and awards kill attribution.

function scr_enemy_die(
    _enemy,
    _damage
)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        _enemy.EnemyState
        == EnemyState.DEAD
    )
    {
        return false;
    }


    _enemy.EnemyState =
        EnemyState.DEAD;


    scr_navigation_enemy_stop(
        _enemy
    );


    if (is_struct(_damage))
    {
        switch (_damage.source_type)
        {
            case DamageSource.PLAYER:
            {
                var _player =
                    _damage.source;


                if (
                    instance_exists(_player)
                    && variable_instance_exists(
                        _player,
                        "combat"
                    )
                    && is_struct(_player.combat)
                )
                {
                    _player.combat.kills++;
                }
            }
            break;


            case DamageSource.TOWER:
            {
                var _tower =
                    _damage.source;


                if (
                    instance_exists(_tower)
                    && variable_instance_exists(
                        _tower,
                        "combat"
                    )
                    && is_struct(_tower.combat)
                )
                {
                    _tower.combat.kills++;
                }
            }
            break;


            case DamageSource.ENEMY:
            case DamageSource.ENVIRONMENT:
            {
                // No player-controlled entity receives credit.
            }
            break;
        }
    }


    show_debug_message(
        "ENEMY DESTROYED: "
        + _enemy.identity.name
    );


    // FUTURE:
    // credits and drops
    // experience
    // particle effect
    // split-on-death
    // transporter release


    instance_destroy(
        _enemy
    );


    return true;
}

/// @description Releases resources owned by one enemy.

function scr_enemy_cleanup(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    scr_navigation_enemy_cleanup(
        _enemy
    );


    return true;
}