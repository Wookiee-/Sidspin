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

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: Kirigami.Units.largeSpacing

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Which desktop do you want?")
            font.pointSize: 18
            font.bold: true
            color: Kirigami.Theme.textColor
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            text: qsTr("It is downloaded from the Debian archive during the installation.")
            font.pointSize: 11
            color: Kirigami.Theme.textColor
        }

        ButtonGroup {
            id: group
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
                implicitHeight: 58
                radius: 6
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: radio.checked ? "#d70a53" : Kirigami.Theme.backgroundColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: Kirigami.Units.largeSpacing

                    RadioButton {
                        id: radio
                        checked: modelData.id === "kde-plasma"
                        ButtonGroup.group: group
                        onClicked: config.packageChoice = modelData.id

                        contentItem: Text {
                            text: radio.text
                            font.pointSize: 13
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            leftPadding: radio.indicator.width + 6
                            verticalAlignment: Text.AlignVCenter
                        }

                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            x: 0
                            y: radio.topPadding + radio.availableHeight / 2 - height / 2
                            radius: width / 2
                            color: radio.checked ? "#d70a53" : "transparent"
                            border.width: 2
                            border.color: radio.checked ? "#d70a53" : "#9a9a9a"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 7
                                height: 7
                                radius: width / 2
                                color: "white"
                                visible: radio.checked
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            text: modelData.name
                            font.pointSize: 13
                            font.bold: true
                            color: Kirigami.Theme.textColor
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.description
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            color: Kirigami.Theme.textColor
                        }
                    }
                }
            }
        }
    }
}
