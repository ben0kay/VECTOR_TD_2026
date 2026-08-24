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


/// @description Acquires an enemy's intended strategic target.

function scr_enemy_target_acquire(_enemy)
{
    if (!instance_exists(_enemy))
        return noone;


    switch (_enemy.targeting.target_type)
    {
        case EnemyTarget.CPU:
        {
            return global.vtd_level.entities.cpu;
        }


        case EnemyTarget.BUILDING:
        {
            var _building = scr_enemy_closest_building_get(_enemy);

            // If no ordinary building exists, attack the CPU instead.
            // This prevents building hunters having no objective at the
            // beginning of a level.

            if (!instance_exists(_building))
                return global.vtd_level.entities.cpu;

            return _building;
        }


        case EnemyTarget.PLAYER:
        {
            return global.vtd_level.entities.player;
        }
    }


    return noone;
}


/// @description Initializes one generic enemy from its data definition.

function scr_enemy_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "enemy_key"))
    {
        show_debug_message("ENEMY ERROR - enemy_key was not supplied.");
        return false;
    }


    var _data = scr_enemy_data_get(_enemy.enemy_key);

    if (!scr_enemy_data_valid(_data))
    {
        show_debug_message(
            "ENEMY ERROR - invalid definition: " + string(_enemy.enemy_key)
        );

        return false;
    }


    _enemy.enemy_data = _data;
    _enemy.EnemyState = EnemyState.SPAWNING;


    _enemy.identity =
    {
        key: _data.identity.key,
        name: _data.identity.name
    };

	_enemy.rewards =
	{
	    experience:
	        _data.rewards.experience,

	    resources:
	        []
	};


	for (
	    var i = 0;
	    i < array_length(_data.rewards.resources);
	    ++i
	)
	{
	    var _reward =
	        _data.rewards.resources[i];

	    array_push(
	        _enemy.rewards.resources,
	        {
	            resource_key:
	                _reward.resource_key,

	            amount:
	                _reward.amount,

	            chance:
	                _reward.chance
	        }
	    );
	}	

    _enemy.visual =
    {
        sprite: _data.visual.sprite,
        draw_function: _data.visual.draw_function,
        draw_angle: 0,
        radius: _data.visual.radius,
        color: _data.visual.color
    };


    _enemy.vitals =
    {
        hp:
        {
            current: _data.vitals.hp_maximum,
            maximum: _data.vitals.hp_maximum
        }
    };
	
	_enemy.vitals.shield =
	{
	    enabled: false,

	    current: 0,

	    maximum:
	        _data.vitals.shield_maximum,

	    color:
	        make_color_rgb(
	            255,
	            110,
	            120
	        ),

	    hit_flash: 0
	};

	_enemy.modifiers = [];

	if (
	    variable_instance_exists(
	        _enemy,
	        "spawn_modifiers"
	    )
	)
	{
	    _enemy.modifiers =
	        scr_enemy_modifiers_copy(
	            _enemy.spawn_modifiers
	        );
	}


	// Activate the runtime effects supplied by each modifier.

	for (
	    var i = 0;
	    i < array_length(_enemy.modifiers);
	    ++i
	)
	{
	    switch (_enemy.modifiers[i])
	    {
	        case EnemyModifier.SHIELDED:
	        {
	            if (_enemy.vitals.shield.maximum > 0)
	            {
	                _enemy.vitals.shield.enabled = true;

	                _enemy.vitals.shield.current =
	                    _enemy.vitals.shield.maximum;
	            }
	        }
	        break;
	    }
	}


	if (
	    variable_struct_exists(
	        _data.visual,
	        "shield_color"
	    )
	)
	{
	    _enemy.vitals.shield.color =
	        _data.visual.shield_color;
	}


    var _brainless = false;
    var _destroy_on_impact = false;

    if (variable_struct_exists(_data.movement, "brainless"))
        _brainless = _data.movement.brainless;

    if (variable_struct_exists(_data.movement, "destroy_on_impact"))
        _destroy_on_impact = _data.movement.destroy_on_impact;


    var _initial_direction = random(360);

    if (variable_instance_exists(_enemy, "spawn_direction"))
        _initial_direction = _enemy.spawn_direction;


    _enemy.movement =
    {
        speed: _data.movement.speed,
        layer: _data.movement.layer,
        brainless: _brainless,
        direction: _initial_direction,
        destroy_on_impact: _destroy_on_impact
    };


    _enemy.visual.draw_angle = _initial_direction;


    _enemy.targeting =
    {
        target: noone,
        strategic: noone,
        breach: noone,
        target_type: _data.targeting.target_type
    };


    _enemy.navigation =
    {
        path_id: -1,
        needs_path: !_brainless,
        repath_timer: real(_enemy.id) mod 4,
        revision_seen: -1,
        reachable: true,
        blocked_action: _data.navigation.blocked_action
    };


    // Brainless enemies never allocate a GameMaker path.

    if (!_brainless)
        _enemy.navigation.path_id = path_add();


    _enemy.attack =
    {
        type: _data.attack.type,
        damage: _data.attack.damage,
        range: _data.attack.range,

        cooldown:
        {
            duration: _data.attack.cooldown_seconds,
            remaining: 0
        },

        projectile: undefined
    };


    if (_enemy.attack.type == EnemyAttack.PROJECTILE)
    {
        var _projectile = _data.attack.projectile;

        _enemy.attack.projectile =
        {
            speed: _projectile.speed,
            lifetime_seconds: _projectile.lifetime_seconds,
            radius: _projectile.radius,
            color: _projectile.color,
            shot_count: _projectile.shot_count,
            spread_degrees: _projectile.spread_degrees
        };
    }


    // ========================================================================
	// ABILITY RUNTIME
	// ========================================================================

	_enemy.ability_runtime =
	{
	    explosion: undefined,
	    split: undefined,
	    transport: undefined,
	    orbit: undefined
	};


	if (
	    scr_enemy_has_ability(
	        _enemy,
	        EnemyAbility.EXPLODE_ON_DEATH
	    )
	)
	{
	    var _explosion =
	        _data.ability_data.explosion;

	    _enemy.ability_runtime.explosion =
	    {
	        damage: _explosion.damage,
	        radius: _explosion.radius,
	        triggered: false
	    };
	}


	if (
	    scr_enemy_has_ability(
	        _enemy,
	        EnemyAbility.SPLIT_ON_DEATH
	    )
	)
	{
	    var _split =
	        _data.ability_data.split;

	    _enemy.ability_runtime.split =
	    {
	        enemy_key: _split.enemy_key,
	        count: _split.count,
	        spawn_distance: _split.spawn_distance,
	        angle_offset: _split.angle_offset,
	        triggered: false
	    };
	}


	if (
	    scr_enemy_has_ability(
	        _enemy,
	        EnemyAbility.TRANSPORT_ENEMIES
	    )
	)
	{
	    var _transport =
	        _data.ability_data.transport;

	    _enemy.ability_runtime.transport =
	    {
	        cargo: _transport.cargo,
	        spawn_radius: _transport.spawn_radius,
	        triggered: false
	    };
	}


	if (
	    scr_enemy_has_ability(
	        _enemy,
	        EnemyAbility.ORBIT_TARGET
	    )
	)
	{
	    var _orbit =
	        _data.ability_data.orbit;

	    _enemy.ability_runtime.orbit =
	    {
	        radius: _orbit.radius,
	        angular_speed: _orbit.angular_speed,
	        entry_tolerance: _orbit.entry_tolerance,

	        angle: random(360),
	        active: false
	    };


	    if (instance_exists(_enemy.targeting.target))
	    {
	        _enemy.ability_runtime.orbit.angle =
	            point_direction(
	                _enemy.targeting.target.x,
	                _enemy.targeting.target.y,
	                _enemy.x,
	                _enemy.y
	            );
	    }
	}


    if (_brainless)
    {
        _enemy.EnemyState = EnemyState.MOVING;
    }
    else
    {
        _enemy.targeting.strategic = scr_enemy_target_acquire(_enemy);
        _enemy.targeting.target = _enemy.targeting.strategic;
    }


    show_debug_message("ENEMY CREATED: " + _enemy.identity.name);

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


