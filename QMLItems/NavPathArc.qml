import QtQuick 2.0
import QtPositioning 5.12
import QtLocation 5.12

MapPolyline{
    visible: false
    line.width: 2
    line.color: BLACK
    property real arclength: INFINITY
    function drawArc(from, to, turn, pcenter){
        path = []
        var i = from;
        if(turn === 1){
            //Right Turn
            line.color = RED
            if(to < from)
                to = to + 360
            for(i = from; i<=to; i = i+0.1){
                addCoordinate(pcenter.atDistanceAndAzimuth(radius,i))
            }
        }
        else if(turn === -1){
            //Left Turn
            line.color = GREEN
            if(to > from)
                to = to - 360
            i = from;
            for(; i>=to; i = i-0.1){
                addCoordinate(pcenter.atDistanceAndAzimuth(radius,i))
            }
        }
        //arclength
        var ang = to - from
        if(ang < 0)
            ang = (-1)*ang
        arclength = radius*ang
    }
    function returnEndPoint(se){
        //se = 0 : Starting Point
        //se = 1 : Ending Point
        return (se ? path[(path.length - 1)] : path[0])
    }
    function returnDistance(){
        return arclength;
    }

    function remove(){
        mapViewOverlay.removeMapItem(this)
    }
}
