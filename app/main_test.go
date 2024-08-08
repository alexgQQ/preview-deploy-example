package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

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
