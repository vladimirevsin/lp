/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "CallModel.hpp"

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(CallModel)

CallModel::CallModel(const std::shared_ptr<linphone::Call> &call, QObject *parent)
    : ::Listener<linphone::Call, linphone::CallListener>(call, parent) {
	qDebug() << "[CallModel] new" << this;
	mustBeInLinphoneThread(getClassName());
	mDurationTimer.setInterval(1000);
	mDurationTimer.setSingleShot(false);
	connect(&mDurationTimer, &QTimer::timeout, this, [this]() { this->durationChanged(mMonitor->getDuration()); });
	mDurationTimer.start();

	mMicroVolumeTimer.setInterval(50);
	mMicroVolumeTimer.setSingleShot(false);
	connect(&mMicroVolumeTimer, &QTimer::timeout, this,
	        [this]() { this->microphoneVolumeChanged(Utils::computeVu(mMonitor->getRecordVolume())); });
	mMicroVolumeTimer.start();

	connect(this, &CallModel::stateChanged, this, [this] {
		auto state = mMonitor->getState();
		if (state == linphone::Call::State::Paused) setPaused(true);
	});
}

CallModel::~CallModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void CallModel::accept(bool withVideo) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto params = core->createCallParams(mMonitor);
	params->enableVideo(withVideo);
	params->setRecordFile(
	    Paths::getCapturesDirPath()
	        .append(Utils::generateSavedFilename(QString::fromStdString(mMonitor->getToAddress()->getUsername()), ""))
	        .append(".mkv")
	        .toStdString());
	mMonitor->enableCamera(withVideo);
	// Answer with local call address.
	auto localAddress = mMonitor->getCallLog()->getLocalAddress();
	for (auto account : core->getAccountList()) {
		if (account->getParams()->getIdentityAddress()->weakEqual(localAddress)) {
			params->setAccount(account);
			break;
		}
	}
	mMonitor->acceptWithParams(params);
	emit cameraEnabledChanged(withVideo);
}

void CallModel::decline() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto errorInfo = linphone::Factory::get()->createErrorInfo();
	errorInfo->set("SIP", linphone::Reason::Declined, 603, "Decline", "");
	mMonitor->terminateWithErrorInfo(errorInfo);
}

void CallModel::terminate() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->terminate();
}
void CallModel::setPaused(bool paused) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (paused) {
		auto status = mMonitor->pause();
		if (status != -1) emit pausedChanged(paused);
	} else {
		auto status = mMonitor->resume();
		if (status != -1) emit pausedChanged(paused);
	}
}

void CallModel::transferTo(const std::shared_ptr<linphone::Address> &address) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mMonitor->transferTo(address) == -1)
		qWarning() << log()
		                  .arg(QStringLiteral("Unable to transfer: `%1`."))
		                  .arg(Utils::coreStringToAppString(address->asStringUriOnly()));
}

void CallModel::terminateAllCalls() {
	auto status = mMonitor->getCore()->terminateAllCalls();
}

void CallModel::setMicrophoneMuted(bool isMuted) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setMicrophoneMuted(isMuted);
	emit microphoneMutedChanged(isMuted);
}

void CallModel::setSpeakerMuted(bool isMuted) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setSpeakerMuted(isMuted);
	emit speakerMutedChanged(isMuted);
}

void CallModel::setCameraEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	// mMonitor->enableCamera(enabled);
	auto params = CoreModel::getInstance()->getCore()->createCallParams(mMonitor);
	params->enableVideo(true);
	auto direction = mMonitor->getCurrentParams()->getVideoDirection();
	auto videoDirection = linphone::MediaDirection::RecvOnly;
	if (enabled) { // +Send
		switch (direction) {
			case linphone::MediaDirection::RecvOnly:
				videoDirection = linphone::MediaDirection::SendRecv;
				break;
			case linphone::MediaDirection::SendOnly:
				videoDirection = linphone::MediaDirection::SendOnly;
				break;
			case linphone::MediaDirection::SendRecv:
				videoDirection = linphone::MediaDirection::SendRecv;
				break;
			default:
				videoDirection = linphone::MediaDirection::SendOnly;
		}
	} else { // -Send
		switch (direction) {
			case linphone::MediaDirection::RecvOnly:
				videoDirection = linphone::MediaDirection::RecvOnly;
				break;
			case linphone::MediaDirection::SendOnly:
				videoDirection = linphone::MediaDirection::Inactive;
				break;
			case linphone::MediaDirection::SendRecv:
				videoDirection = linphone::MediaDirection::RecvOnly;
				break;
			default:
				videoDirection = linphone::MediaDirection::Inactive;
		}
	}
	/*
	auto videoDirection =
	    !enabled ? linphone::MediaDirection::RecvOnly
	    : direction == linphone::MediaDirection::RecvOnly //
	        ? linphone::MediaDirection::SendRecv
	        : direction == linphone::MediaDirection::SendRecv || direction == linphone::MediaDirection::SendOnly
	              ? linphone::MediaDirection::RecvOnly
	              : linphone::MediaDirection::SendOnly;
	              */
	params->setVideoDirection(videoDirection);
	mMonitor->update(params);
}

