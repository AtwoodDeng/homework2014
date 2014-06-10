import cv2
import numpy as np
import scipy
import scipy.sparse
import scipy.sparse.linalg
from math import ceil, exp, pi, cos, sin
from scipy.ndimage import convolve1d, gaussian_filter
from sklearn.neighbors import NearestNeighbors
from numpy.linalg import inv

############# poisson ###########

MASK_LIMIT_LIGHT=240
POISSON_ALPHA = 0.4
MASK_BORDER = 3
MASK_INNER = 1
MASK_EDGE = 2
MASK_OUTER = 0
CORNER_THRESHOLD = 500


GRAD_KERN = np.array([1, 0, -1], dtype=np.float)
NON_MAX_SIZE = (6,6)
NON_MAX_FLAG_MAX = 1
NON_MAX_FLAG_NON = 0
SIFT_SIZE = (8,8)
SIFT_BLOCK_SIZE = (32,32)
IGNORE_K = 2

def neighbor(p):
	(i,j) = p
	res = []
	res.append((i+1,j))
	res.append((i-1,j))
	res.append((i,j+1))
	res.append((i,j-1))
	return res

def check_in(p,rect):
	return p[0] >= rect[0] and p[0] < rect[0]+rect[2] and p[1] >= rect[1] and p[1] < rect[1]+rect[3]

def getG(mat,i,j):
	s = sum( np.int32(mat[p]) for p in neighbor((i,j)))
	m = - np.int32(mat[i,j]) * 4
	r = m + s
	return r

def laplacian(mat):
    [w,h,d] = mat.shape
    res = np.zeros((w,h,d))
    for i in range(1,w-1):
        for j in range(1,h-1):
        	res[i,j] = getG(mat,i,j)
    return res

def from_mat_to_mask(mat):
	[w,h,d] = mat.shape
	sumMat = ( mat[:,:,0]/3 +mat[:,:,1]/3 +mat[:,:,2]/3 )
	res = sumMat / MASK_LIMIT_LIGHT
	res = 1 - res
	# SET THE OUTER PIXEL TO 0

	return res

def make_border(mask):
	[w,h] = mask.shape
	for i in range(0,w):
		for j in range(0,h):
			if mask[i,j] == 0:
				continue
			tem = neighbor((i,j))
			tem = filter(lambda x: check_in(x,(0,0,w,h)), tem)
			tem = filter(lambda x: mask[x] == 0 , tem)
			if len(tem) > 0:
				mask[i,j] = MASK_EDGE
			else:
				mask[i,j] = MASK_INNER

	for i in range(0,w):
		for j in range(0,h):
			if mask[i,j] in (MASK_OUTER,MASK_EDGE):
				continue
			tem = neighbor((i,j))
			tem = filter(lambda x: check_in(x,(0,0,w,h)), tem)
			tem = filter(lambda x: mask[x] in (MASK_OUTER,MASK_EDGE) , tem)
			if len(tem) > 0:
				mask[i,j] = MASK_BORDER 
			else:
				mask[i,j] = MASK_INNER 


def compute_mask(mask):
    [w,h]=mask.shape
    pixel_dict = np.zeros((w,h))
    ind_to_pixel = list()

    for i in range(0, w):
        for j in range(0, h):
            if mask[i,j] in (MASK_BORDER,MASK_INNER) :
                pixel_dict[i,j]=len(ind_to_pixel)
                ind_to_pixel.append((i, j))

    return pixel_dict, ind_to_pixel

