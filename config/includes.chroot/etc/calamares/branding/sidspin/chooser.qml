/* === This file is part of SidSpin - <https://github.com/Wookiee-/Sidspin> ===
 *
 *   SPDX-FileCopyrightText: 2026 SidSpin contributors
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Based on the packagechooserq module of Calamares
 *   (src/modules/packagechooserq/), Copyright 2021 Anke Boersma,
 *   licensed GPL-3.0-or-later.
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 */

import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item
{
    id: chooser

    // The two choices, published to the installer as "<desktop>:<profile>".
    property string currentDe: "kde-plasma"
    property string currentProfile: "full"

    function publish() {
        config.packageChoice = chooser.currentDe + ":" + chooser.currentProfile
    }

    // The radio buttons keep their own state; only the initial state comes
    // from the configuration.  (Binding "checked" to currentDe would make
    // the button undo the very click that changed currentDe.)
    function selectIn( buttons, value ) {
        for ( var i = 0; i < buttons.length; i++ )
            buttons[ i ].checked = ( buttons[ i ].choiceId === value )
    }

    Component.onCompleted: {
        var parts = ( config.packageChoice || "kde-plasma:full" ).split( ":" )
        if ( parts.length > 0 && parts[ 0 ] !== "" )
            chooser.currentDe = parts[ 0 ]
        if ( parts.length > 1 && parts[ 1 ] !== "" )
            chooser.currentProfile = parts[ 1 ]

        chooser.selectIn( group.buttons, chooser.currentDe )
        chooser.selectIn( profileGroup.buttons, chooser.currentProfile )
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.88
        spacing: Kirigami.Units.largeSpacing

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Which desktop do you want?")
            font.pointSize: 17
            font.bold: true
            color: Kirigami.Theme.textColor
        }

        Repeater {
            model: [
                {
                    id: "kde-plasma",
                    name: "KDE Plasma",
                    description: qsTr("The desktop this live image boots into. Fast, polished, and complete.")
                },
                {
                    id: "gnome",
                    name: "GNOME",
                    description: qsTr("Clean and simple, built around activities and a large application suite.")
                },
                {
                    id: "xfce",
                    name: "XFCE",
                    description: qsTr("Lightweight and quick. A good fit for older machines.")
                },
                {
                    id: "mate",
                    name: "MATE",
                    description: qsTr("A classic, traditional desktop with modest resource use.")
                },
                {
                    id: "lxqt",
                    name: "LXQt",
                    description: qsTr("A very light Qt desktop that starts fast.")
                },
                {
                    id: "cinnamon",
                    name: "Cinnamon",
                    description: qsTr("A traditional panel and menu, developed alongside Mint.")
                }
            ]

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 6
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: radio.checked ? "#d70a53" : Kirigami.Theme.backgroundColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 12
                    spacing: Kirigami.Units.largeSpacing

                    RadioButton {
                        id: radio
                        property string choiceId: modelData.id
                        text: modelData.name
                        font.bold: true
                        font.pointSize: 12
                        Kirigami.Theme.highlightColor: "#d70a53"
                        Kirigami.Theme.textColor: Kirigami.Theme.textColor
                        ButtonGroup.group: group
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.description
                        wrapMode: Text.WordWrap
                        font.pointSize: 9
                        color: Kirigami.Theme.textColor
                    }
                }

                // The whole card is one click target.  It sits on top of
                // the radio button, whose own indicator does not get
                // mouse events of its own.
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        radio.checked = true
                        chooser.currentDe = radio.choiceId
                        chooser.publish()
                    }
                }
            }
        }

        // How much of the desktop to install.
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 6
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: fullRadio.checked || minimalRadio.checked ? "#d70a53" : Kirigami.Theme.backgroundColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: Kirigami.Units.largeSpacing * 2

                Text {
                    Layout.fillWidth: true
                    text: qsTr("How much of it?")
                    font.pointSize: 12
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }

                Item {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32

                    RadioButton {
                        id: fullRadio
                        property string choiceId: "full"
                        text: qsTr("Full")
                        font.pointSize: 12
                        Kirigami.Theme.highlightColor: "#d70a53"
                        Kirigami.Theme.textColor: Kirigami.Theme.textColor
                        ButtonGroup.group: profileGroup
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            fullRadio.checked = true
                            chooser.currentProfile = "full"
                            chooser.publish()
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32

                    RadioButton {
                        id: minimalRadio
                        property string choiceId: "minimal"
                        text: qsTr("Minimal")
                        font.pointSize: 12
                        Kirigami.Theme.highlightColor: "#d70a53"
                        Kirigami.Theme.textColor: Kirigami.Theme.textColor
                        ButtonGroup.group: profileGroup
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            minimalRadio.checked = true
                            chooser.currentProfile = "minimal"
                            chooser.publish()
                        }
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: qsTr("<b>Full</b> installs the desktop with its usual applications and tools.<br/>" +
                       "<b>Minimal</b> installs the desktop on its own — add the rest later with your package manager.")
            font.pointSize: 9
            color: Kirigami.Theme.textColor
        }
    }

    ButtonGroup {
        id: group
    }

    ButtonGroup {
        id: profileGroup
    }
}
