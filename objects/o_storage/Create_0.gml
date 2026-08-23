/// @description Initializes one generic resource-storage building.

event_inherited();


if (!instance_exists(id))
    exit;


if (!scr_storage_initialize(id))
{
    show_debug_message(
        "STORAGE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}