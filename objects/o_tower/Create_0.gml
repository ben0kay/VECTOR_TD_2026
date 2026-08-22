/// @description Initializes the building parent and tower runtime.

event_inherited();


if (!instance_exists(id))
    exit;


if (!scr_tower_initialize(id))
{
    show_debug_message(
        "TOWER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}