/// @description Executes one enemy contact, projectile, or kamikaze attack.

function scr_enemy_attack(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _target = _enemy.targeting.target;

    if (!instance_exists(_target))
        return false;


    // Kamikaze enemies detonate once they reach attack range.

    if (scr_enemy_has_ability(_enemy, EnemyAbility.EXPLODE_ON_DEATH))
    {
        scr_enemy_explode(_enemy);
        scr_enemy_die(_enemy, undefined);

        return true;
    }


    switch (_enemy.attack.type)
    {
        case EnemyAttack.CONTACT:
        {
            var _damage = scr_damage_create(
                _enemy.attack.damage,
                _enemy,
                DamageSource.ENEMY
            );


            if (_target.object_index == o_cpu)
            {
                if (!scr_cpu_damage(_target, _damage.amount))
                    return false;
            }
            else if (
                _target.object_index == o_building_par
                || object_is_ancestor(_target.object_index, o_building_par)
            )
            {
                if (!scr_building_damage(_target, _damage))
                    return false;
            }
            else if (_target.object_index == o_player)
            {
                if (!scr_player_damage(_target, _damage))
                    return false;
            }
        }
        break;


        case EnemyAttack.PROJECTILE:
        {
            var _projectile = _enemy.attack.projectile;

            if (!is_struct(_projectile))
                return false;


            var _base_angle = point_direction(
                _enemy.x,
                _enemy.y,
                _target.x,
                _target.y
            );

            var _shot_count = max(1, floor(_projectile.shot_count));
            var _spread = _projectile.spread_degrees;


            for (var i = 0; i < _shot_count; ++i)
            {
                var _amount = 0.5;

                if (_shot_count > 1)
                    _amount = i / (_shot_count - 1);


                var _angle = _base_angle + lerp(
                    -_spread * 0.5,
                    _spread * 0.5,
                    _amount
                );

                var _muzzle_distance = _enemy.visual.radius + 6;


                scr_projectile_enemy_create(
                    _enemy,
                    _enemy.x + lengthdir_x(_muzzle_distance, _angle),
                    _enemy.y + lengthdir_y(_muzzle_distance, _angle),
                    _angle,
                    _enemy.attack.damage,
                    _projectile
                );
            }
        }
        break;
    }


    _enemy.attack.cooldown.remaining = _enemy.attack.cooldown.duration;

    return true;
}

