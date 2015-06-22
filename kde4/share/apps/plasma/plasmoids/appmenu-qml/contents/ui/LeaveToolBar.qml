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
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
	id: leaveToolBar
	height: childrenRect.height

	property int iconSize: 16 // theme.smallIconSize
	property bool buttonsVisible: internal.numOfVisibleButtons > 0

	QtObject {
		id: internal
		property int numOfVisibleButtons: actionsModel.count
		property int buttonWidth: (leaveToolBar.width - (numOfVisibleButtons + 1) * row.spacing) / numOfVisibleButtons
		property bool showLabels: row.width < leaveToolBar.width - 2 * row.spacing
	}

	function configChanged() { // called in main.qml
		iconSize = plasmoid.readConfig("leaveButtonsIconSize");
		actionsModel.clear();
		if (plasmoid.readConfig("lockButtonVisible") == true)
			actionsModel.append({"action": "lockScreen", "text": i18n("Lock Session"), "icon": "system-lock-screen"});
		if (plasmoid.readConfig("leaveButtonVisible") == true)
			actionsModel.append({"action": "requestShutDown", "text": i18n("Leave"), "icon": "system-shutdown"});
		if (plasmoid.readConfig("logOutButtonVisible") == true)
			actionsModel.append({"action": "logOut", "text": i18n("Log Out"), "icon": "system-log-out"});
		if (plasmoid.readConfig("turnOffButtonVisible") == true)
			actionsModel.append({"action": "turnOff", "text": i18n("Turn Off Computer"), "icon": "system-shutdown"});
		if (plasmoid.readConfig("restartButtonVisible") == true)
			actionsModel.append({"action": "restart", "text": i18n("Restart"), "icon": "system-reboot"});
		if (plasmoid.readConfig("suspendToRamButtonVisible") == true)
			actionsModel.append({"action": "suspendToRam", "text": i18n("Sleep"), "icon": "system-suspend"});
		if (plasmoid.readConfig("suspendToDiskButtonVisible") == true)
			actionsModel.append({"action": "suspendToDisk", "text": i18n("Hibernate"), "icon": "system-suspend-hibernate"});
		if (plasmoid.readConfig("switchUserButtonVisible") == true)
			actionsModel.append({"action": "switchUser", "text": i18n("Switch User"), "icon": "system-switch-user"});
	}

	function doAction(action) {
		// see http://api.kde.org/4.10-api/kde-workspace-apidocs/libs/kworkspace/html/namespaceKWorkSpace.html
		if (action == "lockScreen")
			plasmoid.runCommand("qdbus", ["org.freedesktop.ScreenSaver", "/ScreenSaver", "Lock"]);
		else if (action == "requestShutDown")
			plasmoid.runCommand("qdbus", ["org.kde.ksmserver", "/KSMServer", "org.kde.KSMServerInterface.logout", "1", "-1", "-1"]); // ShutdownConfirmYes, ShutdownTypeDefault, ShutdownModeDefault
		else if (action == "logOut")
			plasmoid.runCommand("qdbus", ["org.kde.ksmserver", "/KSMServer", "org.kde.KSMServerInterface.logout", "0", "3", "-1"]); // ShutdownConfirmNo, ShutdownTypeLogout, ShutdownModeDefault
		else if (action == "turnOff")
			plasmoid.runCommand("qdbus", ["org.kde.ksmserver", "/KSMServer", "org.kde.KSMServerInterface.logout", "0", "2", "-1"]); // ShutdownConfirmNo, ShutdownTypeHalt, ShutdownModeDefault
		else if (action == "restart")
			plasmoid.runCommand("qdbus", ["org.kde.ksmserver", "/KSMServer", "org.kde.KSMServerInterface.logout", "0", "1", "-1"]); // ShutdownConfirmNo, ShutdownTypeReboot, ShutdownModeDefault
		else if (action == "suspendToRam")
			plasmoid.runCommand("qdbus", ["org.kde.Solid.PowerManagement", "/org/kde/Solid/PowerManagement", "org.kde.Solid.PowerManagement.suspendToRam"]);
		else if (action == "suspendToDisk")
			plasmoid.runCommand("qdbus", ["org.kde.Solid.PowerManagement", "/org/kde/Solid/PowerManagement", "org.kde.Solid.PowerManagement.suspendToDisk"]);
		else if (action == "switchUser")
			plasmoid.runCommand("qdbus", ["org.kde.krunner", "/App", "org.kde.krunner.App.switchUser"]);
	}

// Activate the following and remove the qdbus commands above when the plasma/viranch/powermanagementservices branch is finally merged in kde-workspace master
/*
	function doAction(action) {
		var service = dataEngine.serviceForSource("PowerDevil");
		var operation = service.operationDescription(action);
		service.startOperationCall(operation);
	}

	PlasmaCore.DataSource {
		id: dataEngine
		engine: "powermanagement"
		connectedSources: ["PowerDevil"]
		interval: 0
	}
*/

	ListModel {
		id: actionsModel
	}

	Row { // this row contains the buttons with the full text label
		id: row
		spacing: 10
		anchors.horizontalCenter: parent.horizontalCenter
		visible: internal.showLabels
		Repeater {
			model: actionsModel
			delegate: PlasmaComponents.Button {
				text: model.text
				iconSource: model.icon
				height: Math.max(implicitHeight, leaveToolBar.iconSize)
				onClicked: doAction(model.action);
			}
		}
	}
	Row { // this row contains the icon-only buttons which replace the above ones when the plasmoid is too narrow
		id: rowSmall
		spacing: 10
		anchors.horizontalCenter: parent.horizontalCenter
		Repeater {
			model: internal.showLabels ? ListModel : actionsModel
			delegate: PlasmaComponents.Button {
				id: smallButton
				iconSource: model.icon
				height: Math.max(implicitHeight, leaveToolBar.iconSize)
				width: height
				onClicked: doAction(model.action);
				PlasmaCore.ToolTip {
					target: smallButton
					mainText: model.text
				}
			}
		}
	}
}
