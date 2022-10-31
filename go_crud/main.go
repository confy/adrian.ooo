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
	e.Logger.Fatal(e.Start(":8080"))
}
