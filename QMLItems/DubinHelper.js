function insertNavPoint(plat, plon, phdg){
    var wpComp = Qt.createComponent("qrc:/QMLItems/NavPoint.qml")
    var navPoint
    if(wpComp.status === Component.Ready){
        navPoint = wpComp.createObject(mapViewOverlay)
        navPoint.returnGroup(plat, plon, phdg, totalNavPoint)
        console.log(plat, plon, phdg, totalNavPoint)
        mapViewOverlay.addMapItemGroup(navPoint)
        itemGroupList.push(navPoint)
        wpList.push(navPoint.returnWP())
        console.log(navPoint.lcenter, navPoint.rcenter)
        totalNavPoint = totalNavPoint + 1
        if(totalNavPoint > 1)
            dubinshortestpath(totalNavPoint -2,totalNavPoint -1)//changing from dubinshortestpath(0,1)
    }
    if(wpComp.status === Component.Error)
        console.log("Error Creating Dynamic QML Objects")
}

function updateNavPoint(wpn){
    if(totalNavPoint > 1){
        if(wpn === 0){ //Starting WayPoint
            dubinshortestpath(wpn, wpn + 1)
        }
        else if(wpn === (totalNavPoint-1)){//Final WayPoint
            dubinshortestpath((wpn-1), wpn)
        }
        else{
            dubinshortestpath((wpn-1), wpn)
            dubinshortestpath(wpn, (wpn + 1))
        }
    }
}
function clearAllWP()
{
    var i,j,k

    for(i=0;i<=(itemGroupList.length-1); ++i)
        mapViewOverlay.removeMapItemGroup(itemGroupList[i])

    for(j=0; j <=(wpList.length-1); j++){
        var visiblePathList = wpList[j].retPathList()
        for(i=0; i<6; ++i){
            for(k=0; k<3; ++k){
                if(visiblePathList[i][k] !== undefined){
                    visiblePathList[i][k].remove()
                }
            }
        }
    }
    itemGroupList = []
    wpList = []
    totalNavPoint = 0
}

