//
//  Film.swift
//  Faraway Frames
//
//  Created by Steven Hill on 10/01/2026.
//

import Foundation
import CoreData

struct Film: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let originalTitle: String
    let originalTitleRomanised: String
    let image: String
    let movieBanner: String
    let description: String
    let director: String
    let producer: String
    let releaseDate: String
    let runningTime: String
    let rottenTomatoesScore: String
    let url: String
    var isUpNext: Bool = false
    var isWatched: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, title, image, description, director, producer, url
        case originalTitle = "original_title"
        case originalTitleRomanised = "original_title_romanised"
        case movieBanner = "movie_banner"
        case releaseDate = "release_date"
        case runningTime = "running_time"
        case rottenTomatoesScore = "rt_score"
    }
}

extension Film {
    /// Maps a Core Data Managed Object into a clean Sendable Struct
    init(from mo: FilmMO) {
        self.id = mo.id ?? ""
        self.title = mo.title ?? "Unknown Title"
        self.originalTitle = mo.originalTitle ?? ""
        self.originalTitleRomanised = mo.originalTitleRomanised ?? ""
        self.image = mo.image ?? ""
        self.movieBanner = mo.movieBanner ?? ""
        self.description = mo.filmDescription ?? ""
        self.director = mo.director ?? ""
        self.producer = mo.producer ?? ""
        self.releaseDate = mo.releaseDate ?? ""
        self.runningTime = mo.runningTime ?? ""
        self.rottenTomatoesScore = mo.rottenTomatoesScore ?? ""
        self.url = mo.url ?? ""
        self.isUpNext = mo.isUpNext
        self.isWatched = mo.isWatched
    }
    
    /// Maps a `Film` Struct to a Core Data Managed Object
    static func makeFilmMO(from film: Film, context: NSManagedObjectContext) -> FilmMO {
        let filmToBeSaved = FilmMO(context: context)
        filmToBeSaved.id = film.id
        filmToBeSaved.title = film.title
        filmToBeSaved.originalTitle = film.originalTitle
        filmToBeSaved.originalTitleRomanised = film.originalTitleRomanised
        filmToBeSaved.image = film.image
        filmToBeSaved.movieBanner = film.movieBanner
        filmToBeSaved.filmDescription = film.description
        filmToBeSaved.director = film.director
        filmToBeSaved.producer = film.producer
        filmToBeSaved.releaseDate = film.releaseDate
        filmToBeSaved.runningTime = film.runningTime
        filmToBeSaved.rottenTomatoesScore = film.rottenTomatoesScore
        filmToBeSaved.url = film.url
        return filmToBeSaved
    }
}

