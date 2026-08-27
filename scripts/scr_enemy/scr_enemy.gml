/// @description Generic data-driven enemy behaviour.

/// @description Initializes one generic enemy from its data definition.

function scr_enemy_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "enemy_key"))
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

    _enemy.EnemyState =
        EnemyState.SPAWNING;


    // ========================================================================
    // IDENTITY
    // ========================================================================

    _enemy.identity =
    {
        key: _data.identity.key,
        name: _data.identity.name
    };


    // ========================================================================
    // REWARDS
    // ========================================================================

    _enemy.rewards =
    {
        experience:
            _data.rewards.experience,

        resources: [],

        physical_drop:
        {
            enabled: false,
            resource_key: "",
            chance: 0,
            amount: 0
        }
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


    if (
        variable_struct_exists(
            _data.rewards,
            "physical_drop"
        )
        && is_struct(
            _data.rewards.physical_drop
        )
    )
    {
        var _drop =
            _data.rewards.physical_drop;

        _enemy.rewards.physical_drop =
        {
            enabled: _drop.enabled,
            resource_key: _drop.resource_key,
            chance: _drop.chance,
            amount: _drop.amount
        };
    }


    // ========================================================================
    // VISUAL
    // ========================================================================

    var _scale_x =
        1;

    var _scale_y =
        1;


    if (
        variable_struct_exists(
            _data.visual,
            "scale_x"
        )
    )
    {
        _scale_x =
            _data.visual.scale_x;
    }

    if (
        variable_struct_exists(
            _data.visual,
            "scale_y"
        )
    )
    {
        _scale_y =
            _data.visual.scale_y;
    }


    _enemy.visual =
    {
        sprite:
            _data.visual.sprite,

        draw_function:
            _data.visual.draw_function,

        draw_angle: 0,

        scale_x:
            _scale_x,

        scale_y:
            _scale_y,

        radius:
            _data.visual.radius,

        color:
            _data.visual.color
    };

	// ========================================================================
	// MINIMAP
	// ========================================================================
	//
	// Colour always comes from _enemy.visual.color.
	// Definitions only control marker size and radar-contact fade duration.

	var _minimap_size =
	    1.5;

	var _minimap_fade_time =
	    4;

	if (
	    variable_struct_exists(
	        _data,
	        "minimap"
	    )
	    && is_struct(_data.minimap)
	)
	{
	    if (
	        variable_struct_exists(
	            _data.minimap,
	            "size"
	        )
	    )
	    {
	        _minimap_size =
	            max(
	                0.5,
	                _data.minimap.size
	            );
	    }

	    if (
	        variable_struct_exists(
	            _data.minimap,
	            "fade_time"
	        )
	    )
	    {
	        _minimap_fade_time =
	            max(
	                0.1,
	                _data.minimap.fade_time
	            );
	    }
	}

	_enemy.minimap =
	{
	    size:
	        _minimap_size,

	    fade_time:
	        _minimap_fade_time,

	    contact_remaining:
	        0
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

        hit_flash: 0,

        // Temporary shields granted by support enemies.
        // This remains separate from the enemy's natural shield.

        support:
        {
            enabled: false,
            current: 0,
            maximum: 0,

            source:
                noone,

            remaining_seconds: 0,

            color:
                c_yellow,

            hit_flash: 0
        }
    };


    // ========================================================================
    // MODIFIERS
    // ========================================================================

    _enemy.modifiers =
        [];


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
                    _enemy.vitals.shield.enabled =
                        true;

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


    // ========================================================================
    // MOVEMENT
    // ========================================================================

    var _brainless =
        false;

    var _destroy_on_impact =
        false;


    if (
        variable_struct_exists(
            _data.movement,
            "brainless"
        )
    )
    {
        _brainless =
            _data.movement.brainless;
    }

    if (
        variable_struct_exists(
            _data.movement,
            "destroy_on_impact"
        )
    )
    {
        _destroy_on_impact =
            _data.movement.destroy_on_impact;
    }


    var _initial_direction =
        random(360);


    if (
        variable_instance_exists(
            _enemy,
            "spawn_direction"
        )
    )
    {
        _initial_direction =
            _enemy.spawn_direction;
    }


    _enemy.movement =
    {
        speed:
            _data.movement.speed,

        speed_base:
            _data.movement.speed,

        layer:
            _data.movement.layer,

        brainless:
            _brainless,

        direction:
            _initial_direction,

        destroy_on_impact:
            _destroy_on_impact
    };


    // ========================================================================
    // PRIMARY BEHAVIOR
    // ========================================================================

    _enemy.EnemyBehavior =
        EnemyBehavior.STANDARD;


    // Existing brainless definitions remain compatible automatically.

    if (_brainless)
    {
        _enemy.EnemyBehavior =
            EnemyBehavior.BRAINLESS;
    }


    // Specialized definitions explicitly select their behavior.

    if (
        variable_struct_exists(
            _data,
            "behavior"
        )
    )
    {
        _enemy.EnemyBehavior =
            _data.behavior;
    }


    _enemy.visual.draw_angle =
        _initial_direction;


    // ========================================================================
    // STATUS EFFECTS
    // ========================================================================

    _enemy.effects =
    {
        slow:
        {
            active: false,
            multiplier: 1,
            remaining_seconds: 0,
            source: noone
        },

        stasis:
        {
            active: false,
            remaining_seconds: 0,
            source: noone
        },

        damage_over_time:
        {
            active: false,
            damage: 0,

            interval_seconds: 1,
            interval_remaining: 0,
            remaining_seconds: 0,

            damage_type:
                DamageType.KINETIC,

            source:
                noone
        }
    };


    // ========================================================================
    // TARGETING
    // ========================================================================

    _enemy.targeting =
    {
        target: noone,
        strategic: noone,
        breach: noone,

        target_type:
            _data.targeting.target_type
    };


    // ========================================================================
    // NAVIGATION
    // ========================================================================

    _enemy.navigation =
    {
        path_id: -1,

        needs_path:
            !_brainless,

        repath_timer:
            real(_enemy.id) mod 4,

        revision_seen: -1,
        reachable: true,

        blocked_action:
            _data.navigation.blocked_action
    };


    // Brainless enemies never allocate a GameMaker path.

    if (!_brainless)
    {
        _enemy.navigation.path_id =
            path_add();
    }


    // ========================================================================
    // ATTACK LINE OF SIGHT
    // ========================================================================
    //
    // The existence of the optional line_of_sight struct enables attack LOS.
    // Enemies without the struct never call LOS checks or allocate an LOS cache.

    var _requires_line_of_sight =
        variable_struct_exists(
            _data.attack,
            "line_of_sight"
        );


    if (
        _requires_line_of_sight
        && !is_struct(
            _data.attack.line_of_sight
        )
    )
    {
        show_debug_message(
            "ENEMY ERROR - attack line_of_sight must be a struct: "
            + _data.identity.key
        );

        return false;
    }


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

        requires_line_of_sight:
            _requires_line_of_sight,

        cooldown:
        {
            duration:
                _data.attack.cooldown_seconds,

            remaining: 0
        },

        projectile:
            undefined
    };


    if (
        _enemy.attack.type
        == EnemyAttack.PROJECTILE
    )
    {
        var _projectile =
            _data.attack.projectile;


        _enemy.attack.projectile =
        {
            speed:
                _projectile.speed,

            lifetime_seconds:
                _projectile.lifetime_seconds,

            radius:
                _projectile.radius,

            color:
                _projectile.color,

            shot_count:
                _projectile.shot_count,

            spread_degrees:
                _projectile.spread_degrees,

            impact:
                variable_struct_exists(
                    _projectile,
                    "impact"
                )
                ? _projectile.impact
                : ProjectileImpact.DIRECT,

            damage_radius:
                variable_struct_exists(
                    _projectile,
                    "damage_radius"
                )
                ? _projectile.damage_radius
                : 0,

            rocket:
                variable_struct_exists(
                    _projectile,
                    "rocket"
                )
                ? _projectile.rocket
                : false
        };
    }


    // ========================================================================
    // ABILITIES
    // ========================================================================
    //
    // Copy the definition array into an independent runtime array.

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
    // ABILITY RUNTIME
    // ========================================================================

    _enemy.ability_runtime =
    {
        explosion: undefined,
        split: undefined,
        transport: undefined,
        orbit: undefined,
        support_shield: undefined
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
            damage:
                _explosion.damage,

            radius:
                _explosion.radius,

            triggered:
                false
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
            enemy_key:
                _split.enemy_key,

            count:
                _split.count,

            spawn_distance:
                _split.spawn_distance,

            angle_offset:
                _split.angle_offset,

            triggered:
                false
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
            cargo:
                _transport.cargo,

            spawn_radius:
                _transport.spawn_radius,

            triggered:
                false
        };
    }


    // ========================================================================
    // ORBIT BEHAVIOR RUNTIME
    // ========================================================================

    if (
        _enemy.EnemyBehavior
        == EnemyBehavior.ORBIT
    )
    {
        if (
            !variable_struct_exists(
                _data,
                "ability_data"
            )
            || !is_struct(
                _data.ability_data
            )
            || !variable_struct_exists(
                _data.ability_data,
                "orbit"
            )
            || !is_struct(
                _data.ability_data.orbit
            )
        )
        {
            show_debug_message(
                "ENEMY ERROR - orbit behavior data missing: "
                + _enemy.identity.key
            );

            return false;
        }


        var _orbit =
            _data.ability_data.orbit;

        _enemy.ability_runtime.orbit =
        {
            radius:
                _orbit.radius,

            angular_speed:
                _orbit.angular_speed,

            entry_tolerance:
                _orbit.entry_tolerance,

            angle:
                random(360),

            active:
                false
        };


        if (
            instance_exists(
                _enemy.targeting.target
            )
        )
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


    // ========================================================================
    // SUPPORT SHIELD RUNTIME
    // ========================================================================

    if (
        scr_enemy_has_ability(
            _enemy,
            EnemyAbility.SHIELD_ALLIES
        )
    )
    {
        var _support =
            _data.ability_data.support_shield;

        _enemy.ability_runtime.support_shield =
        {
            standoff_range:
                _support.standoff_range,

            field_radius:
                _support.field_radius,

            shield_capacity:
                _support.shield_capacity,

            recharge_per_pulse:
                _support.recharge_per_pulse,

            pulse_seconds:
                _support.pulse_seconds,

            linger_seconds:
                _support.linger_seconds,

            maximum_target_radius:
                _support.maximum_target_radius,

            color:
                _support.color,

            pulse_remaining:
                0
        };
    }
	
	
	// ========================================================================
	// OPTIONAL UNIQUE ENEMY EVENTS
	// ========================================================================

	_enemy.has_unique =
	    variable_struct_exists(
	        _data,
	        "unique"
	    );


	_enemy.unique =
	{
	    create_event:
	    {
	        start:
	            undefined
	    },

	    step_event:
	    {
	        start:
	            undefined,

	        finish:
	            undefined,

	        handled:
	            false
	    },

	    draw_event:
	    {
	        start:
	            undefined,

	        finish:
	            undefined,

	        handled:
	            false
	    }
	};


	if (_enemy.has_unique)
	{
	    if (!is_struct(_data.unique))
	    {
	        show_debug_message(
	            "ENEMY UNIQUE ERROR - unique data must be a struct: "
	            + _enemy.identity.key
	        );

	        return false;
	    }


	    var _unique_data =
	        _data.unique;


	    // ========================================================================
	    // CREATE EVENT
	    // ========================================================================

	    if (
	        variable_struct_exists(
	            _unique_data,
	            "create_event"
	        )
	    )
	    {
	        if (!is_struct(_unique_data.create_event))
	        {
	            show_debug_message(
	                "ENEMY UNIQUE ERROR - create_event must be a struct: "
	                + _enemy.identity.key
	            );

	            return false;
	        }


	        if (
	            variable_struct_exists(
	                _unique_data.create_event,
	                "start"
	            )
	        )
	        {
	            _enemy.unique.create_event.start =
	                _unique_data.create_event.start;
	        }
	    }


	    // ========================================================================
	    // STEP EVENT
	    // ========================================================================

	    if (
	        variable_struct_exists(
	            _unique_data,
	            "step_event"
	        )
	    )
	    {
	        if (!is_struct(_unique_data.step_event))
	        {
	            show_debug_message(
	                "ENEMY UNIQUE ERROR - step_event must be a struct: "
	                + _enemy.identity.key
	            );

	            return false;
	        }


	        if (
	            variable_struct_exists(
	                _unique_data.step_event,
	                "start"
	            )
	        )
	        {
	            _enemy.unique.step_event.start =
	                _unique_data.step_event.start;
	        }

	        if (
	            variable_struct_exists(
	                _unique_data.step_event,
	                "finish"
	            )
	        )
	        {
	            _enemy.unique.step_event.finish =
	                _unique_data.step_event.finish;
	        }
	    }


	    // ========================================================================
	    // DRAW EVENT
	    // ========================================================================

	    if (
	        variable_struct_exists(
	            _unique_data,
	            "draw_event"
	        )
	    )
	    {
	        if (!is_struct(_unique_data.draw_event))
	        {
	            show_debug_message(
	                "ENEMY UNIQUE ERROR - draw_event must be a struct: "
	                + _enemy.identity.key
	            );

	            return false;
	        }


	        if (
	            variable_struct_exists(
	                _unique_data.draw_event,
	                "start"
	            )
	        )
	        {
	            _enemy.unique.draw_event.start =
	                _unique_data.draw_event.start;
	        }

	        if (
	            variable_struct_exists(
	                _unique_data.draw_event,
	                "finish"
	            )
	        )
	        {
	            _enemy.unique.draw_event.finish =
	                _unique_data.draw_event.finish;
	        }
	    }


	    // ========================================================================
	    // RUN UNIQUE CREATE EVENT
	    // ========================================================================

	    if (
	        _enemy.unique.create_event.start
	        != undefined
	    )
	    {
	        if (
	            !_enemy.unique.create_event.start(
	                _enemy
	            )
	        )
	        {
	            show_debug_message(
	                "ENEMY UNIQUE ERROR - Create Event failed: "
	                + _enemy.identity.key
	            );

	            return false;
	        }
	    }
	}

    // ========================================================================
    // INITIAL TARGET
    // ========================================================================

    if (_brainless)
    {
        _enemy.EnemyState =
            EnemyState.MOVING;
    }
    else
    {
        _enemy.targeting.strategic =
            scr_enemy_target_acquire(
                _enemy
            );

        _enemy.targeting.target =
            _enemy.targeting.strategic;
    }


    show_debug_message(
        "ENEMY CREATED: "
        + _enemy.identity.name
    );


    return true;
}

