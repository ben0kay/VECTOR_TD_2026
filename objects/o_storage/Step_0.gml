/// @description Inherits building logic and processes active storage behaviour.

event_inherited();

if (!BUILDING_CAN_OPERATE)
    exit;


// FUTURE:
// storage leakage
// active cargo ports
// drone reservations