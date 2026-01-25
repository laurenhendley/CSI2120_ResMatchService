package main

// Imports
import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

// CUSTOM DATA TYPES

// The Resident data type
type Resident struct {
	residentID     int
	firstname      string
	lastname       string
	rol            []string // resident rank order list
	matchedProgram string   // will be "" for unmatched resident
}

// The Program data type
type Program struct {
	programID         string
	name              string
	nPositions        int         // number of positions available (quota)
	rol               []int       // program rank order list
	selectedResidents []*Resident // TO ADD: a data structure
	// for the selected resident IDs
}

// HELPER FUNCTIONS

func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {

}

func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program) {

}

func read_program_csv(filename string) (programs map[string]*Program) {
	f, err := os.Open(filename)

	if err != nil {
		log.Fatal("Error reading path file "+filename, err)
	}

	defer f.Close()

	reader := csv.NewReader(f)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatal("Error parsing file "+filename, err)
	}

	programs = make(map[string]*Program)

	for i := 1; i < len(records); i++ {
		row := records[i]
		if len(row) < 4 {
			log.Fatal("Incorrect format: ", filename, row)
		}

		id := row[0]
		name := row[1]

		numPosition, err := strconv.Atoi(row[2])
		if err != nil {
			log.Fatal("Error reading number of positions: ", filename, err)
		}

		rol := readProgCollection(row[3], filename)

		programs[id] = &Program{
			programID:  id,
			name:       name,
			nPositions: numPosition,
			rol:        rol,
		}
	}

	return programs
}

func readProgCollection(s, filename string) []int {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "[")
	s = strings.TrimSuffix(s, "]")

	if s == "" {
		return []int{}
	}

	parts := strings.Split(s, ",")
	rol := make([]int, 0, len(parts))

	for _, p := range parts {
		val, err := strconv.Atoi(strings.TrimSpace(p))
		if err != nil {
			log.Fatal("Error reading ROL ", filename, err)
		}
		rol = append(rol, val)
	}

	return rol
}

func readResCollection(s string) []string {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "[")
	s = strings.TrimSuffix(s, "]")

	if s == "" {
		return []string{}
	}

	parts := strings.Split(s, ",")
	rol := make([]string, 0, len(parts))

	for _, p := range parts {
		rol = append(rol, strings.TrimSpace(p))
	}

	return rol
}

func read_resident_csv(filename string) (residents map[int]*Resident) {
	f, err := os.Open(filename)

	if err != nil {
		log.Fatal("Error reading path file "+filename, err)
	}

	defer f.Close()

	reader := csv.NewReader(f)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatal("Error parsing file "+filename, err)
	}

	residents = make(map[int]*Resident)

	for i := 1; i < len(records); i++ {
		row := records[i]
		if len(row) < 4 {
			log.Fatal("Incorrect format: ", filename, row)
		}

		id, err := strconv.Atoi(strings.TrimSpace(row[0]))
		if err != nil {
			log.Fatal("Error reading res id: ", filename, err)
		}
		fn := row[1]
		ln := row[2]

		rol := readResCollection(row[3])

		residents[id] = &Resident{
			residentID:     id,
			firstname:      fn,
			lastname:       ln,
			rol:            rol,
			matchedProgram: "",
		}
	}

	return residents
}

// MAIN FUNCTION

func main() {
	start := time.Now() // chrono
	var wg sync.WaitGroup

	residents := read_resident_csv("blank")
	programs := read_program_csv("blank")

	// try to match each resident
	for id := range residents {

		go offer(id, residents, programs)

	}

	wg.Wait()

	end := time.Now() // chrono

	// print solution
	fmt.Printf("\n\nExecution time: %s", end.Sub(start))
}
