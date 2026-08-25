/// @description Initializes one generic data-driven Fabricator.

event_inherited();

if (!instance_exists(id))
    exit;


if (!scr_production_initialize(id))
{
    show_debug_message(
        "FABRICATOR ERROR - production initialization failed."
    );

    instance_destroy();
    exit;
}