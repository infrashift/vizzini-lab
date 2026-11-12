// Package cache reads rendered reports from disk.
package cache

import (
	"io"
	"os"
	"path/filepath"
)

// Dir is where rendered reports are kept.
var Dir = "/var/cache/shop"

// Handle is an open cache entry. Callers must call Release when they are
// done with it, or the entry's file descriptor leaks.
type Handle struct {
	f    *os.File
	data []byte
}

// Load opens the cache entry name and reads it.
func Load(name string) (*Handle, error) {
	f, err := os.Open(filepath.Join(Dir, filepath.Base(name)))
	if err != nil {
		return nil, err
	}
	data, err := io.ReadAll(f)
	if err != nil {
		f.Close()
		return nil, err
	}
	return &Handle{f: f, data: data}, nil
}

// Bytes returns the entry's contents.
func (h *Handle) Bytes() []byte { return h.data }

// Release closes the entry.
func (h *Handle) Release() error { return h.f.Close() }
