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

Item {
	id: favoriteControls

	property int iconSize: 16 // theme.smallIconSize
	property bool isFavorite: false
	property bool isInFavoritesList: false
	property bool moveUpButtonVisible: false
	property bool moveDownButtonVisible: false

	signal addFavorite()
	signal removeFavorite()
	signal moveFavoriteDown()
	signal moveFavoriteUp()

	QtObject {
		id: internal
		property int buttonSize: favoriteControls.iconSize + 4
		property int buttonSep: 3
	}

	width: toggleFavoriteLoader.width + moveFavoriteLoader.width + moveFavoriteLoader.anchors.rightMargin

	Loader {
		id: toggleFavoriteLoader
		anchors.top: parent.top
		anchors.right: parent.right
		sourceComponent: isFavorite ? removeFavoriteIcon : addFavoriteIcon
	}

	Component {
		id: addFavoriteIcon
		PlasmaComponents.ToolButton {
			width: internal.buttonSize
			height: width
			iconSource: "emblem-favorite"
			flat: true
			onClicked: favoriteControls.addFavorite();
		}
	}

	Component {
		id: removeFavoriteIcon
		PlasmaComponents.ToolButton {
			width: internal.buttonSize
			height: width
			iconSource: "list-remove"
			flat: true
			onClicked: favoriteControls.removeFavorite();
		}
	}

	Loader {
		id: moveFavoriteLoader
		anchors.top: parent.top
		anchors.right: toggleFavoriteLoader.left
		anchors.rightMargin: isInFavoritesList ? internal.buttonSep : 0
		sourceComponent: isInFavoritesList ? moveFavoriteIcons : undefined
	}

	Component {
		id: moveFavoriteIcons

		Item {
			width: moveFavoriteDownButton.width + moveFavoriteUpButton.width + internal.buttonSep

			PlasmaComponents.ToolButton {
				id: moveFavoriteDownButton
				anchors.top: parent.top
				anchors.right: parent.right
				width: internal.buttonSize
				height: width
				visible: moveDownButtonVisible
				iconSource: "go-down"
				flat: true
				onClicked: favoriteControls.moveFavoriteDown();
			}

			PlasmaComponents.ToolButton {
				id: moveFavoriteUpButton
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.rightMargin: moveFavoriteDownButton.width + internal.buttonSep
				width: internal.buttonSize
				height: width
				visible: moveUpButtonVisible
				iconSource: "go-up"
				flat: true
				onClicked: favoriteControls.moveFavoriteUp();
			}
		}
	}
}
