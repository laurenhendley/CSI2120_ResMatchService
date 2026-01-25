package main

// Imports
import (
	"fmt"
	"sync"
	"time"
)

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
	nPositions        int   // number of positions available (quota)
	rol               []int // program rank order list
	selectedResidents       // TO ADD: a data structure
	// for the selected resident IDs
}

type selectedResidents struct {
}

func offer(rid int, residents map[int]*Resident, programs map[string]*Program)

func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program)

func read_csv(filename string) (residents map[int]*Resident, programs map[string]*Program)

// MAIN FUNCTION

func main() {
	start := time.Now() // chrono
	var wg sync.WaitGroup

	residents, programs := read_csv("blank")

	// try to match each resident
	for id := range residents {

		go offer(id, residents, programs)

	}

	wg.Wait()

	end := time.Now() // chrono

	// print solution
	fmt.Printf("\n\nExecution time: %s", end.Sub(start))
}
