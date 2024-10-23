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

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.ScreenWidth

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

        Rectangle {
            id: tintLayer
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: "black"
            opacity: config.DimBackgroundImage
            z: 1
        }

        Rectangle {
            id: formBackground
            anchors.fill: form
            anchors.centerIn: form
            color: root.palette.window
            visible: config.HaveFormBackground == "true" ? true : false
            opacity: config.PartialBlur == "true" ? 0.3 : 1
            z: 1
        }
        Background {
            id: mainFrameBackgroundImage
            anchors.fill: parent
            source: isImage ? cfgBackground : ""
            visible: isImage
        }

        Rectangle {
            id: mainFrameBackgroundVideo
            anchors.fill: parent
            visible: isVideo
            color: "black"
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
            // // 加载遮罩层
            // Rectangle {
            //     id: loadingMask
            //     anchors.fill: parent
            //     color: "black"
            //     opacity: 1  // 初始为完全可见
            //     z: 10  // 确保遮罩层在上层
            // }
            //
            // // 定时器
            // Timer {
            //     id: loadingTimer
            //     interval: 1000  // 设置遮罩显示时间（毫秒）
            //     running: false  // 初始为不运行
            //     repeat: false   // 不重复
            //     onTriggered: {
            //         loadingMask.opacity = 0;  // 隐藏遮罩
            //         loadingMask.visible = false
            //         loadingTimer.stop();       // 停止定时器
            //     }
            // }
        }

        LoginForm {
            id: form

            height: virtualKeyboard.state == "visible" ? parent.height - virtualKeyboard.implicitHeight : parent.height
            width: parent.width / 2.5
            anchors.horizontalCenter: config.FormPosition == "center" ? parent.horizontalCenter : undefined
            anchors.left: config.FormPosition == "left" ? parent.left : undefined
            anchors.right: config.FormPosition == "right" ? parent.right : undefined
            virtualKeyboardActive: virtualKeyboard.state == "visible" ? true : false
            z: 1
        }

        Button {
            id: vkb
            onClicked: virtualKeyboard.switchState()
            visible: virtualKeyboard.status == Loader.Ready && config.ForceHideVirtualKeyboardButton == "false"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: implicitHeight
            anchors.horizontalCenter: form.horizontalCenter
            z: 1
            // contentItem: Text {
            //     text: config.TranslateVirtualKeyboardButton || "Virtual Keyboard"
            //     color: parent.visualFocus ? palette.highlight : palette.text
            //     font.pointSize: root.font.pointSize * 0.8
            // }
            // background: Rectangle {
            //     id: vkbbg
            //     color: "transparent"
            // }
        }

        Loader {
            id: virtualKeyboard
            source: "Components/VirtualKeyboard.qml"
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: keyboardActive ? state = "visible" : state = "hidden"
            width: parent.width
            z: 1
            function switchState() { state = state == "hidden" ? "visible" : "hidden" }
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: form
                        systemButtonVisibility: false
                        clockVisibility: false
                    }
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - virtualKeyboard.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: virtualKeyboard
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                virtualKeyboard.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: virtualKeyboard
                                property: "y"
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: virtualKeyboard
                                duration: 100
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }
        // 使用背景图或背景视频
        // Image {
        //     id: backgroundImage
        //
        //     height: parent.height
        //     width: config.HaveFormBackground == "true" && config.FormPosition != "center" && config.PartialBlur != "true" ? parent.width - formBackground.width : parent.width
        //     anchors.left: leftleft ||
        //                   leftcenter ?
        //                         formBackground.right : undefined
        //
        //     anchors.right: rightright ||
        //                    rightcenter ?
        //                         formBackground.left : undefined
        //
        //     horizontalAlignment: config.BackgroundImageHAlignment == "left" ?
        //                          Image.AlignLeft :
        //                          config.BackgroundImageHAlignment == "right" ?
        //                          Image.AlignRight : Image.AlignHCenter
        //
        //     verticalAlignment: config.BackgroundImageVAlignment == "top" ?
        //                        Image.AlignTop :
        //                        config.BackgroundImageVAlignment == "bottom" ?
        //                        Image.AlignBottom : Image.AlignVCenter
        //
        //     source: config.background || config.Background
        //     fillMode: config.ScaleImageCropped == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
        //     asynchronous: true
        //     cache: true
        //     clip: true
        //     mipmap: true
        // }

        MouseArea {
            anchors.fill: mainFrameBackgroundVideo
            onClicked: parent.forceActiveFocus()
        }

        ShaderEffectSource {
            id: blurMask

            sourceItem: mainFrameBackgroundVideo
            width: form.width
            height: parent.height
            anchors.centerIn: form
            sourceRect: Qt.rect(x,y,width,height)
            visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
        }

        GaussianBlur {
            id: blur

            height: parent.height
            width: config.FullBlur == "true" ? parent.width : form.width
            source: config.FullBlur == "true" ? mainFrameBackgroundVideo : blurMask
            radius: config.BlurRadius
            samples: config.BlurRadius * 2 + 1
            cached: true
            anchors.centerIn: config.FullBlur == "true" ? parent : form
            visible: config.FullBlur == "true" || config.PartialBlur == "true" ? true : false
        }
    }
}
