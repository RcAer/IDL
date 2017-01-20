;+
; NAME:
;   great_circle_distance
;
; PURPOSE:
;   This program calculates the great circle distance between a point and another point, or a point
;   and an array of points.
;
; USAGE:
;   data  = great_circle_distance(lat1_in,lon1_in,lat2_in,lon2_in,radius,/degrees) 
;
; PARAMETERS:
;   lat1_in -- A scalar latitude to compute the distances from.
;
;   lon1_in -- A scalar longitude to compute the distances from.
;
;   lat2_in -- A scalar or array of latitudes to compute the distances to.
;
;   lon2_in -- A scalar or array of longitudes to compute the distances to.
;
;   radius -- (optional) The radius of the circle you wish to use.  If this is not provided, 
;             it is set to the mean radius of the earth (6371 km)
;
; KEYWORDS:
;   degrees -- Set this to 1 if the input parameters are in degrees.
;
; RESULT:
;   data -- A scalar or array of the same size as (lat2_in and lon2_in) containing 
;           the great circle distances
;
; REQUIRED PROGRAMS:
;   None
;
; AUTHOR:
;   Christina Kalb
;   kalb@ucar.edu
;
; DATE:
;   April 16, 2012
;
; MODIFIED:
;   June 21, 2013
;    -Created new variables lat1, lon1, lat2, lon2.  The previous version
;     without these variables was causing some errors in lat/lon data back in
;     the calling program.
;-

function great_circle_distance,lat1_in,lon1_in,lat2_in,lon2_in,radius,degrees=degrees

;Error handling, return to the calling program upon an error
on_error,2

;Check to see if the correct number of parameter are input
if n_params() lt 4  or n_params() gt 5 then begin
   Message, 'Incorrect input',/informational
   Message, 'Usage: great_circle_distance,lat1,lon1,lat2,lon2,radius (optional)'
endif

if n_elements(lat1_in) ne 1 or n_elements(lon1_in) ne 1 then $
   Message,'lat1_in and lon1_in must be scalars, stopping...'

if n_elements(lat2_in) ne n_elements(lon2_in) then $
   Message, 'lat2_in and lon2_in must be the same size, stopping...'

;If the user did not input a radius, use the earth's mean radius in km
if n_elements(radius) eq 0 then begin
   Message, 'Radius not defined, Using earths radius in km', /informational
   radius = 6371. 
endif

;Make sure the latitudes and longitudes are in radians
if keyword_set(degrees) then begin

   lat1 = float(lat1_in)*!dtor
   lat2 = float(lat2_in)*!dtor
   lon1 = float(lon1_in)*!dtor
   lon2 = float(lon2_in)*!dtor

endif else begin

   lat1 = float(lat1_in)
   lat2 = float(lat2_in)
   lon1 = float(lon1_in)
   lon2 = float(lon2_in)

endelse

;Compute the great circle distance
great_circle_distance = radius*acos((sin(lat1)*sin(lat2)) + $
	(cos(lat1)*cos(lat2)*cos(lon2-lon1)))


return,great_circle_distance

end
