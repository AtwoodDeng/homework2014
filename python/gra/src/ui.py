from Tkinter import *
import cv2
from PIL import Image, ImageTk
from tkFileDialog import *
import os
from graphic import *


POISSON = 1
STITCH = 2

class UI:


	def chooseBack(self):
		filePath = askopenfilename()
		self.backPath = filePath
		self.out('Open Back Image:\n'+filePath)
		self.back = cv2.imread(self.backPath)
		self.showCVImgAtPos(self.back,(400,300))
		# self.showImg(filePath)

	def chooseFront(self):
		filePath = askopenfilename()
		self.frontPath = filePath
		self.out('Open Front Image:\n'+filePath)
		self.front = cv2.imread(self.frontPath)
		# self.showImg(filePath)
		self.showCVImgAtPos(self.front,(400,300))


	
	def onPoisson(self):
		self.state = POISSON
		self.out("change state to POISSON")

	def onStitch(self):
		self.state = STITCH
		self.state_s = 0
		self.out("change state to STITCH")

	def onStitch1(self):
		self.state = STITCH
		self.state_s = 1
		self.out("change state to STITCH1")
	def onStitch2(self):
		self.state = STITCH
		self.state_s = 2
		self.out("change state to STITCH2")
	def onStitch3(self):
		self.state = STITCH
		self.state_s = 3
		self.out("change state to STITCH3")
	def onStitch4(self):
		self.state = STITCH
		self.state_s = 4
		self.out("change state to STITCH4")
	def onStitch5(self):
		self.state = STITCH
		self.state_s = 5
		self.out("change state to STITCH5")

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
		self.poissonBtn = Button(self.opFrame,width=200,text = "stitch" ,command=self.onStitch )
		self.poissonBtn.pack(fill=X)
		self.poissonBtn = Button(self.opFrame,width=200,text = "stitch_corner_range" ,command=self.onStitch1 )
		self.poissonBtn.pack(fill=X)
		self.poissonBtn = Button(self.opFrame,width=200,text = "stitch_non_max" ,command=self.onStitch2 )
		self.poissonBtn.pack(fill=X)
		self.poissonBtn = Button(self.opFrame,width=200,text = "stitch_key_points" ,command=self.onStitch3 )
		self.poissonBtn.pack(fill=X)
		self.poissonBtn = Button(self.opFrame,width=200,text = "stitch_key_match" ,command=self.onStitch4 )
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
		self.showImgAtPathPos(path,(400,300))
		return

	def showImgAtPathPos(self,path,pos):
		if False == os.path.exists(path):
		    return	
		self.fontImage = Image.open(path)
		self.showImgAtPos(self.fontImage,pos)

	def showImgAtPos(self,img,pos):
		self.fontPhoto = ImageTk.PhotoImage(img)
		self.show.delete("front")
		self.show.create_image(pos[0],pos[1],image=self.fontPhoto,tag="front")
		self.show.update()
		return

	def showCVImgAtPos(self,cvImg,pos):

		h,w,k = cvImg.shape
		print cvImg.shape
		img = Image.new("RGB" , (w,h))
		imgp = img.load()
		for i in range(h):
			for j in range(w):
				imgp[j,i] = (cvImg[i,j,2],cvImg[i,j,1],cvImg[i,j,0])
		
		self.showImgAtPos(img,pos)
		return

	def saveCVImgAtPos(self,cvImg,pos):
		outPath = os.getcwd()+'/out/'+str(self.imageCount)+'.jpg'
		self.out( outPath )
		cv2.imwrite(outPath,cvImg)
		self.imageCount += 1
		self.showImgAtPathPos(outPath,pos)

	def onClick(self,event):
		# a1 = cv2.imread('res/all5.jpg')
		# a2 = cv2.imread('res/all6.jpg')
		# res = stitch(a1,a2)
		# self.saveCVImgAtPos(res,(400,300))

		# back = cv2.imread('res/mosea.jpg')
		# front = cv2.imread('res/ship1.jpg')
		# self.out('begin poison blending')
		# res = poisson_blending(back,front,[event.x,event.y],[800,600],POISSON_ALPHA)
		# self.saveCVImgAtPos(res,(400,300))
		# self.out('poisson editting finished')

		if self.state == POISSON :
			if self.back == None or self.front == None:
				self.out('no input image')
				return
			self.out('begin poison blending')
			h,w,k = self.back.shape
			res = poisson_blending(self.back,self.front,[event.x,event.y],[h,w],POISSON_ALPHA)
			self.saveCVImgAtPos(res,(400,300))
			self.out('poisson editting finished')
			self.state = 0
		elif self.state == STITCH:
			if self.back == None or self.front == None:
				self.out('no input image')
				return
			self.out('begin poison blending')
			h,w,k = self.back.shape
			res = stitch(self.back,self.front,self.state_s)
			self.saveCVImgAtPos(res,(400,300))
			self.out('poisson editting finished')
			self.state = 0
		else:
			self.out('you click (' + str(event.x) + ',' + str(event.y) + ')')

