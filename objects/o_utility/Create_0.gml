/// @description Initializes the building parent and utility runtime.

event_inherited();

if (!instance_exists(id))
    exit;

if (!scr_utility_initialize(id))
{
    show_debug_message(
        "UTILITY ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}