/// @description Updates one generic enemy.

function scr_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    // Brainless enemies perform no targeting or pathfinding.

    if (_enemy.movement.brainless)
        return scr_enemy_brainless_update(_enemy);


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

    if (!instance_exists(_enemy.targeting.strategic))
    {
        _enemy.targeting.strategic =
            scr_enemy_target_acquire(_enemy);
    }

    if (!instance_exists(_enemy.targeting.breach))
        _enemy.targeting.breach = noone;


    if (!instance_exists(_enemy.targeting.target))
    {
        if (instance_exists(_enemy.targeting.strategic))
        {
            _enemy.targeting.target =
                _enemy.targeting.strategic;
        }
        else
        {
            _enemy.targeting.target =
                scr_enemy_target_acquire(_enemy);

            _enemy.targeting.strategic =
                _enemy.targeting.target;
        }


        if (!instance_exists(_enemy.targeting.target))
        {
            scr_navigation_enemy_stop(_enemy);
            return true;
        }


        scr_navigation_enemy_repath_request(
            _enemy,
            true
        );
    }


    // ========================================================================
    // SPECIAL MOVEMENT
    // ========================================================================

    if (
        scr_enemy_has_ability(
            _enemy,
            EnemyAbility.ORBIT_TARGET
        )
    )
    {
        return scr_enemy_orbit_update(_enemy);
    }


    // ========================================================================
    // STANDARD MOVEMENT / COMBAT
    // ========================================================================

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
            if (_edge_distance <= _enemy.attack.range)
            {
                scr_navigation_enemy_stop(_enemy);

                _enemy.EnemyState =
                    EnemyState.ATTACKING;

                break;
            }

            scr_navigation_enemy_update(_enemy);
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

            if (_edge_distance > _enemy.attack.range)
            {
                _enemy.EnemyState =
                    EnemyState.MOVING;

                scr_navigation_enemy_repath_request(
                    _enemy,
                    true
                );

                break;
            }

            if (_enemy.attack.cooldown.remaining <= 0)
                scr_enemy_attack(_enemy);
        }
        break;


        case EnemyState.STUNNED:
        {
            scr_navigation_enemy_stop(_enemy);

            // FUTURE:
            // timed status-effect recovery
        }
        break;


        case EnemyState.DEAD:
        {
            scr_navigation_enemy_stop(_enemy);
        }
        break;
    }


    return true;
}

/// @description Spawns one data-driven enemy with optional direction and modifiers.

function scr_enemy_spawn(
    _enemy_key,
    _world_x,
    _world_y,
    _spawn_direction = undefined,
    _spawn_modifiers = []
)
{
    var _data =
        scr_enemy_data_get(
            _enemy_key
        );

    if (!scr_enemy_data_valid(_data))
        return noone;


    var _creation_variables =
    {
        enemy_key:
            _enemy_key,

        spawn_modifiers:
            scr_enemy_modifiers_copy(
                _spawn_modifiers
            )
    };


    if (!is_undefined(_spawn_direction))
    {
        variable_struct_set(
            _creation_variables,
            "spawn_direction",
            _spawn_direction
        );
    }


    return instance_create_layer(
        _world_x,
        _world_y,
        "Instances",
        o_enemy,
        _creation_variables
    );
}


/// @description Spawns the default CPU-seeking test enemy.

function scr_enemy_spawn_test()
{
    return scr_enemy_spawn_edge("enemy_weak");
}

/// @description Draws one enemy, its optional shield and health display.

function scr_enemy_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    scr_enemy_shield_draw(_enemy);
    scr_enemy_visual_draw(_enemy);
    scr_enemy_health_bar_draw(_enemy);

    return true;
}

/// @description Applies shield-aware damage to one enemy.

