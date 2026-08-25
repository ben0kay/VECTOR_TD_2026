/// @description Reusable Vector TD particle library.


// ============================================================================
// INITIALIZATION
// ============================================================================

/// @description Creates the persistent particle system and particle types.

function scr_particles_initialize()
{
    global.vtd.particles =
    {
        system:
            part_system_create(),

        types:
        {
            glow: part_type_create(),
            spark: part_type_create(),
            ring: part_type_create(),
            ember: part_type_create(),
			contact_spark: part_type_create()
        }
    };


    var _particles =
        global.vtd.particles;

    var _types =
        _particles.types;


    part_system_depth(
        _particles.system,
        -100
    );


    // ========================================================================
    // SOFT GLOW
    // ========================================================================

    part_type_sprite(
        _types.glow,
        s_particle_blur,
        false,
        false,
        false
    );

    part_type_life(
        _types.glow,
        10,
        18
    );

    part_type_size(
        _types.glow,
        0.12,
        0.28,
        -0.012,
        0
    );

    part_type_speed(
        _types.glow,
        0.1,
        0.6,
        -0.02,
        0
    );

    part_type_direction(
        _types.glow,
        0,
        359,
        0,
        0
    );

    part_type_alpha3(
        _types.glow,
        0,
        0.65,
        0
    );


    // ========================================================================
    // VECTOR SPARK
    // ========================================================================

    part_type_sprite(
        _types.spark,
        s_particle_sharp,
        false,
        false,
        false
    );

    part_type_life(
        _types.spark,
        8,
        16
    );

    part_type_size(
        _types.spark,
        0.08,
        0.18,
        -0.006,
        0
    );

    part_type_speed(
        _types.spark,
        1.2,
        3.5,
        -0.12,
        0
    );

    part_type_direction(
        _types.spark,
        0,
        359,
        0,
        0
    );

    part_type_orientation(
        _types.spark,
        0,
        359,
        8,
        0,
        true
    );

    part_type_alpha2(
        _types.spark,
        1,
        0
    );
	
	// ========================================================================
    // CONTACT IMPACT SPARK
    // ========================================================================

    part_type_sprite(
        _types.contact_spark,
        s_particle_sharp,
        false,
        false,
        false
    );


    part_type_life(
        _types.contact_spark,
        8,
        14
    );


    part_type_size(
        _types.contact_spark,
        0.07,
        0.15,
        -0.008,
        0
    );


    part_type_speed(
        _types.contact_spark,
        1.5,
        4,
        -0.18,
        0
    );


    // Direction is assigned at the moment of impact because it depends
    // on which direction the attacking enemy is facing.

    part_type_direction(
        _types.contact_spark,
        0,
        359,
        0,
        0
    );


    // Sharp fragments turn slightly while travelling.

    part_type_orientation(
        _types.contact_spark,
        0,
        359,
        12,
        0,
        true
    );


    part_type_alpha3(
        _types.contact_spark,
        1,
        0.8,
        0
    );


    // ========================================================================
    // EXPANDING RING
    // ========================================================================

    part_type_sprite(
        _types.ring,
        s_particle_ring,
        false,
        false,
        false
    );

    part_type_life(
        _types.ring,
        10,
        16
    );

    part_type_size(
        _types.ring,
        0.2,
        0.3,
        0.055,
        0
    );

    part_type_speed(
        _types.ring,
        0,
        0,
        0,
        0
    );

    part_type_alpha2(
        _types.ring,
        0.8,
        0
    );


    // ========================================================================
    // HEATED EMBER
    // ========================================================================

    part_type_sprite(
        _types.ember,
        s_particle_ember,
        false,
        false,
        false
    );

    part_type_life(
        _types.ember,
        12,
        24
    );

    part_type_size(
        _types.ember,
        0.06,
        0.14,
        -0.003,
        0
    );

    part_type_speed(
        _types.ember,
        0.5,
        2,
        -0.05,
        0
    );

    part_type_direction(
        _types.ember,
        210,
        330,
        0,
        0
    );

    part_type_gravity(
        _types.ember,
        0.025,
        270
    );

    part_type_alpha2(
        _types.ember,
        1,
        0
    );


    show_debug_message(
        "VECTOR TD 2026 - PARTICLES INITIALIZED"
    );


    return true;
}


// ============================================================================
// VALIDATION
// ============================================================================

/// @description Returns whether the global particle library is available.

function scr_particles_ready()
{
    if (!variable_global_exists("vtd"))
        return false;

    if (!is_struct(global.vtd))
        return false;

    if (!variable_struct_exists(global.vtd, "particles"))
        return false;

    if (!is_struct(global.vtd.particles))
        return false;


    return part_system_exists(
        global.vtd.particles.system
    );
}


