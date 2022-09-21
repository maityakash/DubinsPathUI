#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <math.h>
#include<QApplication>

#include "fsavenavpoint.h"
//#include "roadmappoint.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);


    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    fNavPoints *fileSave=new fNavPoints();

    engine.rootContext()->setContextProperty("defaultRadius", 12);
    engine.rootContext()->setContextProperty("INFINITY", INFINITY);
    engine.rootContext()->setContextProperty("PI", M_PI);
    engine.rootContext()->setContextProperty("PIin2", 2*M_PI);
    engine.rootContext()->setContextProperty("PIby2", M_PI_2);
    engine.rootContext()->setContextProperty("FSmodel", fileSave);
    engine.rootContext()->setContextProperty("RED", "#FF800A");
    engine.rootContext()->setContextProperty("GREEN", "#80FF00");
    engine.rootContext()->setContextProperty("BLACK", "#0000AA");
    engine.rootContext()->setContextProperty("fPrecision", 8);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
