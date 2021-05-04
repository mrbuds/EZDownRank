# EZDownRank

A World of Warcraft Classic addon for healers.

## Features

* Adds up to 8 clickable buttons on each raid frame
* Button colors dynamically change depending on health deficit, your spellpower, remaining mana, and talents.
* Support for X and Y offset, column and row count, and gridlines.

## Default Click Configuration

Note: This is with Classic spells, when new ranks are learn in TBC max ranks shift to new ones

### Priest

* <kbd>1</kbd>-<kbd>7</kbd>: `Flash Heal` (Rank 1-7)
* <kbd>shift</kbd> + <kbd>1</kbd>-<kbd>4</kbd>: `Heal` (Rank 2-4)
* <kbd>shift</kbd> + <kbd>5</kbd>-<kbd>8</kbd>: `Greater Heal` (Rank 1-5)

### Druid

* <kbd>1</kbd>-<kbd>8</kbd>: `Healing Touch` (Rank 4-11)
* <kbd>shift</kbd> + <kbd>1</kbd>-<kbd>8</kbd>: `Regrowth` (Rank 2-9)

### Shaman

* <kbd>1</kbd>-<kbd>6</kbd>: `Lesser Healing Wave` (Rank 1-6)
* <kbd>shift</kbd> + <kbd>1</kbd>-<kbd>8</kbd>: `Healing Wave` (Rank 3-10)
* <kbd>ctrl</kbd> + <kbd>1</kbd>-<kbd>3</kbd>: `Chain Heal` (Rank 1-3)

### Paladin

* <kbd>1</kbd>-<kbd>6</kbd>: `Flash of Light` (Rank 1-6)
* <kbd>shift</kbd> + <kbd>1</kbd>-<kbd>8</kbd>: `Holy Light` (Rank 2-9)

## Colors

* Buttons for cast rank that will overheal are transparent (but are still clickable)
* Green: highest spell rank with no overheal
* Yellow: no overheal
* Orange: not enough mana

## Example

![img](https://i.imgur.com/E9L8EeK.png)

Above: Playing a Priest, holding the Shift key, and I 261 mana remaining

* Best heal for *Lonlon* is `Heal (Rank 4)`
* Best heal for *Nemesis* is `Greater Heal (Rank 2)`, max rank I can cast is `Heal (Rank 4)`
* Best heal for *Laevan* is `Greater Heal (Rank 3)`, max rank I can cast is `Heal (Rank 4)`
* My `Heal (Rank 1)` will overheal *Fraisette*

## Q & A

* Where can I file a bug report? [Here](https://github.com/mrbuds/EZDownRank/issues/new)
* Can I buy you a beer? How kind of you! I accept donations via [PayPal](https://paypal.me/BudsWA).
