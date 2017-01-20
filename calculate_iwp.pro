;+
; NAME:
;   calculate_iwp
;
; PURPOSE:
;   This program calculates ice water path from 2 or 3 dimensional radar data.  Note that either 
;   altitude or temperature must be present.  Ice water path is calculated using the following:
;   Ice density based on convective dBZ (units, dBZ)
;            reflectivity > 40.0, rhoi=800.0
;            35 < reflectivity < 40, rhoi=700.0
;            30 < reflectivity < 35, rhoi=600.0
;            18 < reflectivity < 30, rhoi=400.0
;   Convert to linear Z for calculation
;            Zhice=10**(dz(i,j)/10.)
;            rhoa=1
;   Calculate and sum IWC's [g/m3] at each level for computing mean
;   see Doviak and Zrnic (here rhoa=1 so that we are getting units of g/m3)
;           IWC = 1000.*PI*(rhoi/rhoa)*(N0i**(3./7.))*
;           (5.68E-18*Zhice/720.)**(4./7.)
;   Multiply by IWC by vertical spacing and sum in the vertical to get IWP
;           iwcp(i)=iwcp(i)+IWC*VERTSPACING
;
; USAGE:
;   ouput  = calculate_iwp(DZ,alt,vertspacing) 
;
; PARAMETERS:
;   DZ -- Radar reflectivity.  This should be either a 2 or 3 dimensional array
;
;   lvl_var -- This is a variable that defines the vertical threshold to calculate ice water path.  
;              It should be set to either temperature or altitude and should be the same size array 
;              as DZ.  If set to altitude (in meters), then the melting level must be provided in 
;              meters in the keyword melting_level.  If the keyword melting_level is not set then 
;              this is assumed to be temperature.  You can set a temperature threshold using the 
;              keyword temp.  If temp is not set, the temperature threshold is assumed to be -10 C.
;
;   vertspacing -- The vertical spacing between radar gates.  This should be in meters, and either a 
;                  scalar or array the same size as DZ.
;
; KEYWORDS:
;   melting_level -- If using altitude as lvl_var above, this should be set to the height of the 
;                    melting level in km.  If this keyword is not set, then temperature is assumed 
;                    to be input.
;
;   alt_dimension -- The dimension of the array in which the altitude is stored.  If this is not 
;                    defined, it is assumed to be the last dimension of the array.
;
;   temp -- If using temperature as lvl_var above, this can be set to the a temperature threshold for 
;           calculating ice water path.  If not set, the threshold is assumed to be 10 degrees Celsius. 
;
; RESULT:
;   output -- An array of the same dimensions as the X and Y dimensions of DZ containing ice water path.
;
; REQUIRED PROGRAMS:
;   None
;
; AUTHOR:
;   Christina Kalb
;   kalb@ucar.edu
;
; DATE:
;   May 15, 2012
;-

FUNCTION calculate_iwp,DZ,lvl_var,vertspacing_in,MELTING_LEVEL=mlevel,ALT_DIMENSION=alt_dimension,TEMP=temp,glength=glength,gxlen=gxlen,gylen=gylen

;Error handling.  Return to previous program upon error
on_error,2


;Check that we have the correct number of inputs
if n_params() ne 3 then begin
   Message, 'Incorrect number of inputs',/informational
   Message,'Usage: result = calculate_iwp(DZ,lvl_var,vertspacing)'
endif

vertspacing = vertspacing_in

;Check the sizes of the inputs, and make them the same size if they are not
dz_size = size(DZ,/dimensions)
lvl_size = size(lvl_var,/dimensions)
vertspace_size = size(vertspacing,/dimensions)

;If alt_dimension is not provided, set it to the last dimension of the input DZ array
if n_elements(alt_dimension) eq 0 then alt_dimension = n_elements(dz_size)

case 1 of
   n_elements(glength) gt 0: Begin
      gdiv = glength^(2.0)
   end
   n_elements(gxlen) gt 0 and n_elements(gylen) gt 0 and n_elements(glength) eq 0:Begin
      gdiv = gxlen+gylen*1.0
   end
   else: Begin
      gdiv = 1.0
   end
endcase 

;Check that lvl_var is the correct size
if array_equal(dz_size,lvl_size) eq 0 then Message, $
   'DZ and lvl_var must be the same size'

