#include <QApplication>
#include <VPApplication>

// convenient way to load an application from a single QML file
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  VPApplication vplay;

  QQmlApplicationEngine engine;
  vplay.initialize(&engine);

  // use this during development
  vplay.setMainQmlFileName(QStringLiteral("qml/TuperDarioMakerMain.qml"));

  // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
  //vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/TuperDarioMakerMain.qml"));

  engine.load(QUrl(vplay.mainQmlFileName()));

  return app.exec();
}
