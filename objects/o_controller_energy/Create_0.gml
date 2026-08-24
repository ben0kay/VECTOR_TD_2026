/// @description Initializes the local energy-network controller.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

global.vtd_level.energy =
{
    controller: id,

    dirty: true,
    revision: 0,
    networks: [],

    overlay:
    {
        mode: EnergyOverlayMode.OFF
    },

    totals:
    {
        generation: 0,
        demand: 0,
        net: 0,

        stored: 0,
        storage_maximum: 0,

        deficient_networks: 0
    }
};

show_debug_message(
    "VECTOR TD 2026 - ENERGY CONTROLLER INITIALIZED"
);