/// @description Initializes lightweight staggered processing for one enemy.

function scr_enemy_performance_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.performance =
    {
        lazy_factor: 7,

        visibility:
        {
            outside_view: false,
            fog_visible: true,
            visible: true,

            timer:
                1 + (real(_enemy.id) mod 15),

            interval_minimum: 15,
            interval_maximum: 30
        },

        decisions:
        {
            due: false,

            timer:
                1 + (real(_enemy.id) mod 30),

            interval_minimum: 15,
            interval_maximum: 30
        }
    };


    // The first checks are staggered by instance ID, preventing a large
    // spawn group from performing every visibility check on one frame.

    return true;
}

/// @description Updates cached enemy visibility and staggered decision timing.

function scr_enemy_performance_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_enemy.performance))
        return false;


    var _performance =
        _enemy.performance;

    var _visibility =
        _performance.visibility;

    var _decisions =
        _performance.decisions;


    // Reset this one-frame signal.

    _decisions.due =
        false;


    // ========================================================================
    // CACHED CAMERA AND FOG VISIBILITY
    // ========================================================================

    _visibility.timer--;


    if (_visibility.timer <= 0)
    {
        _visibility.outside_view =
            !scr_culling_check_instance(
                _enemy,
                128
            );

        if (_visibility.outside_view)
        {
            // There is no reason to query the fog grid when the enemy is
            // already outside the camera.

            _visibility.fog_visible =
                false;
        }
        else
        {
            _visibility.fog_visible =
                scr_fog_position_visible(
                    _enemy.x,
                    _enemy.y
                );
        }


        _visibility.visible =
            !_visibility.outside_view
            && _visibility.fog_visible;


        _visibility.timer =
            irandom_range(
                _visibility.interval_minimum,
                _visibility.interval_maximum
            );
    }


    // ========================================================================
    // STAGGERED NON-ESSENTIAL DECISIONS
    // ========================================================================

    _decisions.timer--;


    if (_decisions.timer <= 0)
    {
        _decisions.due =
            true;


        var _factor =
            _visibility.visible
            ? 1
            : _performance.lazy_factor;


        _decisions.timer =
            irandom_range(
                _decisions.interval_minimum,
                _decisions.interval_maximum
            )
            * _factor;
    }


    return true;
}

