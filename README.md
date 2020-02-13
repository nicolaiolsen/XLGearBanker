# XL Gear Banker

By @XL_Olsen

***

## Description

XL Gear Banker (XLGB) is an ESO addon that strives to combat the ***tedious*** task of funneling all your gear to another character.
Got multiple healer characters? Multiple tanks? DDs? This addon might be for you!

Before XLGB:

1. Log into character with the gear you need.
2. Go to bank or house storage chest
3. For **every** gear piece you need, **find it** in your inventory and **manually** put it into bank/chest.
4. Log into character that needs the gear.
5. Go to bank or house storage chest
6. For **every** gear piece you need, **find it** in your bank/chest and **manually** withdraw it from the bank.

After XLGB:

- Step 3: Use keybind or UI to deposit **all** gear pieces at **once**.
- Step 6: Use keybind or UI to withdraw **all** gear pieces at **once**.

Easy!

(A how to use is explained in details below)
***

## Dependencies

This addon uses the following libraries:

- LibCustomMenu
- LibDialog ***new since version 0.8!***

These libraries are ***required*** to run the addon.

***

## Changes (version 0.9 + 0.9.3)

On top of the UI changes XLGB now supports "Add currently equipped items to set"! This means that your favourite Dressing Room/Alpha Gear setups can now be used to E A S I L Y create a new set for XLGB! Also the remove item function has been reworked and is now not bugged :angel_smiley_face:


## Roadmap

This is not the only change planned for the XLGB addon. I will further improve the user experience down the road with UI 2.0 as the next big goal that will assist in depositing/withdrawing sets easier (Which will phase out the confusing assigned set to chest thingy), as an alternative to depositing/withdrawing sets via keybinds. Below is a roadmap with features and improvements planned for the addon:

- UI 2.0 (deposit/withdraw UI) (DONE!!!)
- Settings menu
- Multi-language support
- UI polishing (Adding tooltips etc.)

## How to use the addon

### Browsing sets

1. Either open your bank/storage or type '/xlgb' in chat to bring up the UI.
2. Use the arrows to browse your current sets

### Edit sets (change name & add/remove items to/from set)

1. Either open your bank/storage or type '/xlgb' in chat to bring up the UI.
2. Press the edit icon (pen and paper thingy)
    - Now you can edit the name label to a choice of your own! (Press the label and edit away!)
    - Add items you currently wear using the bottom that states it does literally this.
    - Remove items using the 'X' icon to the right of the item you want removed. (If you regret your choice, you can discard your changes!)
3. Now you have a choice:
    1. Discard changes by clicking the "cancel icon" that replaced the edit icon. (If you've made changes a dialog will pop up to confirm)
    2. Accept changes by clicking the "accept icon". (If you've marked items for removal a dialog will pop up to confirm)
    3. Remove the set by click the "minus icon". (If the set is not empty a dialog will pop up to confirm)

### Adding new sets

1. Either open your bank/storage or type '/xlgb' in chat to bring up the UI.
2. Use the '+' to add a new set.
3. You now enter 'edit' mode. (Look above for explanation)

### Removing sets

See "Edit sets" above at 3.3.

### Add items to a gear set

(New in version 0.9.3+)
You can now add all your currently equipped items by opening the ui with "/xlgb", press the edit icon, and press the button "Add equipped items to set".

If you have atleast 1 set you can right-click any armor or weapon in your bank, inventory or even equipped items, an extra item in the drop-down menu will appear reading 'XLGB add >'.
If you hover over this menu you'll see all your sets, and if you click on of the sets the item you've right-clicked will be added to that set.

### Remove items from a gear set

Accidentally added an item to the wrong set? Fear not!
As an alternative to removing items through the "edit mode" in the "/xlgb" UI I've kept the old way of removing items.
When an item belongs to a set a new menu item appears in the drop-down menu, similar to adding items, this menu item reads 'XLGB remove >'.
Clicking on one of the sets listed in the sub-menu will result in removing that gear piece from the set again.

### Depositing/withdrawing gear

With UI 2.0 you can now deposit/withdraw currently displayed set directly through the UI! Open your bank/storage and the UI will appear with 2 buttons at the bottom of the UI saying "Deposit" and "Withdraw". These will deposit/withdraw the set you're currently looking at, easy as that! As an alternative to the UI, keybindings are also offered in keybindings menu that will deposit/withdraw specific sets.
***

### List of slash_commands

/xlgb_deposit setNumber
Deposit all items from set #(setNumber) into the bank.

/xlgb_withdraw setNumber
Withdraw all items from set #(setNumber) into the player inventory.

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
/xlgb_assign setNumber
Assigns set #(setNumber) to opened chest.

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
/xlgb_unassign setNumber
Unassigns set #(setNumber) from opened chest.

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
/xlgb_clearassigned
Clears the list of sets assigned to opened chest.

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
/xlgb_assignedsets
Prints out the sets assigned to opened chest.

/xlgb_debug
Toggles debug mode. (Note: quite verbose)

/xlgb_help
Prints out these commands in the chat.
