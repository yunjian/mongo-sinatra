#dpll, need to split up into several things.
#Knowledge base class(collection of proposistions, dpll satisfiabilty search,print functions);


class Literalzs

	#assignments/degree/best_guess known?
	def initialize(name,id)
######################################3
	#puts "intialize,literal"

		@name       = name
		@id         = id
	
		@degree = 0
		@best_guess = 0
		
		@puret = false		
		@puref = false

		#the number of propositions this literal appears in the knowledge base
		@num_negative     = 0
		@num_positive     = 0
		#best guess is a modified version of degree, counting
		# + if literal is positive, minus else and summing
		assignments = [-1,1]
	end
	
	def neg_increment
		@num_negative +=1
		update_DandB
	end
	def update_DandB
		@degree = @num_positive + @num_negative
		@best_guess = @num_positive - @num_negative
	end

	def pos_increment
		@num_positive +=1
		update_DandB
	end	
	
	def degree
		@degree
	end

	def best_guess
		@best_guess
	end
	#should only be called after best guess is known! not enforced to allow
	# non heuristic based csp search
	def assignment_intialize
		if(@puret and @puref)
			return false
		end
		if(@num_negative == 0 or @puret)
			@assignments = [1]
		elsif(@num_positive == 0 or @puref)
			@assignments = [-1]
		elsif(@best_guess <0)
			@assignments = [-1,1]
		else
			@assignments = [1,-1]
		end
		return true
	end
		
	#comparable, 
	def <=> (literal)
		if(assignments.size < literal.assignments.size)
			return -1
		elsif(assignments.size > literal.assignments.size)
			return 1
		else
			if(self.degree > literal.degree)
				return -1
			else
				return 1
			end
		end	
		return 0
	end
	attr_accessor :puret, :puref,:name, :id, :assignments
	def domain
		@assignments.size()
	end
end

#created to make the dpll algorithm more readable
class Assign_Stack_Object
	def initialize(value, depth)
		@value = value
		@depth = depth
	end
	attr_accessor :value , :depth
end

class KnowledgeBase

	
	def initialize(preposition)
###############################################
#	puts "in intialize!"
	
	@total_variables = 1
	@name_hash = {}
	@kb = Array.new
	@assignment = Array.new
	@id_array = []
	
	self.input(preposition)

	end
	
	attr_accessor :total_variables, :name_hash, :kb, :id_array, :assignment

	#takes a string preposistion and turns it into a 2d array ands of ors with id numbers +- depending on negation
	def string_to_internal(preposition)
		temp_kb =Array.new
		#string input of format literal_name LOGICAL_PREPOSISTION
		preposition_array = preposition.split
	
		next_negated = false

		sentence = []
		preposition_array.each  do |word|
#####################################3	
		#	puts  " word: " + word
			#don't need to handle "or" as long as it is in right format, will look to "and" and the end as limiters
			if (word == "AND" || word == "and")
				temp_kb << sentence
				sentence = []
			elsif(word == "NOT" || word == "not")
				next_negated = true
			elsif(word == "OR" || word =="or")

			else
				temp = @name_hash[word]
	
				#add variable if doesnt exist
				if(temp == nil)
					temp_var = Literalzs.new(word,@total_variables)
					@id_array.push(temp_var)
					@name_hash[word] = @total_variables
					temp = @total_variables	
					@total_variables+=1
				 end
		
				if(next_negated)
				temp = temp.to_i * -1
#########################################################3333				
				#puts  " temp negated, now is: " + temp.to_s
				
				next_negated = false
				end
				sentence << temp
			end
		end
		#need to grab last sentence since it wont be ended with and
		temp_kb << sentence
		return temp_kb
	end	

	#private function to read input, called in intialize 
	#in creation of knowledge base and when adding to knowledge base
	def input(prepositions)
		@kb = string_to_internal(prepositions)
	end	
	
	#calls in sequence, could add logic to remove instead, but rather not make it public
	def find_remove(preposistion)
		remove(find(preposition))
	end

	#removes the last logical statement added, returns false on failure, else true
	def remove_last()
		temp = @kb.pop
		return !temp.nil?
	end

	#finds only the first instance
	def find(prepostion)
		partial_search_kb = string_to_internal(preposition)
		partial_search_kb.each do |sentence|
			ind = @kb.index(sentence)
		end
		return ind
	end
	
	#a modifier that uses an internal identifier, so it is private
	def remove(prep_id)
		@kb.delete_at(prep_id)
	end

	#turns the propositions to CNF(if needed)
	def toCNF
	end

	def to_s
	end

	def print
	end

	#public wrapper for the various satisfiability solvers
	#and techniques	
	def isSatisfiable?()
	end

	def walkSat()
	end

    # write out human readable string for truth assignment
    def solution()
      answer = ""
      @id_array.each do |l|
        if @assignment[l.id-1] != 0 
          answer += l.name + "=" + (@assignment[l.id-1]==1 ? "1" : "0") + " "
        end
      end
      answer
    end

	#edit to make it recalculate the heuristic? or slower... 
	def dpll
		#need to count degree, best_guess, assignments and such heuristic stuff somewhere... makes sense to do it here
		#should make a version without heuristics aswell
