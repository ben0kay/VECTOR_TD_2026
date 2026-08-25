/// @description Initializes one generic cargo drone.

if (!variable_instance_exists(id, "cargo_job"))
    cargo_job = CargoDroneJob.MINER_DELIVERY;

var _initialized =
    cargo_job == CargoDroneJob.MINER_DELIVERY
    ? scr_logistics_drone_initialize(id)
    : scr_refinery_drone_initialize(id);

if (!_initialized)
{
    show_debug_message(
        "CARGO DRONE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}
