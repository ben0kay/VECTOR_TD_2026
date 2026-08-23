/// @description Data-driven raw resource definitions.


/// @description Registers every raw resource definition.

function scr_resource_data_initialize()
{
    global.vtd.data.resources =
    {
        resource_carbon:
        {
            identity:
            {
                key: "resource_carbon",
                name: "Carbon"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(90, 210, 120)
            },

            node:
            {
                amount_min: 700,
                amount_max: 1200
            },

            generation:
            {
                vein_size_min: 4,
                vein_size_max: 9
            }
        },


        resource_silicon:
        {
            identity:
            {
                key: "resource_silicon",
                name: "Silicon"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(80, 190, 255)
            },

            node:
            {
                amount_min: 450,
                amount_max: 850
            },

            generation:
            {
                vein_size_min: 3,
                vein_size_max: 7
            }
        },


        resource_copper:
        {
            identity:
            {
                key: "resource_copper",
                name: "Copper"
            },

            visual:
            {
                sprite: -1,
                draw_function: scr_resource_node_visual_crystal,
                color: make_color_rgb(230, 125, 65)
            },

            node:
            {
                amount_min: 550,
                amount_max: 950
            },

            generation:
            {
                vein_size_min: 3,
                vein_size_max: 8
            }
        }
    };


    show_debug_message("VECTOR TD 2026 - RESOURCE DATA INITIALIZED");

    return true;
}


/// @description Returns one raw resource definition.

function scr_resource_data_get(_resource_key)
{
    if (!is_string(_resource_key))
        return undefined;

    if (_resource_key == "")
        return undefined;

    if (!variable_struct_exists(global.vtd.data.resources, _resource_key))
    {
        show_debug_message(
            "RESOURCE DATA ERROR - unknown key: " + _resource_key
        );

        return undefined;
    }


    return variable_struct_get(
        global.vtd.data.resources,
        _resource_key
    );
}


/// @description Returns whether a resource definition contains valid data.

function scr_resource_data_valid(_data)
{
    if (!is_struct(_data))
        return false;

    if (!variable_struct_exists(_data, "identity"))
        return false;

    if (!variable_struct_exists(_data, "visual"))
        return false;

    if (!variable_struct_exists(_data, "node"))
        return false;

    if (!variable_struct_exists(_data, "generation"))
        return false;


    if (!is_struct(_data.identity))
        return false;

    if (!is_struct(_data.visual))
        return false;

    if (!is_struct(_data.node))
        return false;

    if (!is_struct(_data.generation))
        return false;


    if (!is_string(_data.identity.key))
        return false;

    if (_data.identity.key == "")
        return false;

    if (_data.node.amount_min <= 0)
        return false;

    if (_data.node.amount_max < _data.node.amount_min)
        return false;

    if (_data.generation.vein_size_min <= 0)
        return false;

    if (
        _data.generation.vein_size_max
        < _data.generation.vein_size_min
    )
    {
        return false;
    }


    return true;
}