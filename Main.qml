//
// This file is part of SDDM Sugar Candy.
// A theme for the Simple Display Desktop Manager.
//
// Copyright (C) 2018–2020 Marian Arlt
//
// SDDM Sugar Candy is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or any later version.
//
// You are required to preserve this and any additional legal notices, either
// contained in this file or in other files that you received along with
// SDDM Sugar Candy that refer to the author(s) in accordance with
// sections §4, §5 and specifically §7b of the GNU General Public License.
//
// SDDM Sugar Candy is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SDDM Sugar Candy. If not, see <https://www.gnu.org/licenses/>
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtMultimedia 5.8
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import "Components"

Pane {
    id: root

    // height: config.ScreenHeight || Screen.height
    height: Screen.height
    // width: config.ScreenWidth || Screen.ScreenWidth
    width: Screen.ScreenWidth

    LayoutMirroring.enabled: config.ForceRightToLeft == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    padding: config.ScreenPadding
    palette.button: "transparent"
    palette.highlight: config.AccentColor
    palette.text: config.MainColor
    palette.buttonText: config.MainColor
    palette.window: config.BackgroundColor

    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80)
    focus: true

    property bool leftleft: config.HaveFormBackground == "true" &&
                            config.PartialBlur == "false" &&
                            config.FormPosition == "left" &&
                            config.BackgroundImageHAlignment == "left"

    property bool leftcenter: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "left" &&
                              config.BackgroundImageHAlignment == "center"

    property bool rightright: config.HaveFormBackground == "true" &&
                              config.PartialBlur == "false" &&
                              config.FormPosition == "right" &&
                              config.BackgroundImageHAlignment == "right"

    property bool rightcenter: config.HaveFormBackground == "true" &&
                               config.PartialBlur == "false" &&
                               config.FormPosition == "right" &&
                               config.BackgroundImageHAlignment == "center"

    // 读取背景图路径
    property string cfgBackground: config.Background

    // 判断背景类型
    // property string backgroundType: parseBackgroundType(cfgBackground)
    // property bool isImage: backgroundType === "image"
    // property bool isVideo: backgroundType === "video"
    property bool isImage: false
    property bool isVideo: true

    // 背景类型解析函数
    // function parseBackgroundType(img) {
    //     var vidFormats = ["avi", "mp4", "mov", "mkv", "m4v", "webm"]
    //     var fileExt = img.split('.').pop().toLowerCase()
    //     
    //     return vidFormats.indexOf(fileExt) >= 0 ? "video" : "image"
    // }
    Item {
        id: sizeHelper

        anchors.fill: parent
        height: parent.height
        width: parent.width

        // Background {
        //     id: mainFrameBackgroundImage
        //     anchors.fill: parent
        //     source: isImage ? cfgBackground : ""
        //     visible: isImage
        // }        // 动态渐变色

        Rectangle {
            id: mainFrameBackgroundVideo
            anchors.fill: parent
            height: root.height
            width: root.width
            visible: isVideo
            color: "#1b1b1b"

            MediaPlayer {
                id: previewPlayer
                source: cfgBackground
                onPositionChanged: { previewPlayer.pause() }
           }
            VideoOutput {
                anchors.fill: parent
                source: previewPlayer
                fillMode: VideoOutput.PreserveAspectCrop
            }
            MediaPlayer {
                id: videoPlayer
                source: cfgBackground
                autoPlay: true
                loops: MediaPlayer.Infinite
            }
            VideoOutput {
                id: videoOutput
                source: videoPlayer
                fillMode: VideoOutput.PreserveAspectCrop
                anchors.fill: parent
            }
        }
        LoginForm {
            id: form

            // height: virtualKeyboard.state == "visible" ? parent.height - virtualKeyboard.implicitHeight : parent.height / 2
            height: parent.height / 2
            width: parent.width / 2.5
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            // virtualKeyboardActive: virtualKeyboard.state == "visible" ? true : false
            z: 1
        }

        MouseArea {
            anchors.fill: mainFrameBackgroundVideo
            enabled: false
            onClicked: parent.forceActiveFocus()
        }

        GaussianBlur {
            id: blur
            visible: false

            height: parent.height
            width: config.FullBlur == "true" ? parent.width : form.width
            // source: config.FullBlur == "true" ? mainFrameBackgroundVideo : blurMask
            source: mainFrameBackgroundVideo
            radius: config.BlurRadius
            samples: config.BlurRadius * 2 + 1
            cached: true
            anchors.centerIn: config.FullBlur == "true" ? parent : form
            // visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
        }
    }
}
