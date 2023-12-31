extends RefCounted
class_name Board

var dimensions: Vector2i = Vector2i(3, 3)

var board: Array[Array] = []

func initialize(_dimensions: Vector2i = dimensions) -> void:
	board.clear()
	dimensions = _dimensions
	
	# initialize board table
	for i in dimensions.y:
		board.append([])
		for j in dimensions.x:
			board[i].append(null)

func set_cell(row: int, col: int, value: Variant) -> void:
	board[row][col] = value

# returns the value of the cell at the specified row and column
func get_cell(row: int, col: int) -> Variant:
	return board[row][col]

# returns true if all cells are filled and no victory conditions are met
func check_draw() -> bool:
	# check if all cells are filled
	for row in dimensions.y:
		for col in dimensions.x:
			if get_cell(row, col) == null:
				return false
	
	# check if there is a win condition present
	if check_win_conditions() != null:
		return false
	
	# if we reach this point, there must be a draw
	return true

# returns the token of the player who won, null if no victory conditions are met
func check_win_conditions() -> Variant:
	var check_functions: Array[Callable] = get_win_conditions()
	
	# check all of our win conditions against the board
	var result: Variant = null
	for fun in check_functions:
		result = fun.call()
		
		# non-null result indicates a victory occurred
		if result != null:
			return result
	
	# if we reach this point, no victory
	return null

func get_win_conditions() -> Array[Callable]:
	var functions: Array[Callable] = []
	
	# if the board is square, use row, column, and diagonal conditions
	if dimensions.x == dimensions.y:
		functions = [
			check_win_rows, 
			check_win_columns, 
			check_win_diagonals
		]
	# if the board is not square, use row, column, and square conditions
	else:
		functions = [
			check_win_rows, 
			check_win_columns,
			# check for 2x2 squares
			check_win_square.bind(2)
		]
	
	return functions

# returns the token of the player who meets the row win condition, null if no player meets it
func check_win_rows() -> Variant:
	for row in dimensions.y:
		# make sure all tokens in this row are equal and non-null
		var target_token: Variant = get_cell(row, 0)
		for col in dimensions.x:
			var token: Variant = get_cell(row, col)
			
			# if any token is null, no victory
			if token == null:
				target_token = null
				break
			
			# if any token in this row doesn't match, no victory
			if token != target_token:
				target_token = null
				break
		
		# at this point, if there was no victory target_token should be null
		if target_token == null:
			continue
		
		# if we reach this point, there was a victory
		return target_token
	
	# if we reach this point, there was no victory
	return null

# returns the token of the player who meets the column win condition, null if no player meets it
func check_win_columns() -> Variant:
	for col in dimensions.x:
		# make sure all tokens in this column are equal and non-null
		var target_token: Variant = get_cell(0, col)
		for row in dimensions.y:
			var token: Variant = get_cell(row, col)
			
			# if any token is null, no victory
			if token == null:
				target_token = null
				break
			
			# if any token in this column doesn't match, no victory
			if token != target_token:
				target_token = null
				break
		
		# at this point, if there was no victory target_token should be null
		if target_token == null:
			continue
		
		# if we reach this point, there was a victory
		return target_token
	
	# if we reach this point, there was no victory
	return null

# returns the token of the player who meets the diagonal win condition, null if no player meets it
# only checks main diagonals, limited to square boards
func check_win_diagonals() -> Variant:
	# make sure the board is square
	if dimensions.x != dimensions.y:
		return null
	
	# check top-left to bottom-right diagonal
	# make sure all tokens in this diagonal are equal and non-null
	var target_token: Variant = get_cell(0, 0)
	for idx in dimensions.x:
		var token: Variant = get_cell(idx, idx)
		
		# if any token in this diagonal is null, no victory
		if token == null:
			target_token = null
			break
		
		# if any token in this diagonal doesn't match, no victory
		if token != target_token:
			target_token = null
			break
	
	# if we found a victory on the first diagonal, we can return early
	if target_token != null:
		return target_token
	
	# check bottom-left to top-right diagonal
	# make sure all tokens in this diagonal are equal and non-null
	target_token = get_cell(0, dimensions.x - 1)
	for idx in dimensions.x:
		var token: Variant = get_cell(idx, dimensions.x - 1 - idx)
		
		# if any token in this diagonal is null, no victory
		if token == null:
			target_token = null
			break
		
		# if any token in this diagonal doesn't match, no victory
		if token != target_token:
			target_token = null
			break
	
	# target_token now holds the result of the victory check
	return target_token

# checks if there is a square of a given size of one token
# returns the token of the player who meets this win condition, null if no player meets it
func check_win_square(size: int) -> Variant:
	# check every possible square starting at the top left
	for row in range(0, dimensions.y - size + 1):
		for col in range(0, dimensions.x - size + 1):
			var target_token: Variant = get_cell(row, col)
			# make sure every token in the square matches and is not null
			for i in range(row, row + size):
				for j in range(col, col + size):
					var token: Variant = get_cell(i, j)
					if token == null:
						target_token = null
						break
					if token != target_token:
						target_token = null
						break
				# if target_token is null, no victory
				if target_token == null:
					break
				
			# if target_token is not null, we found a victory
			if target_token != null:
				return target_token
	return null
