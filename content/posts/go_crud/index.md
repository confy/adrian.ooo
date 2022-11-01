---
title: "Building a CRUD API in Go"
date: 2020-06-08T08:06:25+06:00
hero: /images/sections/posts/go_crud/hero.png
description: Adding analytics and disquss comment in hugo theme Toha
menu:
  sidebar:
    name: Go CRUD API
    weight: 500
---

I've been looking for an oppurtunity to pick up Go lately, and with a break in my studies recently it was a good oppurtunity to give it a try. 

Go is really well suited to webservices like this as it offers a relatively simple and friendly syntax, high performance and the ability to compile to a single binary file with no dependencies. Go also offers easily accesible concurrency via goroutines.

In this project we'll be creating a simple web service using Go, Echo and GORM with SQLite. In the end we'll have a single value CRUD API, with the ability to create, read, update and delete entries.

The github repo for this project can be found [here](https://github.com/confy/go_crud).

## Stack

I will be using the following Go modules:

#### Echo

Echo is a high performance, extensible, minimalist web framework for Go. It is designed to quickly create APIs with minimal effort. Echo implements the Go stdlib `http.Handler` interface, with a handler created in a goroutine for each request. This allows for a high level of concurrency and performance.

#### GORM

GORM is an ORM or Object relational mapper for Go that aims to be developer friendly. It is a very powerful tool that makes it easy to interact with databases and supports MySQL, Postgres, SQLite, SQL Server and Oracle.

#### SQLite with the GORM driver

SQLite is a lightweight file based database that is easy to use and does not require a server to run. It's not as fast as a database server, but it will allow us to quickly containerize our application.

We will also be using the SQLite driver for GORM. This driver allows us to use SQLite with GORM.

Eventually, the SQLite database will become a bottleneck as writes will lock the file momentarily. Later on in this project we'll experiment with benchmarking with Jmeter to see how our service performs under load.

## Setup

First make sure you have [Go](https://go.dev/dl/) installed. I'm using Go 1.19.

Let's create a new directory for our project and initialize a new go module.

`mkdir go_crud`

`cd go_crud`

`go mod init go_crud`

This will create a new `go.mod` file in our project directory. This is used by Go to manage dependencies.

```go
module go_crud

go 1.19
```

Next, we'll download our dependencies:

`go get github.com/labstack/echo/v4` 

`go get gorm.io/gorm`

`go get gorm.io/driver/sqlite`

This will download the Echo framework, GORM and the SQLite driver for GORM. 

Our `go.mod` file should now look like this:

```go
module go_crud

go 1.19

require (
	github.com/jinzhu/inflection v1.0.0 // indirect
	github.com/jinzhu/now v1.1.5 // indirect
	github.com/labstack/echo/v4 v4.9.1 // indirect
	github.com/labstack/gommon v0.4.0 // indirect
	github.com/mattn/go-colorable v0.1.11 // indirect
	github.com/mattn/go-isatty v0.0.14 // indirect
	github.com/mattn/go-sqlite3 v1.14.15 // indirect
	github.com/valyala/bytebufferpool v1.0.0 // indirect
	github.com/valyala/fasttemplate v1.2.1 // indirect
	golang.org/x/crypto v0.0.0-20210817164053-32db794688a5 // indirect
	golang.org/x/net v0.0.0-20211015210444-4f30a5c0130f // indirect
	golang.org/x/sys v0.0.0-20211103235746-7861aae1554b // indirect
	golang.org/x/text v0.3.7 // indirect
	gorm.io/driver/sqlite v1.4.3 // indirect
	gorm.io/gorm v1.24.0 // indirect
)
```

## Making the server with Echo

Next we'll create a new file called `main.go` and add the following code.

```go
package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

    e.GET("/hello", func(c echo.Context) error {
        return c.String(http.StatusOK, "Hello 🌎")
    })

	e.Logger.Fatal(e.Start(":8080"))
}
```

This will create a new Echo server that listens on port 8080. We'll be using the Logger and Recover middleware to log requests and recover from panics. We'll also add a new route that returns a string when we visit `localhost:8080/hello`.

Now we can run our server with `go run main.go`

Visit `localhost:8080/hello` and you should see `Hello 🌎` and see output in your terminal:

```plain
  ____    __
  / __/___/ /  ___
 / _// __/ _ \/ _ \
/___/\__/_//_/\___/ v4.9.0
High performance, minimalist Go web framework
https://echo.labstack.com
____________________________________O/_______
                                    O\
⇨ http server started on [::]:8080
{"time":"2022-10-29T16:58:49.0841777-07:00","id":"","remote_ip":"::1","host":"localhost:8080","method":"GET","uri":"/hello","user_agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0
Safari/537.36","status":200,"error":"","latency":0,"latency_human":"0s","bytes_in":0,"bytes_out":10}

```

## Writing the model

We're going to make an API that allows us to create, read, update and delete from our SQLite database using JSON.

Let's start by making a model of our data using GORM. Create a new folder called `models` and add a new file called `model.go` with the following code.

```go
package models

import (
	"time"

	"gorm.io/gorm"
)

type Data struct {
	Value     uint `json:"value"`

	ID        uint   `gorm:"primaryKey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt
}
```

This is a simple model that has a single field called `Value` that is a uint. Following the Name and type of the field, we have a json tag that will be used to serialize the data to JSON. 

We also have the `ID`, `CreatedAt`, `UpdatedAt` and `DeletedAt` fields that are created automatically by GORM which I've chosen to define explicitly here.

## Creating a database factory

Next, we need to create a sqlite database, along with a table for our data. We'll do this in a new file called `database.go` in a new `database` folder.

```go
package database

import (
	"go_crud/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&models.Data{})

	DB = db
	return DB
}
```

First we import our model, along with gorm and the sqlite driver. We'll also create a global variable called `DB` that we can use to access our database from other files.

The `Connect` function will create a new sqlite database called `test.db` and create a table for our data model(using `AutoMigrate`) before returning our DB. If the database already exists, it will just connect to it.

## Creating the routes

Ok let's tie everything together. We'll create a new file called `routes.go` in the `routes` folder and add the following:

```go
package routes

import (
	"go_crud/database"
	"go_crud/models"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

var DB = database.Connect()

func message(message string) map[string]string {
	return map[string]string{"message": message}
}

```

We'll import our database, model and echo, along with http for status codes and strconv for formatting responses. Next we'll create our `DB` variable using the `Connect` function we created earlier.

We'll also create a message function for easily sending JSON responses. One thing that is worth noticing here is the way Go allows you to anonymously declare maps with specific types in the `map[string]string` syntax.


As it is now we aren't using many of our imports, so Go will complain. We can fix this by adding some routes. Each route will receive `c echo.Context` and return the same `error` type

#### Create(POST)

```go
func PostData(c echo.Context) error {
	var data models.Data
	err := c.Bind(&data)
	if err != nil {
		return err
	}

	DB.Create(&data)
	return c.JSON(http.StatusCreated, data)
}
```

#### Read(GET)

```go
func GetData(c echo.Context) error {
	id := c.Param("id")
	var data models.Data
	DB.First(&data, id)
	if data.ID == 0 { // Gorm returns id 0 if not found
		return echo.NewHTTPError(http.StatusNotFound, message("Data not found"))
	}
	return c.JSON(http.StatusOK, data)
}
```

#### Update(PUT)

```go
func PutData(c echo.Context) error {
	id := c.Param("id")
	var data models.Data
	DB.First(&data, id)
	if data.ID == 0 {
		return echo.NewHTTPError(http.StatusNotFound, message("Data not found"))
	}
	id_uint, err := strconv.ParseUint(id, 10, 64)
	data.ID = id_uint
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, message("Invalid ID"))
	}
	if err := c.Bind(&data); err != nil { // Binds the request body to our data var
		return err
	}
	
	DB.Save(&data)
	return c.JSON(http.StatusOK, data)
}
```

#### Delete(DELETE)

```go
func DeleteData(c echo.Context) error {
	id := c.Param("id")
	var data models.Data
	DB.First(&data, id)
	if data.ID == 0 {
		return echo.NewHTTPError(http.StatusNotFound, message("Data not found"))
	}
	DB.Delete(&data)
	return c.NoContent(http.StatusNoContent)
}
```

#### Average

```go
func GetAverage(c echo.Context) error {
	items := []models.Data{}
	DB.Find(&items)
	var sum uint64
	for _, item := range items {
		sum += item.Value
	}
	length := len(items)
	res := struct {
		Average float64 `json:"average"`
		Length int `json:"length"`
	} {
		Average: float64(sum) / float64(length),
		Length: length,
	}
	return c.JSON(http.StatusOK, res)
}
```

## Adding the routes to our server

Now that we have our routes, we need to add them to our server. Open up `main.go` and replace with the following code.

```go
package main

