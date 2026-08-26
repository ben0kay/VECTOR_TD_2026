/// @description Releases level HUD references and cached surfaces.

scr_hud_minimap_static_terrain_destroy(id);

hud.alerts.queue = [];
hud.alerts.active = undefined;


if (
    variable_global_exists("vtd_level")
    && is_struct(global.vtd_level)
    && variable_struct_exists(
        global.vtd_level.entities,
        "hud"
    )
    && global.vtd_level.entities.hud == id
)
{
    global.vtd_level.entities.hud = noone;
}