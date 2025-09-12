package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
)

var db *sql.DB

func initDB() {
	var err error
	host := os.Getenv("POSTGRES_HOST")
	user := os.Getenv("POSTGRES_USER")
	password := os.Getenv("POSTGRES_PASSWORD")
	dbname := os.Getenv("POSTGRES_DB")
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", host, user, password, dbname)

	// リトライしながらDB接続を待つ（30回・2秒間隔）
	maxRetries := 30
	for i := 0; i < maxRetries; i++ {
		db, err = sql.Open("postgres", dsn)
		if err == nil {
			err = db.Ping()
			if err == nil {
				break
			}
		}
		log.Printf("Waiting for DB... (%d/%d): %v (dsn: %s)", i+1, maxRetries, err, dsn)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Could not connect to DB after %d attempts. Last error: %v (dsn: %s)", maxRetries, err, dsn)
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