/// @description Returns whether an enemy currently has an ability.

function scr_enemy_has_ability(
    _enemy,
    _ability
)
{
    if (!instance_exists(_enemy))
        return false;

    if (
        !variable_instance_exists(
            _enemy,
            "abilities"
        )
    )
    {
        return false;
    }

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
			
			scr_particles_enemy_contact_impact(
    _enemy,
    _target
);
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
		
		case EnemyAttack.CONTINUOUS_BEAM:
		{
		    // Continuous damage is processed by the configured beam behavior.
		    // Keeping it out of this function prevents double damage.
		}
		break;
    }


    _enemy.attack.cooldown.remaining = _enemy.attack.cooldown.duration;

    return true;
}

/// @description Processes shared enemy logic and dispatches its primary behavior.

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


    // Brainless enemies do not require strategic targets or paths.

    if (
        _enemy.EnemyBehavior
        == EnemyBehavior.BRAINLESS
    )
    {
        return scr_enemy_behavior_update(
            _enemy
        );
    }


    // ========================================================================
    // STRATEGIC TARGET RECOVERY
    // ========================================================================

    if (!instance_exists(_enemy.targeting.strategic))
    {
        var _strategic =
            scr_enemy_target_acquire(
                _enemy
            );

        scr_enemy_strategic_target_set(
            _enemy,
            _strategic
        );
    }


    if (!instance_exists(_enemy.targeting.breach))
    {
        _enemy.targeting.breach =
            noone;
    }


    // ========================================================================
    // ACTIVE TARGET RECOVERY
    // ========================================================================

    if (!instance_exists(_enemy.targeting.target))
    {
        if (instance_exists(_enemy.targeting.strategic))
        {
            _enemy.targeting.target =
                _enemy.targeting.strategic;
        }
        else
        {
            var _strategic =
                scr_enemy_target_acquire(
                    _enemy
                );

            scr_enemy_strategic_target_set(
                _enemy,
                _strategic
            );

            _enemy.targeting.target =
                _enemy.targeting.strategic;
        }


        if (!instance_exists(_enemy.targeting.target))
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


    // Exactly one primary behavior runs per enemy.

    return scr_enemy_behavior_update(
        _enemy
    );
}



