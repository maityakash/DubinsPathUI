import QtQuick 2.0
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5

MapQuickItem {
    property string id: "value"
    coordinate: QtPositioning.coordinate(14.39012050597920122641-latOffset,
                                         76.57207020752468906721-lonOffset)
    visible: true
    anchorPoint.x: pIcon.width/2
    anchorPoint.y: pIcon.height
    sourceItem:
        Image {
        id: pIcon
        source: "qrc:/images/marker.png"
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: pInfo.visible = !pInfo.visible
        }
        Rectangle{
            id: pInfo
            x: pIcon.width
            y: pIcon.height
            visible: false
            radius: 2
            color: "lightgreen"
            width: infoCol.width
            height: infoCol.height
            ColumnLayout{
                id: infoCol
                Text{
                    text: "ID: " + id
                }
                Text{
                    text: "Lat: " + (coordinate.latitude + latOffset)
                }
                Text{
                    text: "Lon: " + (coordinate.longitude + lonOffset)
                }
            }
        }
    }
}