void CallModel::startRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->startRecording();
	emit recordingChanged(mMonitor->getParams()->isRecording());
}

void CallModel::stopRecording() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->stopRecording();
	emit recordingChanged(mMonitor->getParams()->isRecording());
	// TODO : display notification
}

void CallModel::setRecordFile(const std::string &path) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	auto params = core->createCallParams(mMonitor);
	params->setRecordFile(path);
	mMonitor->update(params);
}

void CallModel::setSpeakerVolumeGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setSpeakerVolumeGain(gain);
	emit speakerVolumeGainChanged(gain);
}

float CallModel::getSpeakerVolumeGain() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto gain = mMonitor->getSpeakerVolumeGain();
	if (gain < 0) gain = CoreModel::getInstance()->getCore()->getPlaybackGainDb();
	return gain;
}

void CallModel::setMicrophoneVolumeGain(float gain) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setMicrophoneVolumeGain(gain);
	emit microphoneVolumeGainChanged(gain);
}

float CallModel::getMicrophoneVolumeGain() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto gain = mMonitor->getMicrophoneVolumeGain();
	return gain;
}

float CallModel::getMicrophoneVolume() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto volume = mMonitor->getRecordVolume();
	return volume;
}

void CallModel::setInputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setInputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit inputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> CallModel::getInputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getInputAudioDevice();
}

void CallModel::setOutputAudioDevice(const std::shared_ptr<linphone::AudioDevice> &device) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setOutputAudioDevice(device);
	std::string deviceName;
	if (device) deviceName = device->getDeviceName();
	emit outputAudioDeviceChanged(deviceName);
}

std::shared_ptr<const linphone::AudioDevice> CallModel::getOutputAudioDevice() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getOutputAudioDevice();
}

std::string CallModel::getRecordFile() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getParams()->getRecordFile();
}

std::shared_ptr<const linphone::Address> CallModel::getRemoteAddress() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getRemoteAddress();
}

bool CallModel::getAuthenticationTokenVerified() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getAuthenticationTokenVerified();
}

void CallModel::setAuthenticationTokenVerified(bool verified) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setAuthenticationTokenVerified(verified);
	emit authenticationTokenVerifiedChanged(verified);
}

std::string CallModel::getAuthenticationToken() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto token = mMonitor->getAuthenticationToken();
	return token;
}

void CallModel::setConference(const std::shared_ptr<linphone::Conference> &conference) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (mConference != conference) {
		mConference = conference;
		emit conferenceChanged();
	}
}

LinphoneEnums::ConferenceLayout CallModel::getConferenceVideoLayout() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return LinphoneEnums::fromLinphone(mMonitor->getParams()->getConferenceVideoLayout());
}

void CallModel::changeConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto coreManager = CoreModel::getInstance();

	//	if (layout == LinphoneEnums::ConferenceLayout::Grid)
	//		coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getGridCameraMode());
	//	else
	// coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getActiveSpeakerCameraMode());
	auto params = coreManager->getCore()->createCallParams(mMonitor);
	params->setConferenceVideoLayout(LinphoneEnums::toLinphone(layout));
	params->enableVideo(layout != LinphoneEnums::ConferenceLayout::AudioOnly);
	if (!params->videoEnabled() && params->screenSharingEnabled()) {
		params->enableScreenSharing(false); // Deactivate screensharing if going to audio only.
	}
	mMonitor->update(params);
}

void CallModel::updateConferenceVideoLayout() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto callParams = mMonitor->getParams();
	//	auto settings = CoreManager::getInstance()->getSettingsModel();
	auto newLayout = LinphoneEnums::fromLinphone(callParams->getConferenceVideoLayout());
	if (!callParams->videoEnabled()) newLayout = LinphoneEnums::ConferenceLayout::AudioOnly;
	if (mConferenceVideoLayout != newLayout) { // && !getPausedByUser()) { // Only update if not in pause.
		                                       //		if (mMonitor->getConference()) {
		//			if (callParams->getConferenceVideoLayout() == linphone::Conference::Layout::Grid)
		//				settings->setCameraMode(settings->getGridCameraMode());
		//			else settings->setCameraMode(settings->getActiveSpeakerCameraMode());
		//		} else settings->setCameraMode(settings->getCallCameraMode());
		qDebug() << "Changing layout from " << mConferenceVideoLayout << " into " << newLayout;
		mConferenceVideoLayout = newLayout;
		emit conferenceVideoLayoutChanged(mConferenceVideoLayout);
	}
}

