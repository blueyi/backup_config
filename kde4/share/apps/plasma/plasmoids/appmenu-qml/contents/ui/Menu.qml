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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.draganddrop 1.0

Item {
	id: menu

	property alias model: menuListView.model
	property alias boundsBehavior: menuListView.boundsBehavior
	property bool isInFavoritesList: false
	property bool isEditing: true
	property int iconSize: 22 // theme.smallMediumIconSize; since iconSize is overwritten in main.qml anyway, do not set iconSize to theme.smallMediumIconSize because that is a QScript binding, setting iconSize to 22 is an optimized binding (run "QML_COMPILER_STATS=1 plasmoidviewer" to see that)
	property int smallIconSize: 16 // theme.smallIconSize
	property bool showDescription: true
	property bool isSearchMenu: false
	property bool dropEnabled: isInFavoritesList && isEditing

	signal itemSelected(string source)
	signal moveItem(int oldIndex, int newIndex)
	signal addFavorite(string source)
	signal removeFavorite(string source)
	signal moveFavoriteDown(int index)
	signal moveFavoriteUp(int index)
	signal goLeft()
	signal goRight(string source)

	function incrementCurrentIndex() {
		menuListView.incrementCurrentIndex();
	}
	function decrementCurrentIndex() {
		menuListView.decrementCurrentIndex();
	}
	function selectCurrentItem() {
		menu.itemSelected(menuListView.count == 0 ? "" : menuListView.currentItem.source);
	}
	function selectLeft() {
		menu.goLeft();
	}
	function selectRight() {
		menu.goRight(menuListView.count == 0 ? "" : menuListView.currentItem.source);
	}
	function pageUp() { // scroll x items up, where x is the number of visible items
		if (menuListView.currentIndex >= 0) {
			var index = Math.max(menuListView.currentIndex - Math.floor(menuListView.height / menuListView.currentItem.height), 0);
			menuListView.currentIndex = index;
		}
	}
	function pageDown() { // scroll x items down, where x is the number of visible items
		if (menuListView.currentIndex >= 0) {
			var index = Math.min(menuListView.currentIndex + Math.floor(menuListView.height / menuListView.currentItem.height), menuListView.count - 1);
			menuListView.currentIndex = index;
		}
	}

	Keys.onRightPressed: menu.selectRight();
	Keys.onReturnPressed: menu.selectCurrentItem();
	Keys.onPressed: {
		if (menuListView.currentIndex >= 0 && isEditing) {
			if (event.key == Qt.Key_Plus || event.key == Qt.Key_Equal)
				menu.addFavorite(menuListView.currentItem.source);
			else if (event.key == Qt.Key_Minus)
				menu.removeFavorite(menuListView.currentItem.source);
		}
	}

	PlasmaComponents.Label {
		id: noEntriesText
		anchors.top: parent.top
		anchors.topMargin: 20
		anchors.horizontalCenter: parent.horizontalCenter
		text: i18n("No entries")
		visible: menuListView.count == 0
	}

	ListView {
		id: menuListView
		anchors.top: menu.top
		anchors.left: menu.left
		anchors.bottom: menu.bottom
		anchors.right: scrollBar.visible ? scrollBar.left : menu.right
		anchors.margins: 5
		spacing: 2
		highlightMoveDuration: 250

		// dirty hack to get rid of the binding loop in PlasmaComponents.ScrollBar when using the Up/Down keys to navigate the list
		Timer {
			id: indexChangeTimer
			running: false
			repeat: false
			interval: 200
			onTriggered: menuListView.currentIndexChanging = false;
		}
		property bool currentIndexChanging: false
		property bool moving: Flickable.moving || currentIndexChanging // this property is not set to true when the list moves because of keypresses, so we set it ourselves
		onContentYChanged: {
			currentIndexChanging = true;
			indexChangeTimer.running = true; // after some delay currentIndexChanging must be set to false again
		}
		// end dirty hack to get rid of the binding loop

		highlight: PlasmaComponents.Highlight {
			hover: menu.focus
			width: menuListView.width // this is necessary so that the width of the focus updates when the menu is resized
		}

		delegate: MenuItem {
			id: menuItemDelegate
			width: menuListView.width

			property variant menuItemModel: isSearchMenu ? model : modelData // dirty hack to allow the search menu to be displayed properly
			property string source: menuItemModel["DataEngineSource"]

			name: menuItemModel["name"]
			genericName: menuItemModel["genericName"] == undefined ? "" : menuItemModel["genericName"]
			entryPath: menuItemModel["entryPath"] == undefined ? "" : menuItemModel["entryPath"]
			iconName: menuItemModel["iconName"]
			isApp: menuItemModel["isApp"]
			isFavorite: menuItemModel["isFavorite"] || main.favoritesSources.indexOf(source) >= 0
			isInFavoritesList: menu.isInFavoritesList
			isEditing: menu.isEditing
			moveUpButtonVisible: index > 0
			moveDownButtonVisible: index < menuListView.count - 1
			iconSize: menu.iconSize
			smallIconSize: menu.smallIconSize
			showDescription: menu.showDescription

			onClicked: menu.itemSelected(source);
			onEntered: menuListView.currentIndex = index;
			onAddFavorite: menu.addFavorite(source);
			onRemoveFavorite: menu.removeFavorite(source);
			onMoveFavoriteDown: menu.moveFavoriteDown(index);
			onMoveFavoriteUp: menu.moveFavoriteUp(index);
		}
	}

	PlasmaComponents.ScrollBar {
		id: scrollBar
		orientation: Qt.Vertical
		flickableItem: menuListView
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom
	}

	DropArea {
		anchors.fill: parent
		visible: dropEnabled

		property int dropIndex: -1
		property int startDragY: -1

		function findDropPosition(event) {
			menuListView.currentIndex = menuListView.indexAt(event.x, event.y + menuListView.contentY);
			if (menuListView.currentIndex == -1) {
				return;
			}
			if (event.y < menuListView.currentItem.y - menuListView.contentY + menuListView.currentItem.height / 2) {
				dropIndex = menuListView.currentIndex - 1
					+ (event.y >= startDragY
					   && startDragY < menuListView.currentItem.y - menuListView.contentY ? 0 : 1); // do not apply correction when both the start and the end position of the drag are in the upper half of the item
				dropTarget.y = menuListView.currentItem.y - menuListView.contentY - menuListView.spacing;
			} else {
				dropIndex = menuListView.currentIndex
					+ (event.y >= startDragY
					   || startDragY <= menuListView.currentItem.y - menuListView.contentY + menuListView.currentItem.height ? 0 : 1); // do not apply correction when both the start and the end position of the drag are in the lower half of the menu item
				dropTarget.y = menuListView.currentItem.y - menuListView.contentY + menuListView.currentItem.height;
			}
		}

		onDrop: {
			if (event.mimeData.text >= 0) // make sure that items from the menus are not dropped in the favorites list (event.mimeData.text is set to -1 in MenuItem.qml for items not in the favorites list)
				menu.moveItem(event.mimeData.text, dropIndex); // event.mimeData.text is equal to the old index of the dragged item (set in MenuItem.qml)
			dropTarget.visible = false;
		}
		onDragEnter: {
			startDragY = event.y;
			findDropPosition(event);
			dropTarget.visible = true;
		}
		onDragMove: findDropPosition(event);
		onDragLeave: dropTarget.visible = false;

		Rectangle {
			id: dropTarget
			width: parent.width
			height: 2
			visible: false
			color: theme.highlightColor
		}
	}
}
