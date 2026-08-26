/// @description Player chassis definitions and stat pipeline.

/// ============================================================================
/// PLAYER CHASSIS ENUMS
/// ============================================================================
///
/// Add these beside your existing PlayerState enum in scr_EnumsMacros.

/// ============================================================================
/// CHASSIS DATA
/// ============================================================================

/// @description Returns one player chassis definition.
function scr_player_chassis_data_get(_chassis)
{
    switch (_chassis)
    {
        case PlayerChassis.ASSAULT:
        {
            return
            {
                key: "assault",
                name: "ASSAULT",
                description:
                    "Direct combat chassis. Fast, aggressive, and built "
                    + "to personally intercept enemy pressure.",

                visual:
                {
                    color: c_lime,
                    style: "assault"
                },

                main_fire:
                    PlayerMainFire.PULSE,

                alternate_ability:
                    PlayerAlternateAbility.COMBAT_BURST,

                stats:
                {
                    move_speed: 7.0,

                    hp_maximum: 100,
                    shield_maximum: 0,

                    weapon_damage: 27,
                    weapon_cooldown_seconds: 0.16,
                    projectile_speed: 22,

                    repair_rate: 4,

                    alternate_cooldown_seconds: 4,
                    alternate_damage: 0
                }
            };
        }


        case PlayerChassis.HEAVY:
        {
            return
            {
                key: "heavy",
                name: "HEAVY",
                description:
                    "Frontline tank chassis. Slow and durable, built to "
                    + "hold dangerous positions under sustained pressure.",

                visual:
                {
                    color: c_orange,
                    style: "heavy"
                },

                main_fire:
                    PlayerMainFire.PULSE,

                alternate_ability:
                    PlayerAlternateAbility.ROCKET,

                stats:
                {
                    move_speed: 4.8,

                    hp_maximum: 175,
                    shield_maximum: 50,

                    weapon_damage: 20,
                    weapon_cooldown_seconds: 0.22,
                    projectile_speed: 19,

                    repair_rate: 2,

                    alternate_cooldown_seconds: 2.5,
                    alternate_damage: 110
                }
            };
        }


        case PlayerChassis.ENGINEER:
        {
            return
            {
                key: "engineer",
                name: "ENGINEER",
                description:
                    "Infrastructure chassis. Weak in direct combat, but "
                    + "excellent at keeping buildings and defenses alive.",

                visual:
                {
                    color: c_yellow,
                    style: "engineer"
                },

                main_fire:
                    PlayerMainFire.PULSE,

                alternate_ability:
                    PlayerAlternateAbility.REPAIR,

                stats:
                {
                    move_speed: 6.4,

                    hp_maximum: 85,
                    shield_maximum: 0,

                    weapon_damage: 15,
                    weapon_cooldown_seconds: 0.20,
                    projectile_speed: 20,

                    repair_rate: 24,

                    alternate_cooldown_seconds: 0.12,
                    alternate_damage: 0
                }
            };
        }


        case PlayerChassis.SUPPORT:
        {
            return
            {
                key: "support",
                name: "SUPPORT",
                description:
                    "Defense assistance chassis. Balanced personally, but "
                    + "strongest when positioned beside an active defense.",

                visual:
                {
                    color: c_fuchsia,
                    style: "support"
                },

                main_fire:
                    PlayerMainFire.PULSE,

                alternate_ability:
                    PlayerAlternateAbility.COMMAND_PULSE,

                stats:
                {
                    move_speed: 6.0,

                    hp_maximum: 110,
                    shield_maximum: 25,

                    weapon_damage: 18,
                    weapon_cooldown_seconds: 0.18,
                    projectile_speed: 20,

                    repair_rate: 7,

                    alternate_cooldown_seconds: 5,
                    alternate_damage: 0
                }
            };
        }
    }

    return undefined;
}


/// ============================================================================
/// STAT PIPELINE
/// ============================================================================

/// @description Creates empty player upgrade modifiers.
function scr_player_stat_modifiers_create()
{
    return
    {
        flat: {},
        multiplier: {}
    };
}

