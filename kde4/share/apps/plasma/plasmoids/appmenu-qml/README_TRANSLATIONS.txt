(Instructions adapted from gmail-plasmoid: http://code.google.com/p/gmail-plasmoid/)

This document contains brief instructions on how to create new
translations for this plasmoid. If any of the instructions are unclear
or you encounter any difficulties please contact the author at the
following email address:

Glad Deschrijver <glad.deschrijver@gmail.com>


---------------------------------------------
Step 1: Creating a new appmenu-qml.po file
---------------------------------------------
First, under the "contents/locale" folder create a new sub-folder with
the same name as your locale, and create a further sub-folder named
"LC_MESSAGES". For example, for a French translation you would create
the following folders "contents/locale/fr/LC_MESSAGES". Second, copy the
appmenu-qml.pot file from the "contents/locale" directory into your new
LC_MESSAGES directory and rename it appmenu-qml.po (in other words, change
the extension from .pot to .po). You are now ready to start translating.

--------------------------------------
Step 2: Translate the required strings
--------------------------------------
While you can edit the appmenu-qml.po file in any text editor, using the
"lokalize" program can make your life easier. This program is packaged
for most distributions so it should be easy to install. Whatever method
you choose, you need to supply a translation for all of the strings that
appear in the .po file.

If you encounter any strings that you cannot translate due to the choice
of words or some other issue, please contact the author to work out a
solution.

Note that the strings "Icon size" and "Small icon size" refer to the icons
in the menu itself and not to the launcher icon. So "icon" is meant to be
translated in its plural form (if applicable).

-------------------------------------------
Step 3: Convert the .po file to an .mo file
-------------------------------------------
In order for the widget to use a translation it must be converted to
a .mo file. This is done using the "Messages.sh" script found in the
"contents/locale" folder, which creates updated .mo files for all
translations.

----------------------------------------------------------
Step 4: Send the translation for inclusion with the widget
----------------------------------------------------------
Once you are happy with the translation please send the .po file to the
author along with translations for the following two strings (see
metadata.desktop):

For the "add widgets" screen:
   "Application Launcher (QML)"
   "Launcher to start applications"

Please send the translations for these two strings only when the
translation is not yet in metadata.desktop.

When you send the .po file and the two strings above, please indicate
whether you give permission to the author to include your name in the
THANKS file.