function scr_enemy_damage(
    _enemy,
    _damage
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_damage))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (_damage.amount <= 0)
        return false;


    var _damage_type =
        DamageType.KINETIC;


    if (
        variable_struct_exists(
            _damage,
            "damage_type"
        )
    )
    {
        _damage_type =
            _damage.damage_type;
    }


    var _remaining_damage =
        _damage.amount;

    var _shield =
        _enemy.vitals.shield;


    // ========================================================================
    // SHIELD DAMAGE
    // ========================================================================

    if (
        _shield.enabled
        && _shield.current > 0
    )
    {
        var _shield_multiplier =
            max(
                0.01,
                scr_damage_shield_multiplier(
                    _damage_type
                )
            );

        var _potential_shield_damage =
            _remaining_damage
            * _shield_multiplier;

        var _shield_before =
            _shield.current;

        var _shield_damage =
            min(
                _shield_before,
                _potential_shield_damage
            );


        _shield.current -=
            _shield_damage;

        _shield.hit_flash =
            1;


        // Convert absorbed shield damage back into raw packet damage.
        // Any unconsumed packet damage can overflow into health.

        var _raw_damage_absorbed =
            _shield_damage
            / _shield_multiplier;

        _remaining_damage =
            max(
                0,
                _remaining_damage
                - _raw_damage_absorbed
            );


        if (
            _shield_before > 0
            && _shield.current <= 0
        )
        {
            _shield.current = 0;
            _shield.enabled = false;


            scr_effect_shockwave_create(
                _enemy.x,
                _enemy.y,
                _enemy.visual.radius + 16,
                _shield.color
            );


            // FUTURE:
            // shield-break particles
            // shield-break sound
        }
    }


    // ========================================================================
    // EXPOSED HEALTH DAMAGE
    // ========================================================================

    if (_remaining_damage > 0)
    {
        var _health_damage =
            _remaining_damage
            * scr_damage_health_multiplier(
                _damage_type
            );


        _enemy.vitals.hp.current =
            max(
                0,
                _enemy.vitals.hp.current
                - _health_damage
            );
    }


    if (_enemy.vitals.hp.current <= 0)
    {
        return scr_enemy_die(
            _enemy,
            _damage
        );
    }


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

/// @description Returns whether a building is a valid enemy target.

function scr_enemy_building_target_valid(_building)
{
    if (!instance_exists(_building))
        return false;

    if (
        _building.object_index != o_building_par
        && !object_is_ancestor(_building.object_index, o_building_par)
    )
    {
        return false;
    }

    if (!variable_instance_exists(_building, "BuildingState"))
        return false;

    if (_building.BuildingState == BuildingState.DESTROYED)
        return false;

    return _building.vitals.hp.current > 0;
}

/// @description Returns the closest valid building to an enemy.

function scr_enemy_closest_building_get(_enemy)
{
    if (!instance_exists(_enemy))
        return noone;


    var _closest = noone;
    var _closest_distance = infinity;
    var _building_count = instance_number(o_building_par);


    for (var i = 0; i < _building_count; ++i)
    {
        var _building = instance_find(o_building_par, i);

        if (!scr_enemy_building_target_valid(_building))
            continue;


        var _distance = point_distance(
            _enemy.x,
            _enemy.y,
            _building.x,
            _building.y
        );


        if (_distance < _closest_distance)
        {
            _closest = _building;
            _closest_distance = _distance;
        }
    }


    return _closest;
}

/// @description Spawns one enemy configuration at a random map edge.

function scr_enemy_spawn_edge(
    _enemy_key,
    _spawn_modifiers = []
)
{
    var _margin = 64;
    var _spawn_x = _margin;
    var _spawn_y = _margin;


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
        _enemy_key,
        _spawn_x,
        _spawn_y,
        undefined,
        _spawn_modifiers
    );
}

/// @description Returns the distance from an explosion to a target's nearest edge.

function scr_enemy_explosion_target_distance(_world_x, _world_y, _target)
{
    if (!instance_exists(_target))
        return infinity;


    if (
        _target.object_index == o_building_par
        || object_is_ancestor(_target.object_index, o_building_par)
    )
    {
        var _cell_size = global.vtd_level.map.cell_size;
        var _half_width = _target.footprint.width_cells * _cell_size * 0.5;
        var _half_height = _target.footprint.height_cells * _cell_size * 0.5;

        var _closest_x = clamp(
            _world_x,
            _target.x - _half_width,
            _target.x + _half_width
        );

        var _closest_y = clamp(
            _world_y,
            _target.y - _half_height,
            _target.y + _half_height
        );

        return point_distance(
            _world_x,
            _world_y,
            _closest_x,
            _closest_y
        );
    }


    var _target_radius = 0;

    if (
        variable_instance_exists(_target, "visual")
        && is_struct(_target.visual)
        && variable_struct_exists(_target.visual, "radius")
    )
    {
        _target_radius = _target.visual.radius;
    }


    return max(
        0,
        point_distance(_world_x, _world_y, _target.x, _target.y)
        - _target_radius
    );
}