def poisson_blending(back,front,pos,size,alpha):
	res = back.copy()
	[bw,bh,bd] = back.shape
	[w,h,d] = front.shape

	print '======= begin blending ====='
	x=pos[1]-w/2
	if x < 0 : x = 0
	if x >= bw-w : x = bw-w-1
	y=pos[0]-h/2
	if y < 0 : y = 0
	if y >= bh-h : y = bh-h-1


	mask = from_mat_to_mask(front)
	make_border(mask)
	print '====== find border ======'

	# in order to work out :
	# |Np|f_p - sum(f_q) = sum(f'_q) + sum(v_pq)
	# we regard all the pixels in the mask as a vector x 
	# the equation can be represent as Ax = b
	# where A is an N * N matrix
	# N is the total number of pixels in the mask

	# first we need to get all the masked pixels
	pixel_dict, ind_to_pixel = compute_mask(mask)

	# then we get the number of pixels
	nPix = len(ind_to_pixel)

	# we use the following function to represent vpq
	# v_pq = g_p - g_q
	front_lap = laplacian(front)
	back_lap = laplacian(back[x:x+w,y:y+h])
	grad_mix = alpha * front_lap + (1-alpha)*back_lap


	# we do this in each channel of the matrix
	for channel in range(0,d):
		print '===== channel %d ========' % (channel)
		b_vpq = np.ndarray([nPix],dtype=np.int32)
		A_in  = scipy.sparse.dok_matrix((nPix,nPix),dtype=np.int32)
		for i in range(0 , nPix):
			if i % 5000 == 0 :
				print '====== i = %d ======' %(i)
			pixel = ind_to_pixel[i]
			if mask[pixel] == MASK_BORDER: # at border
				A_in[i,i]= 1
				b_vpq[i] = np.int32(back[pixel[0]+x,pixel[1]+y][channel])
			else:	
				neighbors = neighbor(pixel)
				neighbors = filter(lambda x: check_in(x,(0,0,w,h)), neighbors)
				for px in neighbors:
					if pixel_dict[px] > 0:
						A_in[i,pixel_dict[px]] = -1
				A_in[i,i] = 4
				b_vpq[i] = -grad_mix[pixel][channel]

		# solve the equation Ax = b
		x_vec = scipy.sparse.linalg.spsolve(A_in.tocsc() , b_vpq)
		for i,px in enumerate(ind_to_pixel):
			if x_vec[i] > 255:
				x_vec[i] = 255
			if x_vec[i] < 1:
				x_vec[i] = 1
			res[px[0]+x,px[1]+y,channel] = np.int8(x_vec[i])

	return res


########### stitch ################

def stitch_is_cor(img):
	cor_R = img2harris_R(img)
	is_cor = cor_R > CORNER_THRESHOLD

	return is_cor * 125 + img[:,:,0]

def stitch_non_max(img):
	cor_R = img2harris_R(img)
	non_max = non_max_sup(cor_R,NON_MAX_SIZE)
	res = img.copy() / 2 
	(w,h,d) = res.shape
	for i in range(w):
		for j in range(h):
			res[i,j,2] = 255 if non_max[i,j] ==  NON_MAX_FLAG_MAX else res[i,j,2];
			res[i,j,1] = 255 if non_max[i,j] ==  NON_MAX_FLAG_MAX else res[i,j,2];
			res[i,j,0] = 255 if non_max[i,j] ==  NON_MAX_FLAG_MAX else res[i,j,2];

	return res


def stitch(img1,img2,step = 0):
	# cor_R = img2harris_R(img2)
	# is_cor = cor_R > CORNER_THRESHOLD
	# non_max = non_max_sup(cor_R,NON_MAX_SIZE)
	# key_mat = is_cor * non_max
	# key_pts = np.transpose(np.where(key_mat))

	# print sift( img2gray(img1) , (100,100) , 5 )

	if step == 1 :
		return stitch_is_cor(img1)
	if step == 2 :
		return stitch_non_max(img1)

	print '========= begin stitch %d ==========' %(step)
	print '========= get features =========='
	fea_img = []
	fea_ind_img = []
	for img in (img1,img2):
		print '========= in a image ========='
		cor_R = img2harris_R(img)
		print 'cor R finished'
		is_cor = cor_R > CORNER_THRESHOLD
		non_max = non_max_sup(cor_R,NON_MAX_SIZE)
		key_mat = is_cor*non_max
		if step == 3:
			return key_mat * 150 + img1[:,:,0] / 2
		key_pts = np.transpose(np.where(key_mat))
		print 'find all key points'
		fea_pts = []
		fea_ind = []
		for pt in key_pts:
			features = sift( img2gray(img), pt, SIFT_SIZE )
			for f in features:
				fea_pts.append(f)
				fea_ind.append(pt)
		print 'get all features'
		fea_img.append(fea_pts)
		fea_ind_img.append(fea_ind)


	print '========== neighbors ==========='
	desc1, desc2 = fea_img[0], fea_img[1]
	indc1, indc2 = fea_ind_img[0], fea_ind_img[1]
	nbrs = NearestNeighbors(n_neighbors=2).fit(desc2)

	dists, match = nbrs.kneighbors(desc1)
	mmatch = []
	for i in range(len(match)):
		d0 = desc1[i]
		d1 = desc2[match[i,0]]
		d2 = desc2[match[i,1]]
		sd1 = np.sqrt(np.sum((d1-d0)**2))
		sd2 = np.sqrt(np.sum((d2-d0)**2))
		
		p0 = indc1[i]
		p1 = indc2[match[i,0]]
		h,w,k = img2.shape

		if ((sd1/sd2) > IGNORE_K or (sd2/sd1) > IGNORE_K ) and (p0[1] > p1[1] + w / 3):
			mmatch.append(match[i,0])
		else:
			mmatch.append(-1)

	if step == 4 :
		return feature_match_img(img1,indc1,img2,indc2,mmatch)

	# return feature_match_img(img1,indc1,img2,indc2,mmatch)

	print '===== transform the image ======'
	pts1 = []
	pts2 = []
	for i in range(len(mmatch)):
		if mmatch[i] >= 0 :
			pts1.append(indc1[i])
			pts2.append(indc2[mmatch[i]])
	trans_m ,trans_b = getTransformMat(pts2,pts1)

	print 'trans m and trans_b'
	print trans_m
	print trans_b

	return transformAndAdd(img1,img2,trans_m,trans_b)


