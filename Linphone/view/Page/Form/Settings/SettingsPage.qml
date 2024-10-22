import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp

AbstractSettingsMenu {
    layoutsPath: "qrc:/Linphone/view/Page/Layout/Settings"
    titleText: qsTr("Настройки")
    families: [
        {title: qsTr("Звонки"), layout: "CallSettingsLayout"},
        //{title: qsTr("Безопасность"), layout: "SecuritySettingsLayout"},
        {title: qsTr("Чаты"), layout: "ChatSettingsLayout", visible: !SettingsCpp.disableChatFeature},
        {title: qsTr("Контакты"), layout: "ContactsSettingsLayout"},
        {title: qsTr("Встречи"), layout: "MeetingsSettingsLayout", visible: !SettingsCpp.disableMeetingsFeature},
        {title: qsTr("Отображение"), layout: "DisplaySettingsLayout"},
        {title: qsTr("Сеть"), layout: "NetworkSettingsLayout"},
        {title: qsTr("Расширенные настройки"), layout: "AdvancedSettingsLayout"}
    ]
}
