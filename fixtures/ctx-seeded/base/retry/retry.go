// Package retry computes backoff delays.
package retry

// Delay returns how long to wait before the given attempt, in milliseconds.
func Delay(attempt int) int {
	return 100 << attempt
}
