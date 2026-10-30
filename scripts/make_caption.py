#!/usr/bin/env python3
"""Make a transparent 1080x1920 caption PNG: big centered distressed cream poster text,
with optional bold red callout bar.
Usage:
  python3 make_caption.py OUT.png "BIG CAPTION LINE|SECOND LINE" [--bar "OUT NOW"] [--y 1350]
  '|' splits lines. Default tagline caption: "The Scariest Funny Movie this year!"
Needs: pip install pillow numpy
"""
import argparse, os, numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
HERE=os.path.dirname(os.path.abspath(__file__)); FD=os.path.join(HERE,'..','assets','fonts')
ARCH=os.path.join(FD,'ArchivoBlack-Regular.ttf'); OSW=os.path.join(FD,'Oswald-VariableFont_wght.ttf')
RED=(226,44,30); CREAM=(247,238,220); W,H=1080,1920
def distress(l,amt=.22):
    a=np.array(l); m=np.random.rand(*a.shape[:2])
    m=np.array(Image.fromarray((m*255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2)))/255
    a[...,3]=(a[...,3]*np.where(m<amt*0.6+0.25*(m<0.3),0.35,1)).astype(np.uint8); return Image.fromarray(a)
ap=argparse.ArgumentParser(); ap.add_argument('out'); ap.add_argument('text')
ap.add_argument('--bar'); ap.add_argument('--y',type=int,default=1300); ap.add_argument('--size',type=int,default=96)
a=ap.parse_args()
im=Image.new('RGBA',(W,H)); y=a.y
if a.bar:
    f=ImageFont.truetype(ARCH,64); d=ImageDraw.Draw(im); b=d.textbbox((0,0),a.bar,font=f); w,h=b[2]-b[0],b[3]-b[1]
    x=(W-w)/2; d.rectangle([x-38,y,x+w+38,y+h+28],fill=RED); d.text((x-b[0],y+14-b[1]),a.bar,font=f,fill=CREAM); y+=h+60
for line in a.text.split('|'):
    size=a.size
    while True:
        f=ImageFont.truetype(OSW,size)
        try: f.set_variation_by_axes([700])
        except Exception: pass
        if ImageDraw.Draw(im).textlength(line,font=f)<=W-100 or size<40: break
        size-=4
    l=Image.new('RGBA',(W,H)); d=ImageDraw.Draw(l); w=d.textlength(line,font=f)
    for dx,dy in ((4,4),):  # drop shadow for readability
        d.text(((W-w)/2+dx,y+dy),line,font=f,fill=(0,0,0,200))
    d.text(((W-w)/2,y),line,font=f,fill=CREAM)
    im.alpha_composite(distress(l)); y+=int(size*1.25)
im.save(a.out); print('Wrote',a.out)
