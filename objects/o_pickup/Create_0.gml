/// @description Initializes one physical pickup.

if (!scr_pickup_initialize(id))
{
    show_debug_message(
        "PICKUP ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}