void CallModel::onDtmfReceived(const std::shared_ptr<linphone::Call> &call, int dtmf) {
	emit dtmfReceived(call, dtmf);
}

void CallModel::onGoclearAckSent(const std::shared_ptr<linphone::Call> &call) {
	emit goclearAckSent(call);
}

void CallModel::onEncryptionChanged(const std::shared_ptr<linphone::Call> &call,
                                    bool on,
                                    const std::string &authenticationToken) {
	emit encryptionChanged(call, on, authenticationToken);
}

void CallModel::onSendMasterKeyChanged(const std::shared_ptr<linphone::Call> &call, const std::string &sendMasterKey) {
	emit sendMasterKeyChanged(call, sendMasterKey);
}

void CallModel::onReceiveMasterKeyChanged(const std::shared_ptr<linphone::Call> &call,
                                          const std::string &receiveMasterKey) {
	emit receiveMasterKeyChanged(call, receiveMasterKey);
}

void CallModel::onInfoMessageReceived(const std::shared_ptr<linphone::Call> &call,
                                      const std::shared_ptr<const linphone::InfoMessage> &message) {
	emit infoMessageReceived(call, message);
}

void CallModel::onStateChanged(const std::shared_ptr<linphone::Call> &call,
                               linphone::Call::State state,
                               const std::string &message) {
	qDebug() << "CallModel::onStateChanged" << (int)state;
	if (state == linphone::Call::State::StreamsRunning) {
		// After UpdatedByRemote, video direction could be changed.
		auto params = call->getRemoteParams();
		emit remoteVideoEnabledChanged(params && params->videoEnabled());
		qWarning() << "CallCameraEnabled:" << call->cameraEnabled();
		auto videoDirection = call->getCurrentParams()->getVideoDirection();
		emit cameraEnabledChanged(videoDirection == linphone::MediaDirection::SendOnly ||
		                          videoDirection == linphone::MediaDirection::SendRecv);
		// emit cameraEnabledChanged(call->cameraEnabled());
		setConference(call->getConference());
		updateConferenceVideoLayout();
	}
	emit stateChanged(state, message);
}

void CallModel::onStatusChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Status status) {
	qDebug() << "CallModel::onStatusChanged" << (int)status;
	emit statusChanged(status);
}

void CallModel::onDirChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::Dir dir) {
	emit dirChanged(dir);
}

void CallModel::onStatsUpdated(const std::shared_ptr<linphone::Call> &call,
                               const std::shared_ptr<const linphone::CallStats> &stats) {
	emit statsUpdated(call, stats);
}

void CallModel::onTransferStateChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) {
	emit transferStateChanged(call, state);
}

void CallModel::onAckProcessing(const std::shared_ptr<linphone::Call> &call,
                                const std::shared_ptr<linphone::Headers> &ack,
                                bool isReceived) {
	emit ackProcessing(call, ack, isReceived);
}

void CallModel::onTmmbrReceived(const std::shared_ptr<linphone::Call> &call, int streamIndex, int tmmbr) {
	emit tmmbrReceived(call, streamIndex, tmmbr);
}

void CallModel::onSnapshotTaken(const std::shared_ptr<linphone::Call> &call, const std::string &filePath) {
	emit snapshotTaken(call, filePath);
}

void CallModel::onNextVideoFrameDecoded(const std::shared_ptr<linphone::Call> &call) {
	emit nextVideoFrameDecoded(call);
}

void CallModel::onCameraNotWorking(const std::shared_ptr<linphone::Call> &call, const std::string &cameraName) {
	emit cameraNotWorking(call, cameraName);
}

void CallModel::onVideoDisplayErrorOccurred(const std::shared_ptr<linphone::Call> &call, int errorCode) {
	emit videoDisplayErrorOccurred(call, errorCode);
}

void CallModel::onAudioDeviceChanged(const std::shared_ptr<linphone::Call> &call,
                                     const std::shared_ptr<linphone::AudioDevice> &audioDevice) {
	emit audioDeviceChanged(call, audioDevice);
}

void CallModel::onRemoteRecording(const std::shared_ptr<linphone::Call> &call, bool recording) {
	emit remoteRecording(call, recording);
}
