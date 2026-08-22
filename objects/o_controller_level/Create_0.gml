/// @description Initializes the current gameplay level.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

if (!variable_global_exists("vtd"))
{
    show_debug_message(
        "LEVEL ERROR - global.vtd does not exist."
    );

    instance_destroy();
    exit;
}


if (!scr_level_initialize())
{
    show_debug_message(
        "LEVEL ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}


// ============================================================================
// PLAYER
// ============================================================================

var _player =
    instance_create_layer(
        room_width * 0.5,
        room_height * 0.5,
        "Instances",
        o_player
    );

if (!instance_exists(_player))
{
    show_debug_message(
        "LEVEL ERROR - player creation failed."
    );

    instance_destroy();
    exit;
}


// ============================================================================
// CAMERA
// ============================================================================

var _camera =
    instance_create_layer(
        0,
        0,
        "Instances",
        o_camera
    );

if (!instance_exists(_camera))
{
    show_debug_message(
        "LEVEL ERROR - camera creation failed."
    );

    instance_destroy();
    exit;
}


show_debug_message(
    "VECTOR TD 2026 - TEST WORLD READY"
);