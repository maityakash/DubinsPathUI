import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Dialogs 1.2
import "QMLItems/DubinHelper.js" as Dubin
import "QMLItems"

ApplicationWindow {

    id: rootWindow;visible: true;width: 640;height: 480
    title: qsTr("Dubin's Path Generator")
    menuBar:
        MenuBar{
        id: topBar
        z: 99
        width: parent.width
        Menu {
            width: 150
            title: qsTr("&File")
            Action { text: qsTr("&Import")
                onTriggered:
                {
                    Dubin.clearAllWP()
                    Dubin.loadImagefromJSON()
                }
            }
            Action { text: qsTr("&Export")
                onTriggered:
                {
                    Dubin.addNavPointList();

                }
            }
            Action {
                text: qsTr("Clear All WPs")
                onTriggered: Dubin.clearAllWP()
            }

            Action
            {
                text:qsTr("Change Radius")
                onTriggered: radiusUpdateDialog.open()
            }

            MenuSeparator { }
            Action {
                text: qsTr("&Quit")
                onTriggered: rootWindow.close()
            }
        }
        Menu {
            width: 100
            title: qsTr("&Help")
            Action { text: qsTr("&About ?") }
        }
    }

    Dialog
    {
        id:radiusUpdateDialog
        width:400; height:100
        title:"Change Radius of Dubin's Path Model"

        standardButtons: StandardButton.Apply | StandardButton.Cancel | StandardButton.Reset

        ColumnLayout{
            anchors.fill: parent
            Text {
                Layout.fillWidth: true
                text: qsTr("Radius ") + qsTr("(" + cbUnit.model.get(cbUnit.currentIndex).unit + ")")
                font.pixelSize: 20
            }

            RowLayout{

                Rectangle{
                    Layout.fillWidth: true
                    border.color: mtrInput.acceptableInput ? "green" : "red"
                    border.width: 2
                    radius: 4
                    height: 30
                    focus: true
                    TextInput
                    {
                        id:mtrInput
                        anchors.fill: parent
                        anchors.left: parent.left
                        anchors.margins: 2
                        anchors.verticalCenter: parent.verticalCenter
                        validator: DoubleValidator{bottom: 0; top:10000000; decimals: fPrecision}
                        font.pixelSize: 20
                        clip: true
                        focus: true
                        onTextEdited: {

                        }
                        onAccepted: radiusUpdateDialog.apply()
                    }
                }
                Rectangle{
                    border.width: 2
                    radius: 4
                    height: 30
                    width: 150
                    ComboBox{
                        id: cbUnit
                        anchors.fill: parent
                        anchors.margins: 2
                        textRole: "unit"
                        model: ListModel{
                            ListElement{unit: "Meter"; value: 1}
                            ListElement{unit: "Feet"; value: 3.2808}
                            ListElement{unit: "Naut. Miles"; value: 0.000539957}
                        }
                        delegate: ItemDelegate {
                            width: cbUnit.width
                            contentItem: Text {
                                text: model.unit
                                color: "black"
                                font: cbUnit.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: cbUnit.highlightedIndex === index
                        }
                        onActivated:
                        {
                            console.log(index, model.get(index).value.toFixed(10))
                            mtrInput.text = (radius*model.get(index).value).toFixed(fPrecision)
                        }
                    }
                }
            }
        }

        onApply:
        {
            if(mtrInput.acceptableInput){
                console.log(radius, (mtrInput.text.valueOf())/cbUnit.model.get(cbUnit.currentIndex).value)
                radius = ((mtrInput.text.valueOf())/cbUnit.model.get(cbUnit.currentIndex).value).toFixed(fPrecision)
                var i=0
                for(;i<wpList.length; ++i){
                    wpList[i].radiusUpdated()
                    Dubin.updateNavPoint(i)
                }
                close()
            }
        }
        onRejected:
        {
            close()
        }
        onReset: {
            cbUnit.currentIndex = 0
            mtrInput.text = defaultRadius
        }
        Component.onCompleted: mtrInput.text = radius
    }

    /******************GLOBAL VARIABLES********************/
    property int totalNavPoint: 0
    property var itemGroupList: []
    property var wpList: []
    property var pathGroupList: []
    property real viewScaleFactor: 0.25

    property variant pivotZoomPoint//: QtPositioning.coordinate(0,0) // Initial Value later changed after the map is loaded.

    property real cursorLat: 0.0
    property real cursorLon: 0.0

    property real cursorX: 0.0
    property real cursorY: 0.0

    readonly property real deg2rad: (3.14/180)
    readonly property real rad2deg: (180/3.14)

    readonly property real latOffset: 0
    readonly property real lonOffset: 0

    property real radius: defaultRadius

    /******************CONTENT ITEM**************************/

    NavPointUpdateDialog
    {
        id:navPointConfigUpdateDialog
        title:"New WayPoint Configuration"
        onApply: {
            if(validInput){
                Dubin.insertNavPoint(lat, lon, head.valueOf())
                close()
            }
        }
    }

    Rectangle{
        id: rootRect
        anchors.fill: parent
        clip: true
            //SET VIEW TO CENTRAL POSITION ACCORDING TO THE AIRCRAFT
            function setVeiwCentralAircraft(){
                contentX = (mapViewOverlay.fromCoordinate(pivotZoomPoint)).x - (width/2)
                contentY = (mapViewOverlay.fromCoordinate(pivotZoomPoint)).y - (height/2)
            }
            Plugin {
                id: mapPlugin
                name: "osm"
                PluginParameter {
                    name: "osm.mapping.providersrepository.disabled"
                    value: "true"
                }
                PluginParameter {
                    name: "osm.mapping.providersrepository.address"
                    value: "http://maps-redirect.qt.io/osm/5.8/satellite"
                }
            }
            Map{
                id:mapViewOverlay
                plugin: mapPlugin
                anchors.fill: parent
                anchors.centerIn: parent
                enabled: true
                gesture.enabled: true
                center: QtPositioning.coordinate(12.31076011,76.62261024)
                zoomLevel: 19

                property point imgTLC//: Qt.point(0,0)
                property point imgBRC//: Qt.point(0,0)

                MouseArea{
                    id: rootRectMouseArea
                    anchors.fill: mapViewOverlay
                    propagateComposedEvents: true
                    hoverEnabled: true
                    enabled: true
                    cursorShape: Qt.CrossCursor
                    onPositionChanged: {
                        cursorLat = (mapViewOverlay.toCoordinate(rootRectMouseArea.mapToItem(mapViewOverlay, mouseX, mouseY)).latitude )
                        cursorLon = (mapViewOverlay.toCoordinate(rootRectMouseArea.mapToItem(mapViewOverlay, mouseX, mouseY)).longitude)
                        cursorX = rootRectMouseArea.mapToItem(mapViewOverlay, mouseX, mouseY).x
                        cursorY = rootRectMouseArea.mapToItem(mapViewOverlay, mouseX, mouseY).y
                    }
                    onClicked:
                    {
                        navPointConfigUpdateDialog.lat = cursorLat.toFixed(fPrecision)
                        navPointConfigUpdateDialog.lon = cursorLon.toFixed(fPrecision)
                        navPointConfigUpdateDialog.open()
                    }
                }
            }

        // Map Controls

        ColumnLayout{
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            height: 100
            width: 40
            Button{
                id: zoomIn
                text: "Zoom In"
                enabled: true
                //opacity: (mapViewOverlay.zoomLevel != mapViewOverlay.maximumZoomLevel) ? 1 : 0.4
                icon { color: "transparent"; source: "qrc:/images/zoomIn48dp.png";height: 50; width: 50;}
                background: Rectangle{
                    color: "white"
                    radius: 5
                    border.color: "green"
                    border.width: 2
                }
                display: AbstractButton.IconOnly
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked:{
                    mapViewOverlay.zoomLevel +=1
                }
            }
            Button{
                id: zoomOut
                text: "Zoom Out"
                enabled: true
                //opacity: (mapViewOverlay.zoomLevel != mapViewOverlay.minimumZoomLevel) ? 1 : 0.4
                icon { color: "transparent"; source: "qrc:/images/zoomOut48dp.png";height: 50; width: 50;}
                background: Rectangle{
                    color: "white"
                    radius: 5
                    border.color: "green"
                    border.width: 2
                }
                display: AbstractButton.IconOnly
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked:{
                    mapViewOverlay.zoomLevel -=1
                }
            }
        }
    }
    /************************************************/

    footer:
        Rectangle{
        id: footerItem
        height: 20
        width: parent.width
        color: "cyan"
        RowLayout{
            //anchors.fill: parent
            Rectangle{
                width: 150
                height: parent.height
                Layout.alignment: Qt.AlignTop
                Text {
                    id: cursorLatDisp
                    text: "LAT: " + cursorLat.toFixed(fPrecision)
                }
            }
            Rectangle{
                width: 150
                height: parent.height
                Layout.alignment: Qt.AlignTop
                Text {
                    id: cursorLonDisp
                    text: "LON: " + cursorLon.toFixed(fPrecision)
                }
            }
            Text {
                id: radiusDisp
                text: "Current Radius : " + radius + " meters"
                font.bold: true
                width: 150
                height: parent.height
                Layout.alignment : Qt.AlignRight
            }
        }
    }

    Component.onCompleted:{
//        rootWindow.showMaximized()
    }

}