/// @description Spawns the default CPU-seeking test enemy.

function scr_enemy_spawn_test()
{
    return scr_enemy_spawn_edge("enemy_weak");
}

/// @description Draws one enemy and its visible combat feedback.

function scr_enemy_draw(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    if (scr_enemy_stealth_cloaked(_enemy))
    {
        var _shimmer =
            sin(
                (global.vtd.tick * 3)
                + real(_enemy.id)
            )
            * 0.035;


        draw_set_alpha(
            clamp(
                _enemy.stealth.alpha.current
                + _shimmer,
                0.08,
                0.2
            )
        );


        scr_enemy_visual_draw(_enemy);


        draw_set_alpha(1);
        draw_set_color(c_white);

        return true;
    }


    draw_set_alpha(1);

    scr_enemy_shield_draw(_enemy);
    scr_enemy_visual_draw(_enemy);
    scr_enemy_effects_draw(_enemy);
    scr_enemy_health_bar_draw(_enemy);

    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}
/// @description Applies support-shield, natural-shield and health damage.

function scr_enemy_damage(_enemy, _damage)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_damage))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;

    if (_damage.amount <= 0)
        return false;


    var _damage_type = DamageType.KINETIC;

    if (variable_struct_exists(_damage, "damage_type"))
        _damage_type = _damage.damage_type;


    var _remaining_damage = _damage.amount;

    var _shield = _enemy.vitals.shield;

    var _shield_multiplier =
        max(
            0.01,
            scr_damage_shield_multiplier(
                _damage_type
            )
        );


    // ========================================================================
    // TEMPORARY SUPPORT SHIELD
    // ========================================================================

    if (
        is_struct(_shield.support)
        && _shield.support.enabled
        && _shield.support.current > 0
    )
    {
        var _support = _shield.support;

        var _support_damage =
            min(
                _support.current,
                _remaining_damage
                * _shield_multiplier
            );

        _support.current -=
            _support_damage;

        _support.hit_flash = 1;

        _remaining_damage =
            max(
                0,
                _remaining_damage
                - (_support_damage / _shield_multiplier)
            );


        if (_support.current <= 0)
		{
		    _support.current =
		        0;

		    _support.enabled =
		        false;


		    scr_effect_shockwave_create(
		        _enemy.x,
		        _enemy.y,
		        _enemy.visual.radius + 20,
		        _support.color,
		        _enemy.movement.layer
		    );


		    scr_particles_shield_break(
		        _enemy.x,
		        _enemy.y,
		        _support.color,
		        _enemy.visual.radius + 20
		    );
		}
    }


    // ========================================================================
    // NATURAL SHIELD
    // ========================================================================

    if (
        _remaining_damage > 0
        && _shield.enabled
        && _shield.current > 0
    )
    {
        var _natural_damage =
            min(
                _shield.current,
                _remaining_damage
                * _shield_multiplier
            );

        _shield.current -=
            _natural_damage;

        _shield.hit_flash = 1;

        _remaining_damage =
            max(
                0,
                _remaining_damage
                - (_natural_damage / _shield_multiplier)
            );


        if (_shield.current <= 0)
		{
		    _shield.current =
		        0;

		    _shield.enabled =
		        false;


		    scr_effect_shockwave_create(
		        _enemy.x,
		        _enemy.y,
		        _enemy.visual.radius + 16,
		        _shield.color,
		        _enemy.movement.layer
		    );


		    scr_particles_shield_break(
		        _enemy.x,
		        _enemy.y,
		        _shield.color,
		        _enemy.visual.radius + 16
		    );
		}
    }


    // ========================================================================
    // HEALTH
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

