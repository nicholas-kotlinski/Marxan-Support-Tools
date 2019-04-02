#runfile('D:/Temp/Downloads/arcpy_11819/zone_stats_arcpy.py')
import os, sys
__arc_gis_dir = "C:\\Program Files (x86)\\ArcGIS\\Desktop10.6\\"
__arc_gis_path = [__arc_gis_dir + "bin",
                __arc_gis_dir + "ArcPy",
                __arc_gis_dir + "ArcToolBox\Scripts"]
for p in __arc_gis_path:
    if p not in sys.path: sys.path += [p]

import arcpy
#from arcpy import env
#from arcpy.sa import *
#from dbfpy import dbf
arcpy.CheckOutExtension("Spatial")

arcpy.env.workspace = r"E:/test"
arcpy.env.overwriteOutput = True
arcpy.env.scratchWorkspace = os.path.join(arcpy.env.workspace, 'scratch')
arcpy.env.cellSize = 10

destination_view = os.path.join(arcpy.env.scratchGDB, 'destination_table_view')
print (destination_view)

#zones to calculate stats on
#inpoly = r"E:/Guyana Priority Areas - Backup/Planning Units/hex_5km_pu_wgs84_102218.shp"
inpoly = r"E:/Guyana Priority Areas - Backup/Planning Units/North_Rupununi/nrup_pu_3119_1km_hex_wgs84_ed.shp"
print(inpoly)

#where to save output files
destination_path = r"E:/test/tables"
print(destination_path)

#list of rasters to calculate statistics on
rasters = arcpy.ListRasters("*", "TIF")

for raster in rasters:
    print(raster)
    destination_raster = os.path.join(destination_path, raster)[:-4] + '.dbf'
    arcpy.gp.ZonalStatisticsAsTable_sa(inpoly, "PU_ID", raster, destination_raster, "DATA", "SUM")

    destination_csv = os.path.join(destination_path, raster)[:-4] + '.csv'
    field_info = arcpy.FieldInfo()
    for field in arcpy.ListFields(destination_raster):
        field_info.addField(field.name, field.name, "VISIBLE", "")
    arcpy.MakeTableView_management(destination_raster, destination_view, "", "", field_info)
    arcpy.CopyRows_management(destination_view, destination_csv)


arcpy.CheckInExtension("Spatial")