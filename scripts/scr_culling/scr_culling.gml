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
    static _cached_tick = -1;
    static _cached_camera = -1;

    static _cached_left = 0;
    static _cached_top = 0;
    static _cached_right = 0;
    static _cached_bottom = 0;


    var _camera =
        view_camera[0];

    if (_camera < 0)
        return true;


    // Every Draw event in one frame uses the same camera bounds.
    // Re-read the camera only once after the main tick advances.

    if (
        _cached_tick != VTD_TICK
        || _cached_camera != _camera
    )
    {
        _cached_tick =
            VTD_TICK;

        _cached_camera =
            _camera;

        _cached_left =
            camera_get_view_x(_camera);

        _cached_top =
            camera_get_view_y(_camera);

        _cached_right =
            _cached_left
            + camera_get_view_width(_camera);

        _cached_bottom =
            _cached_top
            + camera_get_view_height(_camera);
    }


    _radius =
        max(
            0,
            _radius
        );

    return !(
        _world_x + _radius
        < _cached_left - _padding

        || _world_x - _radius
        > _cached_right + _padding

        || _world_y + _radius
        < _cached_top - _padding

        || _world_y - _radius
        > _cached_bottom + _padding
    );
}

/// @description Fast moving-circle camera overlap using cached camera bounds.

function scr_culling_check_circle_fast(
    _world_x,
    _world_y,
    _radius,
    _padding = 128
)
{
    static _cached_tick = -1;
    static _cached_camera = -1;

    static _left = 0;
    static _top = 0;
    static _right = 0;
    static _bottom = 0;


    var _camera =
        view_camera[0];

    if (_camera < 0)
        return true;


    if (
        _cached_tick != VTD_TICK
        || _cached_camera != _camera
    )
    {
        _cached_tick =
            VTD_TICK;

        _cached_camera =
            _camera;

        _left =
            camera_get_view_x(_camera);

        _top =
            camera_get_view_y(_camera);

        _right =
            _left
            + camera_get_view_width(_camera);

        _bottom =
            _top
            + camera_get_view_height(_camera);
    }


    return !(
        _world_x + _radius
            < _left - _padding

        || _world_x - _radius
            > _right + _padding

        || _world_y + _radius
            < _top - _padding

        || _world_y - _radius
            > _bottom + _padding
    );
}

/// @description Fast world-point visibility test using cached camera bounds.

function scr_culling_check_point_fast(
    _world_x,
    _world_y,
    _padding = 64
)
{
    static _cached_tick = -1;
    static _cached_camera = -1;

    static _left = 0;
    static _top = 0;
    static _right = 0;
    static _bottom = 0;


    var _camera =
        view_camera[0];

    if (_camera < 0)
        return true;


    if (
        _cached_tick != VTD_TICK
        || _cached_camera != _camera
    )
    {
        _cached_tick =
            VTD_TICK;

        _cached_camera =
            _camera;


        _left =
            camera_get_view_x(_camera);

        _top =
            camera_get_view_y(_camera);

        _right =
            _left
            + camera_get_view_width(_camera);

        _bottom =
            _top
            + camera_get_view_height(_camera);
    }


    return (
        _world_x >= _left - _padding
        && _world_x <= _right + _padding
        && _world_y >= _top - _padding
        && _world_y <= _bottom + _padding
    );
}

/// @description Returns whether an instance overlaps the camera.

function scr_culling_check_instance(
    _instance,
    _padding = 128
)
{


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