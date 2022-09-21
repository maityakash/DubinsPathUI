import QtQuick 2.0
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import "DubinHelper.js" as Dubin

MapItemGroup {
    id: navPointItem
    property var lcenter: QtPositioning.coordinate(0,0)
    property var rcenter: QtPositioning.coordinate(0,0)
    property real v: 0.0
    property var visiblePathList: [[], [], [], [], [], []]
    Waypoint{
        id: wp
        onCoordinateChanged: {
            lcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing - 90)%360))
            rcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing + 90)%360))
            pivotZoomPoint = coordinate
        }
        onBearingChanged: {
            lcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing - 90)%360))
            rcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing + 90)%360))
        }

        function radiusUpdated(){
            lcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing - 90)%360))
            rcenter = coordinate.atDistanceAndAzimuth(radius, ((360 + bearing + 90)%360))
        }

        function retPathList(){
            return visiblePathList
        }
    }

    MapQuickItem {
        id: itemIcon
        property bool checked: false
        property real heading: 0.0
        property var lastCoordinate
        anchorPoint.x: checked ? itemImg.width : itemImg.width/2
        anchorPoint.y: checked ? itemImg.height*2 : itemImg.height
        z: parent.z + 2
        visible: true
        coordinate: wp.coordinate
        sourceItem:
            Image {
            id: itemImg
            source: "qrc:/images/marker.png"
            scale: itemIcon.checked ? 2 : 1
            Text {
                id: wpNumber
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pixelSize: 20
                color: "white"
            }
            MouseArea{
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                drag.target: itemIcon
                property bool dragTriger: false
                onClicked: {
                    itemIcon.checked = !itemIcon.checked
                    dragPositionUpdate.lat = (itemIcon.coordinate.latitude + latOffset).toFixed(fPrecision)
                    dragPositionUpdate.lon = (itemIcon.coordinate.longitude + lonOffset).toFixed(fPrecision)
                    dragPositionUpdate.head = wp.bearing
                    if(itemIcon.checked){
                        dragPositionUpdate.open()
                    }
                }
                onHoveredChanged: cursorShape = Qt.PointingHandCursor
                onPositionChanged: {
                    if(drag.active){
                        //console.log("Dragging...", dragTriger)
                        dragTriger = true
                    }
                }
                onReleased: {
                    if(dragTriger == true){
                        dragPositionUpdate.lat = (itemIcon.coordinate.latitude + latOffset).toFixed(fPrecision)
                        dragPositionUpdate.lon = (itemIcon.coordinate.longitude + lonOffset).toFixed(fPrecision)
                        dragPositionUpdate.head = wp.bearing
                        dragPositionUpdate.open()
                        dragTriger = false
                    }
                }
            }
            /*Rectangle{
                //For future use
                id: info
                anchors.left: itemImg.right
                anchors.top: itemImg.bottom
                visible: false//itemIcon.checked
                width: 50
                height: 50
                border.color: "red"
                Dial{
                    id: headingDial
                    anchors.fill: parent
                    from:0
                    to:360
                    background: Rectangle {
                        x: headingDial.width / 2 - width / 2
                        y: headingDial.height / 2 - height / 2
                        width: Math.max(64, Math.min(headingDial.width, headingDial.height))
                        height: width
                        color: "transparent"
                        radius: width / 2
                        border.color: headingDial.pressed ? "#17a81a" : "#21be2b"
                        opacity: headingDial.enabled ? 1 : 0.3
                    }

                    handle: Rectangle {
                        id: handleItem
                        x: headingDial.background.x + headingDial.background.width / 2 - width / 2
                        y: headingDial.background.y + headingDial.background.height / 2 - height / 2
                        width: 16
                        height: 16
                        color: headingDial.pressed ? "#17a81a" : "#21be2b"
                        radius: 8
                        antialiasing: true
                        opacity: headingDial.enabled ? 1 : 0.3
                        transform: [
                            Translate {
                                y: -Math.min(headingDial.background.width, headingDial.background.height) * 0.4 + handleItem.height / 2
                            },
                            Rotation {
                                angle: headingDial.angle
                                origin.x: handleItem.width / 2
                                origin.y: handleItem.height / 2
                            }
                        ]
                    }
                }
                Text {
                    id: h
                    x:0
                    y:0
                    text: headingDial.value
                }
            }*/
            Image {
                id: headind
                source: "qrc:/images/heading.png"
                rotation: wp.bearing
                z: itemImg.z - 1
                visible: true
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                transformOrigin: Item.Bottom
            }
        }
        onCoordinateChanged:
        {
            //            console.log(coordinate)//.latitude, coordinate.longitude)
        }
    }
    NavPointUpdateDialog{
        id: dragPositionUpdate
        title: "NavPoint Dragged"
        onApply: {
            if(validInput){
                //wpModel.updateWP(lat,lon,head,wpNumber.text)
                itemIcon.lastCoordinate = QtPositioning.coordinate(itemIcon.coordinate.latitude, itemIcon.coordinate.longitude)
                itemIcon.heading = parseInt(head)%360
                wp.coordinate = itemIcon.lastCoordinate
                wp.bearing = itemIcon.heading
                Dubin.updateNavPoint(parseInt(wpNumber.text))
                close()
                itemIcon.checked = false//!itemIcon.checked
                pivotZoomPoint = wp.coordinate
            }
        }
        onRejected: {
            itemIcon.coordinate = QtPositioning.coordinate(itemIcon.lastCoordinate.latitude, itemIcon.lastCoordinate.longitude)
            itemIcon.checked = false//!itemIcon.checked
        }

    }

    Component.onCompleted: {

    }

    function returnGroup(lat, lon, head, wpn){
        wp.bearing = head
        wp.coordinate = QtPositioning.coordinate(lat - latOffset, lon - lonOffset)
        itemIcon.lastCoordinate = QtPositioning.coordinate(lat - latOffset, lon - lonOffset)
        wpNumber.text = wpn
        return navPointItem//itemIcon
    }

    function returnWP(){
        return wp
    }
}
