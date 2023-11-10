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

#ifndef CALL_H_
#define CALL_H_

#include "model/call/CallModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class Call : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(LinphoneEnums::CallStatus status READ getStatus NOTIFY statusChanged)
	Q_PROPERTY(LinphoneEnums::CallState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QString lastErrorMessage READ getLastErrorMessage NOTIFY lastErrorMessageChanged)

public:
	// Should be call from model Thread. Will be automatically in App thread after initialization
	Call(const std::shared_ptr<linphone::Call> &call);
	~Call();

	LinphoneEnums::CallStatus getStatus() const;
	void setStatus(LinphoneEnums::CallStatus status);

	LinphoneEnums::CallState getState() const;
	void setState(LinphoneEnums::CallState state, const QString &message);
	void onStateChanged(linphone::Call::State state, const std::string &message);

	QString getLastErrorMessage() const;
	void setLastErrorMessage(const QString &message);

signals:
	void statusChanged(LinphoneEnums::CallStatus status);
	void stateChanged(LinphoneEnums::CallState state);
	void lastErrorMessageChanged();

	// Linphone commands
	void lAccept(bool withVideo); // Accept an incoming call
	void lDecline();              // Decline an incoming call
	void lTerminate();            // Hangup a call
	                              /* TODO
	                                  Q_INVOKABLE void acceptWithVideo();
	                          
	                                  Q_INVOKABLE void askForTransfer();
	                                  Q_INVOKABLE void askForAttendedTransfer();
	                                  Q_INVOKABLE bool transferTo(const QString &sipAddress);
	                                  Q_INVOKABLE bool transferToAnother(const QString &peerAddress);
	                          
	                                  Q_INVOKABLE bool getRemoteVideoEnabled() const;
	                                  Q_INVOKABLE void acceptVideoRequest();
	                                  Q_INVOKABLE void rejectVideoRequest();
	                          
	                                  Q_INVOKABLE void takeSnapshot();
	                                  Q_INVOKABLE void startRecording();
	                                  Q_INVOKABLE void stopRecording();
	                          
	                                  Q_INVOKABLE void sendDtmf(const QString &dtmf);
	                                  Q_INVOKABLE void verifyAuthenticationToken(bool verify);
	                                  Q_INVOKABLE void updateStreams();
	                                  Q_INVOKABLE void toggleSpeakerMute();
	                              */
private:
	std::shared_ptr<CallModel> mCallModel;
	LinphoneEnums::CallStatus mStatus;
	LinphoneEnums::CallState mState;
	QString mLastErrorMessage;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(Call *)
#endif
