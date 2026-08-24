/// @description Draws the complete gameplay-level HUD.

if (!variable_global_exists("vtd_level"))
    exit;

if (!is_struct(global.vtd_level))
    exit;


draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);


scr_hud_top_bar_draw(id);
scr_hud_resource_feedback_draw(id);

scr_hud_bottom_bar_draw(id);


var _has_selection =
    instance_exists(
        hud.selection.target
    );


if (
    !hud.build_menu.open
    && !_has_selection
)
{
    scr_hud_pressure_draw(id);
}


if (_has_selection && !hud.build_menu.open)
{
    scr_hud_selection_panel_draw(id);
}
else
{
    scr_hud_build_menu_draw(id);
}


scr_hud_wave_warning_draw(id);
scr_hud_alert_draw(id);


// Debug UI always belongs above the normal level HUD.

scr_debug_menu_draw(id);


draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);