def feature_match_img(img1,indc1,img2,indc2,match):
	h1,w1,k1 = img1.shape
	h2,w2,k2 = img2.shape

	res_mat = np.ndarray((max(h1,h2),w1+w2,3),np.int32)

	res_mat[0:h1,0:w1,:] = img1
	res_mat[0:h2,w1:w1+w2,:] = img2

	print 'len %d %d ' % (len(indc1),len(indc2))

	#for i in range(len(match)):
	for i in range(max(len(match),100)):
		if ( match[i] == -1 ):
			continue
		p1 = (indc1[i][1],indc1[i][0])
		p2 = (indc2[match[i]][1]+w1,indc2[match[i]][0])
		cv2.line(res_mat,p1,p2,cv2.cv.RGB(25*i,0,0))

	return res_mat

def img2gray(img):
	return cv2.cvtColor(img , cv2.COLOR_BGR2GRAY)

def img2harris_R(image,size=3,k=0.04):
	gray = img2gray(image)
	gray = np.float32(gray)
	i_x , i_y = gradient1d(gray)
	ma = i_x * i_x
	mb = i_x * i_y
	mc = i_y * i_y
	ma = gaussian_filter(ma,size)
	mb = gaussian_filter(mb,size)
	mc = gaussian_filter(mc,size)
	mac = ma + mc
	R = ma * mc - mb * mb - k * mac * mac
	return R

def gradient1d(mat):
	return (convolve1d(mat, GRAD_KERN, axis=1, mode="nearest"), convolve1d(mat, GRAD_KERN, axis=0, mode="nearest"))
def non_max_sup(mat,size):
	(h,w) = mat.shape
	(a,b) = size
	res = np.ones((h,w)) * NON_MAX_FLAG_MAX
	for i in range(h):
		for j in range(w):
			for p in range((a+1)/2):
				for q in range((b+1)/2):
					if p == 0 and q == 0 :
						continue
					if check_in(((i+p),(j+q)),(0,0,h,w)):
						if ( mat[i][j] > mat[i+p][j+q]):
							res[i+p][j+q] = NON_MAX_FLAG_NON
						else:
							res[i][j] = NON_MAX_FLAG_NON
	return res;

def gaussian( h , w , center , sigma):
	mat = np.ndarray((h,w),np.float)
	for i in range(h):
		for j in range(w):
			x = i - center[0]
			y = j - center[1]
			mat[i][j] = exp( 1.0 * (- x**2 - y**2 ) / ( 2.0 * sigma * sigma) ) 
	return mat

def direct_hist(mat,block_angle):
	h,w = mat.shape
	size = ( h + w ) / 2
	# get the gradient in x ,y direction
	gx , gy = gradient1d(mat)

	# get the magnitude and angles from the gradient map
	# the magnitude should be filter by gaussian function
	center = (h/2 , w/2)
	mag = (np.sqrt(gx**2+gy**2)*gaussian(h,w,center,1.5*size)).flatten()
	ang = (np.arctan2(gy,gx)/pi*180).flatten()

	# get the histgrom in the block
	indices = np.searchsorted(np.arange(-180+block_angle/2,180+block_angle/2,block_angle),ang)
	hist = np.zeros((360/block_angle))
	for i in range(indices.shape[0]):
		hist[indices[i]%(360/block_angle)] += mag[i]
	return hist

