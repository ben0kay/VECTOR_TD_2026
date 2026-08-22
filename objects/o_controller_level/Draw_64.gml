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

draw_set_halign(
    fa_left
);

draw_set_valign(
    fa_top
);


// ============================================================================
// CONTROLS
// ============================================================================

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
    "LEFT MOUSE: Fire"
);

draw_text(
    16,
    80,
    "C: Toggle Camera"
);

draw_text(
    16,
    100,
    "ARROWS: Move Roaming Camera"
);

draw_text(
    16,
    120,
    "MOUSE WHEEL: Zoom"
);

draw_text(
    16,
    140,
    "N: Spawn Weak Drone"
);

draw_text(
    16,
    160,
    "K: Damage CPU"
);

draw_text(
    16,
    180,
    "B: Build Basic Walls"
);

draw_text(
    16,
    200,
    "LEFT CLICK: Place Wall"
);

draw_text(
    16,
    220,
    "RIGHT CLICK: Cancel Build Mode"
);


// ============================================================================
// LEVEL INFORMATION
// ============================================================================

var _cpu =
    global.vtd_level.entities.cpu;


if (instance_exists(_cpu))
{
    draw_text(
        16,
        250,
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


var _player =
    global.vtd_level.entities.player;


if (instance_exists(_player))
{
    draw_text(
        16,
        270,
        "PLAYER KILLS: "
        + string(
            _player.combat.kills
        )
    );
}


draw_text(
    16,
    290,
    "ENEMIES: "
    + string(
        instance_number(o_enemy)
    )
);


draw_text(
    16,
    310,
    "BUILDINGS: "
    + string(
        instance_number(o_building_par)
    )
);


// ============================================================================
// BUILD MODE
// ============================================================================

var _build_text =
    "NONE";


switch (global.BuildState)
{
    case BuildState.NONE:
    {
        _build_text =
            "NONE";
    }
    break;


    case BuildState.PLACING:
    {
        _build_text =
            "PLACING WALL";
    }
    break;
}


draw_text(
    16,
    340,
    "BUILD MODE: "
    + _build_text
);


// ============================================================================
// CAMERA
// ============================================================================

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
        370,
        "CAMERA: "
        + _mode_text
    );

    draw_text(
        16,
        390,
        "ZOOM: "
        + string_format(
            _camera.camera_runtime
                .zoom.current,
            1,
            2
        )
    );
}


// ============================================================================
// DEFEAT MESSAGE
// ============================================================================

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


draw_set_alpha(
    1
);

draw_set_color(
    c_white
);