extension Film {
    static let sample = [
        Film(
            id: "2baf70d1-42bb-4437-b551-e5fed5a87abe",
            title: "Castle in the Sky",
            originalTitle: "天空の城ラピュタ",
            originalTitleRomanised: "Tenkū no shiro Rapyuta",
            image: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/npOnzAbLh6VOIu3naU5QaEcTepo.jpg",
            movieBanner: "https://image.tmdb.org/t/p/w533_and_h300_bestv2/3cyjYtLWCBE1uvWINHFsFnE8LUK.jpg",
            description: "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa. With the help of resourceful Pazu and a rollicking band of sky pirates, she makes her way to the ruins of the once-great civilization. Sheeta and Pazu must outwit the evil Muska, who plans to use Laputa's science to make himself ruler of the world.",
            director: "Hayao Miyazaki",
            producer: "Isao Takahata",
            releaseDate: "1986",
            runningTime: "124",
            rottenTomatoesScore: "95",
            url: "https://ghibliapi.vercel.app/films/2baf70d1-42bb-4437-b551-e5fed5a87abe"
        ),
        Film(
            id: "12cfb892-aac0-4c5b-94af-521852e46d6a",
            title: "Grave of the Fireflies",
            originalTitle: "火垂るの墓",
            originalTitleRomanised: "Hotaru no haka",
            image: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/qG3RYlIVpTYclR9TYIsy8p7m7AT.jpg",
            movieBanner: "https://image.tmdb.org/t/p/original/vkZSd0Lp8iCVBGpFH9L7LzLusjS.jpg",
            description: "In the latter part of World War II, a boy and his sister, orphaned when their mother is killed in the firebombing of Tokyo, are left to survive on their own in what remains of civilian life in Japan. The plot follows this boy and his sister as they do their best to survive in the Japanese countryside, battling hunger, prejudice, and pride in their own quiet, personal battle.",
            director: "Isao Takahata",
            producer: "Toru Hara",
            releaseDate: "1988",
            runningTime: "89",
            rottenTomatoesScore: "97",
            url: "https://ghibliapi.vercel.app/films/12cfb892-aac0-4c5b-94af-521852e46d6a"
        ),
        Film(
            id: "12cfb892-aac0-4c5b-94af-52185",
            title: "Grave of the Fireflies",
            originalTitle: "火垂るの墓",
            originalTitleRomanised: "Hotaru no haka",
            image: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/qG3RYlIVpTYclR9TYIsy8p7m7AT.jpg",
            movieBanner: "https://image.tmdb.org/t/p/original/vkZSd0Lp8iCVBGpFH9L7LzLusjS.jpg",
            description: "In the latter part of World War II, a boy and his sister, orphaned when their mother is killed in the firebombing of Tokyo, are left to survive on their own in what remains of civilian life in Japan. The plot follows this boy and his sister as they do their best to survive in the Japanese countryside, battling hunger, prejudice, and pride in their own quiet, personal battle.",
            director: "Isao Takahata",
            producer: "Toru Hara",
            releaseDate: "1988",
            runningTime: "89",
            rottenTomatoesScore: "97",
            url: "https://ghibliapi.vercel.app/films/12cfb892-aac0-4c5b-94af-521852e46d6a"
        ),
        Film(
            id: "12cfb892-aac0-4c5b-94af-5",
            title: "Grave of the Fireflies",
            originalTitle: "火垂るの墓",
            originalTitleRomanised: "Hotaru no haka",
            image: "https://image.tmdb.org/t/p/w600_and_h900_bestv2/qG3RYlIVpTYclR9TYIsy8p7m7AT.jpg",
            movieBanner: "https://image.tmdb.org/t/p/original/vkZSd0Lp8iCVBGpFH9L7LzLusjS.jpg",
            description: "In the latter part of World War II, a boy and his sister, orphaned when their mother is killed in the firebombing of Tokyo, are left to survive on their own in what remains of civilian life in Japan. The plot follows this boy and his sister as they do their best to survive in the Japanese countryside, battling hunger, prejudice, and pride in their own quiet, personal battle.",
            director: "Isao Takahata",
            producer: "Toru Hara",
            releaseDate: "1988",
            runningTime: "89",
            rottenTomatoesScore: "97",
            url: "https://ghibliapi.vercel.app/films/12cfb892-aac0-4c5b-94af-521852e46d6a"
        ),
        Film(
            id: "58611636-abd1-4f05-99d2-c0ade97b699f",
            title: "My Neighbor Totoro",
            originalTitle: "となりのトトロ",
            originalTitleRomanised: "Tonari no Totoro",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "Two sisters move to the country with their father in order to be closer to their hospitalized mother, and discover the surrounding trees are inhabited by Totoros, magical spirits of the forest. When the youngest runs away from home, the older sister seeks help from the spirits to find her.",
            director: "Hayao Miyazaki",
            producer: "Hayao Miyazaki",
            releaseDate: "1988",
            runningTime: "86",
            rottenTomatoesScore: "93",
            url: "https://vercel.app"
        ),
        Film(
            id: "ea612890-213a-4fd5-8840-c692d7ad43fc",
            title: "Only Yesterday",
            originalTitle: "おもひでぽろぽろ",
            originalTitleRomanised: "Omoide Poro Poro",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "It’s 1982, and Taeko is 27 years old, unmarried, and has lived her whole life in Tokyo. She decides to visit her family in the countryside, and as the train travels through the night, memories of her youth flood back to her.",
            director: "Isao Takahata",
            producer: "Toshio Suzuki",
            releaseDate: "1991",
            runningTime: "119",
            rottenTomatoesScore: "100",
            url: "https://vercel.app"
        ),
        Film(
            id: "ebbb6b7c-945c-41ee-a791-745c77010864",
            title: "Porco Rosso",
            originalTitle: "紅の豚",
            originalTitleRomanised: "Kurenai no Buta",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "Porco Rosso, a world-weary Italian World War I fighter ace and freelance bounty hunter, now lives as a freelance bounty hunter chasing 'air pirates' in the Adriatic Sea. He has been transformed into an anthropomorphic pig by a mysterious spell.",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseDate: "1992",
            runningTime: "93",
            rottenTomatoesScore: "94",
            url: "https://vercel.app"
        ),
        Film(
            id: "1b67aa9a-2e4a-459a-b968-bea5a3f4718a",
            title: "Pom Poko",
            originalTitle: "平成狸合戦ぽんぽこ",
            originalTitleRomanised: "Heisei Tanuki Gassen Ponpoko",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "As the city of Tama New Town expands, it encroaches on the habitat of a community of tanuki. The tanuki decide to fight back by using their ancient illusion-transformation skills to scare away the humans.",
            director: "Isao Takahata",
            producer: "Toshio Suzuki",
            releaseDate: "1994",
            runningTime: "119",
            rottenTomatoesScore: "78",
            url: "https://vercel.app"
        ),
        Film(
            id: "dc2e6db1-8018-48dd-9199-1c358481098f",
            title: "Princess Mononoke",
            originalTitle: "もののけ姫",
            originalTitleRomanised: "Mononoke-hime",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "Ashitaka, a prince of the disappearing Emishi people, is cursed by a demonized boar god and must journey to the west to find a cure. Along the way, he encounters San, a young woman raised by wolves, and finds himself caught in the middle of a war between forest gods and a mining colony.",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseDate: "1997",
            runningTime: "134",
            rottenTomatoesScore: "93",
            url: "https://vercel.app"
        ),
        Film(
            id: "0440483e-ca0e-4175-9c59-609121f29509",
            title: "Spirited Away",
            originalTitle: "千と千尋の神隠し",
            originalTitleRomanised: "Sen to Chihiro no Kamikakushi",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "10-year-old Chihiro wanders into a world ruled by gods, witches, and spirits, and where humans are changed into beasts. After her parents are turned into pigs, she must work in a bathhouse for the spirits to find a way to free herself and her parents and return to the human world.",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseDate: "2001",
            runningTime: "125",
            rottenTomatoesScore: "96",
            url: "https://vercel.app"
        ),
        Film(
            id: "cd3b2016-42f1-4a37-838b-b8160032e533",
            title: "Howl's Moving Castle",
            originalTitle: "ハウルの動く城",
            originalTitleRomanised: "Hauru no Ugoku Shiro",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "When Sophie, a shy young woman, is cursed with an old body by a spiteful witch, her only chance of breaking the spell lies with a self-indulgent yet insecure young wizard and his companions in his legged, walking castle.",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseDate: "2004",
            runningTime: "119",
            rottenTomatoesScore: "87",
            url: "https://vercel.app"
        ),
        Film(
            id: "758bf02e-3122-46e0-884e-67cf83a38684",
            title: "Ponyo",
            originalTitle: "崖の上のポニョ",
            originalTitleRomanised: "Gake no Ue no Ponyo",
            image: "https://tmdb.org",
            movieBanner: "https://tmdb.org",
            description: "The son of a sailor, 5-year-old Sosuke lives a quiet life on an oceanside cliff with his mother Lisa. One day, he finds a goldfish trapped in a bottle and names her Ponyo. A bond forms between the two, and Ponyo longs to become human to stay with Sosuke.",
            director: "Hayao Miyazaki",
            producer: "Toshio Suzuki",
            releaseDate: "2008",
            runningTime: "101",
            rottenTomatoesScore: "91",
            url: "https://vercel.app"
        )
    ]
}
