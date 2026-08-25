/// @description Fabricator recipe and batch controls.

function scr_hud_fabricator_controls_create()
{
    return
    {
        recipe_buttons: [],

        batch_one:
            scr_hud_button_create(
                "fabricator_batch_one",
                "PRODUCE 1",
                "QUEUE ONE BATCH"
            ),

        batch_five:
            scr_hud_button_create(
                "fabricator_batch_five",
                "PRODUCE 5",
                "QUEUE FIVE BATCHES"
            ),

        auto_button:
            scr_hud_button_create(
                "fabricator_auto",
                "AUTO MODE",
                "DISABLED"
            ),

        previous_target: noone
    };
}


/// @description Rebuilds recipe buttons for the selected Fabricator.

function scr_hud_fabricator_buttons_rebuild(
    _controls,
    _fabricator
)
{
    _controls.recipe_buttons = [];

    if (!instance_exists(_fabricator))
        return false;


    var _keys =
        _fabricator.building_data.fabricator.recipes;


    for (var i = 0; i < array_length(_keys); ++i)
    {
        var _recipe =
            scr_recipe_data_get(
                _keys[i]
            );

        if (!scr_recipe_data_valid(_recipe))
            continue;


        var _button =
            scr_hud_button_create(
                "fabricator_recipe_" + _keys[i],
                string_upper(_recipe.identity.name),
                "SELECT RECIPE"
            );

        _button.data = _keys[i];

        array_push(
            _controls.recipe_buttons,
            _button
        );
    }


    return true;
}


/// @description Updates selected-Fabricator controls.

function scr_hud_fabricator_controls_update(
    _hud,
    _fabricator,
    _inspector_left,
    _tray_top
)
{
    var _controls =
        _hud.hud.fabricator_controls;


    if (_controls.previous_target != _fabricator)
    {
        _controls.previous_target = _fabricator;

        scr_hud_fabricator_buttons_rebuild(
            _controls,
            _fabricator
        );
    }


    var _button_width = 170;
    var _button_height = 58;
    var _gap = 8;


    for (
        var i = 0;
        i < array_length(_controls.recipe_buttons);
        ++i
    )
    {
        var _button =
            _controls.recipe_buttons[i];


        scr_hud_button_bounds_set(
            _button,
            210 + (i * (_button_width + _gap)),
            _tray_top + 36,
            _button_width,
            _button_height
        );


        _button.selected =
            _fabricator.production.selected_recipe_key
            == _button.data;


        if (scr_hud_button_update(_button))
        {
            scr_production_recipe_select(
                _fabricator,
                _button.data
            );
        }
    }


    var _batch_one = _controls.batch_one;
    var _batch_five = _controls.batch_five;
    var _auto = _controls.auto_button;


    scr_hud_button_bounds_set(
        _batch_one,
        210,
        _tray_top + 112,
        150,
        36
    );

    scr_hud_button_bounds_set(
        _batch_five,
        368,
        _tray_top + 112,
        150,
        36
    );

    scr_hud_button_bounds_set(
        _auto,
        526,
        _tray_top + 112,
        150,
        36
    );


    var _has_recipe =
        _fabricator.production.selected_recipe_key
        != "";


    _batch_one.enabled = _has_recipe;
    _batch_five.enabled = _has_recipe;
    _auto.enabled = _has_recipe;

    _auto.selected =
        _fabricator.production.auto_mode;

    _auto.subtitle =
        _fabricator.production.auto_mode
        ? "ENABLED"
        : "DISABLED";


    if (scr_hud_button_update(_batch_one))
        scr_production_batch_queue_add(_fabricator, 1);

    if (scr_hud_button_update(_batch_five))
        scr_production_batch_queue_add(_fabricator, 5);

    if (scr_hud_button_update(_auto))
    {
        _fabricator.production.auto_mode =
            !_fabricator.production.auto_mode;
    }


    return true;
}


/// @description Draws selected-Fabricator controls.

function scr_hud_fabricator_controls_draw(
    _hud,
    _fabricator,
    _inspector_left,
    _tray_top
)
{
    var _controls =
        _hud.hud.fabricator_controls;


    draw_set_color(c_aqua);

    draw_text(
        210,
        _tray_top + 12,
        "SELECT RECIPE"
    );


    for (
        var i = 0;
        i < array_length(_controls.recipe_buttons);
        ++i
    )
    {
        scr_hud_button_draw(
            _controls.recipe_buttons[i]
        );
    }


    scr_hud_button_draw(_controls.batch_one);
    scr_hud_button_draw(_controls.batch_five);
    scr_hud_button_draw(_controls.auto_button);


    var _production =
        _fabricator.production;

    var _bar_left = 700;

    var _bar_right =
        max(
            _bar_left + 180,
            _inspector_left - 220
        );

    var _bar_top =
        _tray_top + 135;


    var _ratio =
        _production.duration > 0
        ? clamp(
            _production.progress
            / _production.duration,
            0,
            1
        )
        : 0;


    draw_set_color(c_dkgray);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_right,
        _bar_top + 14,
        false
    );


    draw_set_color(c_aqua);

    draw_rectangle(
        _bar_left,
        _bar_top,
        _bar_left
        + ((_bar_right - _bar_left) * _ratio),
        _bar_top + 14,
        false
    );


    draw_set_color(c_white);

    draw_text(
        _bar_left,
        _bar_top - 22,
        string_upper(_production.status_text)
        + "  //  QUEUED "
        + string(_production.queued_batches)
    );


    return true;
}


/// @description Draws Fabricator information in the structure inspector.

function scr_hud_fabricator_inspector_draw(
    _fabricator,
    _left,
    _top
)
{
    var _production =
        _fabricator.production;

    var _recipe =
        scr_recipe_data_get(
            _production.selected_recipe_key
        );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 110,
        "OPERATION",
        _production.status_text,
        c_aqua
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 130,
        "QUEUED BATCHES",
        _production.queued_batches,
        c_white
    );


    if (!scr_recipe_data_valid(_recipe))
    {
        scr_hud_label_value_draw(
            _left + 18,
            _top + 150,
            "RECIPE",
            "NONE",
            c_gray
        );

        return true;
    }


    var _input = _recipe.inputs[0];
    var _output = _recipe.outputs[0];

    var _input_data =
        scr_resource_data_get(
            _input.resource_key
        );

    var _output_data =
        scr_resource_data_get(
            _output.resource_key
        );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 150,
        "RECIPE",
        _recipe.identity.name,
        c_white
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 170,
        "INPUT",
        string(_input.amount)
        + " "
        + string_upper(_input_data.identity.name),
        _input_data.visual.color
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 190,
        "OUTPUT",
        string(_output.amount)
        + " "
        + string_upper(_output_data.identity.name),
        _output_data.visual.color
    );


    scr_hud_label_value_draw(
        _left + 18,
        _top + 210,
        "OUTPUT BUFFER",
        string(_production.output.current)
        + " / "
        + string(_production.output.capacity),
        _output_data.visual.color
    );


    return true;
}