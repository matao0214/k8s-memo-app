package main

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"strconv"
)

type Todo struct {
	ID    int    `json:"id"`
	Title string `json:"title"`
	Done  bool   `json:"done"`
}

func getTodos(c *gin.Context) {
       rows, err := db.Query("SELECT id, title, done FROM todos")
       if err != nil {
	       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	       return
       }
       defer rows.Close()
       var todos []Todo
       for rows.Next() {
	       var t Todo
	       err := rows.Scan(&t.ID, &t.Title, &t.Done)
	       if err != nil {
		       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		       return
	       }
	       todos = append(todos, t)
       }
       c.JSON(http.StatusOK, todos)
}

func createTodo(c *gin.Context) {
       var newTodo Todo
       if err := c.ShouldBindJSON(&newTodo); err != nil {
	       c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	       return
       }
       err := db.QueryRow("INSERT INTO todos (title, done) VALUES ($1, $2) RETURNING id", newTodo.Title, newTodo.Done).Scan(&newTodo.ID)
       if err != nil {
	       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	       return
       }
       c.JSON(http.StatusCreated, newTodo)
}

func updateTodo(c *gin.Context) {
       id := c.Param("id")
       var updateTodo Todo
       if err := c.ShouldBindJSON(&updateTodo); err != nil {
	       c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	       return
       }
       res, err := db.Exec("UPDATE todos SET title=$1, done=$2 WHERE id=$3", updateTodo.Title, updateTodo.Done, id)
       if err != nil {
	       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	       return
       }
       rowsAffected, _ := res.RowsAffected()
       if rowsAffected == 0 {
	       c.JSON(http.StatusNotFound, gin.H{"error": "Todo not found"})
	       return
       }
       updateTodo.ID = atoi(id)
       c.JSON(http.StatusOK, updateTodo)
}

func deleteTodo(c *gin.Context) {
       id := c.Param("id")
       res, err := db.Exec("DELETE FROM todos WHERE id=$1", id)
       if err != nil {
	       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	       return
       }
       rowsAffected, _ := res.RowsAffected()
       if rowsAffected == 0 {
	       c.JSON(http.StatusNotFound, gin.H{"error": "Todo not found"})
	       return
       }
       c.Status(http.StatusNoContent)
}


func atoi(s string) int {
	i, _ := strconv.Atoi(s)
	return i
}

func main() {
	initDB()
	r := gin.Default()
       setupCORS(r)
       r.OPTIONS("/*path", func(c *gin.Context) {
	       c.Status(204)
       })
       r.GET("/todos", getTodos)
       r.POST("/todos", createTodo)
       r.PUT("/todos/:id", updateTodo)
       r.DELETE("/todos/:id", deleteTodo)
       r.Run(":8080")
}
