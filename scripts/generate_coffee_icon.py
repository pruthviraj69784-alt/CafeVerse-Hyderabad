import sys, subprocess, os
try:
    from PIL import Image, ImageDraw
except Exception:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--user', 'Pillow'])
    from PIL import Image, ImageDraw

cwd = os.path.dirname(os.path.dirname(__file__))

def make_coffee(path):
    size = 1024
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((size*0.05, size*0.05, size*0.95, size*0.95), fill=(245, 238, 230, 255))
    cup_color = (108, 66, 33, 255)
    draw.rounded_rectangle((size*0.18, size*0.45, size*0.82, size*0.75), radius=int(size*0.06), fill=cup_color)
    draw.ellipse((size*0.2, size*0.38, size*0.8, size*0.5), fill=(94, 49, 22, 255))
    draw.ellipse((size*0.75, size*0.5, size*0.92, size*0.72), outline=cup_color, width=int(size*0.06))
    steam_color = (255,255,255,180)
    for i,off in enumerate([-1,0,1]):
        x = size*0.45 + off*size*0.05
        draw.line((x, size*0.28, x, size*0.16), fill=steam_color, width=int(size*0.03))
    img.save(path, 'PNG')

paths = []
for proj in ('brewhub','admin'):
    outdir = os.path.join(cwd, proj, 'assets')
    os.makedirs(outdir, exist_ok=True)
    outpath = os.path.join(outdir, 'icon.png')
    make_coffee(outpath)
    paths.append(outpath)

print('Wrote:\n' + '\n'.join(paths))
