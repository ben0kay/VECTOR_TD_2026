/// @description Initializes one foundation tile.

if (!scr_foundation_initialize(id))
{
    show_debug_message(
        "FOUNDATION ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}