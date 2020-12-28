



struct JSONPaginator: Codable {
    let count, page, pageCount, pageSize: Int
    let countOnPage: Int
    let hasNextPage: JSONNull?

    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case page = "Page"
        case pageCount = "PageCount"
        case pageSize = "PageSize"
        case countOnPage = "CountOnPage"
        case hasNextPage = "HasNextPage"
    }
    
    func isLastPage(_ page: Int) -> Bool {
        page == pageCount
    }
}
