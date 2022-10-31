package models

import (
	"time"

	"gorm.io/gorm"
)

type Data struct {
	Value     uint64 `json:"value"`
	ID        uint64   `gorm:"primaryKey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}
