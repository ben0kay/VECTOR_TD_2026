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


// ========================================================================
// CPU
// ========================================================================

var _cpu =
    instance_create_layer(
        room_width * 0.5,
        room_height * 0.5,
        "Buildings",
        o_cpu
    );

if (!instance_exists(_cpu))
{
    show_debug_message(
        "LEVEL ERROR - CPU creation failed."
    );

    instance_destroy();
    exit;
}


// ========================================================================
// PLAYER
// ========================================================================

var _player =
    instance_create_layer(
        (room_width * 0.5) - 256,
        room_height * 0.5,
        "Player",
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


// ========================================================================
// CAMERA
// ========================================================================

var _camera =
    instance_create_layer(
        0,
        0,
        "Controller",
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

// ========================================================================
// ENERGY CONTROLLER
// ========================================================================

var _energy_controller =
    instance_create_layer(
        0,
        0,
        "Controller",
        o_controller_energy
    );

if (!instance_exists(_energy_controller))
{
    show_debug_message(
        "LEVEL ERROR - energy controller creation failed."
    );

    instance_destroy();
    exit;
}


// ========================================================================
// FOG OF WAR
// ========================================================================

var _fog =
    instance_create_layer(
        0,
        0,
        "Controller",
        o_controller_fog
    );

if (!instance_exists(_fog))
{
    show_debug_message(
        "LEVEL ERROR - fog controller creation failed."
    );

    instance_destroy();
    exit;
}


// ========================================================================
// BUILD CONTROLLER
// ========================================================================

var _build_controller =
    instance_create_layer(
        0,
        0,
        "Controller",
        o_controller_build
    );

if (!instance_exists(_build_controller))
{
    show_debug_message(
        "LEVEL ERROR - build controller creation failed."
    );

    instance_destroy();
    exit;
}


// ========================================================================
// ENEMY SPAWNER
// ========================================================================

var _spawner =
    instance_create_layer(
        0,
        0,
        "Controller",
        o_enemy_spawner
    );

if (!instance_exists(_spawner))
{
    show_debug_message(
        "LEVEL ERROR - enemy spawner creation failed."
    );

    instance_destroy();
    exit;
}


show_debug_message(
    "VECTOR TD 2026 - TEST WORLD READY"
);