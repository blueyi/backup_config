/**

    Copyright (C) 2011, 2012 Glad Deschrijver <glad.deschrijver@gmail.com>

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
	id: breadCrumb
	height: row.height

	signal itemSelected(int index)

	property int currentIndex

	function insert(index, value) {
		repeater.model.insert(index, {"text" : value});
	}
	function set(index, value) {
		repeater.model.set(index, {"text" : value});
	}
	function remove(index) {
		if (repeater.model.count > index)
			repeater.model.remove(index);
	}
	function text(index) {
		return repeater.model.get(index).text;
	}

	Row {
		id: row
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 2

		Repeater {
			id: repeater
			model: ListModel {} // use ListModel instead of a stringlist, because we want nice animations when items are added or removed, and the bindings don't seem to work when a stringlist is used as a model and we only append items to the stringlist instead of completely replacing the model
			delegate: PlasmaComponents.Label {
				id: text
				width: breadCrumb.width / repeater.model.count
				font.italic: breadCrumb.currentIndex == index
				font.pointSize: theme.defaultFont.pointSize + 1
				text: modelData
				elide: Text.ElideRight

				MouseArea {
					anchors.fill: parent
					onClicked: breadCrumb.itemSelected(index);
				}
			}
		}
		add: Transition {
			NumberAnimation {
				properties: "x, width"
				duration: 300
				easing.type: Easing.Linear
			}
		}
		move: Transition {
			NumberAnimation {
				properties: "x, width"
				duration: 300
				easing.type: Easing.Linear
			}
		}
	}
}
