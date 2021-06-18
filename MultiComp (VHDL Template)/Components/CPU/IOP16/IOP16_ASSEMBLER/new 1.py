			if command == 'WI2C3_CONST':
				# I2C_Ctrl = START
				outList.append([label,'IOW','0X09','0X05','ISSUE START COMMAND'])
				# I2C write command at slave address
				outList.append(['','LRI','0X00',i2cAddr,'LOAD I2C SLAVE ADDRESS TO CPU REG0'])
				outList.append(['','IOW','0X00','0X04','WRITE SLAVE ADDRESS TO CMD REG'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_1','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_1','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = IDLE = 0X00
				outList.append(['','IOW','0X08','0X05','ISSUE IDLE COMMAND'])
				# WRITE MCP REGISTER NUMBER TO I2C DATA REG
				outList.append(['','LRI','0X01',mcpReg,'LOAD MCP REGISTER NUMBER TO CPU REG1'])
				outList.append(['','IOW','0X01','0X04','WRITE MCP REGISTER TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_2','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_2','','LOOP BACK IF STILL BUSY'])
				# WRITE I2C_Ctrl = STOP
				outList.append(['','LRI','0X01','0X03','STOP COMMAND VALUE'])
				outList.append(['','IOW','0X01','0X05','ISSUE STOP COMMAND'])
				# WRITE DATA VALUE TO MCP
				outList.append(['','LRI','0X01',mcpValue,'WRITE DATA TO REG'])
				outList.append(['','IOW','0X01','0X04','WRITE MCP REGISTER TO MCP'])
				# WAIT TILL BUSY CLEARED
				outList.append([label + '_3','IOR','0X07','0X05','POLL I2C STATUS BUSY'])
				outList.append(['','ARI','0X07','0X01','MASK BUSY BIT'])
				outList.append(['','BNZ',label + '_3','','LOOP BACK IF STILL BUSY'])
