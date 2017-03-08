/*
 * PublicationCocoa Copyright (C) 2017 Fatih.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 

class SystemJS {
	
	static let kWidth = "width";
	static let kHeight = "height";
	
	static let kLeft = "left";
	static let kUri = "uri";
	
	static let contentReady = "onLoadNavigation";
	static let contentUpdate = "onUpdateContent";
	
	static let js = "javascript:new function() {\n"
		+ "  var iOSBridge = window.webkit.messageHandlers;\n"
		+ "  if (!String.prototype.startsWith) {\n"
		+ "    String.prototype.startsWith = function(searchString, position) {\n"
		+ "      position = position || 0;\n"
		+ "      return this.substr(position, searchString.length) === searchString;\n"
		+ "    };\n"
		+ "  }\n"
		+ "  var rect = document.body.getBoundingClientRect();\n"
		+ "  if (iOSBridge) {\n"
		+ "    iOSBridge.onLoadNavigation.postMessage({ width: rect.width, height: rect.height });\n"
		+ "  }"
		+ "  var collection = document.body.getElementsByTagName('a') || [];\n"
		+ "  for (var index = 0, z = collection.length; index < z; index++) {\n"
		+ "    var entry = collection[index];\n"
		+ "    var uri = entry.href || '';\n"
		+ "    if (uri.startsWith('file://')) {\n"
		+ "      var xrect = entry.getBoundingClientRect();\n"
		+ "      if (iOSBridge) {\n"
		+ "        iOSBridge.onUpdateContent.postMessage({ left: (xrect.left + (xrect.width / 2)), uri: uri });\n"
		+ "      }\n"
		+ "    }\n"
		+ "  }\n"
		+ "};";
	
}
