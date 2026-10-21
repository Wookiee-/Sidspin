/* === This file is part of Calamares - <http://github.com/calamares> ===
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Calamares is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Calamares.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 15000
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 620

            Text {
                width: parent.width
                text: qsTr("SidSpin")
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 32
                color: "#d70a53"
            }

            Text {
                width: parent.width
                text: qsTr("Debian sid, packaged as a live desktop.<br/>" +
                           "You are looking at a minimal KDE Plasma session.<br/><br/>" +
                           "Double-click the <b>Install SidSpin</b> icon on the desktop to copy this system to your disk. " +
                           "During the installation you get to pick the desktop you want to keep.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 11
                color: "#333333"
            }
        }
    }

    Slide {
        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 620

            Text {
                width: parent.width
                text: qsTr("Your data is safe")
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 24
                color: "#d70a53"
            }

            Text {
                width: parent.width
                text: qsTr("Nothing you do in the live session is written to your disk.<br/>" +
                           "The installer only touches the disk once you confirm the partitioning step, " +
                           "and you are asked to review everything before it starts.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 11
                color: "#333333"
            }
        }
    }
}
