/// @description Inherits building logic and processes active storage behaviour.

event_inherited();


if (!instance_exists(id))
    exit;

if (!GAMEPLAY_ACTIVE) exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;


// FUTURE:
// power state
// storage damage or leakage
// active cargo ports
// drone reservations