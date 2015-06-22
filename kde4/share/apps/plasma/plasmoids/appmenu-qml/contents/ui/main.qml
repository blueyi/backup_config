/**

    Copyright (C) 2011, 2012, 2013 Glad Deschrijver <glad.deschrijver@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, see <http://www.gnu.org/licenses/>.

*/

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
	id: main
	property int minimumWidth: 150 // must set this in order for Plasma to "get" that this is really a PopupApplet
	property int minimumHeight: 200 // idem
	property int maximumWidth
	property int maximumHeight
	property int preferredWidth: numOfColumns == 1 ? 250 : 500
	property int preferredHeight: 350

	function configChanged() {
		scrollOverBounds = plasmoid.readConfig("scrollOverBounds");
		iconSize = plasmoid.readConfig("iconSize");
		smallIconSize = plasmoid.readConfig("smallIconSize");
		showDescription = plasmoid.readConfig("showDescription");
		numOfColumns = plasmoid.readConfig("numOfColumns");
		resetOnShow = plasmoid.readConfig("resetOnShow");
		checkEmptySubmenusThoroughly = plasmoid.readConfig("checkEmptySubmenusThoroughly");

		// hide/unhide the favorites column and its breadcrumb title
		favoritesVisible = plasmoid.readConfig("favoritesVisible");
		if (favoritesVisible && !favoritesAdded) {
			appsMenuBreadCrumb.insert(0, i18n("Favorites"));
			favoritesAdded = true;
		} else if (!favoritesVisible && favoritesAdded) {
			appsMenuBreadCrumb.remove(0);
			favoritesAdded = false;
		}

		leaveToolBar.configChanged();

		popupIcon = plasmoid.readConfig("icon");
		if (plasmoid.formFactor == Horizontal || plasmoid.formFactor == Vertical) {
			var toolTipData = new Object;
			toolTipData["image"] = popupIcon;
			toolTipData["mainText"] = plasmoid.popupIconToolTip["mainText"];
			plasmoid.popupIconToolTip = toolTipData;
		}
		plasmoid.popupIcon = QIcon(popupIcon);
	}

	// configurable variables (the defaults specified here should not have any effect because they are overwritten by the values in the config in configChanged())
	property string popupIcon: "start-here-kde"
	property bool favoritesVisible: true
	property bool favoritesLocked: false
	property bool scrollOverBounds: true
	property int iconSize: theme.smallMediumIconSize // 22
	property int smallIconSize: theme.smallIconSize // 16
	property bool showDescription: true
	property int numOfColumns: 2 // number of visible columns in the widget
	property bool resetOnShow: false
	property bool checkEmptySubmenusThoroughly: false
	// other variables
	property int defaultMargin: 5
	property variant favoritesList: []
	property variant favoritesSources: []
	property variant appsMenu0List
	property variant appsMenu1List
	property variant appsMenu2List
	property variant appsMenu3List
	property variant appsMenu4List
	property int numOfSubMenus: 4 // the maximum number of nested submenus
	property int numOfVisibleSubMenus: 0
	property int startIndex: favoritesVisible ? 1 : 0
	property bool favoritesAdded: true

	Keys.onDownPressed: doMenuAction("down"); // if searchField is focused
	Keys.onUpPressed: doMenuAction("up"); // if searchField is focused
	Keys.onReturnPressed: doMenuAction("select"); // if searchField is focused
	Keys.onPressed: {
		if (event.key == Qt.Key_F5)
			refresh();
		else if (event.key == Qt.Key_PageDown)
			doMenuAction("pageDown");
		else if (event.key == Qt.Key_PageUp)
			doMenuAction("pageUp");
		else if (event.key == Qt.Key_Backspace)
			searchField.text = searchField.text.substring(0, searchField.text.length - 1);
//		else if ((searchField.text != "" || (event.key != Qt.Key_Plus && event.key != Qt.Key_Equal && event.key != Qt.Key_Minus)) && event.key != Qt.Key_Escape && (event.modifiers == Qt.NoModifier || event.modifiers == Qt.ShiftModifier))
		else if ((favoritesLocked || (event.key != Qt.Key_Plus && event.key != Qt.Key_Equal && event.key != Qt.Key_Minus))
		    && event.key != Qt.Key_Escape
		    && (event.modifiers == Qt.NoModifier || event.modifiers == Qt.ShiftModifier))
		{
			searchField.text = searchField.text + event.text;
			searchField.forceActiveFocus();
		}
	}

	function doMenuAction(action) {
		var menu = searchField.text.length == 0 ? appsMenuList.currentItem : searchMenu;
		menu.forceActiveFocus();
		if (action == "down")
			menu.incrementCurrentIndex();
		else if (action == "up")
			menu.decrementCurrentIndex();
		else if (action == "select")
			menu.selectCurrentItem();
		if (action == "pageDown")
			menu.pageDown();
		else if (action == "pageUp")
			menu.pageUp();
	}

	function restoreFavorites() {
//var t1 = new Date().getTime();
		var favoritesSourcesString = plasmoid.readConfig("favorites").toString();
		var favoritesSourcesList = new Array();
		if (favoritesSourcesString.length > 0)
			favoritesSourcesList = favoritesSourcesString.split(",");
		favoritesSources = favoritesSourcesList;
		var model = new Array();
		for (var i = 0; i < favoritesSources.length; i++) {
			if (appsSource.sources.indexOf(favoritesSources[i]) < 0) // if a favorite app has been uninstalled meanwhile (e.g. on transition KMail -> KMail2, Firefox -> Google Chrome, OpenOffice -> LibreOffice, KWord -> Calligra Words, KMail becomes too buggy -> Trojita, ...), then skip it (forever)
				continue;
			var entry = appsSource.data[favoritesSources[i]];
			model.push({"DataEngineSource" : favoritesSources[i], "name" : entry["name"], "genericName" : entry["genericName"], "iconName" : entry["iconName"], "isApp" : entry["isApp"], "entryPath" : entry["entryPath"], "isFavorite" : true});
		}
//console.log("restore favorites:" + (new Date().getTime() - t1));
		favoritesList = model;
	}

	function addFavorite(source) {
		if (favoritesSources.indexOf(source) >= 0)
			return;
		var model = favoritesList; // we cannot directly add to favoritesList, so we introduce a temporary array
		var modelSources = favoritesSources; // idem
		var entry = appsSource.data[source];
		if (!entry["isApp"])
			return;
		model.push({"DataEngineSource" : source, "name" : entry["name"], "genericName" : entry["genericName"], "iconName" : entry["iconName"], "isApp" : entry["isApp"], "entryPath" : entry["entryPath"], "isFavorite" : true});
		modelSources.push(source);
		favoritesList = model;
		favoritesSources = modelSources;
		plasmoid.writeConfig("favorites", favoritesSources.toString());
	}

	function removeFavorite(source) {
		var index = favoritesSources.indexOf(source);
		if (index < 0) // should never happen
			return;
		var model = favoritesList; // we cannot directly add to favoritesList, so we introduce a temporary array
		var modelSources = favoritesSources; // idem
		model.splice(index, 1);
		modelSources.splice(index, 1);
		favoritesList = model;
		favoritesSources = modelSources;
		plasmoid.writeConfig("favorites", favoritesSources.toString());
	}

	function moveFavorite(oldIndex, newIndex) {
		var model = favoritesList; // we cannot directly add to favoritesList, so we introduce a temporary array
		var modelSources = favoritesSources; // idem
//		var movingItem = model.splice(oldIndex, 1); // for some reason, this doesn't work, so we use the following two lines
		var movingItem = model[oldIndex];
		model.splice(oldIndex, 1);
//		var movingSource = modelSources.splice(oldIndex, 1); // idem: this results in main.favoritesSources.indexOf(source) == -1 in Menu.qml
		var movingSource = modelSources[oldIndex];
		modelSources.splice(oldIndex, 1);
		model.splice(newIndex, 0, movingItem);
		modelSources.splice(newIndex, 0, movingSource);
		favoritesList = model;
		favoritesSources = modelSources;
		plasmoid.writeConfig("favorites", favoritesSources.toString());
	}

	function moveFavoriteDown(index) {
		if (index >= favoritesList.length - 1)
			return;
		moveFavorite(index, index + 1);
	}

	function moveFavoriteUp(index) {
		if (index < 1)
			return;
		moveFavorite(index, index - 1);
	}

	function openItem(source, currentMenu) {
		if (source == "")
			return;
		var entry = appsSource.data[source];
		if (!entry["isApp"] && entry["entries"].length > 0) { // create and show submenu
//var t1 = new Date().getTime();
			// if currentMenu == 0 (i.e. in the favorites list), then there are no submenus
			if (currentMenu < startIndex + numOfSubMenus) {
				appsMenuList.currentIndex = currentMenu + 1;
				var currentSubMenu = currentMenu - startIndex + 1;
				eval("appsMenu" + currentSubMenu + "List = getMenuItems(source)");
				appsMenuBreadCrumb.set(currentSubMenu + startIndex, entry["name"]);
				++numOfVisibleSubMenus;
				if (currentMenu < startIndex + numOfSubMenus - 1) {
					eval("appsMenu" + (currentSubMenu + 1) + "List = new Array()"); // clean up old second level submenu
					appsMenuBreadCrumb.remove(currentSubMenu + startIndex + 1);
					numOfVisibleSubMenus = currentSubMenu;
				}
//console.log("create menu:" + (new Date().getTime() - t1));
			} else {
				console.log("Known crash with unknown solution :-(");
			}
		} else { // launch app
			var service = appsSource.serviceForSource(source);
			var operation = service.operationDescription("launch");
			service.startOperationCall(operation);
			plasmoid.hidePopup();
		}
	}

	function goLeft() {
		appsMenuList.decrementCurrentIndex();
	}

	function goRight(source, currentMenu) {
		var entry = appsSource.data[source];
		if (source != "" && !entry["isApp"] && entry["entries"].length > 0) // create and show submenu
			openItem(source, currentMenu);
		else
			appsMenuList.incrementCurrentIndex();
	}

	function isNonHiddenAppOrNonEmptyDirectory(source, entry) {
		if (source == "---" // the entry is a separator
		    || entry["name"] == ".hidden"
		    || !entry["display"]) // respect NoDisplay=true in .desktop file
			return false;

		if (entry["isApp"])
			return true;

		// at this point we have a non-hidden directory, let us check whether it is empty
		var sources = entry["entries"];
		if (sources.length <= 0) // the directory is empty
			return false;

		if (main.checkEmptySubmenusThoroughly) { // the following is slower
			for (var i = 0; i < sources.length; i++) {
				var entry = appsSource.data[sources[i]];
				if (isNonHiddenAppOrNonEmptyDirectory(sources[i], entry))
					return true;
			}
			return false;
		}
		return true;
	}

	function getMenuItems(source) {
//var t1 = new Date().getTime();
		var model = new Array();
		var sources = appsSource.data[source]["entries"];
		var names = new Array();
		for (var i = 0; i < sources.length; i++) {
			var entry = appsSource.data[sources[i]];
			if (isNonHiddenAppOrNonEmptyDirectory(sources[i], entry) && names.indexOf(entry["name"]) < 0) { // the entry has not already been found
				names.push(entry["name"]);
				model.push({"DataEngineSource" : sources[i], "name" : entry["name"], "genericName" : entry["genericName"], "iconName" : entry["iconName"], "isApp" : entry["isApp"], "entryPath" : entry["entryPath"], "isFavorite" : false});
			}
		}
//console.log("get menu items:" + (new Date().getTime() - t1));
		return model;
	}

	function refresh() {
		appsMenu0List = getMenuItems("/");
	}

	function reset() {
		searchField.text = "";
		appsMenuList.currentIndex = 0;
	}

	function action_menuEditor() {
		plasmoid.runApplication("kmenuedit.desktop");
	}

	function action_lockFavorites() {
		main.favoritesLocked = true;
		plasmoid.writeConfig("favoritesLocked", true);
		plasmoid.removeAction("lockFavorites");
		plasmoid.setAction("unlockFavorites", i18n("Unlock Favorites"));
	}

	function action_unlockFavorites() {
		main.favoritesLocked = false;
		plasmoid.writeConfig("favoritesLocked", false);
		plasmoid.removeAction("unlockFavorites");
		plasmoid.setAction("lockFavorites", i18n("Lock Favorites"));
	}

	function popupEventSlot(shown) {
		if (shown) {
			if (resetOnShow)
				reset();
			searchField.forceActiveFocus();
		}
	}

	function activateSlot() {
		searchField.forceActiveFocus();
	}

	Component.onCompleted: {
		// menu editor
		plasmoid.setAction("menuEditor", i18n("Menu Editor"));

		// lock favorites
		main.favoritesLocked = plasmoid.readConfig("favoritesLocked");
		if (main.favoritesLocked)
			plasmoid.setAction("unlockFavorites", i18n("Unlock Favorites"));
		else
			plasmoid.setAction("lockFavorites", i18n("Lock Favorites"));

		// plasmoid look
		if (plasmoid.formFactor == Horizontal || plasmoid.formFactor == Vertical) {
			var toolTipData = new Object;
			toolTipData["image"] = main.popupIcon; // same as in .desktop file
			toolTipData["mainText"] = i18n("Application Launcher"); // same as in .desktop file
			plasmoid.popupIconToolTip = toolTipData;
		}
		plasmoid.popupIcon = QIcon(main.popupIcon); // same as in .desktop file
		plasmoid.aspectRatioMode = IgnoreAspectRatio;

		// plasmoid behaviour
		plasmoid.addEventListener("ConfigChanged", configChanged);
//		configChanged();
		plasmoid.popupEvent.connect(popupEventSlot);
		plasmoid.addEventListener("activate", activateSlot); // when the plasmoid is added on the desktop, pressing its keyboard shortcut will trigger this
	}

	PlasmaCore.DataSource {
		id: appsSource
		engine: "apps"

		onSourceAdded: {
			connectSource(source);
		}

		Component.onCompleted: {
			connectedSources = sources;
//var t1 = new Date().getTime();
			refresh();
//console.log("startup2:" + (new Date().getTime() - t1));
			restoreFavorites();
//console.log("startup2:" + (new Date().getTime() - t1));
		}
	}

	PlasmaCore.Theme {
		id: theme
	}

	SearchField {
		id: searchField
		anchors.top: main.top
		anchors.left: main.left
		anchors.right: main.right
		anchors.margins: main.defaultMargin
		dataSource: appsSource
		searchMenu: searchMenu
		onTextEmptied: appsMenuList.currentItem.forceActiveFocus(); // fix bug: if the search field is emptied (using Backspace) when searchMenu is focused, then appsMenuList.currentItem is not focused, so the Left and Right arrow keys don't work
		Keys.onPressed: {
			if (text.length == 0 && (event.key == Qt.Key_Left || event.key == Qt.Key_Right)) {
				appsMenuList.currentItem.forceActiveFocus();
				if (event.key == Qt.Key_Left)
					appsMenuList.currentItem.selectLeft();
				else
					appsMenuList.currentItem.selectRight();
				event.accepted = true;
			}
		}
	}

	Item {
		id: centralWidget
		anchors.top: searchField.bottom
		anchors.left: main.left
		anchors.right: main.right
		anchors.bottom: leaveToolBar.top
		anchors.topMargin: main.defaultMargin
		anchors.leftMargin: main.defaultMargin
		anchors.rightMargin: main.defaultMargin
		anchors.bottomMargin: main.defaultMargin * (leaveToolBar.buttonsVisible ? 2 : 1)
		clip: true

		Menu {
			id: searchMenu
			width: centralWidget.width
			height: centralWidget.height
			x: 0
			y: searchField.text.length > 0 ? 0 : -centralWidget.height
			boundsBehavior: scrollOverBounds ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
			clip: true
//			model: searchField.model
			isEditing: !main.favoritesLocked && main.favoritesVisible
			iconSize: main.iconSize
			smallIconSize: main.smallIconSize
			showDescription: main.showDescription
			isSearchMenu: true
			onItemSelected: openItem(source, 0);
			onAddFavorite: main.addFavorite(source);
			onRemoveFavorite: main.removeFavorite(source);

			Behavior on y {
				NumberAnimation { duration: 300; easing.type: Easing.Linear }
			}
		}

		Item {
			id: appsMenuListContainer
			width: centralWidget.width
			height: centralWidget.height
			x: 0
			y: searchField.text.length > 0 ? centralWidget.height : 0

			BreadCrumb {
				id: appsMenuBreadCrumb
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				currentIndex: appsMenuList.currentIndex
				Component.onCompleted: {
					insert(0, i18n("Favorites"));
					insert(1, i18n("Applications"));
				}
				onItemSelected: appsMenuList.currentIndex = index;
			}

			ListView {
				id: appsMenuList
				anchors.top: appsMenuBreadCrumb.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				spacing: 5
				snapMode: ListView.SnapOneItem
				orientation: ListView.Horizontal
				highlightMoveSpeed: 400
				highlightMoveDuration: 150
				boundsBehavior: main.scrollOverBounds ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
				clip: true
				focus: true;
				cacheBuffer: main.numOfSubMenus * width // make sure that switching to submenus doesn't make the plasmoid forget the highlighted item in the favorites list and main menus

//				model: numOfVisibleSubMenus + 1 + main.startIndex // this dramatically slows down opening a submenu
				model: main.numOfSubMenus + 1 + main.startIndex
				delegate: Menu {
					id: appsMenu
					width: (appsMenuList.width - appsMenuList.spacing) / numOfColumns
					height: appsMenuList.height
					boundsBehavior: main.scrollOverBounds ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
					model: main.favoritesVisible && index == 0 ? favoritesList : eval("appsMenu" + (index - startIndex) + "List")
					isInFavoritesList: index == 0 && main.favoritesVisible
					isEditing: !main.favoritesLocked && main.favoritesVisible
					iconSize: main.iconSize
					smallIconSize: main.smallIconSize
					showDescription: main.showDescription
					onItemSelected: openItem(source, index);
					onMoveItem: {
						if (isInFavoritesList)
							moveFavorite(oldIndex, newIndex);
					}
					onAddFavorite: main.addFavorite(source);
					onRemoveFavorite: main.removeFavorite(source);
					onMoveFavoriteDown: main.moveFavoriteDown(index);
					onMoveFavoriteUp: main.moveFavoriteUp(index);
					onGoLeft: main.goLeft();
					onGoRight: main.goRight(source, index);
				}

				onMovementEnded: { // make sure currentIndex has the correct value when flicking appsMenuList
					currentIndex = contentX / contentWidth * count;
				}
			}

			Behavior on y {
				NumberAnimation { duration: 300; easing.type: Easing.Linear }
			}
		}
	}

	LeaveToolBar {
		id: leaveToolBar
		anchors.left: main.left
		anchors.right: main.right
		anchors.bottom: main.bottom
		anchors.margins: main.defaultMargin
	}
}
