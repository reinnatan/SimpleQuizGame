extends Node2D

var list_question = []
var temp_answer = ""
var edit_text
var selected_question = 0
var current_answer = ""
var label_question
var dialog
var http
var level = 0
var true_answer
var false_answer
var counter_true_answer = 0
var counter_false_answer = 0
var is_win = false

func _ready() -> void:
	_init_component()
	_create_question()
	_generate_multiple_keyboard_button()
	
func _create_question():
	var url = "https://firestore.googleapis.com/v1/projects/godotquizgame/databases/(default)/documents/GodotListQuestions/"+str(level)
	http.request(url)
	
func _on_request_completed(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	var json = JSON.parse_string(text)

	if json.has("fields"):
		var fields = json["fields"]
		for key in fields.keys():
			var temp = []
			var temp_question = json['fields'][key]["arrayValue"]["values"][0]["stringValue"]
			var temp_answer = json['fields'][key]["arrayValue"]["values"][1]["stringValue"]
			temp.append(temp_question)
			temp.append(temp_answer)
			list_question.append(temp)
		_generate_question(selected_question)
	else:
		dialog.title = "Selamat....."
		dialog.dialog_text = "Anda meyelesaikan seluruh quiz ini"
		dialog.popup_centered()
		is_win = true
		
	

func _init_component():
	# add http request 
	http = HTTPRequest.new()
	http.request_completed.connect(_on_request_completed)
	add_child(http)
	
	#icon component true
	var true_icon = TextureRect.new()
	true_icon.position = Vector2(20, 30)
	true_icon.scale = Vector2(0.125,0.125)
	true_icon.texture = load("res://image/check.png")
	add_child(true_icon)
	
	# add label true answer
	true_answer = Label.new()
	true_answer.position = Vector2(95, 30)
	true_answer.add_theme_font_size_override("font_size", 50)
	true_answer.modulate = Color(255,155,0)
	true_answer.text = "0"
	add_child(true_answer)
	
	#icon component false
	var false_icon = TextureRect.new()
	false_icon.position = Vector2(150, 30)
	false_icon.scale = Vector2(0.125,0.125)
	false_icon.texture = load("res://image/remove.png")
	add_child(false_icon)
	
	# add label false answer
	false_answer = Label.new()
	false_answer.position = Vector2(230, 30)
	false_answer.modulate = Color.FIREBRICK
	false_answer.add_theme_font_size_override("font_size", 50)
	false_answer.text = "0"
	add_child(false_answer)
	
	# create dialog to info answer of player
	dialog = AcceptDialog.new()
	dialog.size = Vector2i(400, 200)
	dialog.add_theme_font_size_override("dialog_title", 120)
	dialog.add_theme_font_size_override("title_font_size", 36)
	add_child(dialog)
	
	# label for question
	label_question = Label.new()
	label_question.position = Vector2(230, 120)
	label_question.custom_minimum_size = Vector2(80,80)
	label_question.add_theme_font_size_override("font_size", 50)
	
	add_child(label_question)
	
	# label for answer
	edit_text = LineEdit.new()
	edit_text.release_focus()
	edit_text.position = Vector2(190, 190)
	edit_text.custom_minimum_size = Vector2(750,30)
	edit_text.add_theme_font_size_override("font_size", 50)
	add_child(edit_text)
	
func _generate_question(index):
	if(index<list_question.size()):
		label_question.text = list_question[index][0]
		current_answer = list_question[index][1]
	else:
		await get_tree().create_timer(3.0).timeout
		dialog.title = "Selamat....."
		dialog.dialog_text = "Anda telah menyelasikan level ini"
		dialog.popup_centered()
		level = level+1
		_create_question()
		
		
func _generate_multiple_keyboard_button():
	var y_pos = 320;
	var ascii = 97
	#generate alpabeth
	for i in range(2):
		for j in range(13):
			var button = Button.new()
			button.custom_minimum_size = Vector2(80,80)
			button.position = Vector2(20+(j*85),y_pos)
			button.text = char(ascii)
			button.add_theme_font_size_override("font_size", 50)
			button.pressed.connect(_on_button_pressed.bind(button))
			add_child(button)
			ascii +=1
		y_pos = y_pos+85
	
	#generate number
	ascii = 48
	for j in range(10):
		var button = Button.new()
		button.custom_minimum_size = Vector2(80,80)
		button.position = Vector2(20+(j*85),y_pos)
		button.text = char(ascii)
		button.add_theme_font_size_override("font_size", 50)
		button.pressed.connect(_on_button_pressed.bind(button))
		ascii = ascii+1
		add_child(button)
		
	# declare button erase one character
	var button = Button.new()
	button.custom_minimum_size = Vector2(80,80)
	button.position = Vector2(20+(10*85),y_pos)
	button.text = "<"
	button.add_theme_font_size_override("font_size", 50)
	button.pressed.connect(_on_button_pressed.bind(button))
	add_child(button)
	
	# declare button erase one character
	button = Button.new()
	button.custom_minimum_size = Vector2(80,80)
	button.position = Vector2(20+(11*85),y_pos)
	button.text = "Cl"
	button.add_theme_font_size_override("font_size", 50)
	button.pressed.connect(_on_button_pressed.bind(button))
	add_child(button)
	
	# declare button erase all characters
	button = Button.new()
	button.custom_minimum_size = Vector2(80,80)
	button.position = Vector2(20+(12*85),y_pos)
	button.text = "Ok"
	button.add_theme_font_size_override("font_size", 50)
	button.pressed.connect(_on_button_pressed.bind(button))
	add_child(button)		

func _on_button_pressed(button):
	if button.text != "<" and button.text != "Cl" and button.text != "Ok":
		temp_answer =  temp_answer + button.text
		edit_text.text = temp_answer
	elif button.text == "<":
		var answer = edit_text.text
		edit_text.text = answer.substr(0, answer.length()-1)
		temp_answer = edit_text.text
	elif button.text == "Cl":
		temp_answer = ""
		edit_text.text = ""
	elif button.text == "Ok" and !is_win:
		if temp_answer.to_lower() == current_answer.to_lower() or edit_text.text.to_lower() == current_answer.to_lower():
			#dialog.title = "Horeeiii"
			#dialog.dialog_text = "Jawaban Anda Benar !!!"
			#dialog.popup_centered()
			temp_answer = ""
			edit_text.text = ""
			selected_question +=1
			counter_true_answer += 1
			true_answer.text = str(counter_true_answer)
			_generate_question(selected_question)
		else:
			counter_false_answer += 1
			false_answer.text = str(counter_false_answer)
			#dialog.title = "Yahhh"
			#dialog.dialog_text = "Jawaban Anda Salah Sedih"
			#dialog.popup_centered()
