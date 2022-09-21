#ifndef FSAVENAVPOINT_H
#define FSAVENAVPOINT_H
#include<QCoreApplication>
#include<QJsonObject>
#include<QJsonDocument>
#include<QJsonValue>
#include<QFile>
#include<QDebug>
#include<QTextStream>
#include<QJsonArray>
#include<iostream>
#include<string>
#include<QObject>
#include<QFileDialog>
#include<QList>
#include <QJSEngine>
struct NavPath{
    double latitude;
    double longitude;
    double heading;
    NavPath(qreal lat, qreal lon, qreal hdg){
        latitude = lat;
        longitude = lon;
        heading = hdg;
    }

};

class fNavPoints:public QObject
{
    Q_OBJECT
    QList<NavPath>NavList;


public:
    fNavPoints(){
    }

public slots:
    void addNavPoint(qreal lat, qreal lon, qreal hdg)
    {
        NavList.append(NavPath(lat,lon,hdg));
    }
    void saveNavPoint()
    {
        QString fileName=QFileDialog::getSaveFileName(nullptr,tr("Save Plan"),QDir::currentPath(),tr("JSON files (*.json *.JSON)"));
        if(fileName != QString()){
            if(!fileName.contains(".json", Qt::CaseInsensitive))
            {
                if (fileName.contains('.')){
                    fileName = fileName.split(".").at(0);
                }
                fileName+=".json";
            }

            QJsonObject rootobj;
            QJsonObject parent;
            QJsonObject child;
            QJsonArray array;

            for(int i=0;i<NavList.length();i++)
            {
                child.insert("heading",NavList[i].heading);
                child.insert("latitude",NavList[i].latitude);
                child.insert("longitude",NavList[i].longitude);
                parent.insert("point",child);
                array.append(parent);
            }
            rootobj.insert("map",array);
            QJsonDocument doc(rootobj);
            QFile file(fileName);
            file.open(QIODevice::WriteOnly|QIODevice::Text);
            QTextStream out(&file);
            out<<doc.toJson();
            NavList.clear();
            file.flush();
            file.close();
        }
    }
    QString  openNavPoint()
    {
        QString file_name=QFileDialog::getOpenFileName(nullptr,"Open Plan",QDir::currentPath(),"JSON files (*.json *.JSON)");

        if(file_name != QString()){
            QFile file(file_name);
            file.open(QFile::ReadOnly|QFile::Text);
            QTextStream stream(&file);
            QByteArray data=stream.readAll().toUtf8();

            QJsonParseError jsonError;
            QJsonDocument doc1=QJsonDocument::fromJson(data,&jsonError);
            QJsonObject jsonobj=doc1.object();
            file.flush();
            file.close();
            NavList.clear();
            return "file://" + file_name;//"qrc:/QMLItems/point.json";
        }
        return "";
    }

};

#endif // FSAVENAVPOINT_H