/// @description Returns the closest valid building, optionally inside a local scan range.

function scr_enemy_closest_building_get(
    _enemy,
    _scan_range = -1
)
{
    if (!instance_exists(_enemy))
        return noone;


    var _closest = noone;
    var _closest_distance_squared = infinity;


    // ========================================================================
    // LOCAL COLLISION-CIRCLE SEARCH
    // ========================================================================

    if (_scan_range > 0)
    {
        var _buildings = ds_list_create();

        var _building_count =
            collision_circle_list(
                _enemy.x,
                _enemy.y,
                _scan_range,
                o_building_par,
                false,
                true,
                _buildings,
                false
            );


        for (var i = 0; i < _building_count; ++i)
        {
            var _building = _buildings[| i];

            if (!scr_enemy_building_target_valid(_building))
                continue;


            var _difference_x =
                _building.x - _enemy.x;

            var _difference_y =
                _building.y - _enemy.y;

            var _distance_squared =
                (_difference_x * _difference_x)
                + (_difference_y * _difference_y);


            if (_distance_squared < _closest_distance_squared)
            {
                _closest = _building;

                _closest_distance_squared =
                    _distance_squared;
            }
        }


        ds_list_destroy(_buildings);

        return _closest;
    }


    // ========================================================================
    // FULL-MAP FALLBACK SEARCH
    // ========================================================================

    var _building_count =
        instance_number(o_building_par);


    for (var i = 0; i < _building_count; ++i)
    {
        var _building =
            instance_find(
                o_building_par,
                i
            );


        if (!scr_enemy_building_target_valid(_building))
            continue;


        var _difference_x =
            _building.x - _enemy.x;

        var _difference_y =
            _building.y - _enemy.y;

        var _distance_squared =
            (_difference_x * _difference_x)
            + (_difference_y * _difference_y);


        if (_distance_squared < _closest_distance_squared)
        {
            _closest = _building;

            _closest_distance_squared =
                _distance_squared;
        }
    }


    return _closest;
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

/// @description Updates enemy hull, turret and compatibility draw angles.

function scr_enemy_visual_direction_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _has_advanced_visual =
        variable_struct_exists(
            _enemy.visual,
            "hull_angle"
        )
        && variable_struct_exists(
            _enemy.visual,
            "turret_angle"
        );


    // ========================================================================
    // BRAINLESS MOVEMENT
    // ========================================================================

    if (_enemy.movement.brainless)
    {
        _enemy.visual.draw_angle =
            _enemy.movement.direction;

        if (_has_advanced_visual)
        {
            _enemy.visual.hull_angle =
                _enemy.movement.direction;

            _enemy.visual.turret_angle =
                _enemy.movement.direction;
        }

        return true;
    }


    // ========================================================================
    // ACTUAL MOVEMENT
    // ========================================================================

    var _moved_x =
        _enemy.x
        - _enemy.xprevious;

    var _moved_y =
        _enemy.y
        - _enemy.yprevious;

    var _moved =
        abs(_moved_x) > 0.01
        || abs(_moved_y) > 0.01;


    if (_moved)
    {
        var _movement_angle =
            point_direction(
                _enemy.xprevious,
                _enemy.yprevious,
                _enemy.x,
                _enemy.y
            );


        if (_has_advanced_visual)
        {
            var _turn_speed = 6;

            if (
                variable_instance_exists(
                    _enemy,
                    "combat_movement"
                )
                && is_struct(
                    _enemy.combat_movement
                )
            )
            {
                _turn_speed =
                    _enemy.combat_movement
                        .data
                        .hull_turn_speed;
            }


            _enemy.visual.hull_angle =
                scr_enemy_angle_approach(
                    _enemy.visual.hull_angle,
                    _movement_angle,
                    _turn_speed
                );

            _enemy.visual.draw_angle =
                _enemy.visual.hull_angle;
        }
        else
        {
            _enemy.visual.draw_angle =
                _movement_angle;
        }
    }


    // ========================================================================
    // TURRET TRACKING
    // ========================================================================

    if (
        _has_advanced_visual
        && instance_exists(
            _enemy.targeting.target
        )
    )
    {
        var _target_angle =
            point_direction(
                _enemy.x,
                _enemy.y,
                _enemy.targeting.target.x,
                _enemy.targeting.target.y
            );

        var _turret_speed = 8;


        if (
            variable_instance_exists(
                _enemy,
                "combat_movement"
            )
            && is_struct(
                _enemy.combat_movement
            )
        )
        {
            _turret_speed =
                _enemy.combat_movement
                    .data
                    .turret_turn_speed;
        }


        _enemy.visual.turret_angle =
            scr_enemy_angle_approach(
                _enemy.visual.turret_angle,
                _target_angle,
                _turret_speed
            );
    }


    // ========================================================================
    // ORDINARY STATIONARY ATTACKERS
    // ========================================================================

    if (
        !_moved
        && _enemy.EnemyState
            == EnemyState.ATTACKING
        && instance_exists(
            _enemy.targeting.target
        )
    )
    {
        var _uses_separate_hull =
            false;


        if (
            variable_instance_exists(
                _enemy,
                "combat_movement"
            )
            && is_struct(
                _enemy.combat_movement
            )
        )
        {
            _uses_separate_hull =
                _enemy.combat_movement
                    .data.type
                != EnemyCombatMovement
                    .STATIONARY;
        }


        if (!_uses_separate_hull)
        {
            _enemy.visual.draw_angle =
                point_direction(
                    _enemy.x,
                    _enemy.y,
                    _enemy.targeting.target.x,
                    _enemy.targeting.target.y
                );

            if (_has_advanced_visual)
            {
                _enemy.visual.hull_angle =
                    _enemy.visual.draw_angle;
            }
        }
    }


    // A newly assigned native path may not have moved yet.

    if (
        !_moved
        && _enemy.EnemyState
            == EnemyState.MOVING
        && _enemy.path_index != -1
    )
    {
        if (_has_advanced_visual)
        {
            _enemy.visual.hull_angle =
                scr_enemy_angle_approach(
                    _enemy.visual.hull_angle,
                    _enemy.direction,
                    6
                );

            _enemy.visual.draw_angle =
                _enemy.visual.hull_angle;
        }
        else
        {
            _enemy.visual.draw_angle =
                _enemy.direction;
        }
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


    switch (_modifier)
    {
        case EnemyModifier.SHIELDED:
        {
            if (_enemy.vitals.shield.maximum <= 0)
                return false;


            array_push(
                _enemy.modifiers,
                _modifier
            );


            _enemy.vitals.shield.enabled = true;

            _enemy.vitals.shield.current =
                _enemy.vitals.shield.maximum;


            return true;
        }


        case EnemyModifier.STEALTHED:
        {
            array_push(
                _enemy.modifiers,
                _modifier
            );


            if (
                variable_instance_exists(
                    _enemy,
                    "stealth"
                )
                && is_struct(_enemy.stealth)
            )
            {
                _enemy.stealth.modifier = true;
            }


            return true;
        }
    }


    array_push(
        _enemy.modifiers,
        _modifier
    );


    return true;
}

/// @description Updates one enemy's natural and temporary support shields.

function scr_enemy_shield_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_struct_exists(_enemy.vitals, "shield"))
        return true;


    var _shield =
        _enemy.vitals.shield;

    if (!is_struct(_shield))
        return true;


    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );


    _shield.hit_flash =
        max(
            0,
            _shield.hit_flash
            - (4 / _fps)
        );


    if (!is_struct(_shield.support))
        return true;


    var _support =
        _shield.support;

    _support.hit_flash =
        max(
            0,
            _support.hit_flash
            - (4 / _fps)
        );


    if (!_support.enabled)
        return true;


    _support.remaining_seconds =
        max(
            0,
            _support.remaining_seconds
            - (1 / _fps)
        );


    if (
        _support.remaining_seconds <= 0
        || _support.current <= 0
    )
    {
        _support.enabled = false;
        _support.current = 0;
        _support.maximum = 0;
        _support.source = noone;
        _support.remaining_seconds = 0;
    }


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

    scr_navigation_enemy_stop(_enemy);
	scr_effect_enemy_death_create(_enemy);


    // ========================================================================
    // DEATH ABILITIES
    // ========================================================================

    if (scr_enemy_has_ability(_enemy, EnemyAbility.EXPLODE_ON_DEATH))
        scr_enemy_explode(_enemy);

    if (scr_enemy_has_ability(_enemy, EnemyAbility.SPLIT_ON_DEATH))
        scr_enemy_split(_enemy);

    if (scr_enemy_has_ability(_enemy, EnemyAbility.TRANSPORT_ENEMIES))
        scr_enemy_transport_release(_enemy);


    // ========================================================================
    // LEVEL STATISTICS
    // ========================================================================

    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && variable_struct_exists(global.vtd_level, "combat")
    )
    {
        global.vtd_level.combat.kills++;
    }


    if (is_struct(_damage))
    {
        scr_level_result_enemy_kill_record(_damage);

        scr_enemy_rewards_grant(
            _enemy,
            _damage
        );

        scr_enemy_pickup_drop_try(
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
    // elite reward modifiers
    // death sounds


    instance_destroy(_enemy);

    return true;
}

/// @description Attempts to create one defeated enemy's physical drop.

function scr_enemy_pickup_drop_try(_enemy, _damage)
{
    if (!instance_exists(_enemy))
        return false;

    if (!scr_enemy_reward_source_valid(_damage))
        return false;

    if (!variable_instance_exists(_enemy, "rewards"))
        return false;

    if (!variable_struct_exists(_enemy.rewards, "physical_drop"))
        return false;


    var _drop =
        _enemy.rewards.physical_drop;


    if (!_drop.enabled)
        return false;

    if (_drop.amount <= 0)
        return false;

    if (random(1) > _drop.chance)
        return false;


    return instance_exists(
        scr_pickup_create(
            _enemy.x,
            _enemy.y,
            _drop.resource_key,
            _drop.amount
        )
    );
}

/// @description Applies enemy damage to one valid player-side target.

function scr_enemy_damage_target(
    _enemy,
    _target,
    _amount,
    _damage_type = DamageType.KINETIC
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;

    if (_amount <= 0)
        return false;


    var _damage = scr_damage_create(
        _amount,
        _enemy,
        DamageSource.ENEMY,
        _damage_type
    );


    if (_target.object_index == o_cpu)
        return scr_cpu_damage(_target, _damage.amount);


    if (_target.object_index == o_player)
        return scr_player_damage(_target, _damage);


    if (
        _target.object_index == o_building_par
        || object_is_ancestor(
            _target.object_index,
            o_building_par
        )
    )
    {
        return scr_building_damage(
            _target,
            _damage
        );
    }


    return false;
}

/// @description Processes the mobile continuous-beam siege platform.

function scr_enemy_siege_beam_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _target =
        _enemy.targeting.target;

    if (!instance_exists(_target))
        return true;


    var _edge_distance =
        scr_enemy_target_edge_distance(
            _enemy,
            _target
        );

    var _combat =
        _enemy.combat_movement;

    var _combat_data =
        _combat.data;

    var _line_clear =
        scr_enemy_attack_line_of_sight_clear(
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
                    <= _combat_data.preferred_range
                && _line_clear
            )
            {
                scr_navigation_enemy_stop(
                    _enemy
                );

                _enemy.EnemyState =
                    EnemyState.ATTACKING;


                if (
                    !scr_enemy_combat_anchor_begin(
                        _enemy,
                        _target
                    )
                )
                {
                    show_debug_message(
                        "ENEMY COMBAT ERROR - siege beam anchor failed: "
                        + _enemy.identity.key
                    );

                    return false;
                }


                break;
            }


            scr_navigation_enemy_update(
                _enemy
            );
        }
        break;


        case EnemyState.ATTACKING:
        {
            _line_clear =
                scr_enemy_attack_line_of_sight_clear(
                    _enemy,
                    _target
                );


            if (
                _edge_distance
                    > _combat_data.maximum_range
                || !_line_clear
            )
            {
                _combat.anchor.valid =
                    false;

                _combat.destination.active =
                    false;

                _enemy.EnemyState =
                    EnemyState.MOVING;

                scr_navigation_enemy_repath_request(
                    _enemy,
                    true
                );

                break;
            }


            // Turret tracking remains independent from hull movement.

            var _target_angle =
                point_direction(
                    _enemy.x,
                    _enemy.y,
                    _target.x,
                    _target.y
                );

            _enemy.visual.turret_angle =
                scr_enemy_angle_approach(
                    _enemy.visual.turret_angle,
                    _target_angle,
                    _combat_data.turret_turn_speed
                );


            // The beam platform may roam inside its combat anchor while
            // continuing to attack.

            scr_enemy_combat_movement_update(
                _enemy,
                _target
            );


            var _fps =
                max(
                    1,
                    game_get_speed(gamespeed_fps)
                );


            if (
                !scr_enemy_damage_target(
                    _enemy,
                    _target,
                    _enemy.attack.damage / _fps,
                    DamageType.LASER
                )
            )
            {
                show_debug_message(
                    "ENEMY ATTACK ERROR - siege beam damage failed: "
                    + _enemy.identity.key
                );

                return false;
            }
        }
        break;


        case EnemyState.STUNNED:
        case EnemyState.DEAD:
        {
            scr_navigation_enemy_stop(
                _enemy
            );

            _combat.destination.active =
                false;
        }
        break;
    }


    return true;
}

