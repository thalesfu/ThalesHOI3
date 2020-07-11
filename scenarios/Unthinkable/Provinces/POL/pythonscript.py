import os, glob

path = ''

for infile in glob.glob( os.path.join(path, '*.txt') ):
	file = open(infile, 'a')
	file.write('1945.06.07 = {\n\tcontroller = POL\n}')
	file.close()
