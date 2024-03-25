import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0
// =============================================================================

Item {
	id: mainItem
	anchors.fill: parent
	
	property CallGui call
	property bool callTerminatedByUser: false
	readonly property var callState: call && call.core.state || undefined
	onCallStateChanged: if (callState === LinphoneEnums.CallState.End) {
							callTerminatedText.visible = true
						}else if( callState === LinphoneEnums.CallState.Error) {
							centerLayout.currentIndex = 1
						}
	
	Text {
		id: callTerminatedText
		visible: false
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 25 * DefaultStyle.dp
		text: mainItem.callTerminatedByUser ? qsTr("Vous avez terminé l'appel") : qsTr("Votre correspondant a terminé l'appel")
		color: DefaultStyle.grey_0
		z: 1
		font {
			pixelSize: 22 * DefaultStyle.dp
			weight: 300 * DefaultStyle.dp
		}
	}
	StackLayout {
		id: centerLayout
		currentIndex: 0
		anchors.fill: parent
		Loader{
			id: callLayout
			Layout.fillWidth: true
			Layout.fillHeight: true
			sourceComponent:ActiveSpeakerLayout{
				Layout.fillWidth: true
				Layout.fillHeight: true
				call: mainItem.call
			}
		}
		ColumnLayout {
			id: userNotFoundLayout
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: parent.height
			Layout.alignment: Qt.AlignCenter
			Text {
				text: qsTr(mainItem.call.core.lastErrorMessage)
				Layout.alignment: Qt.AlignCenter
				color: DefaultStyle.grey_0
				font.pixelSize: 40 * DefaultStyle.dp
			}
		}
	}
}
	/*
	Sticker {
		id: preview
		visible: mainItem.callState != LinphoneEnums.CallState.End
			&& mainItem.callState != LinphoneEnums.CallState.Released
		height: 180 * DefaultStyle.dp
		width: 300 * DefaultStyle.dp
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
		AccountProxy{
			id: accounts
		}
		account: accounts.defaultAccount
		previewEnabled: mainItem.call.core.cameraEnabled

		MovableMouseArea {
			id: previewMouseArea
			anchors.fill: parent
			// visible: mainItem.participantCount <= 2
			movableArea: mainItem
			margin: 10 * DefaultStyle.dp
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
				preview.anchors.rightMargin = previewMouseArea.margin
				preview.anchors.bottomMargin = previewMouseArea.margin
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging) {
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
	
	property int previousWidth
	Component.onCompleted: {
		previousWidth = width
	}
	onWidthChanged: {
		if (width < previousWidth) {
			previewMouseArea.updatePosition(0, 0)
		} else {
			previewMouseArea.updatePosition(width - previousWidth, 0)
		}
		previousWidth = width
	}*/

