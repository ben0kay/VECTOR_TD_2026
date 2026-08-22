/// @description Initializes the current gameplay level.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

if (!variable_global_exists("vtd"))
{
    show_debug_message(
        "LEVEL ERROR - global.vtd does not exist."
    );

    instance_destroy();
    exit;
}

scr_level_initialize();