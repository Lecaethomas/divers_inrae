myDir = 'C:/_CLIENT/ADAGE/RTE_HDFrance_2021/output/Livrables/test_export/'


for vLayer in iface.mapCanvas().layers():
    QgsGeometryValidator.validateGeometry(vLayer)
    QgsVectorFileWriter.writeAsVectorFormat( vLayer, 
        myDir + vLayer.name() + ".shp", "utf-8", 
        QgsCoordinateReferenceSystem( 'EPSG:2154'), "ESRI Shapefile" )