// ============================================================================
// BASIC EMITTERS
// ============================================================================

/// @description Creates a small glowing impact burst.

function scr_particles_impact(
    _x,
    _y,
    _color,
    _spark_count = 5
)
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;

    var _types =
        _particles.types;


    part_type_color1(
        _types.glow,
        _color
    );

    part_type_color1(
        _types.spark,
        _color
    );

    part_type_color1(
        _types.ring,
        _color
    );


    part_particles_create(
        _particles.system,
        _x,
        _y,
        _types.glow,
        2
    );

    part_particles_create(
        _particles.system,
        _x,
        _y,
        _types.spark,
        max(1, round(_spark_count))
    );

    part_particles_create(
        _particles.system,
        _x,
        _y,
        _types.ring,
        1
    );


    return true;
}


/// @description Creates subtle particles distributed along a beam.

function scr_particles_beam(
    _start_x,
    _start_y,
    _end_x,
    _end_y,
    _color,
    _count = 4
)
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;

    var _type =
        _particles.types.glow;

    var _amount =
        max(1, round(_count));


    part_type_color1(
        _type,
        _color
    );


    for (var i = 0; i < _amount; ++i)
    {
        var _position =
            random(1);

        var _x =
            lerp(
                _start_x,
                _end_x,
                _position
            );

        var _y =
            lerp(
                _start_y,
                _end_y,
                _position
            );


        part_particles_create(
            _particles.system,
            _x + random_range(-2, 2),
            _y + random_range(-2, 2),
            _type,
            1
        );
    }


    return true;
}

/// @description Creates a shield-collapse burst.

function scr_particles_shield_break(
    _x,
    _y,
    _color,
    _radius
)
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;

    var _types =
        _particles.types;


    part_type_color1(
        _types.ring,
        _color
    );

    part_type_size(
        _types.ring,
        max(0.2, _radius / 48),
        max(0.25, _radius / 40),
        0.08,
        0
    );


    part_particles_create(
        _particles.system,
        _x,
        _y,
        _types.ring,
        2
    );


    scr_particles_impact(
        _x,
        _y,
        _color,
        8
    );


    return true;
}


/// @description Creates a subtle propulsion particle behind a flying enemy.

function scr_particles_flyer_thrust(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (_enemy.movement.layer != EnemyMovementLayer.FLYING)
        return false;

    if (!scr_particles_ready())
        return false;

    if (!scr_culling_check_instance(_enemy, 128))
        return false;


    var _particles =
        global.vtd.particles;

    var _type =
        _particles.types.glow;

    var _angle =
        _enemy.visual.draw_angle + 180;

    var _distance =
        _enemy.visual.radius * 0.75;

    var _x =
        _enemy.x
        + lengthdir_x(
            _distance,
            _angle
        );

    var _y =
        _enemy.y
        + lengthdir_y(
            _distance,
            _angle
        );


    part_type_color1(
        _type,
        make_color_rgb(
            80,
            210,
            255
        )
    );

    part_type_size(
        _type,
        0.07,
        0.13,
        -0.008,
        0
    );


    part_particles_create(
        _particles.system,
        _x,
        _y,
        _type,
        1
    );


    return true;
}


/// @description Updates staggered ambient particles for one enemy.

function scr_particles_enemy_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (_enemy.EnemyState == EnemyState.DEAD)
        return false;


    switch (_enemy.movement.layer)
    {
        case EnemyMovementLayer.FLYING:
        {
            // Stagger by instance ID so every flyer does not emit together.

            if (
                (
                    global.vtd.tick
                    + real(_enemy.id)
                )
                mod 5
                == 0
            )
            {
                scr_particles_flyer_thrust(
                    _enemy
                );
            }
        }
        break;


        case EnemyMovementLayer.GROUND:
        case EnemyMovementLayer.UNDERGROUND:
        {
            // FUTURE:
            // dust
            // underground disturbance
            // heavy-unit exhaust
        }
        break;
    }


    return true;
}


// ============================================================================
// GAMEPLAY EFFECTS
// ============================================================================

/// @description Creates subtle green repair particles along a repair beam.

function scr_particles_repair(
    _start_x,
    _start_y,
    _end_x,
    _end_y
)
{
    if (!scr_particles_ready())
        return false;


    var _color =
        make_color_rgb(
            100,
            255,
            175
        );


    scr_particles_beam(
        _start_x,
        _start_y,
        _end_x,
        _end_y,
        _color,
        5
    );

    scr_particles_impact(
        _end_x,
        _end_y,
        _color,
        4
    );


    return true;
}


/// @description Creates heated laser particles at an impact position.

