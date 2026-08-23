/// @description Initializes the building parent and miner runtime.

event_inherited();


if (!instance_exists(id))
    exit;


if (!scr_miner_initialize(id))
{
    show_debug_message(
        "MINER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}