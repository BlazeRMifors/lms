import Foundation

protocol CategoriesCacheProtocol {
    func save(categories: [Category])
    func load() -> [Category]
}

final class CategoriesFileCache: CategoriesCacheProtocol {
    private let fileName = "categories_cache.json"

    func save(categories: [Category]) {
        guard let url = getFileURL() else {
            print("[CategoriesFileCache] Не удалось получить путь к файлу для сохранения.")
            return
        }

        let array = categories.map { $0.jsonObject }

        do {
            let data = try JSONSerialization.data(withJSONObject: array)
            try data.write(to: url)
        } catch {
            print("[CategoriesFileCache] Ошибка сохранения: \(error)")
        }
    }

    func load() -> [Category] {
        guard let url = getFileURL() else {
            print("[CategoriesFileCache] Не удалось получить путь к файлу для загрузки.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let array = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
            return array.compactMap { Category.parse(jsonObject: $0) }
        } catch {
            print("[CategoriesFileCache] Ошибка загрузки: \(error)")
            return []
        }
    }

    private func getFileURL() -> URL? {
        let fileManager = FileManager.default

        do {
            let appSupportURLs = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )

            guard let appSupportURL = appSupportURLs.first else {
                print("[CategoriesFileCache] Не удалось найти Application Support директорию")
                return nil
            }

            let cacheDirectory = appSupportURL.appendingPathComponent("CategoriesCache", isDirectory: true)

            if !fileManager.fileExists(atPath: cacheDirectory.path) {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            return cacheDirectory.appendingPathComponent(fileName)
        } catch {
            print("[CategoriesFileCache] Ошибка при получении или создании директории: \(error)")
            return nil
        }
    }
}
