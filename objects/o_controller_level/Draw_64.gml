/// @description Draws temporary development controls.

if (!global.vtd.debug.enabled)
    exit;

if (!variable_global_exists("vtd_level"))
    exit;

if (!is_struct(global.vtd_level))
    exit;


draw_set_color(
    c_white
);

draw_set_alpha(
    1
);


draw_text(
    16,
    16,
    "VECTOR TD 2026"
);

draw_text(
    16,
    40,
    "WASD: Move Player"
);

draw_text(
    16,
    60,
    "C: Toggle Camera"
);

draw_text(
    16,
    80,
    "ARROWS: Move Roaming Camera"
);

draw_text(
    16,
    100,
    "MOUSE WHEEL: Zoom"
);


var _camera =
    global.vtd_level.entities.camera;


if (instance_exists(_camera))
{
    var _mode_text =
        "FOLLOW PLAYER";


    switch (global.CameraState)
    {
        case CameraState.FOLLOW_PLAYER:
        {
            _mode_text =
                "FOLLOW PLAYER";
        }
        break;


        case CameraState.ROAMING:
        {
            _mode_text =
                "ROAMING";
        }
        break;
    }


    draw_text(
        16,
        130,
        "CAMERA: "
        + _mode_text
    );

    draw_text(
        16,
        150,
        "ZOOM: "
        + string_format(
            _camera.camera_runtime
                .zoom.current,
            1,
            2
        )
    );
}


draw_set_color(
    c_white
);