/// @description Creates an optional cached line-of-sight runtime for one attack.

function scr_enemy_attack_line_of_sight_cache_create(
    _interval_minimum = 8,
    _interval_maximum = 15,
    _movement_refresh_distance = 32,
    _blocked_function = scr_world_line_blocked_by_dead
)
{
    var _interval_minimum_final =
        max(
            1,
            floor(_interval_minimum)
        );

    var _interval_maximum_final =
        max(
            _interval_minimum_final,
            floor(_interval_maximum)
        );


    return
    {
        clear: false,
        initialized: false,

        timer: 0,

        interval:
        {
            minimum:
                _interval_minimum_final,

            maximum:
                _interval_maximum_final
        },

        movement_refresh_distance:
            max(
                0,
                _movement_refresh_distance
            ),

        blocked_function:
            _blocked_function,

        target: noone,

        source_position:
        {
            x: 0,
            y: 0
        },

        target_position:
        {
            x: 0,
            y: 0
        },

        navigation_revision: -1
    };
}


/// @description Refreshes and returns one cached attack line-of-sight result.

function scr_enemy_attack_line_of_sight_cache_update(
    _enemy,
    _target,
    _cache,
    _interval_multiplier = 1
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;

    if (!is_struct(_cache))
    {
        show_debug_message(
            "ENEMY ATTACK LOS ERROR - invalid cache supplied."
        );

        return false;
    }


    _cache.timer--;


    var _refresh_distance =
        _cache.movement_refresh_distance;

    var _refresh_distance_squared =
        _refresh_distance
        * _refresh_distance;


    // ========================================================================
    // ENEMY MOVEMENT
    // ========================================================================

    var _enemy_move_x =
        _enemy.x
        - _cache.source_position.x;

    var _enemy_move_y =
        _enemy.y
        - _cache.source_position.y;

    var _enemy_moved =
        (
            (_enemy_move_x * _enemy_move_x)
            + (_enemy_move_y * _enemy_move_y)
        )
        >= _refresh_distance_squared;


    // ========================================================================
    // TARGET MOVEMENT
    // ========================================================================

    var _target_move_x =
        _target.x
        - _cache.target_position.x;

    var _target_move_y =
        _target.y
        - _cache.target_position.y;

    var _target_moved =
        (
            (_target_move_x * _target_move_x)
            + (_target_move_y * _target_move_y)
        )
        >= _refresh_distance_squared;


    // ========================================================================
    // WORLD CHANGES
    // ========================================================================

    var _navigation_revision =
        global.vtd_level.navigation.revision;

    var _navigation_changed =
        _cache.navigation_revision
        != _navigation_revision;


    // ========================================================================
    // REFRESH DECISION
    // ========================================================================

    var _refresh =
        !_cache.initialized
        || _cache.timer <= 0
        || _cache.target != _target
        || _enemy_moved
        || _target_moved
        || _navigation_changed;


    if (!_refresh)
        return _cache.clear;


    var _blocked =
        _cache.blocked_function(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );


    _cache.clear =
        !_blocked;

    _cache.initialized =
        true;

    _cache.target =
        _target;

    _cache.source_position.x =
        _enemy.x;

    _cache.source_position.y =
        _enemy.y;

    _cache.target_position.x =
        _target.x;

    _cache.target_position.y =
        _target.y;

    _cache.navigation_revision =
        _navigation_revision;


    _cache.timer =
        irandom_range(
            _cache.interval.minimum,
            _cache.interval.maximum
        )
        * max(
            1,
            _interval_multiplier
        );


    return _cache.clear;
}


