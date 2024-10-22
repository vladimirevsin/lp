import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
import LinphoneAccountsCpp

Item {
    id: callManager
    width: parent.width
    height: 100

    property FriendGui currentContact
    property var call;
    property var callState: call ? call.core.state : LinphoneEnums.CallState.Idle
    property bool callInProgres: false
    property var transferState: call ? call.core.transferState : null
    property bool callTerminatedByUser: false

    function getColorCallButton() {
        if (callManager.callInProgres) {
            return "red";
        }

        return "green";

        //switch (callState) {
        //    case 0:
        //    case 19:
        //        return "green";
        //    default:
        //        return "red";
        //}
    }

   CallProxy{
        id: callsModel
        onCurrentCallChanged: {
            if(currentCall) {
                callManager.call = currentCall

                currentCall.core.stateChanged.connect(function(newState) {
                    callManager.callInProgres = newState !== LinphoneEnums.CallState.Idle && newState !== LinphoneEnums.CallState.Released
                    callManager.callState = newState;
                });
            }
        }
        onHaveCallChanged: {
            if (!haveCall) {
                callManager.endCall()
            }
        }
    }

    onCallStateChanged: {
        //UtilsCpp.showInformationPopup("State Changed", currentCall.core.state, false);
    }

    Connections {
        enabled: !!call
        target: call && call.core
        function onSecurityUpdated() {
            if (call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
                if (call.core.tokenVerified) {
                    zrtpValidation.close()
                    zrtpValidationToast.open()
                } else {
                    zrtpValidation.open()
                }
            } else {
                zrtpValidation.close()
            }
        }
        function onTokenVerified() {
            if (!zrtpValidation.isTokenVerified) {
                zrtpValidation.securityError = true
            } else zrtpValidation.close()
        }
    }

    function callCurrentContact() {
        if (callManager.callInProgress) {
            if (call) {
                call.core.lTerminate()
            }
        } else {
            if (currentContact) {
                UtilsCpp.createCall(currentContact.core.defaultAddress)
            } else {
                console.log("Нет выбранного контакта для звонка")
            }
        }
    }

    RowLayout {
        Text {
            text: qsTr("state: %1").arg(callState)
        }
    }


    // Удержание или возобновление звонка
    function toggleHold() {
        if (callManager.call) {
            if (callManager.callState === LinphoneEnums.CallState.Paused) {
                callManager.call.core.lSetPaused(false)
            } else {
                callManager.call.core.lSetPaused(true)
            }
        }
    }

    // Трансфер звонка
    function transferCallToContact() {
        if (currentContact)
            call.core.lTransferCall(currentContact.core.defaultAddress)
    }


    RowLayout {
        anchors.centerIn: parent
        spacing: 20



        // // Кнопка трансфера звонка
    }

    // Кнопки управления
    RowLayout {
        anchors.centerIn: parent
        spacing: 20

        // Кнопка удержания звонка
        Button {
            visible: callManager.callInProgress
            icon.source: callManager.callState === LinphoneEnums.CallState.Paused ? AppIcons.play : AppIcons.pause
            Layout.preferredWidth: 55 * DefaultStyle.dp
            Layout.preferredHeight: 55 * DefaultStyle.dp
            icon.width: 32 * DefaultStyle.dp
            icon.height: 32 * DefaultStyle.dp
            background: Rectangle {
                radius: 8
            }
            onClicked: {
                callManager.toggleHold()
            }
        }

        // Кнопка трансфера звонка
        Button {
            visible: callManager.callInProgress
            icon.source: AppIcons.transferCall
            Layout.preferredWidth: 55 * DefaultStyle.dp
            Layout.preferredHeight: 55 * DefaultStyle.dp
            icon.width: 32 * DefaultStyle.dp
            icon.height: 32 * DefaultStyle.dp
            background: Rectangle {
                color: "blue"
                radius: 8
            }
            onClicked: {
                callManager.transferCallToContact()
            }
        }

        // Кнопка вызова/завершения звонка
        Button {
            icon.source: AppIcons.newCall
            Layout.preferredWidth: 55 * DefaultStyle.dp
            Layout.preferredHeight: 55 * DefaultStyle.dp
            icon.width: 32 * DefaultStyle.dp
            icon.height: 32 * DefaultStyle.dp
            background: Rectangle {
                color: getColorCallButton()
                radius: 8
            }
            onClicked: {
                callManager.callCurrentContact()
            }
        }
    }
}