/// @description Creates the player chassis and stat runtime.
function scr_player_chassis_runtime_create()
{
    return
    {
        selected: false,

        type: PlayerChassis.NONE,
        key: "",
        name: "",

        main_fire:
            PlayerMainFire.PULSE,

        alternate_ability:
            PlayerAlternateAbility.NONE,

        visual:
        {
            color: c_aqua,
            style: "default"
        },

        stats:
        {
            base: {},

            persistent:
                scr_player_stat_modifiers_create(),

            level:
                scr_player_stat_modifiers_create(),

            final: {}
        }
    };
}


/// @description Rebuilds final stats from chassis base, persistent and level modifiers.
function scr_player_stats_recalculate(_player)
{
    if (!instance_exists(_player))
        return false;

    var _stats =
        _player.chassis.stats;

    var _base_names =
        variable_struct_get_names(
            _stats.base
        );

    _stats.final = {};

    for (
        var i = 0;
        i < array_length(_base_names);
        ++i
    )
    {
        var _stat_key =
            _base_names[i];

        var _base_value =
            variable_struct_get(
                _stats.base,
                _stat_key
            );

        var _flat_bonus = 0;

        var _multiplier = 1;


        // ====================================================================
        // PERSISTENT UPGRADES
        // ====================================================================

        if (
            variable_struct_exists(
                _stats.persistent.flat,
                _stat_key
            )
        )
        {
            _flat_bonus +=
                variable_struct_get(
                    _stats.persistent.flat,
                    _stat_key
                );
        }

        if (
            variable_struct_exists(
                _stats.persistent.multiplier,
                _stat_key
            )
        )
        {
            _multiplier *=
                variable_struct_get(
                    _stats.persistent.multiplier,
                    _stat_key
                );
        }


        // ====================================================================
        // LEVEL-ONLY UPGRADES
        // ====================================================================

        if (
            variable_struct_exists(
                _stats.level.flat,
                _stat_key
            )
        )
        {
            _flat_bonus +=
                variable_struct_get(
                    _stats.level.flat,
                    _stat_key
                );
        }

        if (
            variable_struct_exists(
                _stats.level.multiplier,
                _stat_key
            )
        )
        {
            _multiplier *=
                variable_struct_get(
                    _stats.level.multiplier,
                    _stat_key
                );
        }


        variable_struct_set(
            _stats.final,
            _stat_key,

            max(
                0,
                (_base_value + _flat_bonus)
                * _multiplier
            )
        );
    }

    return true;
}


/// @description Copies final stats into the existing player runtime systems.
function scr_player_stats_apply_to_runtime(_player)
{
    if (!instance_exists(_player))
        return false;

    var _final =
        _player.chassis.stats.final;

    _player.movement.speed_base =
        _final.move_speed;

    _player.vitals.hp.maximum =
        _final.hp_maximum;

    _player.vitals.hp.current =
        _player.vitals.hp.maximum;

    _player.vitals.shield.maximum =
        _final.shield_maximum;

    _player.vitals.shield.current =
        _player.vitals.shield.maximum;

    _player.vitals.shield.enabled =
        _player.vitals.shield.maximum > 0;

    _player.combat.weapon.damage =
        _final.weapon_damage;

    _player.combat.weapon.cooldown.duration =
        _final.weapon_cooldown_seconds;

    _player.combat.weapon.projectile.speed =
        _final.projectile_speed;

    _player.visual.color =
        _player.chassis.visual.color;

    return true;
}

/// @description Selects one chassis and applies its initial player stats.
function scr_player_chassis_select(
    _player,
    _chassis
)
{
    if (!instance_exists(_player))
        return false;

    var _data =
        scr_player_chassis_data_get(
            _chassis
        );

    if (!is_struct(_data))
        return false;

    _player.chassis.selected =
        true;

    _player.chassis.type =
        _chassis;

    _player.chassis.key =
        _data.key;

    _player.chassis.name =
        _data.name;

    _player.chassis.main_fire =
        _data.main_fire;

    _player.chassis.alternate_ability =
        _data.alternate_ability;

    _player.chassis.visual =
        _data.visual;

    _player.chassis.stats.base =
        _data.stats;

    scr_player_stats_recalculate(
        _player
    );

    scr_player_stats_apply_to_runtime(
        _player
    );

    show_debug_message(
        "PLAYER CHASSIS SELECTED: "
        + _player.chassis.name
    );

    return true;
}