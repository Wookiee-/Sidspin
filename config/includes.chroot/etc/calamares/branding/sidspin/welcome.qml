/* === This file is part of SidSpin - <https://github.com/Wookiee-/Sidspin> ===
 *
 *   SPDX-FileCopyrightText: 2026 SidSpin contributors
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Based on the welcomeq module of Calamares
 *   (src/modules/welcomeq/welcomeq-qt6.qml), Copyright 2020 Adriaan de Groot
 *   and Anke Boersma, licensed GPL-3.0-or-later.
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
import QtQuick.Window

import org.kde.kirigami as Kirigami

Page
{
    id: welcome

    header: Item {
        width: parent.width
        height: parent.height

        Text {
            id: welcomeTopText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            horizontalAlignment: Text.AlignHCenter
            padding: 20
            text: qsTr("<h3>Welcome to %1</h3>").arg( Branding.string( Branding.ProductName ) )
            color: Kirigami.Theme.textColor
        }

        Text {
            id: welcomeSubText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: welcomeTopText.bottom
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: qsTr("<p>%1 is a live image of Debian sid with a minimal KDE Plasma desktop.<br/>" +
                       "You are still in the live session now: nothing has been written to your disk yet.</p>")
                .arg( Branding.string( Branding.ProductName ) )
            color: Kirigami.Theme.textColor
        }

        // The three things the user is about to do, in order.
        RowLayout {
            id: steps
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: welcomeSubText.bottom
            anchors.topMargin: 18
            spacing: Kirigami.Units.largeSpacing * 2

            Repeater {
                model: [
                    { title: qsTr("Language"), text: qsTr("Pick your language, your keyboard layout and your user account.") },
                    { title: qsTr("Disk"), text: qsTr("Erase a disk, shrink one to make room, or lay out the partitions yourself.") },
                    { title: qsTr("Desktop"), text: qsTr("Choose the desktop you want to keep on the installed system.") }
                ]

                ColumnLayout {
                    Layout.preferredWidth: 180
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: width / 2
                        color: "#d70a53"

                        Text {
                            anchors.centerIn: parent
                            text: model.index + 1
                            color: "white"
                            font.pointSize: 15
                            font.bold: true
                        }
                    }

                    Text {
                        text: modelData.title
                        font.pointSize: 13
                        font.bold: true
                        color: Kirigami.Theme.textColor
                    }

                    Text {
                        Layout.preferredWidth: 180
                        text: modelData.text
                        wrapMode: Text.WordWrap
                        font.pointSize: 10
                        color: Kirigami.Theme.textColor
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: steps.bottom
            anchors.topMargin: 16
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Your disk is only touched after you have confirmed the summary.")
            font.pointSize: 10
            color: Kirigami.Theme.textColor
        }

        Requirements {
            visible: !config.requirementsModel.satisfiedRequirements
        }

        RowLayout {
            id: buttonBar
            width: parent.width / 1.5
            height: 64

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: Kirigami.Units.largeSpacing * 2

            Button {
                Layout.fillWidth: true
                text: qsTr("Support")
                icon.name: "system-help"
                Kirigami.Theme.backgroundColor: Qt.rgba( Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.4 )
                Kirigami.Theme.textColor: Kirigami.Theme.textColor

                visible: config.supportUrl !== ""
                onClicked: Qt.openUrlExternally( config.supportUrl )
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Known Issues")
                icon.name: "tools-report-bug"
                Kirigami.Theme.backgroundColor: Qt.rgba( Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.4 )
                Kirigami.Theme.textColor: Kirigami.Theme.textColor

                visible: config.knownIssuesUrl !== ""
                onClicked: Qt.openUrlExternally( config.knownIssuesUrl )
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Release Notes")
                icon.name: "folder-text"
                Kirigami.Theme.backgroundColor: Qt.rgba( Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.4 )
                Kirigami.Theme.textColor: Kirigami.Theme.textColor

                visible: config.releaseNotesUrl !== ""
                onClicked: Qt.openUrlExternally( config.releaseNotesUrl )
            }
        }

        RowLayout {
            id: languageBar
            width: parent.width / 1.2
            height: 48

            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height / 7
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Kirigami.Units.largeSpacing * 4

            Rectangle {
                width: parent.width
                Layout.fillWidth: true
                focus: true

                Loader {
                    id: imLoader

                    Component {
                        id: icon
                        Kirigami.Icon {
                            source: config.languageIcon
                            height: 48
                            width: 48
                        }
                    }

                    Component {
                        id: image
                        Image {
                            height: 48
                            fillMode: Image.PreserveAspectFit
                            source: "img/language-icon-48px.png"
                        }
                    }

                    sourceComponent: ( config.languageIcon != "" ) ? icon : image
                }

                ComboBox {
                    id: languages
                    anchors.left: imLoader.right
                    width: languageBar.width / 1.1
                    textRole: "label"
                    currentIndex: config.localeIndex
                    model: config.languagesModel
                    onCurrentIndexChanged: config.localeIndex = currentIndex
                }
            }
        }
    }
}
