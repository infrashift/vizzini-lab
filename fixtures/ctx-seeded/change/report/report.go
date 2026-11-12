// Package report serves rendered reports.
package report

import (
	"example.com/shop/cache"
	"example.com/shop/store"
)

// Summary returns the rendered report called name.
func Summary(name string) (string, error) {
	h, err := cache.Load(name)
	if err != nil {
		return "", err
	}
	return string(h.Bytes()), nil
}

// OwnerEmail returns the email address of the report's owner.
func OwnerEmail(s *store.Store, ownerID int) string {
	u := s.FindUser(ownerID)
	return u.Email
}
