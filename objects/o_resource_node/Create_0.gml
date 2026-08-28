/// @description Initializes one generic resource node.

if (!scr_resource_node_initialize(id))
{
    show_debug_message(
        "RESOURCE NODE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}