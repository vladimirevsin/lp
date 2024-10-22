import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone 1.0
import UtilsCpp
import SettingsCpp
import LinphoneAccountsCpp

Item {
    id: callManager
    width: parent.width
    height: 100  // Или другой желаемый размер

    // Свойство для текущего выбранного контакта
    property FriendGui currentContact
    property CallGui call
    property var callState: call ? call.core.state : LinphoneEnums.CallState.Idle
    property var transferState: call && call.core.transferState
    property bool callTerminatedByUser: false

    // Доступ к ядру Linphone
    //property var core: Linphone.Core.instance

    // Свойство, указывающее, идет ли звонок
    //property bool callInProgress: core.calls.length > 0

    // Обработка изменений в состоянии звонков
    // Connections {
    //     target: core
    //     onCallStateChanged: {
    //         callInProgress = core.calls.length > 0
    //     }
    // }

    //Connections {
    //    enabled: !!call
    //    target: call && call.core

    //    onStateChanged: {
    //        callManager.callState = call.core.state
    //        callManager.handleCallStateChanged()
    //        Connections {
    //            enabled: !!call
    //            target: call && call.core
    //
    //            onStateChanged: {
    //                callManager.callState = call.core.state
    //                callManager.handleCallStateChanged()
    //            }
    //             onTransferStateChanged: {
    //                callManager.transferState = call.core.transferState
    //                callManager.handleTransferStateChanged()
    //            }
    //            function onSecurityUpdated() {
    //                if (call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
    //                    if (call.core.tokenVerified) {
    //                        zrtpValidation.close()
    //                        zrtpValidationToast.open()
    //                    } else {
    //                        zrtpValidation.open()
    //                    }
    //                } else {
    //                    zrtpValidation.close()
    //                }
    //            }
    //            function onTokenVerified() {
    //                if (!zrtpValidation.isTokenVerified) {
    //                    zrtpValidation.securityError = true
    //                } else zrtpValidation.close()
    //            }
    //
    //        }
    //    }
    //     onTransferStateChanged: {
    //        callManager.transferState = call.core.transferState
    //        callManager.handleTransferStateChanged()
    //    }
    //    function onSecurityUpdated() {
    //        if (call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
    //            if (call.core.tokenVerified) {
    //                zrtpValidation.close()
    //                zrtpValidationToast.open()
    //            } else {
    //                zrtpValidation.open()
    //            }
    //        } else {
    //            zrtpValidation.close()
    //        }
    //    }
    //    function onTokenVerified() {
    //        if (!zrtpValidation.isTokenVerified) {
    //            zrtpValidation.securityError = true
    //        } else zrtpValidation.close()
    //    }

    //}

    // Вызываем или завершаем звонок в зависимости от состояния
    function callCurrentContact() {
        if (callManager.callState !== LinphoneEnums.CallState.Idle) {
            // Завершаем текущий звонок
            if (call) {
                call.lTerminate()
            }
        } else {
            if (currentContact) {
                UtilsCpp.createCall(currentContact.core.defaultAddress)
            } else {
                console.log("Нет выбранного контакта для звонка")
            }
        }
    }

    // Удержание или возобновление звонка
    // function toggleHold() {
    //     var call = core.currentCall
    //     if (call) {
    //         if (call.state === Linphone.CallState.Paused) {
    //             call.resume()
    //         } else {
    //             call.pause()
    //         }
    //     }
    // }

    // // Трансфер звонка
    // function transferCall() {
    //     var call = core.currentCall
    //     if (call && currentContact) {
    //         call.transfer(currentContact.core.defaultAddress)
    //     } else {
    //         console.log("Нет активного звонка или выбранного контакта для трансфера")
    //     }
    // }

    // Кнопки управления
    RowLayout {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width

        // // Кнопка удержания звонка
        // Button {
        //     visible: callManager.callInProgress
        //     icon.source: core.currentCall && core.currentCall.state === Linphone.CallState.Paused ? AppIcons.play : AppIcons.pause
        //     Layout.preferredWidth: 55 * DefaultStyle.dp
        //     Layout.preferredHeight: 55 * DefaultStyle.dp
        //     icon.width: 32 * DefaultStyle.dp
        //     icon.height: 32 * DefaultStyle.dp
        //     background: Rectangle {
        //         color: "orange"
        //         radius: 8
        //     }
        //     onClicked: {
        //         callManager.toggleHold()
        //     }
        // }

        // // Кнопка трансфера звонка
        // Button {
        //     visible: callManager.callInProgress
        //     icon.source: AppIcons.transfer
        //     Layout.preferredWidth: 55 * DefaultStyle.dp
        //     Layout.preferredHeight: 55 * DefaultStyle.dp
        //     icon.width: 32 * DefaultStyle.dp
        //     icon.height: 32 * DefaultStyle.dp
        //     background: Rectangle {
        //         color: "blue"
        //         radius: 8
        //     }
        //     onClicked: {
        //         callManager.transferCall()
        //     }
        // }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width

        // Кнопка вызова
        Button {
            icon.source: AppIcons.newCall
            icon.width: 32 * DefaultStyle.dp
            icon.height: 32 * DefaultStyle.dp
            height: 54 * DefaultStyle.dp
            width: parent.width
            background: Rectangle {
                color: callState === LinphoneEnums.CallState.Idle ? "green" : "red"
                radius: 8
            }

            onClicked: {
                callManager.callCurrentContact()
            }
        }
    }
}
