package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

func http500(w http.ResponseWriter) {
	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

func http405(w http.ResponseWriter) {
	http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
}

func loadEnvVar(key string) (string, error) {
	value := os.Getenv(key)
	if value == "" {
		return value, fmt.Errorf("Environment value `%s` is not set", key)
	}
	return value, nil
}

func renderRoot(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http405(w)
		return
	}

	lp := filepath.Join("templates", "layout.html")
	fp := filepath.Join("templates", "index.html")

	tmpl, err := template.ParseFiles(lp, fp)
	if err != nil {
		log.Fatal("template: ParseFiles: %w", err)
		http500(w)
		return
	}

	form_input := r.FormValue("test_input")
	if len(form_input) > 0 {
		template_data := map[string]interface{}{
			"text_input": form_input,
		}
		err = tmpl.ExecuteTemplate(w, "layout", template_data)
		if err != nil {
			log.Fatal("template: ExecuteTemplate: %w", err)
			http500(w)
			return
		}
	} else {
		err = tmpl.ExecuteTemplate(w, "layout", nil)
		if err != nil {
			log.Fatal("template: ExecuteTemplate: %w", err)
			http500(w)
			return
		}
	}

}

func renderHealth(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http405(w)
		return
	}
	sha, _ := loadEnvVar("COMMIT_SHA")
	data := map[string]string{"health": "ok", "commit_sha": sha}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

func main() {
	http.HandleFunc("/", renderRoot)
	http.HandleFunc("/health-check", renderHealth)

	fmt.Printf("Listening on port 8080\n")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
