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
scr_hud_bottom_bar_draw(id);
scr_hud_pressure_draw(id);
scr_hud_vector_window_draw(id);


// FUTURE:
// notifications
// attack-side warnings
// wave banners
// power overlay
// fog information


draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);