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
import org.kde.qtextracomponents 0.1
import org.kde.draganddrop 1.0

Item {
	id: menuItem
	height: childrenRect.height

	signal clicked()
	signal entered()
	signal addFavorite()
	signal removeFavorite()
	signal moveFavoriteDown()
	signal moveFavoriteUp()

	property string iconName
	property alias name: label.text
	property alias genericName: subLabel.text
	property string entryPath
	property bool isApp: true
	property bool isFavorite: false
	property bool isInFavoritesList: false
	property int iconMargin: 6
	property bool isEditing: true
	property bool moveUpButtonVisible: false
	property bool moveDownButtonVisible: false
	property int iconSize: 22 // theme.smallMediumIconSize
	property int smallIconSize: 16 // theme.smallIconSize
	property bool showDescription: true
	property bool dragEnabled: isApp

	Item { // don't use Row so that we can add a left margin to icon
		id: row
		width: parent.width
		height: Math.max(icon.height, label.height + subLabel.height) + 2 * iconMargin // use fixed height because otherwise menuListView.contentHeight is not calculated correctly (and even varies during scroll)

		QIconItem {
			id: icon
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			anchors.leftMargin: iconMargin
			width: iconSize
			height: iconSize
			icon: QIcon(iconName);
		}

		Column {
			id: column
			anchors.left: icon.right
			anchors.verticalCenter: icon.verticalCenter;
			anchors.leftMargin: iconMargin

			PlasmaComponents.Label {
				id: label
				width: menuItem.width - 2 * iconMargin - icon.width - (arrowLoader.sourceComponent == arrow ? arrowLoader.width + iconMargin : 0) - (favoriteControlsLoader.sourceComponent == favoriteControls ? favoriteControlsLoader.width + iconMargin : 0)
				height: theme.defaultFont.mSize.height
				elide: Text.ElideRight
			}

			PlasmaComponents.Label {
				id: subLabel
				width: label.width
				height: showDescription ? label.height : 0
				font.pointSize: theme.smallestFont.pointSize
				opacity: 0.6
				visible: showDescription && text != ""
				elide: Text.ElideRight
			}
		}

		Loader {
			id: arrowLoader
			sourceComponent: isApp ? undefined : arrow
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.rightMargin: iconMargin
		}
		Component {
			id: arrow
			RightArrow {
				size: smallIconSize
			}
		}
	}

	DragArea {
		id: dragArea
		anchors.fill: parent
		supportedActions: Qt.MoveAction | Qt.LinkAction
		delegateImage: QIcon(menuItem.iconName)
		mimeData.source: parent
		mimeData.text: isInFavoritesList ? index : -1
		mimeData.url: menuItem.entryPath.length == 0 ? "" : "file://" + menuItem.entryPath
		visible: menuItem.dragEnabled
		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			onClicked: menuItem.clicked();
			onEntered: menuItem.entered();
		}
	}
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		visible: !menuItem.dragEnabled
		onClicked: menuItem.clicked();
		onEntered: menuItem.entered();
	}

	Loader {
		id: favoriteControlsLoader
		sourceComponent: isApp && isEditing ? favoriteControls : undefined
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.topMargin: iconMargin
		anchors.rightMargin: iconMargin
	}
	Component {
		id: favoriteControls
		FavoriteControls {
			iconSize: menuItem.smallIconSize
			isFavorite: menuItem.isFavorite
			isInFavoritesList: menuItem.isFavorite && menuItem.isInFavoritesList
			moveUpButtonVisible: menuItem.moveUpButtonVisible
			moveDownButtonVisible: menuItem.moveDownButtonVisible

			onAddFavorite: menuItem.addFavorite()
			onRemoveFavorite: menuItem.removeFavorite()
			onMoveFavoriteDown: menuItem.moveFavoriteDown()
			onMoveFavoriteUp: menuItem.moveFavoriteUp()
		}
	}
}
