/// @description Initializes one generic data-driven refinery.

event_inherited();
if (!instance_exists(id)) exit;

if (!scr_refinery_initialize(id))
{
    show_debug_message("REFINERY ERROR - initialization failed.");
    instance_destroy();
    exit;
}