/// @description Detonates one enemy and damages every valid nearby target.

function scr_enemy_explode(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!scr_enemy_has_ability(_enemy, EnemyAbility.EXPLODE_ON_DEATH))
        return false;

    if (!is_struct(_enemy.ability_runtime.explosion))
        return false;


    var _explosion = _enemy.ability_runtime.explosion;

    if (_explosion.triggered)
        return false;


    _explosion.triggered = true;

    var _world_x = _enemy.x;
    var _world_y = _enemy.y;
    var _damage = scr_damage_create(
        _explosion.damage,
        _enemy,
        DamageSource.ENEMY
    );


    // ========================================================================
    // CPU
    // ========================================================================

    var _cpu = global.vtd_level.entities.cpu;

    if (
        instance_exists(_cpu)
        && scr_enemy_explosion_target_distance(_world_x, _world_y, _cpu)
        <= _explosion.radius
    )
    {
        scr_cpu_damage(_cpu, _damage.amount);
    }


    // ========================================================================
    // PLAYER
    // ========================================================================

    var _player = global.vtd_level.entities.player;

    if (
        instance_exists(_player)
        && scr_enemy_explosion_target_distance(_world_x, _world_y, _player)
        <= _explosion.radius
    )
    {
        scr_player_damage(_player, _damage);
    }


    // ========================================================================
    // BUILDINGS
    // ========================================================================

    var _building_count = instance_number(o_building_par);

    for (var i = _building_count - 1; i >= 0; --i)
    {
        var _building = instance_find(o_building_par, i);

        if (!scr_enemy_building_target_valid(_building))
            continue;

        if (
            scr_enemy_explosion_target_distance(
                _world_x,
                _world_y,
                _building
            )
            > _explosion.radius
        )
        {
            continue;
        }


        scr_building_damage(_building, _damage);
    }


    // Temporary vector feedback until scr_particle is implemented.

    show_debug_message(
        "ENEMY EXPLOSION: "
        + _enemy.identity.name
        + " | DAMAGE "
        + string(_explosion.damage)
        + " | RADIUS "
        + string(_explosion.radius)
    );


    // FUTURE:
    // scr_particle_explosion_create(...)
    // camera shake
    // sound
    // damage falloff
    // knockback
    // shield interaction


    return true;
}


/// @description Moves one brainless enemy straight ahead until impact.

function scr_enemy_brainless_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _start_x = _enemy.x;
    var _start_y = _enemy.y;

    var _end_x =
        _start_x
        + lengthdir_x(
            _enemy.movement.speed,
            _enemy.movement.direction
        );

    var _end_y =
        _start_y
        + lengthdir_y(
            _enemy.movement.speed,
            _enemy.movement.direction
        );


    _enemy.visual.draw_angle =
        _enemy.movement.direction;


    // ========================================================================
    // PERMANENT TERRAIN IMPACT
    // ========================================================================

    if (
        scr_world_moving_circle_solid(
            _start_x,
            _start_y,
            _end_x,
            _end_y,
            _enemy.visual.radius
        )
    )
    {
        // This is terrain removal, not a player/tower kill.
        //
        // FUTURE:
        // impact particles
        // terrain-impact sound
        // optional explosion-on-terrain behavior

        instance_destroy(_enemy);
        return true;
    }


    // ========================================================================
    // ENTITY IMPACT
    // ========================================================================

    // This sweep finds the first CPU, player, or building crossed.

    var _target =
        scr_projectile_enemy_hit_find(
            _enemy,
            _start_x,
            _start_y,
            _end_x,
            _end_y
        );


    if (instance_exists(_target))
    {
        _enemy.targeting.target = _target;

        scr_enemy_attack(_enemy);


        if (
            instance_exists(_enemy)
            && _enemy.movement.destroy_on_impact
        )
        {
            // Impact deaths are not credited to the player or a tower.

            instance_destroy(_enemy);
        }


        return true;
    }


    // ========================================================================
    // MOVEMENT
    // ========================================================================

    _enemy.x = _end_x;
    _enemy.y = _end_y;


    var _margin = 128;


    if (
        _enemy.x < -_margin
        || _enemy.x > room_width + _margin
        || _enemy.y < -_margin
        || _enemy.y > room_height + _margin
    )
    {
        instance_destroy(_enemy);
    }


    return true;
}


/// @description Releases evenly spaced brainless children from a splitter.

