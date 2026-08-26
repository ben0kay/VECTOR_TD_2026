/// @description Initializes a unique Centipede head or child.

function scr_enemy_unique_centipede_create(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.centipede =
    {
        detached:
            false,

        master:
            noone,

        follow_delay:
            0,

        last_direction:
            _enemy.movement.direction,

        trail: [],

        trail_stagger:
            1,

        maximum_children:
            0,

        children: []
    };


    // ========================================================================
    // CHILD CREATED BY A CENTIPEDE HEAD
    // ========================================================================

    if (
        variable_instance_exists(
            _enemy,
            "centipede_master"
        )
    )
    {
        _enemy.centipede.master =
            _enemy.centipede_master;


        if (
            variable_instance_exists(
                _enemy,
                "centipede_follow_delay"
            )
        )
        {
            _enemy.centipede.follow_delay =
                _enemy.centipede_follow_delay;
        }


        if (
            !instance_exists(
                _enemy.centipede.master
            )
        )
        {
            show_debug_message(
                "CENTIPEDE ERROR - child received an invalid master."
            );

            return false;
        }


        return true;
    }


    // ========================================================================
    // HEAD CONFIGURATION
    // ========================================================================

    if (
        !variable_struct_exists(
            _enemy.enemy_data.unique,
            "centipede"
        )
        || !is_struct(
            _enemy.enemy_data.unique.centipede
        )
    )
    {
        show_debug_message(
            "CENTIPEDE ERROR - head configuration is missing: "
            + _enemy.identity.key
        );

        return false;
    }


    var _settings =
        _enemy.enemy_data.unique.centipede;

    var _runtime =
        _enemy.centipede;


    _runtime.trail_stagger =
        max(
            1,
            floor(
                _settings.trail_stagger
            )
        );

    _runtime.maximum_children =
        max(
            floor(
                _settings.child_count_minimum
            ),

            floor(
                _settings.child_count_maximum
            )
        );


    var _maximum_history =
        (
            _runtime.maximum_children
            * _runtime.trail_stagger
        )
        + 5;


    repeat (_maximum_history)
    {
        array_push(
            _runtime.trail,
            {
                x: _enemy.x,
                y: _enemy.y
            }
        );
    }


    var _child_count =
        irandom_range(
            floor(
                _settings.child_count_minimum
            ),

            floor(
                _settings.child_count_maximum
            )
        );


    for (
        var i = 1;
        i <= _child_count;
        ++i
    )
    {
        var _child =
            scr_enemy_unique_centipede_child_create(
                _enemy,
                _settings.child_key,
                i * _runtime.trail_stagger
            );


        if (!instance_exists(_child))
        {
            show_debug_message(
                "CENTIPEDE ERROR - child creation failed: "
                + _enemy.identity.key
            );

            return false;
        }


        array_push(
            _runtime.children,
            _child
        );
    }


    return true;
}


/// @description Creates one child behind a Centipede head.

function scr_enemy_unique_centipede_child_create(
    _head,
    _child_key,
    _follow_delay
)
{
    if (!instance_exists(_head))
        return noone;


    var _data =
        scr_enemy_data_get(
            _child_key
        );


    if (!scr_enemy_data_valid(_data))
    {
        show_debug_message(
            "CENTIPEDE ERROR - invalid child definition: "
            + string(_child_key)
        );

        return noone;
    }


    var _wave_number =
        0;


    if (
        variable_instance_exists(
            _head,
            "major_wave_number"
        )
    )
    {
        _wave_number =
            _head.major_wave_number;
    }


    var _creation_variables =
    {
        enemy_key:
            _child_key,

        spawn_modifiers:
            scr_enemy_modifiers_copy(
                _head.modifiers
            ),

        major_wave_number:
            _wave_number,

        spawn_direction:
            _head.movement.direction,

        centipede_master:
            _head,

        centipede_follow_delay:
            _follow_delay
    };


    return instance_create_layer(
        _head.x,
        _head.y,

        scr_layer_enemy_get(
            EnemyMovementLayer.GROUND
        ),

        o_enemy,
        _creation_variables
    );
}


/// @description Moves an attached child along its delayed breadcrumb.

function scr_enemy_unique_centipede_step_start(_child)
{
    if (!instance_exists(_child))
        return false;


    var _runtime =
        _child.centipede;


    // Detached children return to ordinary brainless movement.

    if (_runtime.detached)
        return true;


    var _master =
        _runtime.master;


    if (!instance_exists(_master))
    {
        _runtime.detached =
            true;

        _child.movement.direction =
            _runtime.last_direction;

        _child.visual.draw_angle =
            _runtime.last_direction;

        return true;
    }


    var _trail =
        _master.centipede.trail;

    var _trail_index =
        array_length(_trail)
        - 1
        - _runtime.follow_delay;


    // The unique function owns the attached child's gameplay this frame.

    _child.unique.step_event.handled =
        true;


    if (_trail_index < 0)
        return true;


    var _target =
        _trail[_trail_index];


    if (
        _child.x != _target.x
        || _child.y != _target.y
    )
    {
        _runtime.last_direction =
            point_direction(
                _child.x,
                _child.y,
                _target.x,
                _target.y
            );

        _child.visual.draw_angle =
            _runtime.last_direction;

        _child.movement.direction =
            _runtime.last_direction;
    }


    _child.x =
        _target.x;

    _child.y =
        _target.y;


    return true;
}


/// @description Records the head's position after its ordinary movement.

function scr_enemy_unique_centipede_step_finish(_head)
{
    if (!instance_exists(_head))
        return false;


    var _runtime =
        _head.centipede;


    array_push(
        _runtime.trail,
        {
            x: _head.x,
            y: _head.y
        }
    );


    var _maximum_history =
        (
            _runtime.maximum_children
            * _runtime.trail_stagger
        )
        + 5;


    while (
        array_length(_runtime.trail)
        > _maximum_history
    )
    {
        array_delete(
            _runtime.trail,
            0,
            1
        );
    }


    return true;
}
