/// @description Initializes the CPU.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}


if (!scr_cpu_initialize(id))
{
    show_debug_message(
        "CPU ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}