/// @description Draws temporary development information.

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

draw_text(
    16,
    120,
    "N: Spawn Weak Drone"
);

draw_text(
    16,
    140,
    "K: Damage CPU"
);


var _cpu =
    global.vtd_level.entities.cpu;


if (instance_exists(_cpu))
{
    draw_text(
        16,
        170,
        "CPU: "
        + string(
            _cpu.vitals.hp.current
        )
        + " / "
        + string(
            _cpu.vitals.hp.maximum
        )
    );
}


draw_text(
    16,
    190,
    "ENEMIES: "
    + string(
        instance_number(o_enemy)
    )
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
        220,
        "CAMERA: "
        + _mode_text
    );

    draw_text(
        16,
        240,
        "ZOOM: "
        + string_format(
            _camera.camera_runtime
                .zoom.current,
            1,
            2
        )
    );
}


if (
    global.LevelState
    == LevelState.FAILED
)
{
    draw_set_halign(
        fa_center
    );

    draw_set_valign(
        fa_middle
    );

    draw_set_color(
        c_red
    );

    draw_text(
        display_get_gui_width() * 0.5,
        display_get_gui_height() * 0.5,
        "CPU DESTROYED"
    );

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_top
    );
}


draw_set_color(
    c_white
);