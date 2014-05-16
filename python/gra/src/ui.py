from Tkinter import *
import cv2
from PIL import Image, ImageTk
from tkFileDialog import *
import os
from graphic import *


POISSON = 1
class UI:


	def chooseBack(self):
		filePath = askopenfilename()
		self.backPath = filePath
		self.out('Open Back Image:\n'+filePath)
		self.showImg(filePath)

	def chooseFront(self):
		filePath = askopenfilename()
		self.frontPath = filePath
		self.out('Open Front Image:\n'+filePath)
		self.showImg(filePath)

	
	def onPoisson(self):
		self.state = POISSON
		self.out("change state to POISSON")
	def out(self,str):
		self.label.config(text=str)

	def __init__(self):

		self.win = Tk()
		self.win.geometry('1000x600')
		self.win.title('group graphic')

		# ### frame ####

		self.showFrame = Frame(self.win,width=800,height=600,bg='black')
		self.showFrame.pack(side=LEFT)

		self.opFrame = Frame(self.win,width=200,height=600,bg='black')
		self.opFrame.pack(side=RIGHT)

		self.show = Canvas( self.showFrame,
			width = 800,
			height = 600,
			bg = 'white')
		self.show.pack( fill=BOTH , expand =1)
		self.show.bind('<Button-1>',self.onClick)

		#label
		self.label=Label(self.opFrame,text='For Test',bg='white',wraplength=200,justify='left')
		self.label.pack(side=TOP,fill=X)

		# ### buttons ###

		self.backBtn = Button(self.opFrame,width=200,text = "background" ,command=self.chooseBack )
		self.backBtn.pack(fill=X)
		self.fontBtn = Button(self.opFrame,width=200,text = "front" ,command=self.chooseFront )
		self.fontBtn.pack(fill=X)
		self.poissonBtn = Button(self.opFrame,width=200,text = "poisson" ,command=self.onPoisson )
		self.poissonBtn.pack(fill=X)

		# initilize
		self.frontPath = ''
		self.state = 0
		self.imageCount = 0

		# im = cv2.imread("res/all.jpg")
		# [h,w,d] = im.shape
		# self.out( "h %d w %d d %d" % (h,w,d))

		self.win.mainloop()


	def showImg(self,path):
		self.showImgAtPos(path,0,0)
		return

	def showImgAtPos(self,path,posX,posY):
		if False == os.path.exists(path):
		    return
		self.fontImage = Image.open(path)
		self.fontPhoto = ImageTk.PhotoImage(self.fontImage)
		self.show.delete("front")
		self.show.create_image(posX,posY,image=self.fontPhoto,tag="front")
		self.show.update()
		return
	def showCVImgAtPos(self,posX,posY,cvImg):
	    outPath = os.getcwd()+'/out/'+str(self.imageCount)+'.jpg'
	    self.out(outPath)
	    cv2.imwrite(outPath,cvImg)
	    self.imageCount += 1
	    self.showImgAtPos(outPath,posX,posY)


	def onClick(self,event):
		a1 = cv2.imread('res/all5.jpg')
		a2 = cv2.imread('res/all6.jpg')
		res = stitch(a1,a2)
		self.showCVImgAtPos(400,300,res)

		# back = cv2.imread('res/mosea.jpg')
		# front = cv2.imread('res/ship1.jpg')
		# self.out('begin poison blending')
		# res = poisson_blending(back,front,[event.x,event.y],[800,600],POISSON_ALPHA)
		# self.showCVImgAtPos(400,300,res)
		# self.out('poisson editting finished')

		# if ( self.state == POISSON):
		# 	back = cv2.imread(self.backPath)
		# 	front = cv2.imread(self.frontPath)
		# 	self.out('begin poison blending')
		# 	res = poisson_blending(back,front,[event.x,event.y],[800,600],POISSON_ALPHA)
		# 	self.showCVImgAtPos(400,300,res)
		# 	self.out('poisson editting finished')
		# else:
		#     self.showImgAtPos(self.frontPath,event.x,event.y)
