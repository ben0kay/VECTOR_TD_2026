/// @description Releases the level energy runtime.

if (
    variable_global_exists("vtd_level")
    && is_struct(global.vtd_level)
    && variable_struct_exists(global.vtd_level, "energy")
)
{
    global.vtd_level.energy.networks = [];
    global.vtd_level.energy.controller = noone;
}