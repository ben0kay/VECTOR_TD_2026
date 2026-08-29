/// @description Draws the gameplay HUD and mission-result overlay.

// ========================================================================
// FPS COUNTER
// ========================================================================
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();
draw_set_halign(fa_right);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_gui_width - 12,_gui_height * 0.5,string(fps_real) + " FPS");
// ========================================================================

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);


if (hud.debug.hide)
    exit;

if (!variable_global_exists("vtd_level")) exit;
if (!is_struct(global.vtd_level)) exit;

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _result_active =
    variable_struct_exists(
        global.vtd_level,
        "result"
    )
    && global.vtd_level.result.active;
	
	if (
    global.LevelState
    == LevelState.CHASSIS_SELECT
)
{
    scr_hud_chassis_select_draw(id);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    exit;
}

if (_result_active)
{
    // Results replace every ordinary HUD element and alert.
    scr_level_result_hud_draw(id);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    exit;
}

scr_hud_top_bar_draw(id);
scr_hud_resource_feedback_draw(id);
scr_hud_bottom_bar_draw(id);

scr_hud_minimap_draw(id);

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

if (
    _has_selection
    && !hud.build_menu.open
)
{
    scr_hud_selection_panel_draw(id);
}
else
{
    scr_hud_build_menu_draw(id);
}

scr_hud_wave_warning_draw(id);
scr_hud_notification_draw(id);
scr_hud_alert_draw(id);

// Debug interface remains above normal gameplay HUD elements.
scr_debug_menu_draw(id);

