#Zilog 80 CPU for the Game Boy, note that the game boy version has a slightly modified Z80 with less ops.
class Z80
	attr_accessor :clock, :register, :mmu
	
	def initialize(mmu)
		self.mmu = mmu
		clock = [
			"m", 0,
			"t", 0
		]
		register = [
			"a", 0, #a - l 8-bit registers
			"b", 0,
			"c", 0,
			"d", 0,
			"e", 0,
			"h", 0,
			"l", 0,			
			"f", 0, #Flags
			"pc", 0,#Program Counter: 16-bit register
			"sp", 0,#Stack Pointer: 16-bit register
			"m", 0, "t", 0 #Clock for last instruction
		]
		initOps()
	end
	
	##
	#Memory-handling instructions
	##
	
	#Push registers B and C to the stack (PUSH BC)
	def PUSHBC
		@register["sp"]-- #Drop through the stack
		@mmu.wb(@register["sp"], @register["b"]) #Write B
		@register["sp"]-- #Drop through the stack
		mmu.wb(@register["sp"], @register["c"]) #Write C
		@register["m"] = 3 #3 M-times taken
		@register["t"] = 12
	end
	
	#Read a byte from absolute location into A (LD A, addr)
	def LDAmm
		addr = @mmu.rw(@register["pc"]) #Get address from instruction
		@register["pc"] += 2 #Advance PC
		@register["a"] = mmu.rb(addr) #Read from address
		@register["m"] = 4 #4 M-times taken
		@register["t"] = 16
	end
	
	#Reset function
	def reset
		@register.each{ |key, value| value = 0 }
		@clock.each{ |key, value| value = 0 }
	end
	
	#Dispatcher is the main loop for fetching and decoding instructions
	def dispatch
		op = @mmu.rb(@register["pc"]++) #Fetch next instruction
		@ops["op"]() #Dispatch operation
		@register["pc"] &= 65535 #Mask PC to 16 bits 2^16 - 1 = 65535
		@clock["m"] += @register["m"] #Add time to CPU clock
		@clock["t"] += @register["t"]
	end
	
	def initOps
		@opts = [
			"NOP", 0,
			"LDBCnn", 0 #TODO: ops.
		]
	end	
end