function scr_enemy_split(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !scr_enemy_has_ability(
            _enemy,
            EnemyAbility.SPLIT_ON_DEATH
        )
    )
    {
        return false;
    }

    if (!is_struct(_enemy.ability_runtime.split))
        return false;


    var _split =
        _enemy.ability_runtime.split;

    if (_split.triggered)
        return false;


    _split.triggered = true;


    var _count =
        max(
            1,
            floor(_split.count)
        );

    var _angle_step =
        360 / _count;

    var _base_angle =
        random(360)
        + _split.angle_offset;


    for (var i = 0; i < _count; ++i)
    {
        var _angle =
            _base_angle
            + (i * _angle_step);

        var _spawn_x =
            _enemy.x
            + lengthdir_x(
                _split.spawn_distance,
                _angle
            );

        var _spawn_y =
            _enemy.y
            + lengthdir_y(
                _split.spawn_distance,
                _angle
            );


        scr_enemy_spawn(
            _split.enemy_key,
            _spawn_x,
            _spawn_y,
            _angle,

            // Children inherit composable spawn modifiers.

            _enemy.modifiers
        );
    }


    // FUTURE:
    // split particles
    // split sound
    // modifier inheritance exceptions
    // several possible child enemy keys


    return true;
}

/// @description Updates an enemy's custom draw angle from its real movement.

function scr_enemy_visual_direction_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    // ========================================================================
    // BRAINLESS MOVEMENT
    // ========================================================================

    // Brainless enemies control their movement direction directly.

    if (_enemy.movement.brainless)
    {
        _enemy.visual.draw_angle =
            _enemy.movement.direction;

        return true;
    }


    // ========================================================================
    // ATTACKING
    // ========================================================================

    // Stationary attacking enemies face their current target.

    if (
        _enemy.EnemyState == EnemyState.ATTACKING
        && instance_exists(_enemy.targeting.target)
    )
    {
        _enemy.visual.draw_angle =
            point_direction(
                _enemy.x,
                _enemy.y,
                _enemy.targeting.target.x,
                _enemy.targeting.target.y
            );

        return true;
    }


    // ========================================================================
    // ACTUAL MOVEMENT
    // ========================================================================

    var _moved_x =
        _enemy.x - _enemy.xprevious;

    var _moved_y =
        _enemy.y - _enemy.yprevious;


    // Use actual displacement whenever the enemy moved this frame.

    if (
        abs(_moved_x) > 0.01
        || abs(_moved_y) > 0.01
    )
    {
        _enemy.visual.draw_angle =
            point_direction(
                _enemy.xprevious,
                _enemy.yprevious,
                _enemy.x,
                _enemy.y
            );

        return true;
    }


    // Native GameMaker paths maintain the built-in direction variable.
    // This handles a newly assigned path before its first movement frame.

    if (
        _enemy.EnemyState == EnemyState.MOVING
        && _enemy.path_index != -1
    )
    {
        _enemy.visual.draw_angle =
            _enemy.direction;
    }


    return true;
}


/// @description Returns whether a damage source qualifies for combat rewards.

function scr_enemy_reward_source_valid(_damage)
{
    if (!is_struct(_damage))
        return false;


    switch (_damage.source_type)
    {
        case DamageSource.PLAYER:
        case DamageSource.TOWER:
            return instance_exists(_damage.source);
    }


    return false;
}

/// @description Grants one defeated enemy's fixed rewards.

function scr_enemy_rewards_grant(_enemy, _damage)
{
    if (!instance_exists(_enemy))
        return false;

    if (!scr_enemy_reward_source_valid(_damage))
        return false;

    if (!variable_instance_exists(_enemy, "rewards"))
        return false;


    var _credits_earned = 0;


    // ========================================================================
    // RESOURCE REWARDS
    // ========================================================================

    for (
        var i = 0;
        i < array_length(_enemy.rewards.resources);
        ++i
    )
    {
        var _reward =
            _enemy.rewards.resources[i];

        if (_reward.amount <= 0)
            continue;

        if (random(1) > _reward.chance)
            continue;


        var _accepted =
            scr_resource_amount_add(
                _reward.resource_key,
                _reward.amount
            );


        if (
            _reward.resource_key
            == "resource_credits"
        )
        {
            _credits_earned += _accepted;
        }
    }


    // ========================================================================
    // LEVEL STATISTICS
    // ========================================================================

    if (!variable_struct_exists(global.vtd_level.combat, "credits_earned"))
        global.vtd_level.combat.credits_earned = 0;

    global.vtd_level.combat.credits_earned +=
        _credits_earned;


    if (_credits_earned > 0)
    {
        scr_hud_resource_gain_push(
            "resource_credits",
            _credits_earned
        );
    }


    // ========================================================================
    // SOURCE ATTRIBUTION
    // ========================================================================

    switch (_damage.source_type)
    {
        case DamageSource.PLAYER:
        {
            var _player =
                _damage.source;

            if (
                instance_exists(_player)
                && variable_instance_exists(_player, "combat")
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
                && variable_instance_exists(_tower, "progression")
            )
            {
                _tower.progression.kills++;

                scr_tower_experience_add(
                    _tower,
                    _enemy.rewards.experience
                );
            }
        }
        break;
    }


    return true;
}

