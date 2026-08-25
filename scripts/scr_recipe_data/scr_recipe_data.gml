/// @description Data-driven refinery recipes.

function scr_recipe_data_initialize()
{
    global.vtd.data.recipes = {
        refined_carbon:
        {
            identity: { key: "refined_carbon", name: "Refined Carbon" },
            inputs: [{ resource_key: "resource_carbon", amount: 100 }],
            outputs: [{ resource_key: "resource_refined_carbon", amount: 1 }],
            production: { time_seconds: 30, energy_per_second: 4 }
        },

        refined_silicon:
        {
            identity: { key: "refined_silicon", name: "Refined Silicon" },
            inputs: [{ resource_key: "resource_silicon", amount: 100 }],
            outputs: [{ resource_key: "resource_refined_silicon", amount: 1 }],
            production: { time_seconds: 45, energy_per_second: 5 }
        },

        refined_copper:
        {
            identity: { key: "refined_copper", name: "Refined Copper" },
            inputs: [{ resource_key: "resource_copper", amount: 100 }],
            outputs: [{ resource_key: "resource_refined_copper", amount: 1 }],
            production: { time_seconds: 40, energy_per_second: 4.5 }
        }
    };

    show_debug_message("VECTOR TD 2026 - RECIPE DATA INITIALIZED");
    return true;
}

function scr_recipe_data_get(_recipe_key)
{
    if (!is_string(_recipe_key) || _recipe_key == "") return undefined;
    if (!variable_struct_exists(global.vtd.data.recipes, _recipe_key)) return undefined;
    return variable_struct_get(global.vtd.data.recipes, _recipe_key);
}

function scr_recipe_data_valid(_data)
{
    if (!is_struct(_data)) return false;
    if (!variable_struct_exists(_data, "identity")) return false;
    if (!variable_struct_exists(_data, "inputs") || !is_array(_data.inputs)) return false;
    if (!variable_struct_exists(_data, "outputs") || !is_array(_data.outputs)) return false;
    if (!variable_struct_exists(_data, "production") || !is_struct(_data.production)) return false;
    if (array_length(_data.inputs) <= 0 || array_length(_data.outputs) <= 0) return false;
    return _data.production.time_seconds > 0 && _data.production.energy_per_second >= 0;
}
