# Copyright (C) 2025 JamesTech4849
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

extends Node
class_name GodotDownloader

signal download_started(total_bytes:int);
signal download_progressed(current:int, total:int);
signal download_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray);

@export var download_url:String = "";
@export var save_path:String = "./";

var _downloaded_bytes:int = 0;
var _total_bytes:int = 0;
var _request:HTTPRequest = null;
var _req_head_only:bool = true;

var downloading:bool = false;

func _parse_content_length(headers:PackedStringArray) -> int:
	print("GodotDownloader -> PCL: Headers %s" % headers);
	for header:String in headers:
		if header.begins_with("Content-Length: "):
			var length_str:String = header.substr(16).strip_edges();
			if Settings.debug: print("GodotDownloader -> PCL: Content Length: %s" % length_str);
			return int(length_str);
		else: if Settings.debug: push_warning("GodotDownloader -> PCL: Header is not Content-Length!");
	return 0;

func _init(url:String = "", path:String = "./") -> void:
	self.download_url = url;
	self.save_path = path;
	print("GodotDownloader -> Init: Url is %s, Path is %s" % [url, path]);
	pass

func _on_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void:
	downloading = false;
	if _req_head_only:
		_total_bytes = _parse_content_length(headers);
		if _total_bytes <= 0:
			push_error("GodotDownloader -> Request Complete: Failed to get content length from headers.");
			pass
		download_completed.emit(result, response_code, headers, body);
		return;
	if result == OK:
		if response_code == 200: if Settings.debug: print("GodotDownloader -> Request Complete: Download success.");
		else: push_error("GodotDownloader -> Request Complete: Download failed with response code: " + str(response_code));
	else: push_error("GodotDownloader -> Request Complete: Download request failed with error: " + str(result));

	download_completed.emit(result, response_code, headers, body);
	pass

func start_download() -> void:
	downloading = false;
	_downloaded_bytes = 0;
	_total_bytes = 0;

	if download_url == "" or save_path == "":
		push_error("GodotDownloader -> Start Download: Download URL or save path is not set, returning.");
		return;

	if !_request:
		push_error("GodotDownloader -> Start Download: HTTP Request is null! Returning.");
		return;

	_request.download_file = save_path;

	_req_head_only = true;
	var _err:Error = _request.request(download_url, [], HTTPClient.METHOD_HEAD);
	if _err != OK:
		push_error("GodotDownloader -> Start Download: Failed to start HEAD request with error: " + str(_err));
		return;
	await download_completed;

	_req_head_only = false;
	downloading = true;

	_err = _request.request(download_url, [], HTTPClient.METHOD_GET);
	if _err != OK:
		push_error("GodotDownloader -> Start Download: Failed to start download request with error: " + str(_err));
		downloading = false;
		return;
	download_started.emit(_total_bytes);
	pass

func _ready() -> void:
	_request = HTTPRequest.new();
	self.add_child(_request);
	await get_tree().process_frame;
	var _s:int = _request.request_completed.connect(_on_request_completed);
	pass

func _download_progress() -> void:
	download_progressed.emit(_downloaded_bytes, _total_bytes);
	pass

func _process(_delta: float) -> void:
	if downloading:
		_downloaded_bytes = _request.get_downloaded_bytes();
		_download_progress();
		pass
	pass
