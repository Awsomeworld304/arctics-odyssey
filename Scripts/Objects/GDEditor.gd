@tool
# Copyright (C) 2024 JamesTech4849
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
extends CodeEdit

func _ready() -> void:
	# Keywords
	for ck in ["if", "else", "elif", "case", "default", "break", "continue", "return", "for", "while", "match", "pass", "class", "class_name", "extends", "is", "do", "in", "as", "self", "super", "signal", "func", "static", "const", "enum", "var", "preload", "load", "await", "yield", "assert"]:
		self.syntax_highlighter.add_keyword_color(ck, Color("ff7085"));
	
	# Base Types
	for ck in ["void", "Node", "Control", "Object", "StoryScript"]:
		self.syntax_highlighter.add_keyword_color(ck, Color("42ffc2"));
	
	# Comments
	for ck in ["#", "##"]:
		self.syntax_highlighter.add_color_region(ck, "", Color("cfd0d180"), true);
	for ck in ["\"\"\"", "\""]:
		self.syntax_highlighter.add_color_region(ck, ck, Color("ffeda1"));
	if Engine.is_editor_hint():
		# Keywords
		for ck in ["if", "else", "elif", "case", "default", "break", "continue", "return", "for", "while", "match", "pass", "class", "class_name", "extends", "is", "do", "in", "as", "self", "super", "signal", "func", "static", "const", "enum", "var", "preload", "load", "await", "yield", "assert"]:
			self.syntax_highlighter.add_keyword_color(ck, Color("ff7085"));
	
		# Base Types
		for ck in ["void", "Node", "Control", "Object", "StoryScript"]:
			self.syntax_highlighter.add_keyword_color(ck, Color("42ffc2"));
	
		# Comments
		for ck in ["#", "##"]:
			self.syntax_highlighter.add_color_region(ck, "", Color("cfd0d180"), true);
		for ck in ["\"\"\"", "\""]:
			self.syntax_highlighter.add_color_region(ck, ck, Color("ffeda1"));
pass


func _on_code_completion_requested() -> void:
	for each in self.function_names:
		add_code_completion_option(CodeEdit.KIND_FUNCTION, each, each+"()", syntax_highlighter.function_color);
	for each in self.variable_names:
		add_code_completion_option(CodeEdit.KIND_VARIABLE, each, each);
	update_code_completion_options(true);
	self.changed = true;
	pass # Replace with function body.
