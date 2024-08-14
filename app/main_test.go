package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestMain(m *testing.M) {
	rc := m.Run()

	fmt.Println("coverage at", testing.Coverage())

	// tests pass now coverage check, fail under 10%
	// requires the -cover flag on `go test`
	// As a side note I'm a little surprised there isn't a flag for this
	// on the `go test` or the coverage tool
	if rc == 0 && testing.CoverMode() != "" {
		t := 0.10
		c := testing.Coverage()
		if c < t {
			fmt.Println("Tests passed but coverage failed at", c)
			rc = -1
		}
	}
	os.Exit(rc)
}

func TestHealthCheck(t *testing.T) {
	req, err := http.NewRequest("GET", "/health-check", nil)
	if err != nil {
		t.Fatal(err)
	}
	rr := httptest.NewRecorder()
	renderHealth(rr, req)
	resp := rr.Result()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			resp.StatusCode, http.StatusOK)
	}

	if resp.Header.Get("Content-Type") != "application/json" {
		t.Errorf("handler returned wrong content type: got %v want %v",
			resp.Header.Get("Content-Type"), "application/json")
	}

	// Quick and dirty json parsing
	body, _ := io.ReadAll(resp.Body)
	resBytes := []byte(string(body))
	var jsonRes map[string]interface{}
	_ = json.Unmarshal(resBytes, &jsonRes)
	if jsonRes["health"].(string) != "ok" {
		t.Errorf("handler returned unexpected body")
	}
}