/// @description Returns whether an enemy's attack has clear sight of its target.

function scr_enemy_attack_line_of_sight_clear(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;

    if (
        !variable_instance_exists(
            _enemy,
            "enemy_data"
        )
        || !is_struct(_enemy.enemy_data)
        || !variable_struct_exists(
            _enemy.enemy_data,
            "attack"
        )
        || !is_struct(_enemy.enemy_data.attack)
    )
    {
        show_debug_message(
            "ENEMY ATTACK LOS ERROR - attack definition is missing: "
            + string(_enemy.id)
        );

        return false;
    }


    var _attack_data =
        _enemy.enemy_data.attack;


    // LOS is optional. Most enemies stop here without creating any cache.

    if (
        !variable_struct_exists(
            _attack_data,
            "line_of_sight"
        )
    )
    {
        return true;
    }


    var _line_data =
        _attack_data.line_of_sight;


    if (!is_struct(_line_data))
    {
        show_debug_message(
            "ENEMY ATTACK LOS ERROR - line_of_sight must be a struct: "
            + _enemy.identity.key
        );

        return false;
    }

    if (
        !variable_struct_exists(
            _line_data,
            "required"
        )
    )
    {
        show_debug_message(
            "ENEMY ATTACK LOS ERROR - required field is missing: "
            + _enemy.identity.key
        );

        return false;
    }


    if (!_line_data.required)
        return true;


    // Only an enemy whose attack requires LOS creates this optional runtime.

    if (
        !variable_struct_exists(
            _enemy.attack,
            "line_of_sight_cache"
        )
    )
    {
        var _interval_minimum =
            variable_struct_exists(
                _line_data,
                "interval_minimum"
            )
            ? _line_data.interval_minimum
            : 8;

        var _interval_maximum =
            variable_struct_exists(
                _line_data,
                "interval_maximum"
            )
            ? _line_data.interval_maximum
            : 15;

        var _movement_refresh_distance =
            variable_struct_exists(
                _line_data,
                "movement_refresh_distance"
            )
            ? _line_data.movement_refresh_distance
            : 32;

        var _blocked_function =
            variable_struct_exists(
                _line_data,
                "blocked_function"
            )
            ? _line_data.blocked_function
            : scr_world_line_blocked_by_dead;


        _enemy.attack.line_of_sight_cache =
            scr_enemy_attack_line_of_sight_cache_create(
                _interval_minimum,
                _interval_maximum,
                _movement_refresh_distance,
                _blocked_function
            );
    }


    if (
        !is_struct(
            _enemy.attack.line_of_sight_cache
        )
    )
    {
        show_debug_message(
            "ENEMY ATTACK LOS ERROR - cache creation failed: "
            + _enemy.identity.key
        );

        return false;
    }


    var _interval_multiplier =
        1;


    // Enemies outside the visible area may refresh less often.

    if (
        variable_instance_exists(
            _enemy,
            "performance"
        )
        && is_struct(_enemy.performance)
        && !_enemy.performance.visibility.visible
    )
    {
        _interval_multiplier =
            _enemy.performance.lazy_factor;
    }


    return scr_enemy_attack_line_of_sight_cache_update(
        _enemy,
        _target,
        _enemy.attack.line_of_sight_cache,
        _interval_multiplier
    );
}


