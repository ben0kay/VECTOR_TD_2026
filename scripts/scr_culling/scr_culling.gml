/// @description Returns the active world-camera bounds.

function scr_culling_camera_bounds_get(_padding = 0)
{
    var _camera = view_camera[0];

    if (_camera < 0)
        return undefined;


    var _left = camera_get_view_x(_camera);
    var _top = camera_get_view_y(_camera);
    var _width = camera_get_view_width(_camera);
    var _height = camera_get_view_height(_camera);

    return
    {
        left: _left - _padding,
        top: _top - _padding,
        right: _left + _width + _padding,
        bottom: _top + _height + _padding,
        width: _width,
        height: _height
    };
}


/// @description Returns whether a world-space circle overlaps the camera.

function scr_culling_check_circle(
    _world_x,
    _world_y,
    _radius,
    _padding = 128
)
{
    var _bounds =
        scr_culling_camera_bounds_get(_padding);

    if (!is_struct(_bounds))
        return true;


    _radius = max(0, _radius);

    return !(
        _world_x + _radius < _bounds.left
        || _world_x - _radius > _bounds.right
        || _world_y + _radius < _bounds.top
        || _world_y - _radius > _bounds.bottom
    );
}


/// @description Returns whether an instance overlaps the camera.

function scr_culling_check_instance(
    _instance,
    _padding = 128
)
{
    if (!instance_exists(_instance))
        return false;


    var _radius = 16;

    if (
        variable_instance_exists(_instance, "visual")
        && is_struct(_instance.visual)
        && variable_struct_exists(_instance.visual, "radius")
    )
    {
        _radius = max(1, _instance.visual.radius);
    }
    else if (
        variable_instance_exists(_instance, "collision")
        && is_struct(_instance.collision)
        && variable_struct_exists(_instance.collision, "radius")
    )
    {
        _radius = max(1, _instance.collision.radius);
    }
    else if (
        variable_instance_exists(_instance, "footprint")
        && is_struct(_instance.footprint)
    )
    {
        var _cell_size =
            global.vtd_level.map.cell_size;

        _radius = max(
            _instance.footprint.width_cells,
            _instance.footprint.height_cells
        ) * _cell_size;
    }


    return scr_culling_check_circle(
        _instance.x,
        _instance.y,
        _radius,
        _padding
    );


    // FUTURE:
    // rectangular bounds for enormous entities
    // chunk visibility
    // audible-distance checks
    // effect-detail tiers
}