function dubinshortestpath(start,end){

    var swp = wpList[start]
    var snavpoint = itemGroupList[start]

    var ewp = wpList[end]
    var enavpoint = itemGroupList[end]

    var visiblePathList = swp.retPathList()

    //Clean Path List
    var i,j
    for(i=0; i<6; ++i){
        for(j=0; j<3; ++j){
            if(visiblePathList[i][j] !== undefined){
                visiblePathList[i][j].remove()
            }
        }
    }

    var slcenter = snavpoint.lcenter
    var srcenter = snavpoint.rcenter
    var elcenter = enavpoint.lcenter
    var ercenter = enavpoint.rcenter

    var finaPathlength = INFINITY, curPathLen = 0, type = 0
    curPathLen = sampleLSLpath(swp,ewp,slcenter,elcenter, visiblePathList[0]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 0
    }
    curPathLen = sampleLSRpath(swp,ewp,slcenter,ercenter, visiblePathList[1]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 1
    }
    curPathLen = sampleRSRpath(swp,ewp,srcenter,ercenter, visiblePathList[2]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 2
    }
    curPathLen = sampleRSLpath(swp,ewp,srcenter,elcenter, visiblePathList[3]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 3
    }
    curPathLen = sampleLRLpath(swp,ewp,slcenter,elcenter, visiblePathList[4]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 4
    }
    curPathLen = sampleRLRpath(swp,ewp,srcenter,ercenter, visiblePathList[5]);
    if(curPathLen < finaPathlength){
        finaPathlength = curPathLen
        type = 5
    }
    console.log("Least Length = ", finaPathlength, "Type = ", type)

    visiblePathList[type][0].visible = true
    visiblePathList[type][1].visible = true
    visiblePathList[type][2].visible = true
}
function sampleRLRpath(swp,ewp,srcenter,ercenter, storeList)
{
    var pathlen=INFINITY;
    var source = swp.coordinate ;
    var destination = ewp.coordinate;
    var l=srcenter.distanceTo(ercenter);
    var shead = swp.bearing
    var dhead = ewp.bearing

    if(l < (4*radius) && (Math.abs((shead - dhead)) === 180)){

        var omega3=Math.acos(l/(4*radius))*rad2deg;
        var angleCsCd=srcenter.azimuthTo(ercenter);
        var anglec2=angleCsCd+omega3;


        var centerC2=srcenter.atDistanceAndAzimuth((2*radius),anglec2);

        var angleTs1=angleCsCd+omega3;
        var angleTd1=angleCsCd+(PI*rad2deg)-omega3;//***

        var TS1=srcenter.atDistanceAndAzimuth(radius,angleTs1);
        var TD1=ercenter.atDistanceAndAzimuth(radius,angleTd1);

        var ssAngle = srcenter.azimuthTo(source);
        var seAngle = srcenter.azimuthTo(TS1);
        var dsAngle = ercenter.azimuthTo(TD1);
        var deAngle = ercenter.azimuthTo(destination);
        var isAngle = centerC2.azimuthTo(TS1);
        var ieAngle = centerC2.azimuthTo(TD1);

        var seg1 = createArc()
        var seg2 = createArc()
        var seg3 = createArc()

        seg1.drawArc(ssAngle, seAngle, 1, srcenter)
        seg2.drawArc(isAngle, ieAngle, -1, centerC2)
        seg3.drawArc(dsAngle, deAngle, 1, ercenter)

        storeList[0] = seg1
        storeList[1] = seg2
        storeList[2] = seg3
        console.log("RLR PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))
    }
    else{
        console.log("RLR not possible : (l < 4R) OR Headings are not Similar")
    }

    return pathlen;

}

function sampleLRLpath(swp,ewp,slcenter,elcenter, storeList)
{
    var pathlen=INFINITY;
    var source = swp.coordinate ;
    var destination = ewp.coordinate;
    var l=slcenter.distanceTo(elcenter);
    var shead = swp.bearing
    var dhead = ewp.bearing

    if(l < (4*radius) && (Math.abs((shead - dhead)) === 180)){

        var omega3=Math.acos(l/(4*radius))*rad2deg;
        var angleCsCd=slcenter.azimuthTo(elcenter);
        var anglec1=angleCsCd-omega3;


        var centerC1=slcenter.atDistanceAndAzimuth((2*radius),anglec1);

        var angleTs1=angleCsCd-omega3;
        var angleTd1=angleCsCd-(PI*rad2deg)+omega3;//***

        var TS1=slcenter.atDistanceAndAzimuth(radius,angleTs1);
        var TD1=elcenter.atDistanceAndAzimuth(radius,angleTd1);

        var ssAngle = slcenter.azimuthTo(source);
        var seAngle = slcenter.azimuthTo(TS1);
        var dsAngle = elcenter.azimuthTo(TD1);
        var deAngle = elcenter.azimuthTo(destination);
        var isAngle = centerC1.azimuthTo(TS1);
        var ieAngle = centerC1.azimuthTo(TD1);

        var seg1 = createArc()
        var seg2 = createArc()
        var seg3 = createArc()

        seg1.drawArc(ssAngle, seAngle, -1, slcenter)
        seg2.drawArc(isAngle, ieAngle, 1, centerC1)
        seg3.drawArc(dsAngle, deAngle, -1, elcenter)

        storeList[0] = seg1
        storeList[1] = seg2
        storeList[2] = seg3

        console.log("LRL PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))
    }
    else{
        console.log("LRL not possible : (l < 4R) OR Headings are not Similar")
    }

    return pathlen;

}

function sampleLSRpath(swp,ewp,slcenter,ercenter, storeList)
{

    var pathlen = INFINITY
    var l = slcenter.distanceTo(ercenter);
    if(l>2*radius)
    {
        var source = swp.coordinate ;
        var destination = ewp.coordinate
        var angleCsCd = slcenter.azimuthTo(ercenter);
        var omega2=Math.acos((2*radius)/l)*rad2deg


        //source TangentAngles
        var angleTs4=angleCsCd+omega2;

        //Destination TangentAngles
        var angleTd4=(angleCsCd+PI*rad2deg)+omega2;

        //TangentPoints
        var Ts4=slcenter.atDistanceAndAzimuth(radius,angleTs4);
        var Td4=ercenter.atDistanceAndAzimuth(radius,angleTd4);


        //arcAngles
        var ssAngle = slcenter.azimuthTo(source);
        var seAngle = slcenter.azimuthTo(Ts4);
        var dsAngle = ercenter.azimuthTo(Td4);
        var deAngle = ercenter.azimuthTo(destination);

        //Arcdraw

        var seg2 = createStraightLine()
        var seg1 = createArc()
        var seg3 = createArc()

        seg1.drawArc(ssAngle, seAngle, -1, slcenter)
        seg3.drawArc(dsAngle, deAngle, 1, ercenter)
        seg2.addCoordinate(seg1.returnEndPoint(1))
        seg2.addCoordinate(seg3.returnEndPoint(0))

        storeList[0] = seg1
        storeList[1] = seg2
        storeList[2] = seg3

        console.log("LSR PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))
    }
    else
        console.log("l<2*radius :LSR Not valid");
    return pathlen
}


function sampleLSLpath(swp,ewp,slcenter,elcenter, storeList)
{
    var  source = swp.coordinate ;
    var destination = ewp.coordinate
    var l = slcenter.distanceTo(elcenter);
    var pathlen = INFINITY

    var omega2=Math.acos((2*radius)/l)*rad2deg
    var angleCsCd=slcenter.azimuthTo(elcenter);

    //source TangentAngles
    var angleTs2=angleCsCd+(PIby2*rad2deg);


    //Destination TangentAngles
    var angleTd2=angleTs2;


    //TangentsPoints
    var Ts2=slcenter.atDistanceAndAzimuth(radius,angleTs2);
    var Td2=elcenter.atDistanceAndAzimuth(radius,angleTd2);

    //ArcAngle
    var ssAngle = slcenter.azimuthTo(source);
    var seAngle = slcenter.azimuthTo(Ts2);
    var dsAngle = elcenter.azimuthTo(Td2);
    var deAngle = elcenter.azimuthTo(destination);

    //Arcdraw

    var seg2 = createStraightLine()
    var seg1 = createArc()
    var seg3 = createArc()

    seg1.drawArc(ssAngle, seAngle, -1, slcenter)
    seg3.drawArc(dsAngle, deAngle, -1, elcenter)
    seg2.addCoordinate(seg1.returnEndPoint(1))
    seg2.addCoordinate(seg3.returnEndPoint(0))

    storeList[0] = seg1
    storeList[1] = seg2
    storeList[2] = seg3

    console.log("LSL PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))
    return pathlen
}

function sampleRSRpath(swp,ewp,srcenter,ercenter, storeList)
{

    var l = srcenter.distanceTo(ercenter);
    var source = swp.coordinate ;
    var destination = ewp.coordinate
    var pathlen = INFINITY

    var omega2=Math.acos((2*radius)/l)
    var angleCsCd=srcenter.azimuthTo(ercenter);

    //source TangentAngles
    var angleTs1=angleCsCd-90;
    //var angleTs2=angleCsCd+(PIby2*rad2deg);

    //Destination TangentAngles
    var angleTd1=angleTs1;
    //var angleTd2=angleTs2;

    //TangentPoints
    var Ts1=srcenter.atDistanceAndAzimuth(radius,angleTs1);
    var Td1=ercenter.atDistanceAndAzimuth(radius,angleTd1);

    //ArcAngle
    var ssAngle = srcenter.azimuthTo(source);
    var seAngle = srcenter.azimuthTo(Ts1);
    var dsAngle = ercenter.azimuthTo(Td1);
    var deAngle = ercenter.azimuthTo(destination);

    //Arcdraw

    var seg2 = createStraightLine()
    var seg1 = createArc()
    var seg3 = createArc()

    seg1.drawArc(ssAngle, seAngle, 1, srcenter)
    seg3.drawArc(dsAngle, deAngle, 1, ercenter)
    seg2.addCoordinate(seg1.returnEndPoint(1))
    seg2.addCoordinate(seg3.returnEndPoint(0))

    storeList[0] = seg1
    storeList[1] = seg2
    storeList[2] = seg3

    console.log("RSR PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))

    return pathlen
}


function sampleRSLpath(swp,ewp,srcenter,elcenter, storeList)
{

    var l = srcenter.distanceTo(elcenter);
    var pathlen = INFINITY
    if(l > 2*radius)
    {
        var source = swp.coordinate;
        var destination = ewp.coordinate
        var angleCsCd=srcenter.azimuthTo(elcenter);
        var omega2 = Math.acos((2*radius)/l)
        omega2 = omega2*rad2deg

        //source TangentAngles
        var angleTs3=angleCsCd-omega2;

        //Destination TangentAngles
        var angleTd3=((angleCsCd+180)-omega2);

        //TangentPoints
        var Ts3=srcenter.atDistanceAndAzimuth(radius,angleTs3);
        var Td3=elcenter.atDistanceAndAzimuth(radius,angleTd3);

        var ssAngle = srcenter.azimuthTo(source);
        var seAngle = srcenter.azimuthTo(Ts3);
        var dsAngle = elcenter.azimuthTo(Td3);
        var deAngle = elcenter.azimuthTo(destination);

        var seg2 = createStraightLine()
        var seg1 = createArc()
        var seg3 = createArc()

        seg1.drawArc(ssAngle, seAngle, 1, srcenter)
        seg3.drawArc(dsAngle, deAngle, -1, elcenter)
        seg2.addCoordinate(seg1.returnEndPoint(1))
        seg2.addCoordinate(seg3.returnEndPoint(0))

        storeList[0] = seg1
        storeList[1] = seg2
        storeList[2] = seg3

        console.log("RSL PATH LENGTH = ", pathlen = (seg1.returnDistance()+seg2.returnDistance()+seg3.returnDistance()))
    }
    else
        console.log("l<2*radius :RSL Not valid");
    return pathlen

}

function createArc(){
    var navPath
    var comp = Qt.createComponent("qrc:/QMLItems/NavPathArc.qml")
    navPath = comp.createObject(mapViewOverlay)
    mapViewOverlay.addMapItem(navPath)
    pathGroupList.push(navPath)
    return navPath
}

function createStraightLine(){
    var navPath
    var comp=Qt.createComponent("qrc:/QMLItems/NavPathPolyLine.qml")
    navPath=comp.createObject(mapViewOverlay);
    mapViewOverlay.addMapItem(navPath)
    pathGroupList.push(navPath)
    return navPath
}
function loadImagefromJSON()
{
    var file = FSmodel.openNavPoint()
    if(file !== ""){
        var RawData=new XMLHttpRequest();
        var allText
        RawData.open("GET",file,false)
        RawData.onreadystatechange=function()
        {
            if(RawData.readyState===4)
            {
                if(RawData.status===200 || RawData.status===0)
                {
                    var allText=RawData.responseText;
                    var mapPoints=JSON.parse(allText)
                    var i=0;
                    var nPoints=mapPoints.map.length
                    while(i<nPoints)
                    {
                        var latit=mapPoints.map[i].point.latitude
                        var longi=mapPoints.map[i].point.longitude
                        var head=mapPoints.map[i].point.heading
                        console.log(latit,longi,head)
                        insertNavPoint(latit,longi,head)
                        i++
                    }

                }
            }
        }
        RawData.send(null)
    }
}
function addNavPointList()
{
    var len=wpList.length;
    for(var i=0;i<len;i++)
    {
        var swp=wpList[i]
        var coordinates=swp.coordinate;
        var lat=coordinates.latitude+latOffset;
        var lon=coordinates.longitude+lonOffset;
        var head=swp.bearing

        FSmodel.addNavPoint(lat,lon,head);
        console.log("coordinates point",lat+latOffset,lon+lonOffset,head);

    }
    FSmodel.saveNavPoint();
}
