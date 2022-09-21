import QtQuick 2.0
import QtPositioning 5.12
import QtLocation 5.12

MapPolyline{
    line.color: "black"
    line.width: 2
    path: []
    //onPathChanged: console.log("path[",path.length,"] = ", path[path.length -1].latitude, path[path.length -1].longitude)
    visible: false

    property real arclength: INFINITY

    function addPathCoord(lat, lon){
        addCoordinate(QtPositioning.coordinate(lat, lon))
    }
    function itemReturn(clr){
        line.color = clr
        return this
    }
    function returnDistance(){
        arclength = path[0].distanceTo(path[path.length-1])
        return arclength;
    }

    function remove(){
        mapViewOverlay.removeMapItem(this)
    }
}
