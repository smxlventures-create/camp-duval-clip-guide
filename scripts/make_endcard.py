#!/usr/bin/env python3
"""Build the clean Camp Duval end card (1080x1920): "Available on / CampDuval.com"
plus the iTunes/Apple and Amazon logos. Nothing else (no "Apple and Amazon" text).
Usage: python3 make_endcard.py OUT.png      Needs: pip install pillow numpy
"""
import os, sys, numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
HERE=os.path.dirname(os.path.abspath(__file__)); A=os.path.join(HERE,'..','assets')
ARCH=A+'/fonts/ArchivoBlack-Regular.ttf'; OSW=A+'/fonts/Oswald-VariableFont_wght.ttf'
CREAM=(247,238,220); GOLD=(250,196,48); W,H=1080,1920
ys,xs=np.mgrid[0:H,0:W].astype(np.float32); r=np.sqrt(((xs-W/2)/W)**2+((ys-H*.5)/H)**2)
g=np.clip(1-r*1.6,0,1); arr=np.array([10,8,10],np.float32)+np.array([92,30,12],np.float32)*g[...,None]**1.6
arr+=np.random.normal(0,9,(H,W,1)); im=Image.fromarray(np.clip(arr,0,255).astype(np.uint8)).convert('RGBA')
d=ImageDraw.Draw(im)
def ctext(t,f,y,fill,glow=None):
    l=Image.new('RGBA',(W,H)); dd=ImageDraw.Draw(l); w=dd.textlength(t,font=f); dd.text(((W-w)/2,y),t,font=f,fill=fill)
    if glow:
        gl=Image.new('RGBA',(W,H),glow+(0,)); gl.putalpha(l.getchannel('A').filter(ImageFilter.GaussianBlur(14)).point(lambda v:int(v*.6))); im.alpha_composite(gl)
    im.alpha_composite(l)
o=ImageFont.truetype(OSW,64)
try: o.set_variation_by_axes([700])
except Exception: pass
ctext('Available on',o,760,CREAM); ctext('CampDuval.com',ImageFont.truetype(ARCH,104),850,GOLD,glow=(255,90,20))
h=90; it=Image.open(A+'/logos/itunes-white.png').convert('RGBA'); am=Image.open(A+'/logos/amazon-white.png').convert('RGBA')
it=it.crop(it.getbbox()); am=am.crop(am.getbbox()); it=it.resize((int(it.width*h/it.height),h)); ah=int(h*.85); am=am.resize((int(am.width*ah/am.height),ah))
x=(W-(it.width+80+am.width))//2; im.alpha_composite(it,(x,1030)); im.alpha_composite(am,(x+it.width+80,1030+(h-ah)//2+6))
im.convert('RGB').save(sys.argv[1] if len(sys.argv)>1 else 'endcard.png'); print('Wrote end card')
