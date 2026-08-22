/// @description Initializes the level camera.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

if (!scr_camera_initialize(id))
{
    show_debug_message(
        "CAMERA ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}