;Check the vertspacing size.  If it is provided as a scalar, make it the same size as DZ.
case 1 of
   ;Case #1, vertspacing is the same size as DZ
   array_equal(dz_size,vertspace_size):Begin
      ;Do Nothing
   end  ;Case #1

   ;Case #2, vertspacing is a scalar
   n_elements(vertspacing) eq 1:Begin
      ;Make vertspacing the same size as DZ
      vertspacing = replicate(vertspacing,dz_size)
   end  ;Case #2

   ;Case #3, vertspacing is not a scalar or the same size as DZ 
   else:Begin
      ;Error...  vertspacing must either be a scalar or the same size as DZ
      Message,'vertspacing must either be a scalar or an array the same size as DZ'
   end  ;Case #3
endcase


;Start the calculations
;Convert to linear Z
DZtt=DZ/10d
dz_invlog=10d^(DZtt)

;Define constants:
rhoa=1d
N0i=4d*(10d^(6))
factor=((5.68d*10d^(-18d))/720d)

;Set up rhoi for the different thresholds
rhoi = fltarr(dz_size)

;Get the indices of DZ for the different thresholds
if ceil(max(DZ,/nan)) ne 0 then begin
   tmp = histogram(DZ,min=18,max=ceil(max(DZ,/nan)),binsize=1,reverse_indices=ri_dz,locations=binv)

   hsize = n_elements(tmp)

   if tmp[hsize-1] eq 0 then begin

      tmp = tmp[0:hsize-2]
      hsize = n_elements(tmp)

   endif

   case 1 of
      hsize le 12: begin
         ;Set rhoi for 18 < reflectivity < 30
         rhoi[ri_dz[ri_dz[0]:ri_dz[hsize]-1]] = 400.0
      end

      hsize gt 12 and hsize le 17: begin
         ;Set rhoi for 18 < reflectivity < 30
         rhoi[ri_dz[ri_dz[0]:ri_dz[12]-1]] = 400.0

         ;Set rhoi for 40 < reflectivity < 35
         rhoi[ri_dz[ri_dz[12]:ri_dz[hsize]-1]] = 600.0
      end

      hsize gt 17 and hsize le 22: begin
         ;Set rhoi for 18 < reflectivity < 30
         rhoi[ri_dz[ri_dz[0]:ri_dz[12]-1]] = 400.0

         ;Set rhoi for 40 < reflectivity < 35
         if ri_dz[12] ne ri_dz[17] then rhoi[ri_dz[ri_dz[12]:ri_dz[17]-1]] = 600.0

         ;Set rhoi for 35 < reflectivity < 40
         rhoi[ri_dz[ri_dz[17]:ri_dz[hsize]-1]] = 700.0
      end

      hsize gt 22: begin
         ;Set rhoi for 18 < reflectivity < 30
         rhoi[ri_dz[ri_dz[0]:ri_dz[12]-1]] = 400.0

         ;Set rhoi for 40 < reflectivity < 35
         if ri_dz[12] ne ri_dz[17] then rhoi[ri_dz[ri_dz[12]:ri_dz[17]-1]] = 600.0

         ;Set rhoi for 35 < reflectivity < 40
         rhoi[ri_dz[ri_dz[17]:ri_dz[22]-1]] = 700.0

         ;Set rhoi for reflectivity > 40
         rhoi[ri_dz[ri_dz[22]:ri_dz[hsize]-1]] = 800.0
      end
   endcase

   ;Find where the altitude is less than the melting level or the temperature is greater
   ;than temp, and set rhoi to 0 there
   case 1 of
      ;Case #1, temp keyword is set
      keyword_set(temp):Begin
         above_temp = where(lvl_var gt temp,above_temp_count)
         if above_temp_count gt 0 then rhoi[above_temp] = 0
      end  ;Case #1

      ;Case #2,  melting_level keyword is set
      keyword_set(mlevel):Begin
         melting_level=mlevel
         below_ml = where(lvl_var lt melting_level,below_ml_count)
         if below_ml_count gt 0 then rhoi[below_ml] = 0
      end  ;Case #2

      ;Case #3, neither temp nor melting_level keywords set
      else:Begin
         ;Assume input is temp, and use -10C threshold
         above_temp = where(lvl_var gt -10.,above_temp_count)
         if above_temp_count gt 0 then rhoi[above_temp] = 0
      end  ;Case #3
   endcase


   ;Calculate ice water mass
   iwmass = (1000.*!dpi*(rhoi/rhoa)*(N0i^(3d/7d))*(factor*dz_invlog)^(4d/7d))/gdiv

   ;Sum in the vertical to get iwcp
   iwcp = total(iwmass*vertspacing,alt_dimension,/nan)

endif else begin

   iwmass = (replicate(0.0,size(dz_invlog,/dimension)))/gdiv

   iwcp = total(iwmass*vertspacing,alt_dimension,/nan)

endelse

return,iwcp

end
