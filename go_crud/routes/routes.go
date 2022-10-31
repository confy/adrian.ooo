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


func PostData(c echo.Context) error {
	var data models.Data
	err := c.Bind(&data)
	if err != nil {
		return err
	}

	DB.Create(&data)
	return c.JSON(http.StatusCreated, data)
}

func GetData(c echo.Context) error {
	id := c.Param("id")
	var data models.Data
	DB.First(&data, id)
	if data.ID == 0 {
		return echo.NewHTTPError(http.StatusNotFound, message("Data not found"))
	}
	return c.JSON(http.StatusOK, data)
}

func PutData(c echo.Context) error {
	id := c.Param("id")
	var data models.Data

	id_uint, err := strconv.ParseUint(id, 10, 32)
	data.ID = id_uint
	
	if err != nil {
		return c.JSON(http.StatusBadRequest, message("Invalid ID"))
	}
	DB.First(&data, id)
	if err := c.Bind(&data); err != nil {
		return err
	}
	if data.ID == 0 {
		return echo.NewHTTPError(http.StatusNotFound, message("Data not found"))
	}
	DB.Save(&data)
	return c.JSON(http.StatusOK, data)
}

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