/**

    Copyright (C) 2012, 2013 Glad Deschrijver <glad.deschrijver@gmail.com>

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

Item {
	id: arrow

	property int size: 16 // theme.smallIconSize

	width: arrow.size
	height: arrow.size

	PlasmaCore.SvgItem {
		svg: arrowSvg
		elementId: "right-arrow"
		anchors.fill: parent
	}
	PlasmaCore.Svg {
		id: arrowSvg
		imagePath: "widgets/arrows"
	}
}
