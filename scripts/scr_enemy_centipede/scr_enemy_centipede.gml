/// @description Initializes optional Centipede head or child runtime.

function scr_enemy_centipede_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.centipede =
    {
        is_head: false,
        is_child: false,
        detached: false,

        master: noone,
        follow_delay: 0,
        last_direction: _enemy.movement.direction,

        trail: [],
        trail_stagger: 20,
        maximum_children: 0,
        children: []
    };


    // ========================================================================
    // CHILD CREATED BY A HEAD
    // ========================================================================

    if (variable_instance_exists(_enemy, "centipede_master"))
    {
        _enemy.centipede.is_child = true;
        _enemy.centipede.master = _enemy.centipede_master;

        if (variable_instance_exists(_enemy, "centipede_follow_delay"))
        {
            _enemy.centipede.follow_delay =
                _enemy.centipede_follow_delay;
        }

        return true;
    }


    // ========================================================================
    // ORDINARY NON-CENTIPEDE ENEMY
    // ========================================================================

    var _data = _enemy.enemy_data;

    if (!variable_struct_exists(_data, "centipede"))
        return true;

    if (!is_struct(_data.centipede))
        return false;


    // ========================================================================
    // HEAD
    // ========================================================================

    var _settings = _data.centipede;
    var _runtime = _enemy.centipede;

    _runtime.is_head = true;
    _runtime.trail_stagger =
        max(1, floor(_settings.trail_stagger));

    _runtime.maximum_children =
        max(
            floor(_settings.child_count_minimum),
            floor(_settings.child_count_maximum)
        );


    var _maximum_history =
        (_runtime.maximum_children * _runtime.trail_stagger)
        + 5;


    // Begin with the head's spawn position filling the trail.
    // The children naturally stretch out as the head begins moving.

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
            floor(_settings.child_count_minimum),
            floor(_settings.child_count_maximum)
        );


    for (var i = 1; i <= _child_count; ++i)
    {
        var _child =
            scr_enemy_centipede_child_create(
                _enemy,
                _settings.child_key,
                i * _runtime.trail_stagger
            );

        if (instance_exists(_child))
            array_push(_runtime.children, _child);
    }


    return true;
}


/// @description Creates one child behind a Centipede head.

function scr_enemy_centipede_child_create(
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
        return noone;


    var _wave_number = 0;

    if (variable_instance_exists(_head, "major_wave_number"))
        _wave_number = _head.major_wave_number;


    var _creation_variables =
    {
        enemy_key: _child_key,

        spawn_modifiers:
            scr_enemy_modifiers_copy(
                _head.modifiers
            ),

        major_wave_number: _wave_number,
        spawn_direction: _head.movement.direction,

        centipede_master: _head,
        centipede_follow_delay: _follow_delay
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


/// @description Records the Centipede head's current position.

function scr_enemy_centipede_head_update(_head)
{
    if (!instance_exists(_head))
        return false;

    if (!_head.centipede.is_head)
        return false;


    var _runtime = _head.centipede;

    array_push(
        _runtime.trail,
        {
            x: _head.x,
            y: _head.y
        }
    );


    var _maximum_history =
        (_runtime.maximum_children * _runtime.trail_stagger)
        + 5;


    while (array_length(_runtime.trail) > _maximum_history)
        array_delete(_runtime.trail, 0, 1);


    return true;
}


/// @description Makes a child follow its delayed head breadcrumb.
/// @returns True while the child handled its movement here.

function scr_enemy_centipede_child_update(_child)
{
    if (!instance_exists(_child))
        return false;

    if (!_child.centipede.is_child)
        return false;

    if (_child.centipede.detached)
        return false;


    var _master =
        _child.centipede.master;


    // The existing brainless enemy behavior takes over when the head dies.

    if (!instance_exists(_master))
    {
        _child.centipede.detached = true;

        _child.movement.direction =
            _child.centipede.last_direction;

        _child.visual.draw_angle =
            _child.centipede.last_direction;

        return false;
    }


    var _trail =
        _master.centipede.trail;

    var _trail_index =
        array_length(_trail)
        - 1
        - _child.centipede.follow_delay;


    if (_trail_index < 0)
        return true;


    var _target =
        _trail[_trail_index];


    if (
        _child.x != _target.x
        || _child.y != _target.y
    )
    {
        _child.centipede.last_direction =
            point_direction(
                _child.x,
                _child.y,
                _target.x,
                _target.y
            );

        _child.visual.draw_angle =
            _child.centipede.last_direction;

        _child.movement.direction =
            _child.centipede.last_direction;
    }


    _child.x = _target.x;
    _child.y = _target.y;


    return true;
}