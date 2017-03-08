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
 
import MVPCocoa
import ObjectMapper

public class FileStorage: NSObject, FileStorageType, LogType {
	
	private let json = "book.json";
	private let ww = "www";
	private let ext = ".hpub";
	private let manager = FileManager.default;
	
	public var directory: URL?;
	
	public override init() {
		super.init();
		if #available(iOS 9.0, *) {
			self.directory = manager.urls(for: .documentDirectory, in: .userDomainMask).first;
		} else {
			self.directory = URL(fileURLWithPath: NSTemporaryDirectory())
				.appendingPathComponent(ww);
			if let directory = directory {
				if !manager.fileExists(atPath: directory.path) {
					try? manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil);
				}
			}
		}
	}
	
	public func read(in directory: URL) -> Configuration? {
		let file = directory.appendingPathComponent(json);
		let jsonString = try? String(contentsOf: file, encoding: .utf8);
		if let jsonString = jsonString {
			return Mapper<Configuration>().map(JSONString: jsonString);
		}
		return nil;
	}
	
	public func file(file named: String) -> URL? {
		return directory?.appendingPathComponent("\(named)\(ext)");
	}
	
	public func isLogEnabled() -> Bool {
		return true;
	}
	
	public func getClassTag() -> String {
		return String(describing: FileStorage.self);
	}
}
