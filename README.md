# XL Gear Banker

By @XL_Olsen

***

#### Description

XL Gear Banker (XLGB) is an ESO addon that strives to combat the ***tedious*** task of funneling all your gear to another character.

Before XLGB:

1. Log into character with the gear you need.
2. Go to bank
3. For **every** gear piece you need, **find it** in your inventory and **manually** put it into bank.
4. Log into character that needs the gear.
5. Go to bank
6. For **every** gear piece you need, **find it** in your bank and **manually** withdraw it from the bank.

After XLGB:

- Step 3: Use depositgear function to deposit **all** gear pieces at **once**.
- Step 6: Use withdrawgear function to withdraw **all** gear pieces at **once**.

Easy!
***

## How to use the addon

***

### Usage of slash_commands

The main interaction with this addon happens through slash_commands (for now). A slash_command is simply something you type into your ESO chat while having the game open (e.g. a favourite one of mine is "/hammerlow" to help ZOS fix the servers). 
Some slash_commands take an "argument" which basically is extra information the command needs to do its thing. In this addon every slash_command takes up to 1 argument, where the argument is what you write after the slash_command itself.

### Add a gear set

First off you'll need to add a gear set. Using the slash_command "/xlgb_addset setName" you'll create a new empty set with the name specified (setName).
'setName' can be anything you'd like it to be.

Example:
\xlgb_addset DD single target

### Add items to a gear set

If you have atleast 1 set you can right-click any armor or weapon in your bank, inventory or even equipped items, an extra item in the drop-down menu will appear reading 'XLGB add >'.
If you hover over this menu you'll see all your sets, and if you click on of the sets the item you've right-clicked will be added to that set.

### Depositing/withdrawing gear

For now depositing and withdrawing gear happens through slash_commands similar to adding gear sets. Using the slash_commands "/xlgb_deposit setNumber", "/xlgb_withdraw setNumber", while having your bank open will result in depositing/withdrawing the gear set #(setNumber) to/from the bank.
**Note:** The argument 'setNumber' should be a number between 1 and total number of sets.

Examples:
/xlgb_withdraw 1
/xlgb_deposit 2

### Getting the setNumber of a set or items in a set

How do you know which set belongs to which set number? Using the provided slash_command "/xlgb_sets" will print out all sets you've added together with their respective set numbers. "/xlgb_items setNumber" will print out all items you've added to the set #(setNumber).
**Note:** The argument 'setNumber' should be a number between 1 and total number of sets.

Examples:
/xlgb_sets
/xlgb_items 3

### Remove items from a gear set

Accidentally added an item to the wrong set? Fear not! When an item belongs to a set a new menu item appears in the drop-down menu, similar to adding items, this menu item reads 'XLG remove >'.
Clicking on one of the sets listed in the sub-menu will result in removing that gear piece from the set again.

### Remove a gear set

If you've spelled a name wrong (Sorry no support for renaming sets yet) or just don't like a set you've previously created you can remove it with the slash_command  "/xlgb_removeset setNumber".
**Warning:** This slash_command will immediately remove the gear set specified without any prompts, with no way to restore the gear set. (Doesn't delete the items themselves but removes your hard work of adding things to a set)

Examples:
/xlgb_removeset 2
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

/xlgb_debug
Toggles debug mode. (Note: quite verbose)

/xlgb_help
Prints out these commands in the chat.
