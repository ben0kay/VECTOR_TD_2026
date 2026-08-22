/// @description Initializes building placement control.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}


if (!scr_build_mode_initialize(id))
{
    show_debug_message(
        "BUILD CONTROLLER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}