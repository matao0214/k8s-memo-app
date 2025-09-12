package main

import (
       "database/sql"
       _ "github.com/lib/pq"
       "log"
       "os"
       "fmt"
       "time"
)

var db *sql.DB

func initDB() {
       var err error
       host := os.Getenv("POSTGRES_HOST")
       user := os.Getenv("POSTGRES_USER")
       password := os.Getenv("POSTGRES_PASSWORD")
       dbname := os.Getenv("POSTGRES_DB")
       dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", host, user, password, dbname)

       // リトライしながらDB接続を待つ
       for i := 0; i < 10; i++ {
              db, err = sql.Open("postgres", dsn)
              if err == nil {
                     err = db.Ping()
                     if err == nil {
                            break
                     }
              }
              log.Printf("Waiting for DB... (%d/10): %v", i+1, err)
              time.Sleep(1 * time.Second)
       }
       if err != nil {
              log.Fatal("Could not connect to DB: ", err)
       }
       createTable := `CREATE TABLE IF NOT EXISTS todos (
              id SERIAL PRIMARY KEY,
              title TEXT,
              done BOOLEAN
       );`
       _, err = db.Exec(createTable)
       if err != nil {
              log.Fatal(err)
       }
}
