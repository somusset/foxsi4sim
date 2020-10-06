PRO sophie_linecolors, help=help, nmax=nmax, out_rgb=out_rgb

; this procedure is inspired from hsi_linecolors
; sophie_linecolors, /help >> will plot the colors and their indices in a small window
DEFAULT, nmax, 30
tvlct, r,g,b, /get

; I use a list so that one can add easily more colors in that list, without changing anything else in the procedure
colorlist = list()

; I use the color names defined in IDL. To see the available colors go to https://www.harrisgeospatial.com/docs/FormattingSymsAndLines.html
; the RGB colors of the color specified (array of 3 values) are added to the list one by one
colorlist.add, !color.black
colorlist.add, !color.white
colorlist.add, !color.firebrick
colorlist.add, !color.orange_red
IF nmax GE 10 THEN colorlist.add, !color.dark_orange
colorlist.add, !color.orange
IF nmax GE 10 THEN colorlist.add, !color.gold
IF NMAX GE 10 THEN colorlist.add, !color.green_yellow
colorlist.add, !color.lime_green
IF NMAX GE 10 THEN colorlist.add, !color.forest_green
colorlist.add, !color.dark_green
IF NMAX GE 10 THEN colorlist.add, !color.light_sea_green
IF NMAX GE 10 THEN colorlist.add, !color.dark_turquoise
colorlist.add, !color.dodger_blue
colorlist.add, !color.medium_blue
colorlist.add, !color.indigo
colorlist.add, !color.medium_slate_blue
colorlist.add, !color.purple
colorlist.add, !color.dark_red
colorlist.add, !color.sienna
colorlist.add, !color.lemon_chiffon
colorlist.add, !color.moccasin
colorlist.add, !color.peach_puff
colorlist.add, !color.misty_rose
colorlist.add, !color.lavender_blush
colorlist.add, !color.honeydew
colorlist.add, !color.pale_turquoise
colorlist.add, !color.light_sky_blue
colorlist.add, !color.powder_blue
colorlist.add, !color.alice_blue
colorlist.add, !color.magenta
colorlist.add, !color.lime
colorlist.add, !color.dark_grey
colorlist.add, !color.grey
colorlist.add, !color.crimson
colorlist.add, !color.saddle_brown
colorlist.add, !color.dark_magenta
colorlist.add, !color.blue




; calculate the number of colors
used = n_elements(colorlist)

; conversion from list to array, then create the RGB arrays
colo = colorlist.toarray() ; this becomes an array of dimension used*3
r = reform(colo[*,0])
g = reform(colo[*,1])
b = reform(colo[*,2])

out_rgb = colo

; construct the linecolors
tvlct, r,g,b

; if help keyword is provided, the colors and their indices will be displayed
if keyword_set(help) and ( (!d.name eq 'X') or (!d.name eq 'WIN') ) then begin
  bar=rebin(indgen(used),32*used,used*4,/sample)
  wtemp=!d.window
  wdef,zz,/ur,image=bar
  tv,bar
  xyouts,indgen(used)*32+8, 32,strtrim(sindgen(used),2),/device,size=1.5,charthick=2.
  if wtemp ne -1 then wset,wtemp
endif

END

