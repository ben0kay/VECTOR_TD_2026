/// @description Building-capacity and specialized hub functions.


/// @description Returns the default capacity category for one building.

function scr_build_limit_default_type_get(_data)
{
    if (!is_struct(_data))
        return BuildLimitType.NONE;

    switch (_data.identity.type)
    {
        case BuildingType.TOWER:
            return BuildLimitType.TOWER;

        case BuildingType.WALL:
            return BuildLimitType.DEFENSE;

        case BuildingType.MINER:
        case BuildingType.STORAGE:
        case BuildingType.REFINERY:
            return BuildLimitType.ECONOMY;

        case BuildingType.POWER_GENERATOR:
        case BuildingType.POWER_NODE:
        case BuildingType.POWER_BATTERY:
        case BuildingType.SUPPORT:
            return BuildLimitType.INFRASTRUCTURE;
    }

    return BuildLimitType.NONE;
}


/// @description Adds capacity metadata to definitions that do not specify it.

function scr_build_limit_data_defaults_apply()
{
    var _keys =
        variable_struct_get_names(
            global.vtd.data.buildings
        );

    for (var i = 0; i < array_length(_keys); ++i)
    {
        var _data =
            variable_struct_get(
                global.vtd.data.buildings,
                _keys[i]
            );

        if (!is_struct(_data))
            continue;

        if (!variable_struct_exists(_data, "build_limit"))
        {
            _data.build_limit =
            {
                type:
                    scr_build_limit_default_type_get(
                        _data
                    ),

                amount:
                    1
            };
        }
    }

    return true;
}


/// @description Creates one runtime capacity entry.

function scr_build_limit_entry_create(_base)
{
    var _starting_capacity =
        max(
            0,
            floor(_base)
        );

    return
    {
        base: _starting_capacity,
        bonus: 0,
        used: 0,
        maximum: _starting_capacity
    };
}


/// @description Initializes build capacity for the current level.

function scr_build_limits_initialize(_world_data)
{
    var _base_tower = 10;
    var _base_defense = 50;
    var _base_economy = 10;
    var _base_infrastructure = 20;


    if (
        is_struct(_world_data)
        && variable_struct_exists(
            _world_data,
            "build_limits"
        )
        && is_struct(_world_data.build_limits)
    )
    {
        var _limits =
            _world_data.build_limits;


        if (variable_struct_exists(_limits, "tower"))
            _base_tower = _limits.tower;

        if (variable_struct_exists(_limits, "defense"))
            _base_defense = _limits.defense;

        if (variable_struct_exists(_limits, "economy"))
            _base_economy = _limits.economy;

        if (
            variable_struct_exists(
                _limits,
                "infrastructure"
            )
        )
        {
            _base_infrastructure =
                _limits.infrastructure;
        }
    }


    var _entries =
        array_create(
            5,
            undefined
        );


    _entries[BuildLimitType.NONE] =
        scr_build_limit_entry_create(0);

    _entries[BuildLimitType.TOWER] =
        scr_build_limit_entry_create(
            _base_tower
        );

    _entries[BuildLimitType.DEFENSE] =
        scr_build_limit_entry_create(
            _base_defense
        );

    _entries[BuildLimitType.ECONOMY] =
        scr_build_limit_entry_create(
            _base_economy
        );

    _entries[BuildLimitType.INFRASTRUCTURE] =
        scr_build_limit_entry_create(
            _base_infrastructure
        );


    global.vtd_level.build_limits =
    {
        entries: _entries,
        revision: 0
    };


    return true;
}


/// @description Returns one current-level capacity entry.

function scr_build_limit_entry_get(_type)
{
    if (!variable_global_exists("vtd_level"))
        return undefined;

    if (!is_struct(global.vtd_level))
        return undefined;

    if (
        !variable_struct_exists(
            global.vtd_level,
            "build_limits"
        )
    )
    {
        return undefined;
    }


    var _build_limits =
        global.vtd_level.build_limits;

    if (!is_struct(_build_limits))
        return undefined;

    if (!is_array(_build_limits.entries))
        return undefined;

    if (
        _type <= BuildLimitType.NONE
        || _type >= array_length(
            _build_limits.entries
        )
    )
    {
        return undefined;
    }


    return _build_limits.entries[_type];
}


/// @description Returns whether one definition fits inside current capacity.

function scr_build_limit_can_place(_data)
{
    if (!is_struct(_data))
        return false;

    if (
        !variable_struct_exists(
            _data,
            "build_limit"
        )
    )
    {
        return true;
    }


    var _limit =
        _data.build_limit;

    if (!is_struct(_limit))
        return true;

    if (_limit.type == BuildLimitType.NONE)
        return true;


    var _entry =
        scr_build_limit_entry_get(
            _limit.type
        );

    if (!is_struct(_entry))
        return false;


    return (
        _entry.used
        + max(0, _limit.amount)
        <= _entry.maximum
    );
}


/// @description Reserves capacity immediately for one placed building.

function scr_build_limit_register(_building)
{
    if (!instance_exists(_building))
        return false;


    _building.build_limit =
    {
        type: BuildLimitType.NONE,
        amount: 0,
        registered: false,
        hub_bonus_active: false
    };


    var _data =
        _building.building_data;


    if (
        !variable_struct_exists(
            _data,
            "build_limit"
        )
    )
    {
        return true;
    }


    var _limit =
        _data.build_limit;

    if (!is_struct(_limit))
        return true;


    _building.build_limit.type =
        _limit.type;

    _building.build_limit.amount =
        max(
            0,
            _limit.amount
        );


    if (_limit.type == BuildLimitType.NONE)
        return true;


    var _entry =
        scr_build_limit_entry_get(
            _limit.type
        );

    if (!is_struct(_entry))
        return false;


    _entry.used +=
        _building.build_limit.amount;

    _building.build_limit.registered =
        true;

    global.vtd_level.build_limits
        .revision++;


    return true;
}


