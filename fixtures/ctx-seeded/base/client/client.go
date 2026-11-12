// Package client calls the payments service.
package client

import (
	"time"

	"example.com/shop/retry"
)

// Wait sleeps before the given retry attempt.
func Wait(attempt int) {
	time.Sleep(time.Duration(retry.Delay(attempt)) * time.Millisecond)
}
