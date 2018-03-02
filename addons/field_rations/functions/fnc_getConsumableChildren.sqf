/*
 * Author: mharis001, Glowbal, PabstMirror
 * Returns children actions for consumable items in player's inventory.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Actions <ARRAY>
 *
 * Example:
 * [ACE_player] call acex_field_rations_fnc_getConsumableChildren
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_player"];

private _actions = [];
private _alreadyAdded = [];

{
    private _cfg = configFile >> "CfgWeapons" >> _x;

    if (isClass _cfg && {!(_x in _alreadyAdded)}) then {
        private _thirstRestored = getNumber (_cfg >> QGVAR(isDrinkable));
        private _hungerRestored = getNumber (_cfg >> QGVAR(isEatable));

        // Check if valid consumable item
        if (_thirstRestored isEqualTo 0 && {_hungerRestored isEqualTo 0}) exitWith {};

        // Prevent multiple entries of same item
        _alreadyAdded pushBack _x;

        // Get action text (allows for custom text to be defined)
        private _displayName = getText (_cfg >> "displayName");
        private _consumeActionText = getText (_cfg >> QGVAR(consumeActionText));

        private _actionText = switch (true) do {
            case (_consumeActionText != ""): {
                if (isLocalized _consumeActionText) then {localize _consumeActionText} else {_consumeActionText};
            };
            case (_hungerRestored >= _thirstRestored): {
                format ["%1 %2", localize LSTRING(Eat), _displayName];
            };
            case (_thirstRestored > _hungerRestored): {
                format ["%1 %2", localize LSTRING(Drink), _displayName];
            };
        };

        private _picture = getText (_cfg >> "picture");

        private _action = [_x, _actionText, _picture, LINKFUNC(consumeItem), LINKFUNC(canConsumeItem), {}, _x] call ACEFUNC(interact_menu,createAction);
        _actions pushBack [_action, [], _player];
    };
} forEach (items _player);

_actions
