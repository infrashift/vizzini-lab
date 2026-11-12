// Package retry computes backoff delays.
package retry

// Delay returns how long to wait before the given attempt, in seconds,
// capped at 30.
func Delay(attempt int) int {
	d := 1 << attempt
	if d > 30 {
		d = 30
	}
	return d
}