/// @description Returns a safe independent copy of a modifier array.

function scr_enemy_modifiers_copy(_modifiers)
{
    var _copy = [];

    if (!is_array(_modifiers))
        return _copy;


    for (var i = 0; i < array_length(_modifiers); ++i)
        array_push(_copy, _modifiers[i]);


    return _copy;
}

/// @description Returns whether an enemy currently has a modifier.

function scr_enemy_modifier_has(
    _enemy,
    _modifier
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "modifiers"))
        return false;

    if (!is_array(_enemy.modifiers))
        return false;


    for (
        var i = 0;
        i < array_length(_enemy.modifiers);
        ++i
    )
    {
        if (_enemy.modifiers[i] == _modifier)
            return true;
    }


    return false;
}

/// @description Adds one modifier to an existing enemy.

function scr_enemy_modifier_add(
    _enemy,
    _modifier
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "modifiers"))
        _enemy.modifiers = [];

    if (scr_enemy_modifier_has(_enemy, _modifier))
        return true;


    array_push(
        _enemy.modifiers,
        _modifier
    );


    switch (_modifier)
    {
        case EnemyModifier.SHIELDED:
        {
            if (_enemy.vitals.shield.maximum <= 0)
                return false;

            _enemy.vitals.shield.enabled = true;

            _enemy.vitals.shield.current =
                _enemy.vitals.shield.maximum;
        }
        break;
    }


    return true;
}


/// @description Updates one enemy's temporary shield feedback.

function scr_enemy_shield_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_struct_exists(_enemy.vitals, "shield"))
        return true;

    var _shield = _enemy.vitals.shield;

    if (!is_struct(_shield))
        return true;

    if (!variable_struct_exists(_shield, "enabled"))
        return true;

    if (!_shield.enabled)
        return true;

    var _fps = max(1, game_get_speed(gamespeed_fps));

    _shield.hit_flash =
        max(
            0,
            _shield.hit_flash - (4 / _fps)
        );

    return true;
}

/// @description Releases one Transporter's configured enemy cargo.

function scr_enemy_transport_release(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !scr_enemy_has_ability(
            _enemy,
            EnemyAbility.TRANSPORT_ENEMIES
        )
    )
    {
        return false;
    }

    var _transport =
        _enemy.ability_runtime.transport;

    if (!is_struct(_transport))
        return false;

    if (_transport.triggered)
        return false;

    _transport.triggered = true;


    // ========================================================================
    // COUNT COMPLETE CARGO
    // ========================================================================

    var _total_cargo = 0;

    for (var i = 0; i < array_length(_transport.cargo); ++i)
    {
        var _cargo = _transport.cargo[i];

        _total_cargo +=
            irandom_range(
                max(0, floor(_cargo.count_min)),
                max(0, floor(_cargo.count_max))
            );
    }

    if (_total_cargo <= 0)
        return true;


    // ========================================================================
    // RELEASE CARGO
    // ========================================================================

    var _released = 0;

    for (var i = 0; i < array_length(_transport.cargo); ++i)
    {
        var _cargo = _transport.cargo[i];

        var _count =
            irandom_range(
                max(0, floor(_cargo.count_min)),
                max(0, floor(_cargo.count_max))
            );

        var _child_modifiers = [];

        if (_cargo.inherit_modifiers)
        {
            _child_modifiers =
                scr_enemy_modifiers_copy(
                    _enemy.modifiers
                );
        }


        for (var j = 0; j < _count; ++j)
        {
            var _angle =
                (_released / max(1, _total_cargo)) * 360;

            var _distance =
                random_range(
                    _transport.spawn_radius * 0.45,
                    _transport.spawn_radius
                );

            var _spawn_x =
                clamp(
                    _enemy.x
                    + lengthdir_x(_distance, _angle),
                    32,
                    room_width - 32
                );

            var _spawn_y =
                clamp(
                    _enemy.y
                    + lengthdir_y(_distance, _angle),
                    32,
                    room_height - 32
                );


            // If the surrounding position is obstructed, release the child
            // at the Transporter's valid current position instead.

            if (
                scr_world_moving_circle_solid(
                    _enemy.x,
                    _enemy.y,
                    _spawn_x,
                    _spawn_y,
                    8
                )
            )
            {
                _spawn_x = _enemy.x;
                _spawn_y = _enemy.y;
            }


            scr_enemy_spawn(
                _cargo.enemy_key,
                _spawn_x,
                _spawn_y,
                _angle,
                _child_modifiers
            );

            _released++;
        }
    }


    scr_effect_shockwave_create(
        _enemy.x,
        _enemy.y,
        _transport.spawn_radius + 20,
        _enemy.visual.color
    );


    // FUTURE:
    // opening transport panels
    // cargo launch particles
    // configurable release-on-arrival
    // mixed cargo formations
    // cargo capacity affected by modifiers


    return true;
}

