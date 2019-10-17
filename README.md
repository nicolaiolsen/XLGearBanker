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

- Step 3: Use slash_command or keybind to deposit **all** gear pieces at **once**.
- Step 6: Use slash_command or keybind to withdraw **all** gear pieces at **once**.

Easy!
***

## Dependencies

This addon uses the following libraries:

- LibCustomMenu

These libraries are ***required*** to run the addon.

***

## How to use the addon


### Usage of slash_commands

The main interaction with this addon happens through slash_commands (for now). A slash_command is simply something you type into your ESO chat while having the game open (e.g. a favourite one of mine is "/hammerlow" to help ZOS fix the servers). 
Some slash_commands take an "argument" which basically is extra information the command needs to do its thing. In this addon every slash_command takes up to 1 argument, where the argument is what you write after the slash_command itself.

### Add a gear set

First off you'll need to add a gear set. Using the slash_command "/xlgb_addset setName" you'll create a new empty set with the name specified (setName).
'setName' can be anything you'd like it to be.

Examples:
/xlgb_addset Stamina Necro DD
/xlgb_addset Healer sets
/xlgb_addset Tank sets
/xlgb_addset Everything

### Add items to a gear set

If you have atleast 1 set you can right-click any armor or weapon in your bank, inventory or even equipped items, an extra item in the drop-down menu will appear reading 'XLGB add >'.
If you hover over this menu you'll see all your sets, and if you click on of the sets the item you've right-clicked will be added to that set.

### Depositing/withdrawing gear

Depositing and withdrawing gear happens either through keybindings or slash_commands similar to adding gear sets. Using the slash_commands "/xlgb_deposit setNumber", "/xlgb_withdraw setNumber", while having your bank/storage chest open will result in depositing/withdrawing the gear set #(setNumber) to/from the bank/storage chest.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Examples:
/xlgb_withdraw 1
/xlgb_deposit 2

### Getting the setNumber of a set or items in a set

How do you know which set belongs to which set number? Using the provided slash_command "/xlgb_sets" will print out all sets you've added together with their respective set numbers. "/xlgb_items setNumber" will print out all items you've added to the set #(setNumber).
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Examples:
/xlgb_sets
/xlgb_items 3

### Remove items from a gear set

Accidentally added an item to the wrong set? Fear not! When an item belongs to a set a new menu item appears in the drop-down menu, similar to adding items, this menu item reads 'XLGB remove >'.
Clicking on one of the sets listed in the sub-menu will result in removing that gear piece from the set again.

### Remove a gear set

If you've spelled a name wrong (Sorry no support for renaming sets yet) or just don't like a set you've previously created you can remove it with the slash_command  "/xlgb_removeset setNumber".
**Warning:** *This slash_command will immediately remove the gear set specified without any prompts, with no way to restore the gear set. (Doesn't delete the items themselves but removes your hard work of adding things to a set).*

Examples:
/xlgb_removeset 2

### Assign sets to storage chest

To assign items to a chest simply open up the chest you want to assign to and use the slash_command "/xlgb_assign setNumber". This will assign the items from the set to the opened chest up to the total chest size number of items assigned. When adding/removing items to/from a gearSet the assigned items stored in the storage chest will also automatically update.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Example:
/xlgb_assign 4

### Unassign sets from/reset storage chest

If you want to remove (or reassign) a set from sets assigned to a chest, you'd open the chest you want to unassign the set from (similar to assigning sets) and use the slash_command "/xlgb_unassign setNumber". This way the items in the set will be unassigned (unless they also appear in another set). If you want to fully reset a chest (i.e. unassign all sets and items from the chest) you could also use the slash_command "/xlgb_clearassigned" which will reset the currently opened chest.
**Note:** *The argument 'setNumber' should be a number between 1 and total number of sets.*

Examples:
/xlgb_unassign 4
/xlgb_clearassigned

### Print assigned sets and number of items

If you want to know which sets you've assigned to a chest and how many items that are assigned to it you can use the slash_command "/xlgb_assignedsets" while having a chest open, and the information will be printed in chat.

Example:
/xlgb_assignedsets

***

### List of slash_commands

/xlgb_sets
Prints out saved sets to chat.

/xlgb_items setNumber
Prints out set #(setNumber)s items to chat.

/xlgb_addset setName
Creates a new set named (setName).

/xlgb_removeset setNumber
Removes set #(setNumber).

/xlgb_deposit setNumber
Deposit all items from set #(setNumber) into the bank.

/xlgb_withdraw setNumber
Withdraw all items from set #(setNumber) into the player inventory.

/xlgb_assign setNumber
Assigns set #(setNumber) to opened chest.

/xlgb_unassign setNumber
Unassigns set #(setNumber) from opened chest.

/xlgb_clearassigned
Clears the list of sets assigned to opened chest.

/xlgb_assignedsets
Prints out the sets assigned to opened chest.

/xlgb_debug
Toggles debug mode. (Note: quite verbose)

/xlgb_help
Prints out these commands in the chat.
