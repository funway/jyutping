import Foundation
import SQLite3

struct UserPhraseManager {
        
        private var userdb: OpaquePointer? = {
                guard let cachesUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
                let userDBUrl: URL = cachesUrl.appendingPathComponent("userdb.sqlite3", isDirectory: false)
                var db: OpaquePointer? = nil
                if sqlite3_open_v2(userDBUrl.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
                        debugPrint("sqlite3_open_v2 done.")
                        debugPrint(userDBUrl)
                        return db
                } else {
                        debugPrint("sqlite3_open_v2 failed.")
                        return nil
                }
        }()
        
        init() {
                ensureTable()
        }
        
        private func ensureTable() {
                // id = (input + word + jyutping).hash
                // token = input.hash
                // shortcut = jyutping.initials.hash
                let createTableString = "CREATE TABLE IF NOT EXISTS phrase(id INTEGER NOT NULL PRIMARY KEY,token INTEGER NOT NULL,shortcut INTEGER NOT NULL,frequency INTEGER NOT NULL,word TEXT NOT NULL,jyutping TEXT NOT NULL);"
                var createTableStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(userdb, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                        if sqlite3_step(createTableStatement) == SQLITE_DONE {
                                debugPrint("Ensured phrase table.")
                        } else {
                                debugPrint("User phrase table could not be created.")
                        }
                } else {
                        debugPrint("CREATE TABLE statement could not be prepared.")
                }
                sqlite3_finalize(createTableStatement)
        }
        
        func insert(phrase: Phrase) {
                let insertStatementString = "INSERT INTO phrase (id, token, shortcut, frequency, word, jyutping) VALUES (?, ?, ?, ?, ?, ?);"
                var insertStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(userdb, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                        sqlite3_bind_int64(insertStatement, 1, phrase.id)
                        sqlite3_bind_int64(insertStatement, 2, phrase.token)
                        sqlite3_bind_int64(insertStatement, 3, phrase.shortcut)
                        sqlite3_bind_int64(insertStatement, 4, phrase.frequency)
                        sqlite3_bind_text(insertStatement, 5, (phrase.word as NSString).utf8String, -1, nil)
                        sqlite3_bind_text(insertStatement, 6, (phrase.jyutping as NSString).utf8String, -1, nil)
                        
                        if sqlite3_step(insertStatement) == SQLITE_DONE {
                                debugPrint("Successfully inserted row.")
                        } else {
                                debugPrint("Could not insert row.")
                        }
                } else {
                        debugPrint("INSERT statement could not be prepared.")
                }
                sqlite3_finalize(insertStatement)
        }
        
        func update(id: Int64, frequency: Int64) {
                let updateStatementString = "UPDATE phrase SET frequency = \(frequency) WHERE id = \(id);"
                var updateStatement: OpaquePointer?
                if sqlite3_prepare_v2(userdb, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                        if sqlite3_step(updateStatement) == SQLITE_DONE {
                                debugPrint("Successfully updated row.")
                        } else {
                                debugPrint("Could not update row.")
                        }
                } else {
                        debugPrint("UPDATE statement is not prepared.")
                }
                sqlite3_finalize(updateStatement)
        }
        
