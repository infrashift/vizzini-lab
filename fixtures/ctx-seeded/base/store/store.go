// Package store keeps customer accounts in memory.
package store

// User is a customer account.
type User struct {
	ID    int
	Email string
}

// Store holds users by id.
type Store struct {
	users map[int]*User
	admin *User
}

// New returns a store with its administrator account already in place.
func New(adminEmail string) *Store {
	admin := &User{ID: 0, Email: adminEmail}
	return &Store{users: map[int]*User{0: admin}, admin: admin}
}

// Add stores u.
func (s *Store) Add(u *User) { s.users[u.ID] = u }

// FindUser returns the user with this id, or nil when there is none.
func (s *Store) FindUser(id int) *User { return s.users[id] }

// Admin returns the administrator account. New always sets it, so the
// result is never nil.
func (s *Store) Admin() *User { return s.admin }
