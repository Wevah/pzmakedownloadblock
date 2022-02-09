// Port of shell script: https://gist.github.com/Wevah/8c4315833cd0aa66c6a8921c0d1912d1

import Foundation
import CryptoKit

guard CommandLine.arguments.count > 1 else { exit(1) }

struct Download {
	
	var url: URL
	
	func htmlString() -> String {
		let values: URLResourceValues

		do {
			values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
		} catch {
			print(error.localizedDescription)
			exit(1)
		}
		
		let filename = url.lastPathComponent.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
		let downloadName = url.deletingPathExtension().lastPathComponent
		
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
		let isoString = isoFormatter.string(for: values.contentModificationDate!)!
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .none
		let dateString = dateFormatter.string(for: values.contentModificationDate!)!
		
		let byteFormatter = ByteCountFormatter()
		byteFormatter.allowedUnits = [.useBytes]
		let fileSize = byteFormatter.string(for: values.fileSize!)!
		
		let kind = url.pathExtension
	
		return """
			<p class="download">
				<span><a href="downloads/\(filename)">\(downloadName)</a></span>
				<span class="info">(10.9+; \(kind)) [\(fileSize)]</span>
				<time datetime="\(isoString)">\(dateString)</time>
				<span class="hash">SHA-256: \(fileHash())</span>
			</p>
			"""
	}
	
	func fileHash() -> String {
		let data = try! Data(contentsOf: url)	
		let digest = SHA256.hash(data: data)
				
		return digest.reduce(into: "") {
			$0.append(String($1, radix: 16))
		}
	}
	
}

for file in CommandLine.arguments[1...] {
	let url = URL(fileURLWithPath: file)

	let download = Download(url: url)

	print(download.htmlString())
}