import (
	"go_crud/routes"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.POST("/data", routes.PostData)
	e.GET("/data/:id", routes.GetData)
	e.PUT("/data/:id", routes.PutData)
	e.DELETE("/data/:id", routes.DeleteData)

	e.GET("/average", routes.GetAverage)

	e.GET("/hello", func(c echo.Context) error {
        return c.String(http.StatusOK, "Hello 🌎")
    })

	e.Logger.Fatal(e.Start(":8080"))
	
}
```

We'll import our routes and also bind each of our routes to the `/data` or `/average` url.

Finally, we can start our server using `go run main.go` and test our routes using curl or Postman.

If we post to `localhost:8080/data` with a JSON body of `{"value": 10}` we should get a response of

```json
{
  "id": 1,
  "value": 10,
  "created_at": "2021-01-01T00:00:00Z",
  "updated_at": "2021-01-01T00:00:00Z",
  "deleted_at": null
}
```

We'll post again using `{"value": 21}` and now we can query `localhost:8080/average` to get a response of

```json
{ "average": 15.5, "length": 2 }
```

## Conclusion
I hope this showcased how easy it is to get started with Go and how it can be used to create a simple web service. I was surprised at how easy it was to use and how much I enjoyed working with it.

I would usually use python for something like this and I have dealt with some slowness in the past. Compared to Python, Go really is the best of both worlds. It has the speed and simplicity of a compiled language and the ease of use of a scripting language.

I hope you enjoyed this tutorial and if you have any questions or suggestions, feel free to email me at [me@adrian.ooo](mailto:me@adrian.ooo)
