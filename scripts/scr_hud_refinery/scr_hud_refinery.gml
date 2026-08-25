/// @description Selected-refinery bottom-bar controls and information.

function scr_hud_refinery_controls_create()
{
    return {
        recipe_buttons: [],
        auto_button: scr_hud_button_create("refinery_auto", "AUTO MODE", "ENABLED"),
        previous_target: noone
    };
}

function scr_hud_refinery_buttons_rebuild(_controls, _refinery)
{
    _controls.recipe_buttons = [];
    if (!instance_exists(_refinery)) return false;

    var _keys = _refinery.building_data.refinery.recipes;
    for (var i = 0; i < array_length(_keys); ++i)
    {
        var _recipe = scr_recipe_data_get(_keys[i]);
        if (!scr_recipe_data_valid(_recipe)) continue;

        var _button = scr_hud_button_create("recipe_" + _keys[i], string_upper(_recipe.identity.name), "SELECT RECIPE");
        _button.data = _keys[i];
        array_push(_controls.recipe_buttons, _button);
    }
    return true;
}

function scr_hud_refinery_controls_update(_hud, _refinery, _inspector_left, _tray_top)
{
    var _controls = _hud.hud.refinery_controls;

    if (_controls.previous_target != _refinery)
    {
        _controls.previous_target = _refinery;
        scr_hud_refinery_buttons_rebuild(_controls, _refinery);
    }

    var _button_width = 170;
    var _button_height = 58;
    var _gap = 8;

    for (var i = 0; i < array_length(_controls.recipe_buttons); ++i)
    {
        var _button = _controls.recipe_buttons[i];
        scr_hud_button_bounds_set(_button, 210 + (i * (_button_width + _gap)), _tray_top + 36, _button_width, _button_height);
        _button.selected = _refinery.production.selected_recipe_key == _button.data;

        if (scr_hud_button_update(_button))
            scr_refinery_recipe_select(_refinery, _button.data);
    }

    var _auto = _controls.auto_button;
    scr_hud_button_bounds_set(_auto, 210, _tray_top + 132, 170, 34);
    _auto.selected = _refinery.production.auto_mode;
    _auto.subtitle = _refinery.production.auto_mode ? "ENABLED" : "DISABLED";

    if (scr_hud_button_update(_auto))
        _refinery.production.auto_mode = !_refinery.production.auto_mode;

    return true;
}

function scr_hud_refinery_controls_draw(_hud, _refinery, _inspector_left, _tray_top)
{
    var _controls = _hud.hud.refinery_controls;
    draw_set_color(c_aqua);
    draw_text(210, _tray_top + 12, "SELECT RECIPE");

    for (var i = 0; i < array_length(_controls.recipe_buttons); ++i)
        scr_hud_button_draw(_controls.recipe_buttons[i]);

    var _production = _refinery.production;
    var _bar_left = 400;
    var _bar_right = max(_bar_left + 200, _inspector_left - 220);
    var _bar_top = _tray_top + 135;
    var _ratio = _production.duration > 0
        ? clamp(_production.progress / _production.duration, 0, 1)
        : 0;

    draw_set_color(c_dkgray);
    draw_rectangle(_bar_left, _bar_top, _bar_right, _bar_top + 14, false);
    draw_set_color(c_aqua);
    draw_rectangle(_bar_left, _bar_top, _bar_left + ((_bar_right - _bar_left) * _ratio), _bar_top + 14, false);

    draw_set_color(c_white);
    draw_text(_bar_left, _bar_top - 22,
        string_upper(_production.status_text)
        + "  //  "
        + string_format(_production.progress, 0, 1)
        + " / " + string_format(_production.duration, 0, 1) + "s"
    );

    scr_hud_button_draw(_controls.auto_button);
    return true;
}

function scr_hud_refinery_inspector_draw(_refinery, _left, _top)
{
    var _production = _refinery.production;
    var _recipe = scr_recipe_data_get(_production.selected_recipe_key);

    scr_hud_label_value_draw(_left + 18, _top + 110, "OPERATION", _production.status_text, c_aqua);

    if (!scr_recipe_data_valid(_recipe))
    {
        scr_hud_label_value_draw(_left + 18, _top + 130, "RECIPE", "NONE", c_gray);
        return true;
    }

    scr_hud_label_value_draw(_left + 18, _top + 130, "RECIPE", _recipe.identity.name, c_white);

    var _input = _recipe.inputs[0];
    var _output = _recipe.outputs[0];
    var _input_data = scr_resource_data_get(_input.resource_key);
    var _output_data = scr_resource_data_get(_output.resource_key);

    scr_hud_label_value_draw(_left + 18, _top + 150, "INPUT",
        string(_input.amount) + " " + string_upper(_input_data.identity.name), _input_data.visual.color);
    scr_hud_label_value_draw(_left + 18, _top + 170, "OUTPUT",
        string(_output.amount) + " " + string_upper(_output_data.identity.name), _output_data.visual.color);
    scr_hud_label_value_draw(_left + 18, _top + 190, "OUTPUT BUFFER",
        string(_production.output.current) + " / " + string(_production.output.capacity), _output_data.visual.color);
    scr_hud_label_value_draw(_left + 18, _top + 210, "AUTO MODE",
        _production.auto_mode ? "ENABLED" : "DISABLED", _production.auto_mode ? c_lime : c_yellow);
    return true;
}
