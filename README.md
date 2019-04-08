# Marxan
ArcPy (ArcGIS) and R scripts for creating Marxan input files, including: species distribution models, abundance table, and cost table.

(1) SSDM package - run through example for creating species distribution models based on presence point data <br>
(2) Zonal Statistics in R - only use for very small datasets (<100 planning units/zones, <50 distribution models), for large datasets see ArcPy script <br>
(3) Zonal Statistics in ArcPy - this method is much faster than the R code, but does require an extra step for merging output tables together to make the final abundance table<br>
(4) Merge zonal statistics output tables to final abundance table - if using ArcPy code