##############################################3
#		puts "the kb : " + @kb.to_s

		@kb.each do |sente|
##########################################################333
#			puts  " the sentences: " + sente.to_s

			if(sente.size==1)
				index=sente[0]
				if(index > 0)
					@id_array[index-1].pos_increment
					@id_array[index-1].puret=true					
				else
					index*=-1
					@id_array[index-1].neg_increment
					@id_array[index-1].puref = true
				end	
			else	
				sente.each do |atome|
#############################################################
#					puts "the individual atoms: " + atome.to_s
					if(atome > 0)
						index = atome-1
						@id_array[index].pos_increment
					else
						index = -1*atome-1
						@id_array[index].neg_increment
					end			
				end
			end	
		end
		@id_array.each  do |var|
			if(!var.assignment_intialize)
				return false
			end
		end
		
		#intialization stuff
		##########heuristic sort!
		var_list = @id_array
		var_list.sort!
		
		depth=0
		satisfiable = false
		stack = []
	
		#make parallel array assignment
		id_array.map { @assignment << 0}
		

		#insert root
		(var_list[depth].assignments).map  do |child|
			stack.push(Assign_Stack_Object.new(child,depth))
		end
		
		#start depth-first search
		while(stack.size()>0)
	
			temp = stack.pop
		
			#comparing depth to make sure assignment variables reassigned if popping up the tree
			while(depth>temp.depth)
				@assignment[depth] = 0
				depth -=1
			end	
			#add it to the assignment evaluation list (depth doubles as index through var_list)
			@assignment[var_list[temp.depth].id - 1] = temp.value
		
			#Evaluate the assignment list
			if(satisfiable_assignment?(@assignment)==1)
##########################################################################333
				puts "the kb is: " + @kb.to_s 
				puts "the assignment that evaluates to true: "
				puts  @assignment.to_s
#############################################################################
				
				return true
			end
	
			#add children
			depth+=1	
	
			#if not bottumed out, add more children based on values from the var
			if(depth<var_list.size())
				(var_list[depth].assignments).map do |child|
					stack.push(Assign_Stack_Object.new(child,depth))
				end	 
			else
		#reset to bottom value
				depth =var_list.size-1
			end
		end
		return false
	end
# the way this is designed, it short circuts. so sometimes when it should say false it will say indeterminant for the whole knowledgebase
# returns false, true, or indetermninant as -1,1,0 (in current encoding) alike with the assignment list and literal class
#assignment must be parallel array to id nums (may want to use hashes instead)
# CAN BE SPED UP BY (1) SKIPPING ALREADY EVALUATED SENTENCES, AND (2) USING WATCHED LITERALS.
	def satisfiable_assignment?(assignment)
		sentence_eval = 1
		index = 0
		while(sentence_eval == 1 && index < @kb.size)
			sentence_eval = 0
			all_false = true
##############################################3
#			puts "kb is: " + @kb.to_s
#			puts "the assignments are : " + assignment.to_s
		
			@kb[index].each do |id|
################################################33
#			puts " the atom to check : " + id.to_s				

				temp_id = id
				if(temp_id >0)
					assign = assignment[temp_id - 1]
###################################################
#				puts "the atom is : " +  id.to_s 
#				puts "the variable is assigned to: " + assignment[temp_id-1].to_s
#				puts "which evaluates to: " +  assign.to_s
 				
				else
					assign = assignment[temp_id*-1 -1].to_i * -1

###################################################
#				puts "the atom is : " +  id.to_s 
#				puts "the variable is assigned to: " + (assignment[temp_id*-1 - 1] - 1).to_s
#				puts "which evaluates to: " +  assign.to_s

				end
					
				if(assign==1)
					sentence_eval = 1
					all_false = false				
					break
				elsif(assign == 0)
					all_false = false
				end
			end
			if(all_false)
				sentence_eval = -1
			end
			index+=1
		end		
		return sentence_eval
	end
end