def gen_block(img, pt, theta,size = SIFT_BLOCK_SIZE):
	res = np.ndarray(size,np.float)
	for i in range(size[0]):
		for j in range(size[1]):
			y = i - size[0] / 2 - 0.5
			x = j - size[1] / 2 - 0.5
			x_r = x * cos(theta) - y * sin(theta)
			y_r = x * sin(theta) + y * cos(theta)
			res[i][j] = extral_mat_value(img, y_r + pt[0] , x_r + pt[1])
	return res
 
def extral_mat_value(mat , row , col):
	assert len(mat.shape) == 2, 'can only get value of 2-d mat '
	h,w = mat.shape
	r = int(row)
	c = int(col)
	if not check_in((r,c),(0,0,h-1,w-1)):
		return 0.0
	else:
		rb = row - r
		cb = col - c
		ra = 1 - rb
		ca = 1 - cb 
		return mat[r][c] * ra * ca + mat[r][c + 1] * ra * cb + mat[r + 1][c] * rb * ca + mat[r + 1][c + 1] * rb * cb

# get the sift attribution of the pixel : p 
def sift(mat,p,size):
	neig_pix = mat[p[0]-size[0]:p[0]+size[0]+1,p[1]-size[1]:p[1]+size[1]+1]
	h , w = neig_pix.shape
	
	hist = direct_hist(neig_pix,10)
	
	# find the max and second max value
	h_max_index = hist.argmax(axis=0)
	h_max = float(hist[h_max_index])

	# get the direction list
	index2angle = lambda x: (x - 18) * pi / 18
	directions = list()

	# the direction with value larger than 0.8 * max will be consider
	for i,val in enumerate(hist):
		if val > 0.8 * h_max:
			directions.append(index2angle(i))

	# get the hist of all the directions
	features = list()
	size = [size[0]*4 , size[1]*4] 
	for index , theta in enumerate(directions):
		block = gen_block(mat, p , theta,size)
		feature = np.zeros((128), np.float)
		i_d = 0
		for i in range(4):
			for j in range(4):
				i_size = size[0] / 4
				j_size = size[1] / 4 
				block_d = block[i*i_size:(i+1)*i_size,j*j_size:(j+1)*j_size]
				hist_d = direct_hist(block_d,360/8)
				feature[i_d*8:(i_d+1)*8] = hist_d
				i_d += 1
		if ( np.linalg.norm(feature) != 0 ):
			feature = feature / np.linalg.norm(feature)
		features.append(feature)

	return features

def getTransformMat(pts_from,pts_to):
	pnum = min(len(pts_from),len(pts_to))
	if pnum == 0 :
		print 'no points to match'
		return 0.0

	A = np.zeros((2*pnum,6),np.float)
	b = np.zeros((2*pnum),np.float)
	for i in range(pnum):
		A[2*i][0] = A[2*i+1][2] = pts_from[i][0] # x
		A[2*i][1] = A[2*i+1][3] = pts_from[i][1] # y
		A[2*i][4] = A[2*i+1][5] = 1 
		b[2*i] = pts_to[i][0]
		b[2*i+1] = pts_to[i][1]

	print ' A is '
	print A
	print ' b is'
	print b

	res = np.linalg.lstsq(A,b)
	print 'res is '
	print res 

	res_m = np.ndarray((2,2),np.float)
	res_b = np.ndarray((2,1),np.float)

	res_m[0,0]=res[0][0]
	res_m[0,1]=res[0][1]
	res_m[1,0]=res[0][2]
	res_m[1,1]=res[0][3]
	res_b[0,0]=res[0][4]
	res_b[1,0]=res[0][5]

	return res_m , res_b

