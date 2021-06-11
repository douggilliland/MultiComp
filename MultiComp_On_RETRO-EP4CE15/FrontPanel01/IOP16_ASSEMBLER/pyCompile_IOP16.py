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
		inFileName = myCSVFileReadClass.getLastPathFileName()
		defaultPath = myCSVFileReadClass.getLastPath()
		defaultParmsClass.storeKeyValuePair('DEFAULT_PATH',defaultPath)
		if inList[0] != ['LABEL', 'COMMAND', 'I2C_ADDR', '23017_REG', 'VALUE', 'COMMENT']:
			print('header does not match expected values')
			print('header :',inList[0])
			assert False,'header does not match expected values'
		else:
			print('header ok')
		print('inList',inList)
		outList = []
		# ['LABEL', 'COMMAND', 'I2C_ADDR', '23017_REG', 'VALUE', 'COMMENT']
		# ['WR001', 'WI2C3_CONST', '0X40', '0X00', '0XFF', 'SET IODIRA TO ALL_INS']
		# ['WR002', 'WI2C3_CONST', '0X40', '0X01', '0X00', 'SET IODIRB TO ALL_OUTS']
		# ['WR003', 'WI2C3_CONST', '0X40', '0X02', '0XFF', 'SET IPOLA TO INVERTED']
		# ['WR004', 'WI2C3_CONST', '0X40', '0x04', '0XFF', 'SET GPINTENA TO ENABLED']
		# ['WR005', 'WI2C3_CONST', '0X40', '0x05', '0X00', 'SET GPINTENB TO DISABLED']
		# ['WR006', 'WI2C3_CONST', '0X40', '0X06', '0X00', 'SET DEFVALA TO 0X00']
		# ['WR007', 'WI2C3_CONST', '0X40', '0x08', '0x00', 'SET INTCONA TO INTCON_PREVPIN']
		# ['WR008', 'WI2C3_CONST', '0X40', '0x0A', '0x04', 'SET IOCONA TO DISABLE SEQ']
		# ['WR009', 'WI2C3_CONST', '0X40', '0x0B', '0x04', 'SET IOCONB TO DISABLE SEQ']
		# ['WR010', 'WI2C3_CONST', '0X40', '0X0C', '0XFF', 'SET GPPUA TO PULLUPS']
		# ['WR011', 'WI2C3_CONST', '0X40', '0X15', '0X55', 'SET OLATB TO 0X55']
		for row in inList[1:]:
			# print(row)
			label = row[0]
			command = row[1]
			i2cAddr = row[2]
			mcpReg = row[3]
			mcpValue = row[4]
			comment = row[5]
			if command == 'WI2C3_CONST':
				# WRITE I2C_Ctrl = START (0X01)
				outLine = []
				outLine.append(label)
				outLine.append('IOW')
				outLine.append('0X09')		# rEG9 = 0X01
				outLine.append('0X05')
				funName = '** ' + comment + ' **'
				outLine.append(funName)
				outList.append(outLine)
				# WRITE SLAVE ADDRESS TO DATA REG
				outLine = []
				outLine.append('')
				outLine.append('LRI')
				outLine.append('0X00')
				outLine.append(i2cAddr)
				outLine.append('LOAD I2C SLAVE ADDRESS TO CPU REG0')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('IOW')		
				outLine.append('0X00')
				outLine.append('0X04')
				outLine.append('WRITE SLAVE ADDRESS TO CMD REG')
				outList.append(outLine)
				# WAIT TILL BUSY CLEARED
				outLine = []
				loopLabel = label + '_1'
				outLine.append(loopLabel)
				outLine.append('IOR')
				outLine.append('0X07')
				outLine.append('0X05')
				outLine.append('POLL I2C STATUS BUSY')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('ARI')
				outLine.append('0X07')
				outLine.append('0X01')
				outLine.append('MASK BUSY BIT')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('BNZ')
				outLine.append(loopLabel)
				outLine.append('')
				outLine.append('LOOP BACK IF STILL BUSY')
				outList.append(outLine)
				# WRITE I2C_Ctrl = IDLE = 0X00
				outLine = []
				outLine.append('')
				outLine.append('IOW')		
				outLine.append('0X08')
				outLine.append('0X05')
				outLine.append('ISSUE IDLE COMMAND')
				outList.append(outLine)
				# WRITE MCP REGISTER NUMBER TO I2C DATA REG
				outLine = []
				outLine.append('')
				outLine.append('LRI')
				outLine.append('0X01')
				outLine.append(mcpReg)
				outLine.append('LOAD MCP REGISTER NUMBER TO CPU REG1')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('IOW')
				outLine.append('0X01')
				outLine.append('0X04')
				outLine.append('WRITE MCP REGISTER TO MCP')
				outList.append(outLine)
				# WAIT TILL BUSY CLEARED
				outLine = []
				loopLabel = label + '_2'
				outLine.append(loopLabel)
				outLine.append('IOR')
				outLine.append('0X07')
				outLine.append('0X05')
				outLine.append('POLL I2C STATUS BUSY')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('ARI')
				outLine.append('0X07')
				outLine.append('0X01')
				outLine.append('MASK BUSY BUT')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('BNZ')
				outLine.append(loopLabel)
				outLine.append('')
				outLine.append('LOOP BACK IF STILL BUSY')
				outList.append(outLine)
				# WRITE I2C_Ctrl = STOP
				outLine = []
				outLine.append('')
				outLine.append('LRI')
				outLine.append('0X01')
				outLine.append('0X03')
				outLine.append('STOP COMMAND VALUE')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('IOW')		
				outLine.append('0X01')
				outLine.append('0X05')
				outLine.append('ISSUE STOP COMMAND')
				outList.append(outLine)
				# WRITE DATA VALUE TO MCP
				outLine = []
				outLine.append('')
				outLine.append('LRI')
				outLine.append('0X01')
				outLine.append(mcpValue)
				outLine.append('WRITE DATA TO REG')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('IOW')
				outLine.append('0X01')
				outLine.append('0X04')
				outLine.append('WRITE MCP REGISTER TO MCP')
				outList.append(outLine)
				# WAIT TILL BUSY CLEARED
				outLine = []
				loopLabel = label + '_3'
				outLine.append(loopLabel)
				outLine.append('IOR')
				outLine.append('0X07')
				outLine.append('0X05')
				outLine.append('POLL I2C STATUS BUSY')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('ARI')
				outLine.append('0X07')
				outLine.append('0X01')
				outLine.append('MASK BUSY BUT')
				outList.append(outLine)
				outLine = []
				outLine.append('')
				outLine.append('BNZ')
				outLine.append(loopLabel)
				outLine.append('')
				outLine.append('LOOP BACK IF STILL BUSY')
				outList.append(outLine)
			elif command == 'HALT':
				outLine = []
				outLine.append('HALT')
				outLine.append('JMP')
				outLine.append('HALT')
				outLine.append('')
				outLine.append('LOOP FOREVER')
				outList.append(outLine)
				
			else:
				assert False,'bad command'
		# for row in outList:
			# print(row)
		outFileName = inFileName[0:-4] + '_out.csv'
		outHeader = ['LABEL', 'OPCODE', 'REG_LABEL', 'OFFSET_ADDR', 'COMMENT']
		outFileClass = WriteListtoCSV()
		outFileClass.writeOutList(outFileName, outHeader, outList)		
		errorDialog('Done')
			
class Dashboard:
	def __init__(self):
		self.win = Tk()
		self.win.geometry("320x240")
		self.win.title("IOP16 Compiler")

	def add_menu(self):
		self.mainmenu = Menu(self.win)
		self.win.config(menu=self.mainmenu)

		self.filemenu = Menu(self.mainmenu, tearoff=0)
		self.mainmenu.add_cascade(label="File",menu=self.filemenu)

		self.filemenu.add_command(label="Open asm file",command=control.doConvert)
		self.filemenu.add_separator()
		self.filemenu.add_command(label="Exit",command=self.win.quit)

		self.win.mainloop()
		
if __name__ == "__main__":
	if version_info.major != 3:
		errorDialog("Requires Python 3")
	control = ControlClass()
	x = Dashboard()
	x.add_menu()
