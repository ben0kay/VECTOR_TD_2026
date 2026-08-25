/// @description Releases cargo-drone assignments.

if (cargo_job == CargoDroneJob.MINER_DELIVERY)
    scr_logistics_drone_cleanup(id);
else
    scr_refinery_drone_cleanup(id);
