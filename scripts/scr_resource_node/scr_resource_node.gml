/// @description Generic resource-node initialization and drawing.


/// @description Initializes one data-driven resource node.

function scr_resource_node_initialize(_node)
{
    if (!instance_exists(_node))
        return false;


    if (
        !variable_instance_exists(_node, "world_cell_x")
        || !variable_instance_exists(_node, "world_cell_y")
        || !variable_instance_exists(_node, "resource_key")
        || !variable_instance_exists(_node, "vein_id")
    )
    {
        return false;
    }


    if (
        scr_world_cell_type_get(
            _node.world_cell_x,
            _node.world_cell_y
        )
        != WorldCellType.RESOURCE
    )
    {
        return false;
    }


    var _data = scr_resource_data_get(_node.resource_key);

    if (!scr_resource_data_valid(_data))
        return false;


    _node.resource_data = _data;


    _node.identity =
    {
        key: _data.identity.key,
        name: _data.identity.name,
        vein_id: _node.vein_id
    };


    var _amount = irandom_range(
        _data.node.amount_min,
        _data.node.amount_max
    );


    _node.amount =
    {
        current: _amount,
        maximum: _amount,
        depleted: false
    };


    _node.claim =
    {
        miner: noone
    };


    _node.visual =
    {
        sprite: _data.visual.sprite,
        draw_function: _data.visual.draw_function,
        color: _data.visual.color,
        rotation: irandom(3) * 90,
        scale: random_range(0.8, 1)
    };


    return true;
}

/// @description Draws the primitive crystal used by unsprited resource nodes.

function scr_resource_node_visual_crystal(_node)
{
    if (!instance_exists(_node))
        return false;


    var _cell_size = global.vtd_level.map.cell_size;
    var _radius = _cell_size * 0.38 * _node.visual.scale;
    var _angle = _node.visual.rotation;


    var _top_x = _node.x + lengthdir_x(_radius, _angle + 90);
    var _top_y = _node.y + lengthdir_y(_radius, _angle + 90);

    var _right_x = _node.x + lengthdir_x(_radius, _angle);
    var _right_y = _node.y + lengthdir_y(_radius, _angle);

    var _bottom_x = _node.x + lengthdir_x(_radius, _angle - 90);
    var _bottom_y = _node.y + lengthdir_y(_radius, _angle - 90);

    var _left_x = _node.x + lengthdir_x(_radius, _angle + 180);
    var _left_y = _node.y + lengthdir_y(_radius, _angle + 180);


    draw_set_color(_node.visual.color);

    draw_triangle(
        _top_x,
        _top_y,
        _right_x,
        _right_y,
        _node.x,
        _node.y,
        false
    );

    draw_triangle(
        _node.x,
        _node.y,
        _bottom_x,
        _bottom_y,
        _left_x,
        _left_y,
        false
    );

    draw_line_width(
        _top_x,
        _top_y,
        _bottom_x,
        _bottom_y,
        2
    );

    draw_line_width(
        _left_x,
        _left_y,
        _right_x,
        _right_y,
        2
    );


    draw_set_color(c_white);

    draw_circle(
        _node.x,
        _node.y,
        2,
        true
    );


    return true;
}


/// @description Draws one unclaimed resource node.

function scr_resource_node_draw(_node)
{
    if (!instance_exists(_node))
        return false;


    if (instance_exists(_node.claim.miner))
        return true;


    if (_node.visual.sprite != -1)
    {
        draw_sprite_ext(
            _node.visual.sprite,
            _node.image_index,
            _node.x,
            _node.y,
            1,
            1,
            _node.visual.rotation,
            c_white,
            1
        );
    }
    else if (!is_undefined(_node.visual.draw_function))
    {
        _node.visual.draw_function(_node);
    }


    draw_set_color(c_white);

    draw_text(
        _node.x - 12,
        _node.y + 12,
        string(floor(_node.amount.current))
    );


    return true;
}

/// @description Returns the resource node occupying one world cell.

function scr_resource_node_at_cell(_cell_x, _cell_y)
{
    var _count = instance_number(o_resource_node);


    for (var i = 0; i < _count; ++i)
    {
        var _node = instance_find(o_resource_node, i);

        if (!instance_exists(_node))
            continue;

        if (
            _node.world_cell_x == _cell_x
            && _node.world_cell_y == _cell_y
        )
        {
            return _node;
        }
    }


    return noone;
}