def transformAndAdd(img_static,img_trans,trans_m,trans_b):
	
	print '[transformAndAdd] build the image'
	img_static = np.int32(img_static)
	img_trans = np.int32(img_trans)
	hs,ws,ks=img_static.shape
	ht,wt,kt=img_trans.shape

	p0 = np.dot( trans_m , np.array([[0],[0]])) + trans_b
	p1 = np.dot( trans_m , np.array([[0],[wt]])) + trans_b
	p2 = np.dot( trans_m , np.array([[ht],[0]])) + trans_b
	p3 = np.dot( trans_m , np.array([[ht],[wt]])) + trans_b

	trans_frame = (min(p0[0],p1[0],p2[0],p2[0]),min(p0[1],p1[1],p2[1],p2[1]),max(p0[0],p1[0],p2[0],p2[0]),max(p0[1],p1[1],p2[1],p2[1]))

	print trans_frame
	
	wr = np.int32(max(trans_frame[3],ws))

	res_mat = np.zeros((hs,wr,3),np.int32)
	trans_mat = res_mat.copy()
	h , w , k = res_mat.shape

	print res_mat.shape

	res_mat[0:hs,0:ws,:] = img_static

	print '[transformAndAdd] build the transform'

	trans_m_t = inv(trans_m)

	# print trans_m_t

	# print np.dot(trans_m,trans_m_t)

	# pt = np.dot( trans_m , np.array([[100] , [200]])) + trans_b

	# ps = np.dot(trans_m_t , pt) - np.dot(trans_m_t ,trans_b )
	# print pt 
	# print ps

	# for i in range(ht):
	# 	for j in range(wt):
	# 		pt = np.dot(trans_m , np.array([[i],[j]])) + trans_b
	# 		px = np.int32(pt[0,0])
	# 		py = np.int32(pt[1,0])
	# 		if not check_in((px,py),(0,0,h-1,w-1)):
	# 			continue;
	# 		if check_in((px,py),(0,0,hs-1,ws-1)):
	# 			ds = ws - py
	# 			dt = py - trans_frame[1]
	# 			# print ' ws %d py %d ds %d t %d py %d  tb %d' % (ws,py,ds,dt,py,trans_b[1,0])
	# 			if ( dt + ds ) == 0 :
	# 				trans_mat[px,py] = img_trans[i,j]
	# 			else:
	# 				trans_mat[px,py] = res_mat[px,py] * ds / (dt+ds) + img_trans[i,j] * dt  / (dt  + ds)
	# 		else:
	# 			trans_mat[px,py] = img_trans[i,j]

	for i in range(h-1):
		for j in range(w-1):
			pt = np.dot(trans_m_t , np.array([[i],[j]])) - np.dot(trans_m_t ,trans_b )
			px = np.int32(pt[0,0])
			py = np.int32(pt[1,0])
			# print ' i %d j %d px %d py %d ' %(i,j,px,py)
			if not check_in((px,py),(0,0,ht-1,wt-1)):
				continue;
			trans_mat[i,j] = img_trans[px,py]

	print '[transformAndAdd] merge the original with tranformed'
	for i in range(1,h-1):
		for j in range(1,w-1):
			# if sum(trans_mat[i,j]) < 1 :
			# 	if (sum(trans_mat[i+1,j]) > 100 or sum(trans_mat[i-1,j])) or (sum(trans_mat[i,j+1]) > 100 or sum(trans_mat[i,j-1])):
			# 		trans_mat[i,j] = ( trans_mat[i+1,j] + trans_mat[i-1,j] + trans_mat[i,j+1] + trans_mat[i,j-1] ) /4
			# if sum(trans_mat[i,j]) > 100 :
			# 	res_mat[i,j] = trans_mat[i,j]

			ds = ws - j
			dt = j - trans_frame[1]
			if ds > 0 and dt > 0: 
				res_mat[i,j] = res_mat[i,j] * ds / (dt+ds) + trans_mat[i,j] * dt  / (dt  + ds)
			elif ds <= 0 :
				res_mat[i,j] = trans_mat[i,j]


			if res_mat[i,j,0] <= 0:
				res_mat[i,j,0] = 1
			if res_mat[i,j,1] <= 0:
				res_mat[i,j,1] = 1
			if res_mat[i,j,2] <= 0:
				res_mat[i,j,2] = 1
			if res_mat[i,j,0] >= 255:
				res_mat[i,j,0] = 255
			if res_mat[i,j,1] >= 255:
				res_mat[i,j,1] = 255
			if res_mat[i,j,2] >= 255:
				res_mat[i,j,2] = 255
	print '[transformAndAdd] finished! '
	return res_mat


    