/// @description Processes cargo-drone movement and delivery.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


if (cargo_job == CargoDroneJob.MINER_DELIVERY)
    scr_logistics_drone_update(id);
else
    scr_refinery_drone_update(id);
