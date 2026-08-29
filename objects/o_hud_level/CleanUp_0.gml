/// @description Releases level HUD references and cached surfaces.

scr_hud_minimap_static_terrain_destroy(id);


if (
    variable_struct_exists(
        hud,
        "static_surface"
    )
)
{
    if (
        surface_exists(
            hud.static_surface.surface_id
        )
    )
    {
        surface_free(
            hud.static_surface.surface_id
        );
    }

    hud.static_surface.surface_id =
        -1;
}


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
    global.vtd_level.entities.hud =
        noone;
}