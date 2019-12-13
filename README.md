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

- Step 3: Use keybind to deposit **all** gear pieces at **once**.
- Step 6: Use keybind to withdraw **all** gear pieces at **once**.

Easy!

(A how to use is explained in details below)
***

## Dependencies

This addon uses the following libraries:

- LibCustomMenu
- LibDialog

These libraries are ***required*** to run the addon.

***

## Changes (0.8.0)

Christmas is coming early with this new update (0.8.0). An XL change that alot of people I've talked to have asked for (including myself). The XLGB addon is getting its UI and is now not a complete mess to setup anymore! What this UI update includes is a UI that would help you track your sets, create new sets, and edit current sets easier than ever before! It's simple to use:

### You can now actually see your sets! (BIIG)

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Use the arrows to browse your current sets

### New way to edit sets! (change name/remove items from set)

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Press the edit icon (pen and paper thingy)
    - Now you can edit the name label to a choice of your own! (Press the label and edit away!)
    - Mark items for removal by using the 'X' icon to the right of the item you want removed. (If you regret your choice, press the cancel button to unmark it again!)
3. Now you have a choice:
    1. Discard changes by clicking the "cancel icon" that replaced the edit icon. (If you've made changes a dialog will pop up to confirm)
    2. Accept changes by clicking the "accept icon". (If you've marked items for removal a dialog will pop up to confirm)
    3. Remove the set by click the "minus icon". (If the set is not empty a dialog will pop up to confirm)

### Adding new sets (The EZ Clap way)

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Use the '+' to add a new set.
3. You now enter 'edit' mode. (Look above for explanation)

### Removing sets (YEET)

See "Edit sets" above at 3.3.

## Roadmap

This is not the only change planned for the XLGB addon. I will further improve the user experience down the road with UI 2.0 as the next big goal that will assist in depositing/withdrawing sets easier (Which will phase out the confusing assigned set to chest thingy), as an alternative to depositing/withdrawing sets via keybinds. Below is a roadmap with features and improvements planned for the addon:

- UI 2.0 (deposit/withdraw UI)
- Settings menu
- Multi-language support
- UI polishing (Adding tooltips etc.)

## How to use the addon

### Browsing sets

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Use the arrows to browse your current sets

### Edit sets (change name/remove items from set)

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Press the edit icon (pen and paper thingy)
    - Now you can edit the name label to a choice of your own! (Press the label and edit away!)
    - Mark items for removal by using the 'X' icon to the right of the item you want removed. (If you regret your choice, press the cancel button to unmark it again!)
3. Now you have a choice:
    1. Discard changes by clicking the "cancel icon" that replaced the edit icon. (If you've made changes a dialog will pop up to confirm)
    2. Accept changes by clicking the "accept icon". (If you've marked items for removal a dialog will pop up to confirm)
    3. Remove the set by click the "minus icon". (If the set is not empty a dialog will pop up to confirm)

### Adding new sets

1. Open your chat and type in '/xlgb' to bring up the UI.
2. Use the '+' to add a new set.
3. You now enter 'edit' mode. (Look above for explanation)

### Removing sets

See "Edit sets" above at 3.3.

### Add items to a gear set

If you have atleast 1 set you can right-click any armor or weapon in your bank, inventory or even equipped items, an extra item in the drop-down menu will appear reading 'XLGB add >'.
If you hover over this menu you'll see all your sets, and if you click on of the sets the item you've right-clicked will be added to that set.

### Remove items from a gear set

Accidentally added an item to the wrong set? Fear not!
As an alternative to removing items through the "edit mode" in the "/xlgb" UI I've kept the old way of removing items.
When an item belongs to a set a new menu item appears in the drop-down menu, similar to adding items, this menu item reads 'XLGB remove >'.
Clicking on one of the sets listed in the sub-menu will result in removing that gear piece from the set again.

### Depositing/withdrawing gear

**NOTE:** *For now the recommeded way is to bind a key in your keybinding menu - UI 2.0 is coming to help make this an easier process*
Depositing and withdrawing gear happens either through keybindings or slash_commands. Using the slash_commands "/xlgb_deposit setNumber", "/xlgb_withdraw setNumber", while having your bank/storage chest open will result in depositing/withdrawing the gear set #(setNumber) to/from the bank/storage chest.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Examples:
/xlgb_withdraw 1
/xlgb_deposit 2

### Assign sets to storage chest

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
To assign items to a chest simply open up the chest you want to assign to and use the slash_command "/xlgb_assign setNumber". This will assign the items from the set to the opened chest up to the total chest size number of items assigned. When adding/removing items to/from a gearSet the assigned items stored in the storage chest will also automatically update.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Example:
/xlgb_assign 4

### Unassign sets from/reset storage chest

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
If you want to remove (or reassign) a set from sets assigned to a chest, you'd open the chest you want to unassign the set from (similar to assigning sets) and use the slash_command "/xlgb_unassign setNumber". This way the items in the set will be unassigned (unless they also appear in another set). If you want to fully reset a chest (i.e. unassign all sets and items from the chest) you could also use the slash_command "/xlgb_clearassigned" which will reset the currently opened chest.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Examples:
/xlgb_unassign 4
/xlgb_clearassigned

### Print assigned sets and number of items

**NOTE:** *This feature is planned for removal with the big UI 2.0 update*
If you want to know which sets you've assigned to a chest and how many items that are assigned to it you can use the slash_command "/xlgb_assignedsets" while having a chest open, and the information will be printed in chat.

Example:
/xlgb_assignedsets

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
