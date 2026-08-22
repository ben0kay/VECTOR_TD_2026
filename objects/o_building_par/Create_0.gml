/// @description Initializes one generic building.

if (!scr_building_initialize(id))
{
    show_debug_message(
        "BUILDING ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}