        func fetchAll() -> [Phrase] {
                let queryStatementString = "SELECT * FROM phrase;"
                var queryStatement: OpaquePointer? = nil
                var phrases: [Phrase] = []
                if sqlite3_prepare_v2(userdb, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let id = sqlite3_column_int64(queryStatement, 0)
                                let token = sqlite3_column_int64(queryStatement, 1)
                                let shortcut = sqlite3_column_int64(queryStatement, 2)
                                let frequency = sqlite3_column_int64(queryStatement, 3)
                                let word = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                                let jyutping = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                                let phrase = Phrase(id: id, token: token, shortcut: shortcut, frequency: frequency, word: word, jyutping: jyutping)
                                phrases.append(phrase)
                        }
                } else {
                        debugPrint("SELECT statement could not be prepared.")
                }
                sqlite3_finalize(queryStatement)
                return phrases
        }
        
        func fetch(by id: Int64) -> Phrase? {
                let queryStatementString = "SELECT * FROM phrase WHERE id = \(id) LIMIT 1;"
                var queryStatement: OpaquePointer? = nil
                var phrase: Phrase?
                if sqlite3_prepare_v2(userdb, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                // let id = sqlite3_column_int64(queryStatement, 0)
                                let token = sqlite3_column_int64(queryStatement, 1)
                                let shortcut = sqlite3_column_int64(queryStatement, 2)
                                let frequency = sqlite3_column_int64(queryStatement, 3)
                                let word = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                                let jyutping = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                                phrase = Phrase(id: id, token: token, shortcut: shortcut, frequency: frequency, word: word, jyutping: jyutping)
                        }
                } else {
                        debugPrint("SELECT statement could not be prepared.")
                }
                sqlite3_finalize(queryStatement)
                return phrase
        }
        
        func match(for text: String) -> [Candidate] {
                let token: Int64 = Int64(text.hash)
                let queryStatementString = "SELECT * FROM phrase WHERE token = \(token) ORDER BY frequency DESC LIMIT 5;"
                var queryStatement: OpaquePointer? = nil
                var candidates: [Candidate] = []
                if sqlite3_prepare_v2(userdb, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                // let id = sqlite3_column_int64(queryStatement, 0)
                                // let token = sqlite3_column_int64(queryStatement, 1)
                                // let shortcut = sqlite3_column_int64(queryStatement, 2)
                                // let frequency = sqlite3_column_int64(queryStatement, 3)
                                let word = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                                let jyutping = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                                
                                let candidate: Candidate = Candidate(text: word, footnote: jyutping, input: text)
                                candidates.append(candidate)
                        }
                } else {
                        debugPrint("SELECT statement could not be prepared.")
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        func matchShortcut(for text: String) -> [Candidate] {
                let shortcut: Int64 = Int64(text.hash)
                let queryStatementString = "SELECT * FROM phrase WHERE shortcut = \(shortcut) ORDER BY frequency DESC LIMIT 5;"
                var queryStatement: OpaquePointer? = nil
                var candidates: [Candidate] = []
                if sqlite3_prepare_v2(userdb, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                // let id = sqlite3_column_int64(queryStatement, 0)
                                // let token = sqlite3_column_int64(queryStatement, 1)
                                // let shortcut = sqlite3_column_int64(queryStatement, 2)
                                // let frequency = sqlite3_column_int64(queryStatement, 3)
                                let word = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                                let jyutping = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                                
                                let candidate: Candidate = Candidate(text: word, footnote: jyutping, input: text)
                                candidates.append(candidate)
                        }
                } else {
                        debugPrint("SELECT statement could not be prepared.")
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        
        func deleteRow(id: Int64) {
                let deleteStatementStirng = "DELETE FROM phrase WHERE id = ?;"
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(userdb, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                        sqlite3_bind_int64(deleteStatement, 1, id)
                        if sqlite3_step(deleteStatement) == SQLITE_DONE {
                                debugPrint("Successfully deleted row. id = \(id)")
                        } else {
                                debugPrint("Could not delete row.")
                        }
                } else {
                        debugPrint("DELETE statement could not be prepared.")
                }
                sqlite3_finalize(deleteStatement)
        }
        
        func deleteAll() {
                let deleteStatementStirng = "DELETE FROM phrase;"
                var deleteStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(userdb, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                        if sqlite3_step(deleteStatement) == SQLITE_DONE {
                                debugPrint("Successfully deleted all rows.")
                        } else {
                                debugPrint("Could not delete all rows.")
                        }
                } else {
                        debugPrint("DELETE ALL statement could not be prepared.")
                }
                sqlite3_finalize(deleteStatement)
        }
}