/// @description Initializes one generic cargo drone.

if (!scr_logistics_drone_initialize(id))
{
    show_debug_message(
        "CARGO DRONE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}