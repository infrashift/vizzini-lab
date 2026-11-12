package report

import "example.com/shop/store"

// AdminEmail returns the administrator's email address, for the report
// footer.
func AdminEmail(s *store.Store) string {
	return s.Admin().Email
}