/// @description Activates the capacity supplied by a completed hub.

function scr_build_limit_hub_activate(_building)
{
    if (!instance_exists(_building))
        return false;

    if (
        !variable_instance_exists(
            _building,
            "build_limit"
        )
    )
    {
        return false;
    }

    if (_building.build_limit.hub_bonus_active)
        return true;


    var _data =
        _building.building_data;


    if (!variable_struct_exists(_data, "hub"))
        return true;


    var _hub =
        _data.hub;

    if (!is_struct(_hub))
        return false;


    var _entry =
        scr_build_limit_entry_get(
            _hub.limit_type
        );

    if (!is_struct(_entry))
        return false;


    _entry.bonus +=
        max(
            0,
            _hub.amount
        );

    _entry.maximum =
        _entry.base
        + _entry.bonus;


    _building.build_limit.hub_bonus_active =
        true;

    global.vtd_level.build_limits
        .revision++;


    scr_hud_alert_push(
        HudAlertType.SUCCESS,
        "CAPACITY EXPANDED",

        scr_build_limit_name(
            _hub.limit_type
        )
        + " LIMIT +"
        + string(_hub.amount),

        2.5
    );


    return true;
}


/// @description Releases used capacity and any completed hub bonus.

function scr_build_limit_unregister(_building)
{
    if (!instance_exists(_building))
        return false;

    if (
        !variable_instance_exists(
            _building,
            "build_limit"
        )
    )
    {
        return true;
    }


    var _runtime =
        _building.build_limit;


    // Release the capacity consumed by this building.

    if (_runtime.registered)
    {
        var _entry =
            scr_build_limit_entry_get(
                _runtime.type
            );

        if (is_struct(_entry))
        {
            _entry.used =
                max(
                    0,
                    _entry.used
                    - _runtime.amount
                );
        }


        _runtime.registered =
            false;
    }


    // Remove capacity supplied by a completed hub.

    if (
        _runtime.hub_bonus_active
        && variable_struct_exists(
            _building.building_data,
            "hub"
        )
    )
    {
        var _hub =
            _building.building_data.hub;

        var _hub_entry =
            scr_build_limit_entry_get(
                _hub.limit_type
            );


        if (is_struct(_hub_entry))
        {
            _hub_entry.bonus =
                max(
                    0,
                    _hub_entry.bonus
                    - _hub.amount
                );

            _hub_entry.maximum =
                _hub_entry.base
                + _hub_entry.bonus;


            if (
                _hub_entry.used
                > _hub_entry.maximum
                && global.LevelState
                    == LevelState.PLAYING
            )
            {
                scr_hud_alert_push(
                    HudAlertType.WARNING,
                    "BASE OVER CAPACITY",

                    scr_build_limit_name(
                        _hub.limit_type
                    )
                    + "  "
                    + string(_hub_entry.used)
                    + " / "
                    + string(_hub_entry.maximum),

                    3
                );
            }
        }


        _runtime.hub_bonus_active =
            false;
    }


    if (
        variable_global_exists("vtd_level")
        && is_struct(global.vtd_level)
        && variable_struct_exists(
            global.vtd_level,
            "build_limits"
        )
    )
    {
        global.vtd_level.build_limits
            .revision++;
    }


    return true;
}


/// @description Returns a readable capacity-category name.

function scr_build_limit_name(_type)
{
    switch (_type)
    {
        case BuildLimitType.TOWER:
            return "TOWER";

        case BuildLimitType.DEFENSE:
            return "DEFENSE";

        case BuildLimitType.ECONOMY:
            return "ECONOMY";

        case BuildLimitType.INFRASTRUCTURE:
            return "INFRASTRUCTURE";
    }

    return "UNLIMITED";
}

/// @description Creates the reusable bottom build-menu runtime.

function scr_hud_build_menu_create()
{
    var _categories =
    [
        BuildMenuCategory.TOWERS,
        BuildMenuCategory.DEFENSE,
        BuildMenuCategory.EXTRACTION,
        BuildMenuCategory.STORAGE,
        BuildMenuCategory.POWER,
        BuildMenuCategory.PRODUCTION,
        BuildMenuCategory.SUPPORT
    ];


    var _category_buttons =
        [];


    for (
        var i = 0;
        i < array_length(_categories);
        ++i
    )
    {
        var _category =
            _categories[i];

        var _button =
            scr_hud_button_create(
                _category,
                scr_hud_build_category_name(
                    _category
                )
            );


        _button.data =
            _category;


        array_push(
            _category_buttons,
            _button
        );
    }


    // One saved scroll position for every BuildMenuCategory value.

    var _scroll_positions =
        array_create(
            8,
            0
        );


    return
    {
        open: false,
        progress: 0,
        animation_speed: 0.16,

        category:
            BuildMenuCategory.TOWERS,

        category_buttons:
            _category_buttons,

        building_buttons:
            [],

        scroll_positions:
            _scroll_positions,

        scroll_index:
            0,

        build_button:
            scr_hud_button_create(
                "build",
                "BUILD",
                "B"
            ),

        left_button:
            scr_hud_button_create(
                "left",
                "<"
            ),

        right_button:
            scr_hud_button_create(
                "right",
                ">"
            ),

        layout:
        {
            card_width: 142,
            card_height: 136,
            card_gap: 8,

            strip_left: 0,
            strip_top: 0,
            strip_width: 0,
            strip_height: 0,

            visible_count: 1
        }
    };
}