/// @description Processes ordinary targeting, movement and attacking.

function scr_enemy_step_event_gameplay(
    _enemy,
    _decision_due
)
{
    if (!instance_exists(_enemy))
        return false;


    // ========================================================================
    // PLAYER TARGETING AND STRATEGIC RETARGETING
    // ========================================================================

    if (scr_enemy_order_active(id))
    {
        scr_enemy_order_update(id);
    }
    else
    {
        var _player_target_active =
            variable_struct_exists(
                targeting,
                "player"
            )
            && targeting.player.active;


        if (
            _player_target_active
            || _decision_due
        )
        {
            scr_enemy_player_targeting_update(
                id
            );
        }
        else
        {
            scr_enemy_strategic_retarget_update(
                id
            );
        }
    }


    if (!instance_exists(_enemy))
        return true;


    // ========================================================================
    // PRIMARY GAMEPLAY
    // ========================================================================

    scr_enemy_update(
        _enemy
    );


    return true;
}


/// @description Finishes one enemy Step with optional visual and shield work.

function scr_enemy_step_event_finish(
    _enemy,
    _visible
)
{
    if (!instance_exists(_enemy))
        return false;


    if (_visible)
    {
        scr_enemy_visual_direction_update(
            _enemy
        );

        scr_particles_enemy_update(
            _enemy
        );
    }


    var _shield_active =
        _enemy.vitals.shield.hit_flash > 0
        || (
            is_struct(
                _enemy.vitals.shield.support
            )
            && _enemy.vitals.shield.support.enabled
        );


    if (_shield_active)
    {
        scr_enemy_shield_update(
            _enemy
        );
    }


    return true;
}
