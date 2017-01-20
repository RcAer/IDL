;+
; NAME:
;   month_to_number
;
; PURPOSE:
;   This program takes an input string(s) containing a month name (or month abbreviation) and 
;   returns the month number as a string.  It works by comparing the input string to a month name
;   string.  if you are using an abbreviation, make sure to set the n keyword.
;
; USAGE:
;   result  = month_to_number(imth) 
;
; PARAMETERS:
;   imth -- The input month name(s).  This can be a scalar or a vector. 
;
; KEYWORDS:
;   n -- The length of the string to compare.  If not set, the entire input string(s) are compared.
;
;   fold_case -- Set this keyword to 1 to ignore the case of the string.  If not set, the matching
;                is case sensitive.
;
; RESULT:
;   A string array containing the month number of the input(s). This will be the same size as imth.
;
; REQUIRED PROGRAMS:
;   None
;
; AUTHOR:
;   Christina Kalb
;   kalb@ucar.edu
;
; DATE:
;   May 30, 2012
;-

function month_to_number,imth,n=n,fold_case=fc

;Error handling.  Return to previous program upon error
on_error,2

;Check inputs
if n_params() ne 1 then Message,$
	'usage: result = month_to_number(imth)'

;If n was input, check to make sure it is either a scalar or array the same size as imth
nsize = n_elements(n)

case 1 of
  nsize eq 0:Begin
	n = strlen(imth)
  end

  nsize eq 1 and nsize ne n_elements(imth):Begin
	n = replicate(n,n_elements(imth))
  end

  nsize eq n_elements(imth):Begin
	;Do nothing
  end

  else:Begin
	Message,'n must either be a undefined, a scalar, or the same size as imth'
  end
endcase

;Set up an array for the output data
mth_num = strarr(n_elements(imth))

;Convert the month name to number
for mn=0,n_elements(imth)-1 do begin

   case 1 of
      strcmp(imth[mn],'January',n[mn],fold_case=fc) eq 1:Begin
         mth_num[mn] = '01'
      end

      strcmp(imth[mn],'February',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '02'
      end

      strcmp(imth[mn],'March',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '03'
      end

      strcmp(imth[mn],'April',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '04'
      end

      strcmp(imth[mn],'May',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '05'
      end

      strcmp(imth[mn],'June',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '06'
      end

      strcmp(imth[mn],'July',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '07'
      end

      strcmp(imth[mn],'August',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '08'
      end

      strcmp(imth[mn],'September',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '09'
      end

      strcmp(imth[mn],'October',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '10'
      end

      strcmp(imth[mn],'November',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '11'
      end

      strcmp(imth[mn],'December',n[mn],fold_case=fc) eq 1:Begin
	 mth_num[mn] = '12'
      end
   endcase

endfor

return,mth_num

end