function scr_particles_laser_impact(
    _x,
    _y,
    _color
)
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;


    part_type_color2(
        _particles.types.ember,
        c_white,
        _color
    );


    part_particles_create(
        _particles.system,
        _x,
        _y,
        _particles.types.ember,
        4
    );


    scr_particles_impact(
        _x,
        _y,
        _color,
        3
    );


    return true;
}


/// @description Creates a construction-completion particle burst.

function scr_particles_construction_complete(
    _x,
    _y,
    _color
)
{
    if (!scr_particles_ready())
        return false;


    scr_particles_impact(
        _x,
        _y,
        _color,
        10
    );


    return true;
}


/// @description Creates a restrained explosion burst.

function scr_particles_explosion(
    _x,
    _y,
    _color,
    _strength = 1
)
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;

    var _strength_final =
        max(0.25, _strength);


    part_type_color2(
        _particles.types.ember,
        c_white,
        _color
    );


    part_particles_create(
        _particles.system,
        _x,
        _y,
        _particles.types.ember,
        round(8 * _strength_final)
    );


    scr_particles_impact(
        _x,
        _y,
        _color,
        round(6 * _strength_final)
    );


    // FUTURE:
    // Add smoke for large explosions only.
    // Add bright flame core for cannon and rocket impacts.
    // Add broad flame body for major enemy explosions.


    return true;
}

/// @description Creates a directional particle burst when an enemy contact attack lands.

function scr_particles_enemy_contact_impact(
    _enemy,
    _target
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!instance_exists(_target))
        return false;

    if (!scr_particles_ready())
        return false;


    // No reason to create particles far outside the visible play area.

    if (!scr_culling_check_instance(_enemy, 96))
        return false;


    var _particles =
        global.vtd.particles;

    var _types =
        _particles.types;


    // ========================================================================
    // IMPACT DIRECTION
    // ========================================================================

    // Use the actual target direction rather than relying entirely on the
    // enemy's draw angle. This guarantees the effect comes from the side
    // currently striking the target.

    var _attack_angle =
        point_direction(
            _enemy.x,
            _enemy.y,
            _target.x,
            _target.y
        );


    // ========================================================================
    // CONTACT POSITION
    // ========================================================================

    // Start the particles at the forward edge / tip of the enemy.

    var _distance =
        _enemy.visual.radius;


    var _impact_x =
        _enemy.x
        + lengthdir_x(
            _distance,
            _attack_angle
        );

    var _impact_y =
        _enemy.y
        + lengthdir_y(
            _distance,
            _attack_angle
        );


    // ========================================================================
    // DIRECTIONAL SPARK SPRAY
    // ========================================================================

    // The enemy is travelling toward _attack_angle.
    //
    // Impact debris sprays mostly back toward the enemy and sideways,
    // like fragments bouncing away from the surface it struck.

    var _spray_angle =
        _attack_angle
        + 180;


    part_type_direction(
        _types.contact_spark,

        _spray_angle - 55,
        _spray_angle + 55,

        0,
        0
    );


    // Neutral impact colour.
    //
    // This keeps the effect readable regardless of enemy class colour.

    part_type_color2(
        _types.contact_spark,
        c_white,
        make_color_rgb(
            255,
            185,
            80
        )
    );


    part_particles_create(
        _particles.system,
        _impact_x,
        _impact_y,
        _types.contact_spark,
        irandom_range(
            5,
            8
        )
    );


    // ========================================================================
    // SMALL CONTACT FLASH
    // ========================================================================

    part_type_color1(
        _types.glow,
        make_color_rgb(
            255,
            210,
            120
        )
    );


    part_type_size(
        _types.glow,
        0.07,
        0.13,
        -0.008,
        0
    );


    part_particles_create(
        _particles.system,
        _impact_x,
        _impact_y,
        _types.glow,
        1
    );


    // ========================================================================
    // SMALL IMPACT RING
    // ========================================================================

    part_type_color1(
        _types.ring,
        make_color_rgb(
            255,
            190,
            80
        )
    );


    part_type_size(
        _types.ring,
        0.10,
        0.14,
        0.025,
        0
    );


    part_particles_create(
        _particles.system,
        _impact_x,
        _impact_y,
        _types.ring,
        1
    );


    return true;
}



// ============================================================================
// CLEANUP
// ============================================================================

/// @description Releases the persistent particle library.

function scr_particles_cleanup()
{
    if (!scr_particles_ready())
        return false;


    var _particles =
        global.vtd.particles;

    var _types =
        _particles.types;


    part_type_destroy(_types.glow);
    part_type_destroy(_types.spark);
    part_type_destroy(_types.ring);
    part_type_destroy(_types.ember);
	part_type_destroy(_types.contact_spark);

    part_system_destroy(
        _particles.system
    );


    global.vtd.particles =
        undefined;


    return true;
}



//// effects