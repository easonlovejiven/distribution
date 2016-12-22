class Object
	def tries(*methods)
		obj = self
		methods.each { |method| obj = obj.try(method) }
		return obj
	end
end
