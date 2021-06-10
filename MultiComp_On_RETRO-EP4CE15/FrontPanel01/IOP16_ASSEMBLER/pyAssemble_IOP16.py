import csv
import string
import os
import sys
from sys import version_info

import time
from datetime import date

# Fix path below if imports fail
sys.path.append('C:\\Users\\HPz420\\Documents\\GitHub\\land-boards\\lb-Python-Code\\dgCommonModules\\TKDGCommon')

from dgProgDefaultsTk import *
from dgReadCSVtoListTk import *
from dgWriteListtoCSVTk import *

from tkinter import filedialog
from tkinter import *
from tkinter import messagebox

defaultPath = '.'

class ControlClass:
	"""Methods to read tindie or Kickstarter files and write out USPS and PayPal lists.
	"""
	def doConvert(self):
		"""The code that calls the other code
		"""
		global defaultPath
		defaultParmsClass = HandleDefault()
		defaultParmsClass.initDefaults()
		defaultPath = defaultParmsClass.getKeyVal('DEFAULT_PATH')
		# print '(doConvert): defaultPath',defaultPath
		myCSVFileReadClass = ReadCSVtoList()	# instantiate the class
		myCSVFileReadClass.setVerboseMode(False)	# turn on verbose mode until all is working 
		myCSVFileReadClass.setUseSnifferFlag(True)
		doneReading = False
		inList = myCSVFileReadClass.findOpenReadCSV(defaultPath,'Select ASM (CSV) File')	# read in TSV into list
		if inList == []:
			errorDialog("doConvert): No file selected")
			return
		defaultPath = myCSVFileReadClass.getLastPath()
		defaultParmsClass.storeKeyValuePair('DEFAULT_PATH',defaultPath)
		if inList[0] != ['LABEL', 'OPCODE', 'VAL4', 'VAL8', 'COMMENT']:
			print('header does not match expected values')
			print('header :',inList[0])
			assert False,'header does not match expected values'
		else:
			print('header ok')
		progCounter = 0
		labelsList = {}
		for row in inList[1:]:
			if row[0] != '':
				labelsList[row[0]] = progCounter
			progCounter += 1
		print('labelsList',labelsList)
		program = []
		progCounter = 0
		for row in inList[1:]:
			row[1] = row[1].upper()
			if row[1] != '':
				if row[1] == 'NOP':
					vecStr = '0x0000'				
					program.append(vecStr)
				elif row[1] == 'LRI':
					vecStr = '0x2'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'IOR':
					vecStr = '0x6'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'IOW':
					vecStr = '0x7'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'ARI':
					vecStr = '0x8'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'ORI':
					vecStr = '0x9'
					vecStr += row[2][-1]
					vecStr += row[3][-2:]
					program.append(vecStr)
				elif row[1] == 'BEZ':
					vecStr = '0xC'
					distance = labelsList[row[2]] - progCounter
					distance = labelsList[row[2]] - progCounter
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'BNZ':
					vecStr = '0xD'
					distance = labelsList[row[2]] - progCounter
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				elif row[1] == 'JMP':
					vecStr = '0xF'
					distance = labelsList[row[2]]
					distStr = self.calcOffsetString(distance)
					vecStr += distStr
					program.append(vecStr)
				else:
					print('bad instr', row)
					assert False,'bad instr'
				progCounter += 1
		# print('program',program)
		annotatedSource = []
		progOffset = 0
		for rowOffset in range(len(inList)-1):
			annRow = []
			annRow.append(inList[rowOffset+1][0])
			if inList[rowOffset+1][1] != '':
				annRow.append(program[progOffset])
				progOffset += 1
			else:
				annRow.append('')
			annRow.append(inList[rowOffset+1][1])
			annRow.append(inList[rowOffset+1][2])
			annRow.append(inList[rowOffset+1][3])
			annRow.append(inList[rowOffset+1][4])
			#print(annRow)
			annotatedSource.append(annRow)		
		self.outStuff(defaultPath,annotatedSource)
		
	def calcOffsetString(self,distanceInt):
		dresultStr = ''
		if distanceInt < 0:
			distanceInt = (distanceInt ^ 4095) + 1
		distStr = hex(distanceInt).upper()
		if distStr[0] == '-':	# -0xffe
			if len(distStr) == 6:
				return distStr[3:]
			elif len(distStr) == 5:
				return '0' + distStr[3:]
			elif len(distStr) == 4:
				return '00' + distStr[3:]
		else:	#0x000
			if len(distStr) == 5:
				return distStr[2:]
			elif len(distStr) == 4:
				return '0' + distStr[2:]
			elif len(distStr) == 3:
				return '00' + distStr[2:]
		print('distance =',distStr)
		return distStr
	
	def outStuff(self,inFileName,sourceFile):
		"""
		[['LABEL', 'OPCODE', 'VAL4', 'VAL8', 'COMMENT'], ['INIT', 'NOP', '', '', ''], ['', 'LRI', '0X00', '0X01', 'LOAD START CMD'], ['', 'LRI', '0X01', '0X40', 'LOAD SLAVE ADDR<<1, WRITE'], ['', 'LRI', '0X02', '0X00', 'LOAD IDLE CMD'], ['', 'LRI', '0X03', '0X00', 'LOAD IODIRA REGISTER_OFFSET'], ['', 'LRI', '0X04', '0XFF', 'LOAD IODIRA_ALL_INS'], ['', 'IOW', '0X00', '0X00', 'ISSUE START CMD'], ['', 'IOW', '0X01', '0X00', 'ISSUE SLAVE ADDR<<1, WRITE'], ['', 'IOW', '0X02', '0X00', 'ISSUE IDLE CMD'], ['', 'IOW', '0X03', '0X00', 'ISSUE IODIRA REGISTER_OFFSET'], ['', 'IOW', '0X04', '0X00', 'ISSUE IODIRA_ALL_INS'], ['LDST000', 'IOR', '0X05', '0X00', 'READ STATUS'], ['', 'ARI', '0X05', '0X01', 'BUSY BIT'], ['', 'BNZ', '', 'LDST000', 'LOOP UNTIL NOT BUSY'], ['SELF', 'JMP', 'SELF', '', '']]
		"""
		for row in sourceFile:
			print(row)
		assert False,'stop'
		outList = []
		outStr = '-- File: ' + inFileName[0:-4] + '.mif'
		outList.append(outStr)
		outList.append('-- Generated by bin2mif.py')
		outList.append('-- ')
		outStr = 'DEPTH = '+ str(len(outArray)) + ';'
		outList.append(outStr)
		outStr = ''
		outList.append('WIDTH = 12;')
		outList.append('ADDRESS_RADIX = OCTAL;')
		outList.append('DATA_RADIX = OCTAL;')
		outList.append('CONTENT BEGIN')
		lineCount = 0
		addrCount = 0
		for cell in outArray:
			if lineCount == 0:
				# if len(str(addrCount)) == 4:
					# outVal = str(addrCount) + ':'
				# elif len(str(addrCount)) == 3:
					# outVal = '0' + str(addrCount) + ':'
				# elif len(str(addrCount)) == 2:
					# outVal = '00' + str(addrCount) + ':'
				# elif len(str(addrCount)) == 1:
					# outVal = '000' + str(addrCount) + ':'
				# outStr += outVal
				outStr += str((addrCount >> 9) & 7)
				outStr += str((addrCount >> 6) & 7)
				outStr += str((addrCount >> 3) & 7)
				outStr += str(addrCount & 7)
				outStr += ':'
			lineCount += 1
			addrCount += 1	
			newCell	= ''
			if len(cell) == 4:
				newCell = cell
			elif len(cell) == 3:
				newCell = '0' + cell
			elif len(cell) == 2:
				newCell = '00' + cell
			elif len(cell) == 1:
				newCell = '000' + cell
			outStr += ' ' + newCell
			if lineCount == 8:
				lineCount = 0
				outStr += ';'
				outList.append(outStr)
				outStr = ''
		outList.append('END;')
		# for line in outList:
			# print(line)

		F = open(outFileName, 'w')
		for row in outList:
			F.writelines(row+'\n')
		F.close()
			
class Dashboard:
	def __init__(self):
		self.win = Tk()
		self.win.geometry("320x240")
		self.win.title("pyPirateShip.py")

	def add_menu(self):
		self.mainmenu = Menu(self.win)
		self.win.config(menu=self.mainmenu)

		self.filemenu = Menu(self.mainmenu, tearoff=0)
		self.mainmenu.add_cascade(label="File",menu=self.filemenu)

		self.filemenu.add_command(label="Open file",command=control.doConvert)
		self.filemenu.add_separator()
		self.filemenu.add_command(label="Exit",command=self.win.quit)

		self.win.mainloop()
		
if __name__ == "__main__":
	if version_info.major != 3:
		errorDialog("Requires Python 3")
	control = ControlClass()
	x = Dashboard()
	x.add_menu()