/*

Item {
	id: mainItem
	property CallModel callModel
	property bool isRightReducedLayout: false
	property bool isLeftReducedLayout: false
	property bool cameraEnabled: true
	property bool isConference: callModel && callModel.isConference
	property bool isConferenceReady: isConference && callModel.conferenceModel && callModel.conferenceModel.isReady
	
	property int participantCount: isConference ? allDevices.count + 1 : 2	// +me. allDevices==0 if !conference
	
	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: allDevices
			callModel: mainItem.callModel
			showMe: false		
			
			onConferenceCreated: cameraView.resetCamera()
		}
	
	Sticker{
		id: cameraView
		anchors.fill: parent
		anchors.leftMargin: isRightReducedLayout || isLeftReducedLayout? 30 : 140
		anchors.rightMargin: isRightReducedLayout ? 10 : 140
		cameraQmlName: 'AS'
		callModel: mainItem.callModel
		currentDevice: isPreview
							? allDevices.me
							: mainItem.isConference
								? allDevices.activeSpeaker
								: null
		deactivateCamera: !mainItem.cameraEnabled || (isPreview && callModel.pausedByUser)
							? true
							: mainItem.isConference
								?  (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused) )
									|| (!(callModel && callModel.cameraEnabled) && mainItem.participantCount == 1)
									|| (currentDevice && !currentDevice.videoEnabled)// && mainItem.participantCount == 2)
									|| !mainItem.isConferenceReady
								: (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused || !callModel.videoEnabled) )
									|| currentDevice && !currentDevice.videoEnabled
		isPreview: !preview.visible && mainItem.participantCount == 1
		onIsPreviewChanged: {cameraView.resetCamera() }
		isCameraFromDevice: isPreview
		isPaused: isPreview && callModel.pausedByUser
					? false
					: mainItem.isConference
						? //callModel && callModel.pausedByUser && mainItem.participantCount != 2 || 
							(currentDevice && currentDevice.isPaused)
						: callModel && !callModel.pausedByUser && (callModel.status === CallModel.CallStatusPaused)
		
		quickTransition: true
		showCloseButton: false
		showActiveSpeakerOverlay: false	// This is an active speaker. We don't need to show the indicator.
		showCustomButton:  false
		avatarStickerBackgroundColor: isPreview ?  IncallStyle.container.avatar.stickerPreviewBackgroundColor.color : IncallStyle.container.avatar.stickerBackgroundColor.color
		avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
	}
	Item{// Need an item to not override Sticker internal states. States are needed for changing anchors.
		id: preview
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.rightMargin: 30
		anchors.bottomMargin: 15
		
		height: visible ? miniViews.cellHeight : 0
		width: 16 * height / 9
		
		visible: mainItem.isConferenceReady && allDevices.count >= 1
				|| (!mainItem.isConference && mainItem.callModel && mainItem.callModel.cameraEnabled)// use videoEnabled if we want to show the preview sticker
		
		Loader{
			anchors.fill: parent
			anchors.margins: 3
			sourceComponent: 
			Sticker{
				id: previewSticker
				cameraQmlName: 'AS_Preview'
				deactivateCamera: !mainItem.cameraEnabled || !mainItem.callModel || callModel.pausedByUser || !mainItem.callModel.cameraEnabled
				currentDevice: allDevices.me
				isPreview: true
				callModel: mainItem.callModel
				isCameraFromDevice:  true
				showCloseButton: false
				showCustomButton:  false
				showAvatarBorder: true
				avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerPreviewBackgroundColor.color
				avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
			}
			active: parent.visible
		}
		
		MovableMouseArea{
			id: dragger
			anchors.fill: parent
			visible: mainItem.participantCount <= 2
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging){
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
	
	Item{
		id: miniViewArea
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: preview.top
		anchors.rightMargin: 30
		anchors.topMargin: 15
		anchors.bottomMargin: 0
//---------------
		width: 16 * miniViews.cellHeight / 9
		visible: mainItem.isConferenceReady || !mainItem.isConference
		property int heightLeft: parent.height - preview.height
		onHeightLeftChanged: {Qt.callLater(miniViewArea.forceRefresh)}
		function forceRefresh(){// Force a content refresh via margins. Qt is buggy when managing sizes in ListView.
			++miniViewArea.anchors.topMargin
			--miniViewArea.anchors.topMargin
		}
		
		ScrollableListView{
			id: miniViews
			property int cellHeight: 150
			anchors.fill: parent
			model : mainItem.isConference && mainItem.participantDevices.count > 1 ? mainItem.participantDevices : []
			spacing: 0
			verticalLayoutDirection: ListView.BottomToTop
			fitCacheToContent: false
			property int oldCount : 0// Count changed can be called without a change... (bug?). Use oldCount to avoid it.
			onCountChanged: {if(oldCount != count){ oldCount = count ; Qt.callLater(miniViewArea.forceRefresh)}}
			Component.onCompleted: {Qt.callLater(miniViewArea.forceRefresh)}
			delegate:Item{
					height: visible ? miniViews.cellHeight + 15 : 0
					width: visible ? miniViews.width : 0
					visible: cameraView.currentDevice != modelData
					clip:false
					Sticker{
						id: miniView
						anchors.fill: parent
						anchors.topMargin: 3
						anchors.leftMargin: 3
						anchors.rightMargin: 3
						anchors.bottomMargin: 18
						cameraQmlName: 'S_'+index
						deactivateCamera: (!mainItem.isConferenceReady || !mainItem.isConference)
											&& (index <0 || !mainItem.cameraEnabled || (!modelData.videoEnabled) || (callModel && callModel.pausedByUser) )
						currentDevice: modelData.isPreview ? null : modelData
						callModel: modelData.isPreview ? null : mainItem.callModel
						isCameraFromDevice:  mainItem.isConference
						isPaused: currentDevice && currentDevice.isPaused
						showCloseButton: false
						showCustomButton:  false
						showAvatarBorder: true
						avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerBackgroundColor.color
						avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
					}
				}
		}
	}
}
*/

