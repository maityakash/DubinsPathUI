import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3

Dialog
{
    property alias lat: latInput.text
    property alias lon: lonInput.text
    property alias head: hdgInput.text

    property bool validInput: (latInput.acceptableInput && lonInput.acceptableInput && hdgInput.acceptableInput)

    title: "Nav Point Dialog"

    standardButtons: StandardButton.Apply | StandardButton.Cancel
    width: 250
    ColumnLayout
    {
        anchors.fill: parent
        Text
        {
            Layout.fillWidth: true
            text: qsTr("Latitude : ")
            font.pixelSize: 20
        }

        Rectangle
        {
            id:latrec
            radius: 5
            border.width: latInput.focus ? 2 : 1
            border.color: latInput.acceptableInput ? "green" : "red"
            Layout.fillWidth: true
            height: 25
            TextInput
            {
                id:latInput
                width: parent.width
                anchors.left: parent.left
                anchors.margins: 2
                anchors.verticalCenter: parent.verticalCenter
                validator: DoubleValidator{bottom: -90; top:90; decimals: fPrecision}
                font.pixelSize: 15
                clip: true
            }
        }

        Text
        {
            Layout.fillWidth: true
            text: qsTr("Longitude : ")
            font.pixelSize: 20
        }

        Rectangle
        {
            id:lonrec
            radius: 5
            border.width: lonInput.focus ? 2 : 1
            border.color: lonInput.acceptableInput ? "green" : "red"
            Layout.fillWidth: true
            height: 25
            TextInput
            {
                id:lonInput
                width: parent.width
                anchors.left: parent.left
                anchors.margins: 2
                anchors.verticalCenter: parent.verticalCenter
                validator: DoubleValidator{bottom: -180; top: 180; decimals: fPrecision}
                font.pixelSize: 15
                clip: true
            }
        }


        Text
        {
            Layout.fillWidth: true
            text: qsTr("Heading (in Degree): ")
            font.pixelSize: 20
        }

        Rectangle
        {
            id:hdgrec
            radius: 5
            border.width: hdgInput.focus ? 2 : 1
            border.color: hdgInput.acceptableInput ? "green" : "red"
            Layout.fillWidth: true
            height: 25
            TextInput
            {
                id:hdgInput
                width: parent.width
                anchors.left: parent.left
                anchors.margins: 2
                anchors.verticalCenter: parent.verticalCenter
                validator: IntValidator{bottom: 0; top: 360;}
                text: "0"
                font.pixelSize: 15
                clip: true
                onAccepted: apply()
            }
        }
    }
}
