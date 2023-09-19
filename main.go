package main

import (
	"github.com/gofiber/fiber/v2"
	midlog "github.com/gofiber/fiber/v2/middleware/logger"
	"log"
)

func main() {

	app := fiber.New(fiber.Config{
		DisableStartupMessage: true,
	})

	// print request log
	app.Use(midlog.New())

	// mock handler
	app.Get("/ping", func(c *fiber.Ctx) error {
		return c.SendString("pong!")
	})

	log.Println("application running success")
	if err := app.Listen(":4000"); err != nil {
		log.Fatal(err)
	}
}
