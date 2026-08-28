/// @description Initializes one generic resource node.

if (!scr_resource_node_initialize(id))
{
    show_debug_message(
        "RESOURCE NODE ERROR - initialization failed."
    );
	


    instance_destroy();
    exit;
}


resource_node_visible =
    true;

resource_node_visibility_timer =
    real(id) mod 3;