/// @description Approaches and then orbits an enemy's strategic target.

function scr_enemy_orbit_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    var _target =
        _enemy.targeting.target;

    if (!instance_exists(_target))
        return false;

    var _orbit =
        _enemy.ability_runtime.orbit;

    if (!is_struct(_orbit))
        return false;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _distance =
        point_distance(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );

    var _entry_distance =
        _orbit.radius
        + _orbit.entry_tolerance;


    // ========================================================================
    // APPROACH
    // ========================================================================

    if (
        !_orbit.active
        && _distance > _entry_distance
    )
    {
        _enemy.EnemyState =
            EnemyState.MOVING;

        var _direction =
            point_direction(
                _enemy.x,
                _enemy.y,
                _target.x,
                _target.y
            );

        _enemy.x +=
            lengthdir_x(
                _enemy.movement.speed,
                _direction
            );

        _enemy.y +=
            lengthdir_y(
                _enemy.movement.speed,
                _direction
            );

        _enemy.x =
            clamp(
                _enemy.x,
                _enemy.visual.radius,
                room_width - _enemy.visual.radius
            );

        _enemy.y =
            clamp(
                _enemy.y,
                _enemy.visual.radius,
                room_height - _enemy.visual.radius
            );

        return true;
    }


    // ========================================================================
    // ENTER ORBIT
    // ========================================================================

    if (!_orbit.active)
    {
        _orbit.active = true;

        _orbit.angle =
            point_direction(
                _target.x,
                _target.y,
                _enemy.x,
                _enemy.y
            );
    }


    // ========================================================================
    // ORBIT
    // ========================================================================

    _enemy.EnemyState =
        EnemyState.ATTACKING;

    _orbit.angle +=
        _orbit.angular_speed
        / _fps;

    _orbit.angle =
        _orbit.angle mod 360;


    var _orbit_x =
        _target.x
        + lengthdir_x(
            _orbit.radius,
            _orbit.angle
        );

    var _orbit_y =
        _target.y
        + lengthdir_y(
            _orbit.radius,
            _orbit.angle
        );


    var _move_direction =
        point_direction(
            _enemy.x,
            _enemy.y,
            _orbit_x,
            _orbit_y
        );

    var _move_distance =
        min(
            _enemy.movement.speed,
            point_distance(
                _enemy.x,
                _enemy.y,
                _orbit_x,
                _orbit_y
            )
        );


    _enemy.x +=
        lengthdir_x(
            _move_distance,
            _move_direction
        );

    _enemy.y +=
        lengthdir_y(
            _move_distance,
            _move_direction
        );


    _enemy.x =
        clamp(
            _enemy.x,
            _enemy.visual.radius,
            room_width - _enemy.visual.radius
        );

    _enemy.y =
        clamp(
            _enemy.y,
            _enemy.visual.radius,
            room_height - _enemy.visual.radius
        );


    // Gunships face inward while firing, similar to the original enemy.

    _enemy.visual.draw_angle =
        point_direction(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );


    if (_enemy.attack.cooldown.remaining <= 0)
        scr_enemy_attack(_enemy);


    return true;
}

/// @description Kills an enemy, processes abilities and awards valid kills.

function scr_enemy_die(_enemy, _damage)
{
    if (!instance_exists(_enemy))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;


    _enemy.EnemyState =
        EnemyState.DEAD;

    scr_navigation_enemy_stop(
        _enemy
    );


    // ========================================================================
    // DEATH ABILITIES
    // ========================================================================

    if (
        scr_enemy_has_ability(
            _enemy,
            EnemyAbility.EXPLODE_ON_DEATH
        )
    )
    {
        scr_enemy_explode(_enemy);
    }


    if (
        scr_enemy_has_ability(
            _enemy,
            EnemyAbility.SPLIT_ON_DEATH
        )
    )
    {
        scr_enemy_split(_enemy);
    }


    if (
        scr_enemy_has_ability(
            _enemy,
            EnemyAbility.TRANSPORT_ENEMIES
        )
    )
    {
        scr_enemy_transport_release(_enemy);
    }


    // ========================================================================
    // LEVEL KILL COUNT
    // ========================================================================

    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && variable_struct_exists(
            global.vtd_level,
            "combat"
        )
    )
    {
        global.vtd_level.combat.kills++;
    }


    // ========================================================================
    // REWARDS AND KILL ATTRIBUTION
    // ========================================================================

    if (is_struct(_damage))
    {
        scr_enemy_rewards_grant(
            _enemy,
            _damage
        );
    }


    show_debug_message(
        "ENEMY DESTROYED: "
        + _enemy.identity.name
    );


    // FUTURE:
    // particles
    // physical item drops
    // elite reward modifiers
    // death sounds


    instance_destroy(_enemy);

    return true;
}

