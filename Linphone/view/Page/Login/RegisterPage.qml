import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal returnToLogin()
	signal registerCalled(countryCode: string, phoneNumber: string, email: string)
	readonly property string countryCode: phoneNumberInput.countryCode
	readonly property string phoneNumber: phoneNumberInput.phoneNumber
	readonly property string email: emailInput.text

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			Layout.preferredWidth: width
			text: qsTr("Inscription")
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			wrapMode: Text.NoWrap
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15 * DefaultStyle.dp
			color: DefaultStyle.main2_700
			text: qsTr("Déjà un compte ?")
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
		}
		Button {
			// Layout.alignment: Qt.AlignRight
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			text: qsTr("Connexion")
			onClicked: {
				console.debug("[RegisterPage] User: return")
				returnToLogin()
			}
		}
	}

	centerContent: ColumnLayout {
		Layout.topMargin: 40 * DefaultStyle.dp
		TabBar {
			Layout.fillWidth: true
			id: bar
			model: [qsTr("Register with phone number"), qsTr("Register with email")]
		}
		StackLayout {
			currentIndex: bar.currentIndex
			Layout.topMargin: 50 * DefaultStyle.dp

			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					spacing: 15 * DefaultStyle.dp
					RowLayout {
						FormItemLayout {
							label: qsTr("Username")
							mandatory: true
							contentItem: TextField {
								Layout.preferredWidth: 346 * DefaultStyle.dp
							}
						}
						ComboBox {
							Layout.alignment: Qt.AlignBottom
							enabled: false
							model: [{text:"@sip.linphone.org"}]
							Layout.preferredWidth: 210 * DefaultStyle.dp
							Layout.preferredHeight: 49 * DefaultStyle.dp
						}
					}
					PhoneNumberInput {
						id: phoneNumberInput
						label: qsTr("Phone number")
						mandatory: true
						placeholderText: "Phone number"
						Layout.preferredWidth: 346 * DefaultStyle.dp
					}
					RowLayout {
						ColumnLayout {
							FormItemLayout {
								label: qsTr("Password")
								mandatory: true
								contentItem: TextField {
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
						ColumnLayout {
							FormItemLayout {
								label: qsTr("Confirm password")
								mandatory: true
								contentItem: TextField {
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							text: qsTr("I would like to suscribe to the newsletter")
						}
					}
					RowLayout {
						CheckBox {
						}
						RowLayout {
							spacing: 0
							Layout.fillWidth: true
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								text: qsTr("I accept the Terms and Conditions: ")
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								font.underline: true
								text: qsTr("Read the Terms and Conditions.")
								MouseArea {
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: console.log("TODO : display terms and conditions")
								}
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								text: qsTr("I accept the Privacy policy: ")
							}
							Text {
								// Layout.preferredWidth: 450 * DefaultStyle.dp
								font.underline: true
								text: qsTr("Read the Privacy policy.")
								MouseArea {
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
									onClicked: console.log("TODO : display privacy policy")
								}
							}
						}
					}
					Button {
						leftPadding: 20 * DefaultStyle.dp
						rightPadding: 20 * DefaultStyle.dp
						topPadding: 11 * DefaultStyle.dp
						bottomPadding: 11 * DefaultStyle.dp
						text: qsTr("Register")
						onClicked:{
							console.log("[RegisterPage] User: Call register with phone number", phoneNumberInput.phoneNumber)
							mainItem.registerCalled(phoneNumberInput.countryCode, phoneNumberInput.phoneNumber, "")
						}
					}
				}
				Item {
					Layout.fillWidth: true
				}
				Image {
					Layout.rightMargin: 40 * DefaultStyle.dp
					Layout.preferredWidth: 395 * DefaultStyle.dp
					fillMode: Image.PreserveAspectFit
					source: AppIcons.loginImage
				}
			}
			RowLayout {
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					spacing: 15 * DefaultStyle.dp
					RowLayout {
						FormItemLayout {
							label: qsTr("Username")
							mandatory: true
							contentItem: TextField {
								Layout.preferredWidth: 346 * DefaultStyle.dp
							}
						}
						ComboBox {
							// if we don't set a label this item is offset
							// due to the invisibility of the upper label
							enabled: false
							model: [{text:"@sip.linphone.org"}]
							Layout.preferredWidth: 210 * DefaultStyle.dp
							Layout.alignment: Qt.AlignBottom
						}
					}
					FormItemLayout {
						label: qsTr("Email")
						mandatory: true
						contentItem: TextField {
							id: emailInput
							Layout.preferredWidth: 346 * DefaultStyle.dp
						}
					}
					RowLayout {
						ColumnLayout {
							FormItemLayout {
								label: qsTr("Password")
								mandatory: true
								contentItem: TextField {
									id: pwdInput
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
						ColumnLayout {
							FormItemLayout {
								label: qsTr("Confirm password")
								mandatory: true
								contentItem: TextField {
									id: confirmPwdInput
									hidden: true
									Layout.preferredWidth: 346 * DefaultStyle.dp
								}
							}
							Text {
								text: qsTr("The password must contain 6 characters minimum")
								font {
									pixelSize: 12 * DefaultStyle.dp
									weight: 300 * DefaultStyle.dp
								}
							}
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							text: qsTr("I would like to suscribe to the newsletter")
						}
					}
					RowLayout {
						CheckBox {
						}
						Text {
							Layout.preferredWidth: 450 * DefaultStyle.dp
							text: qsTr("I accept the Terms and Conditions : Read the Terms and Conditions. <br>I accept the Privacy policy : Read the Privacy policy.")
						}
					}
					Button {
						leftPadding: 20 * DefaultStyle.dp
						rightPadding: 20 * DefaultStyle.dp
						topPadding: 11 * DefaultStyle.dp
						bottomPadding: 11 * DefaultStyle.dp
						text: qsTr("Register")
						onClicked:{
							console.log("[RegisterPage] User: Call register with email", emailInput.text)
							if (emailInput.text.length == 0) {
								emailInput.errorMessage = qsTr("You must enter an email")
								return
							}
							mainItem.registerCalled("", "", emailInput.text)
						}
					}
				}
				Item {
					Layout.fillWidth: true
				}
				Image {
					Layout.rightMargin: 40 * DefaultStyle.dp
					Layout.preferredWidth: 395 * DefaultStyle.dp
					fillMode: Image.PreserveAspectFit
					source: AppIcons.loginImage
				}
			}
		}
	}
}
 
